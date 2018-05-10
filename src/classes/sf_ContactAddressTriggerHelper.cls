/*
* @author: Oleg Rikkers
* @date: 05/13/2014
* @description: 
*   US442
* Acceptance Criteria:
    Create a new contact with new address a new account will be created and the contact will be associated to it
    Create a new contact with an existing address the contact will be associated to the existing account
    Modify an address on an existing contact with an address that doesn't exist a new account will be created and the contact associated to it
    Modify an address on an existing contact with an address that does exist the contact will be associated to that account


*/

public with sharing class sf_ContactAddressTriggerHelper {

    public static final map<string,Schema.RecordTypeInfo> AccountRecordTypeInfoByNameMap = Account.sObjectType.getDescribe().getRecordTypeInfosByName(); 
    public static final map<string,Schema.RecordTypeInfo> ContactRecordTypeInfoByNameMap = Contact.sObjectType.getDescribe().getRecordTypeInfosByName(); 
    
    public static void processNewContacts (List <Contact> contacts) {
        Map <String, Account> householdAddressMap = new Map <String, Account> ();
        Set <String> addressSet = new Set <String> ();
        List<Contact> consumerContacts = new List<Contact>();
        
        for (Contact c: contacts) {
            if(c.RecordTypeId != ContactRecordTypeInfoByNameMap.get('Business Contact').getRecordTypeId()){
                
                String addressKey = !String.isEmpty(c.Primary_Address_Line_1__c) ? c.Complete_Address__c : getContactCreatedDate(c);
                addressSet.add (addressKey);
                
                consumerContacts.add(c);
            }
        }

        //alm 1396
        System.debug(System.LoggingLevel.INFO, 'addressSet \n' + addressSet);
        String todayName = Datetime.now().format('YYYY-MM-dd');



        //get all accounts with addresses from contacts
        String householdRt = AccountRecordTypeInfoByNameMap.get('Household').getRecordTypeId();
        for (Account a: [SELECT Id
                                ,Complete_Address__c
                                ,Address_Line_1__c
                                ,Name 
                        FROM Account 
                        WHERE (Address_Key__c IN :addressSet 
                                OR Name = :todayName 
                                OR Name IN :addressSet)  
                        AND RecordTypeId = :householdRt]){

            String addressKey = !String.isEmpty(a.Address_Line_1__c) ? a.Complete_Address__c : a.Name;
            householdAddressMap.put (addressKey, a);
        }

        System.debug(System.LoggingLevel.INFO, 'householdAddressMap \n' + householdAddressMap);

        //in case there are no accounts for a specific address yet
        List <Account> newAccounts = new List <Account> ();

        //once accounts are inserted, these need to be reprocessed
        List <Contact> needAccountConList = new List <Contact> ();

        //go through contacts and see if anything matches 
        for (Integer i=0; i<consumerContacts.size(); i++) { // need to be able to remove elements from array
            Contact c = consumerContacts[i];
            String addressKey = !String.isEmpty(c.Primary_Address_Line_1__c) ? c.Complete_Address__c : getContactCreatedDate(c);
            
            System.debug(System.LoggingLevel.INFO, 'for consumerContacts addressKey \n' + addressKey);
            
            Account acc = householdAddressMap.get(addressKey);

            if (acc == null) { //need to create account
                Account a = createAccountFromContact (c);
                newAccounts.add (a);
                needAccountConList.add (c);
            } else{
                c.AccountId = acc.Id;
            }
        }

        //recursive 
        if (!newAccounts.isEmpty()) {
            try {
                Database.SaveResult[] srList = Database.insert(newAccounts, true);

                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug(System.LoggingLevel.INFO, 'Successfully inserted account. Account ID: ' + sr.getId());
                    } else {
                    // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                }
                processNewContacts (needAccountConList);

            } catch (Exception e) {
                //no need to fail the whole transaction?
                for (Contact c: contacts) {
                    c.addError (e.getMessage() + ' ' + e.getStackTraceString());
                }
                System.debug(e.getMessage() + ' ' + e.getStackTraceString());
            }
        }
    }

    public static void processExistingContacts (Map <Id, Contact> oldMap, Map <Id, Contact> newMap) {
        List <Contact>changedContacts = new List <Contact> ();
        for (Contact c: newMap.values()) {
            if(c.RecordTypeId != ContactRecordTypeInfoByNameMap.get('Business Contact').getRecordTypeId()){
                if ((oldMap.get(c.Id).Complete_Address__c != c.Complete_Address__c) || c.AccountId == null) {
                    changedContacts.add (c);
                }
            }

        }

        if (!changedContacts.isEmpty()) {
            processNewContacts (changedContacts);
        }
    }

    private static String getContactCreatedDate(Contact c){
        if(c.CreatedDate == null){
            // The contact is being created, and hasnt been saved yet.
            //return Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day();
            return Datetime.now().format('YYYY-MM-dd');
        }else{
            // The contact already has a createdDate
            //return c.CreatedDate.year() + '-' + c.CreatedDate.month() + '-' + c.CreatedDate.day();
            return c.CreatedDate.format('YYYY-MM-dd');
        }
    }
    private static Account createAccountFromContact (Contact c) {
        System.debug('TRIGGER_createAccountFromContact contact.LastName = ' + c.LastName + '; contact.Complete_Address__c = ' + c.Complete_Address__c);
        Account a = new Account ();
        if(String.isEmpty(c.Primary_Address_Line_1__c)){
            a.Name = getContactCreatedDate(c);
        }else{
            a.Name = c.Primary_Address_Line_1__c;
        }
        a.Address_Line_1__c = c.Primary_Address_Line_1__c;
        a.Address_Line_2__c = c.Primary_Address_Line_2__c;
        a.Address_Line_3__c = c.Primary_Address_Line_3__c;
        a.City__c = c.Primary_City__c;
        a.State_Province__c = c.Primary_State_Province__c;
        a.Postal_Code__c = c.Primary_Postal_Code__c;
        a.Country__c = c.Primary_Country__c;
        a.RecordTypeId = AccountRecordTypeInfoByNameMap.get('Household').getRecordTypeId();

        return a;
    }
}