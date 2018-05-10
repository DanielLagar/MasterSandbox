/**
  * @author: Jason Clark
  * @date: 8/28/2014
  *
  * @description: Trigger Helper class for Repeater Detection logic.  Used by AccountTrigger, ContactTrigger, CaseTrigger.
  */

public without sharing class sf_RepeaterHelper {

    public static final string SUSPECTED = 'Suspected Repeater';
    public static final string CASE_CLOSED_STATUS = 'Closed';
    public static final string CASE_PENDING_VALIDATION = 'Pending Validation';
    public static final string CASE_FRAUD_CASE = 'Fraudulent Case';
    public static final string FULFILLMENT_ORDER_OPEN = 'Open';
    public static final string FULFILLMENT_ORDER_DRAFT = 'Draft';
    public static final string FULFILLMENT_ORDER_DELETED = 'Deleted';
	
	@TestVisible 
    private static set<id> processed = new set<id>();

    /**
     *  Called by Account After Update trigger; if the account's Repeater_Status__c has changed,
     *  copies the new value to all contacts on the account
     *  @param oldMap  trigger.oldMap
     *  @param newMap  trigger.newMap
     */
    public static void syncAccountToContacts(map<id, Account> oldMap, map<id, Account> newMap) {
    	list<id> accountIdsForUpdate = new list<id>();
    	for(Account newAccount : newMap.values()) {
    		if(processed.contains(newAccount.id)) {
    			continue;
    		}
    		Account oldAccount = oldMap.get(newAccount.id);
    		if(oldAccount.Repeater_Status__c != newAccount.Repeater_Status__c) {
    			accountIdsForUpdate.add(oldAccount.id);
                processed.add(newAccount.id);
    		}
    	}
    	list<Contact> contacts = [select id, accountId, Repeater_Status__c from Contact where AccountId in :accountIdsForUpdate];
    	list<Contact> contactsToUpdate = new list<Contact>();
    	for(Contact c : contacts) {
    		processed.add(c.id); // account was just updated, no need to process contact's account
		    c.Repeater_Status__c = newMap.get(c.accountId).Repeater_Status__c;
		    contactsToUpdate.add(c);
    	}
    	update contactsToUpdate;
    }

    /**
     *  Called by Contact After Update trigger; if the contact's Repeater_Status__c has changed,
     *  copies the new value to the contact's account
     *  @param oldMap  trigger.oldMap
     *  @param newMap  trigger.newMap
     */
    public static void syncContactToAccount(map<id, Contact> oldMap, map<id, Contact> newMap) {
        map<id, id> accountToContactMap = new map<id, id>();
        for(Contact newContact : newMap.values()) {
        	if(processed.contains(newContact.id)) {
        		continue;
        	}
            Contact oldContact = oldMap.get(newContact.id);
            if(oldContact.Repeater_Status__c != newContact.Repeater_Status__c) {
            	//if a bulk update change multiple contacts on a single account to have different Repeater_Status__c values, the winner is undefined
                accountToContactMap.put(newContact.AccountId, newContact.id);
                processed.add(newContact.id);
            }
        }
        list<Account> accounts = [select id, Repeater_Status__c from Account where id in :accountToContactMap.keyset()];
        list<Account> accountsToUpdate = new list<Account>();
        for(Account a : accounts) {
            a.Repeater_Status__c = newMap.get(accountToContactMap.get(a.id)).Repeater_Status__c;
            accountsToUpdate.add(a);
        }
        update accountsToUpdate;
    }

    /**
     *  Called by Contact Before Update trigger; if the contact's account has changed,
     *  mark contact as suspected if the Account is known or suspected. 
     *  @param oldMap  trigger.oldMap
     *  @param newMap  trigger.newMap
     */
    public static void syncExistingContactFromAccount(map<id, Contact> oldMap, map<id, Contact> newMap) {
        list<id> accountIds = new list<id>();
        for(Contact newContact : newMap.values()) {
            Contact oldContact = oldMap.get(newContact.id);
            if(oldContact.Accountid != newContact.Accountid && string.isblank(newContact.Repeater_Status__c)) {
                accountIds.add(newContact.accountid);
            }
        }
        map<id, Account> accountMap = new map<id,Account>([select id, Repeater_Status__c from Account where id in :accountIds]);
        for(Contact newContact : newMap.values()) {
            Contact oldContact = oldMap.get(newContact.id);
            if(oldContact.Accountid != newContact.Accountid && string.isblank(newContact.Repeater_Status__c) && accountMap.containsKey(newContact.AccountId)) {
                Account a= accountMap.get(newContact.AccountId);
                if(! string.isBlank(a.Repeater_Status__c)) {
                	newContact.Repeater_Status__c = SUSPECTED;
                }
            }
        }
    	
    }

    /**
     *  Called by Contact Before Insert trigger; sets repeater status to account's repeater status
     *  @param newList  trigger.new
     */
    public static void syncNewContactFromAccount(list<Contact> newList) {
    	list<id> accountIds = new list<id>();
    	for(Contact ct : newList) {
    		if(ct.accountId!=null) {
    			accountIds.add(ct.AccountId);
    		}
    	}
    	
    	map<id, Account> accountMap = new map<id, Account>([select id, Repeater_Status__c from Account where id in :accountIds]);
    	
    	for(Contact ct: newList) {
    		if(ct.AccountId!=null && accountMap.containsKey(ct.accountid)) {
    			ct.Repeater_Status__c = accountMap.get(ct.accountId).Repeater_Status__c;
    		}
    	}
    	
    }

    /**
     *  Called by Case Before Update trigger; evaluates the case's account for repeater status,
     *  updates if needed
     *  @param oldMap  trigger.oldMap
     *  @param newMap  trigger.newMap
     */
    public static void checkCaseRepeaterStatus(map<id, Case> oldMap, map<id, Case> newMap) {
    	map<string, Repeater_Threshold__c> thresholds = Repeater_Threshold__c.getAll();
    	integer maxDays = 1;
    	for(Repeater_Threshold__c t : thresholds.values()) {
    		if (t.Threshold_Period__c > maxDays) {maxDays = (integer)t.Threshold_Period__c;}
    	}
    	list<id> accountsIdsForRepeaterCheck = new list<id>();
    	set<id> allAccountIds = new set<id>();
    	set<id> allContactIds = new set<id>();
    	for(Case newCase : newMap.values()) {
    		Case oldCase = oldMap.get(newCase.id);
    		if(oldCase.status != CASE_CLOSED_STATUS && newCase.status == CASE_CLOSED_STATUS && !newCase.Repeater_Status_Checked__c) {
    			if(newCase.accountId!=null) {
    				allAccountIds.add(newCase.accountId);
    			}
    			if(newCase.contactId!=null) {
    				allContactIds.add(newCase.contactId);
    			}
    			
    			accountsIdsForRepeaterCheck.add(newCase.accountId);
    		}
    	}

    	Map <Id, Account> allAccounts = new Map <Id, Account>([SELECT Id, Repeater_Status__c FROM Account WHERE Id IN :allAccountIds]);
    	Map <Id, Contact> allContacts = new Map <Id, Contact>([SELECT Id, Repeater_Status__c FROM Contact WHERE Id IN :allContactIds]);
        
        for(Case newCase : newMap.values()) {
            
            Case oldCase = oldMap.get(newCase.id);
            
            if(oldCase.status != CASE_CLOSED_STATUS && newCase.status == CASE_CLOSED_STATUS && !newCase.Repeater_Status_Checked__c) {
                
                newCase.Repeater_Status_Checked__c = true;
                
                if(  (newCase.accountId!=null && allAccounts.containsKey(newCase.accountId) && !String.isBlank(allAccounts.get(newCase.accountId).Repeater_Status__c))
                  || (newCase.contactId!=null && allContacts.containsKey(newCase.contactId) && !String.isBlank(allContacts.get(newCase.contactId).Repeater_Status__c)) ) {
                	
                    //new user story 50 = no more pending validation
                    //newCase.Repeater_Case__c = CASE_PENDING_VALIDATION;

                    newCase.Repeater_Case__c = CASE_FRAUD_CASE;
                }
            }
            
        }

    	String datefield = 'CreatedDate';
        String soql = '';  //using dynamic soql as you can't use a bind var with LAST_N_DAYS: and its ilk.  
        soql += 'select id, Country__c, Repeater_Status__c, Exclude_from_Repeater_Calculation__c, ';
        soql += '       (select id, Total_Fulfillment_Amount__c, ' + datefield ;
        //soql += '          from Cases where ' + datefield + ' = LAST_N_DAYS:' + maxDays + ' order by ' + datefield + ' desc) ';
        //WR125 Use active RSFs
        soql += ' from cases where '+ datefield + ' = LAST_N_DAYS:' + maxDays + ' and (Number_of_Active_PQC_Comments__c > 0 Or Number_of_Active_Adverse_Event__c > 0)' + 'order by ' + datefield + ' desc) ';
        soql += '  from Account ' ;
        soql += ' where id in :accountsIdsForRepeaterCheck';  //yes, you can use (simple, in-local-scope) bind vars in dynamic soql
        soql += '   and Repeater_Status__c=\'\'';             //no point in checking if the account is already a known or suspected repeater

        
        system.debug('>>> checkCaseRepeaterStatus: Account/Case SOQL: '+soql);
    	
        List <Account> accounts = Database.query(soql);
    	
    	for (Account a : accounts) {
    		if (a.Cases.size() > 0) {
                if(thresholds.containsKey(a.Country__c)) {
                    Repeater_Threshold__c threshold = thresholds.get(a.Country__c);
                    Integer cct = (integer)threshold.Case_Count_Threshold__c;
                    Double rvt = threshold.Reimbursement_Value_Threshold__c;
                    Integer caseCount = 0;
                    Double totalValue = 0.0;
                    Date cutoffDate = System.today().addDays(-(Integer)threshold.Threshold_Period__c);
                    
                    for(Case c : a.Cases) {
                    	if(((Datetime)c.get(datefield)).date() < cutoffDate) {
                    		continue;
                    	}
                    	caseCount++;
                    	totalValue += c.Total_Fulfillment_Amount__c;
                    }
					system.debug('****************** caseCount : cct = '+caseCount+' : '+cct);
                    if (!a.Exclude_from_Repeater_Calculation__c) {
                        if ( (cct!=null && caseCount >= cct) || (rvt!=null && totalValue>=rvt)) {
                            system.debug('****************** setting Account repeater status');
                            a.Repeater_Status__c = SUSPECTED;
                        }
                    }

                    
                }
    		}
    	}//for loop close
    	update accounts;
    }

    /**
     *  Called by Case After Update trigger; updates Fulfillment order status based on case repeater status
     *  if Case Repeater status changes, OR if case closes and it repeater status isn't clear
     *  @param oldMap  trigger.oldMap
     *  @param newMap  trigger.newMap
     */
    public static void updateFulfillmentOrders(Map <Id, Case> oldMap, Map <Id, Case> newMap) {
        Map <Id, String> caseFulfillmentOrderStatusMap = new Map <Id, String>(); 
        
        for(Case newCase: newMap.values()) {
            Case oldCase = oldMap.get(newCase.id);
            String fulfillmentStatus;
            
            if( oldCase.Repeater_Case__c != newCase.Repeater_Case__c 
                || (oldCase.status != CASE_CLOSED_STATUS && newCase.status == CASE_CLOSED_STATUS 
                    && !String.isBlank(newCase.Repeater_Case__c))) {
                
                if(newCase.Repeater_Case__c == CASE_PENDING_VALIDATION) {
                    fulfillmentStatus = FULFILLMENT_ORDER_DRAFT;
                }
                
                else if(newCase.Repeater_Case__c == CASE_FRAUD_CASE) {
                    fulfillmentStatus = FULFILLMENT_ORDER_DELETED;
                }
                
                else {
                    fulfillmentStatus = FULFILLMENT_ORDER_OPEN;
                }
                
                caseFulfillmentOrderStatusMap.put(newCase.id, fulfillmentStatus);
            }
        }
        
        List <Fulfillment_Order__c> orders = [SELECT Id 
                                                    ,Case__c
                                                    ,Status__c
                                                    ,(SELECT Id 
                                                            FROM Fulfillment_Order_Line_Items__r 
                                                            WHERE Type__c != 'FL') 
                                            FROM Fulfillment_Order__c 
                                            WHERE Case__c IN :caseFulfillmentOrderStatusMap.keyset()];

        List <Fulfillment_Order__c> ordersToUpdate = new List <Fulfillment_Order__c> ();
        
        for(Fulfillment_Order__c o: orders) {
        	
            //to avoid recursive update triggers (Case->FfmtOrder->Case), only update orders which need it
            if(caseFulfillmentOrderStatusMap.containsKey(o.case__c) 
                && o.status__c != caseFulfillmentOrderStatusMap.get(o.case__c) 
                && o.Fulfillment_Order_Line_Items__r.size()>0) {
            	
                o.status__c = caseFulfillmentOrderStatusMap.get(o.case__c);
            	ordersToUpdate.add(o);
            }
    	}
    	
        if (ordersToUpdate.size() > 0) {
    	    update ordersToUpdate;
    	}
    }

    /**
     *  Called by Fulfillment Order After Update trigger; clears Case's repeater status if order is cleared
     *  updates if needed
     *  @param oldMap  trigger.oldMap
     *  @param newMap  trigger.newMap
     */
    public static void clearCasesFromClearedOrders(Map <Id, Fulfillment_Order__c> oldMap, Map <Id, Fulfillment_Order__c> newMap) {
    	Set <Id> caseIdsToClear = new Set <Id>();
    	
        for(Fulfillment_Order__c newOrder : newMap.values()) {
    		Fulfillment_Order__c oldOrder = oldMap.get(newOrder.id);
    		if(newOrder.Status__c != oldOrder.Status__c && newOrder.Status__c == FULFILLMENT_ORDER_OPEN) {
    			caseIdsToClear.add(newOrder.case__c);
    		}
    	}
    	
        List <Case> casesToUpdate = new List <Case>();
    	
        for(Case c : [SELECT Id, Repeater_Case__c FROM Case WHERE Id IN :caseIdsToClear]) {
    		
            //to avoid recursive update triggers (Case->FfmtOrder->Case), only update orders which need it
    		if( !String.isBlank(c.Repeater_Case__c) ) {
    			c.Repeater_Case__c = null;
    			casesToUpdate.add(c);
    		}
    	}
    	
        if(casesToUpdate.size()>0) {
    		update casesToUpdate;
    	}
    }
}