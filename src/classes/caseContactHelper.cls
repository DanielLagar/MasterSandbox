/*
 * Helper Class for items relating to Multiple Case Contacts
 * Without sharing to allow guest site users to create the Case Contact Record
*/
public without sharing class caseContactHelper {

    public static void setPrimaryCaseContact(map<id, Case>oldMap, map<id, Case>newMap){
        Map<Id, Case> casesToProcessMap = new Map<Id,Case>();
        Map<Id, Map<Id,Case_Contact__c>> caseConMap = new Map<Id, Map<Id, Case_Contact__c>>();
        Set<Case_Contact__c> caseContactsToUpsert = new Set<Case_Contact__c>();

		//Any Cases to process?
		for(Case c : newMap.values()){
			Case oldCase = oldMap.get(c.Id);
			//checkRecursive.newCase -> for Salesforce for Outlook/Other API created Cases
			if(checkRecursive.newCase && c.contactId != null || (c.contactId != null && oldCase.ContactId != c.contactId)){
				casesToProcessMap.put(c.Id, c);
			}
		}
           
		if(!casesToProcessMap.isEmpty()){
			//Create CaseContactMap
			for(Case_Contact__c cc : [SELECT Id, Case__c, Contact__c, Case_Primary_Contact__c FROM Case_Contact__c WHERE Case__c In : newMap.keySet()]){
                //Using map of map
				if(caseConMap.get(cc.Case__c) != null){
					caseConMap.get(cc.Case__c).put(cc.Contact__c,cc);
				}
				else{
					Map<Id, Case_Contact__c> ccMap = new Map<Id, Case_Contact__c>();
					ccMap.put(cc.Contact__c,cc);
					caseConMap.put(cc.Case__c, ccMap);  
				}
			}
                
            //Now loop through Cases to determine if CaseContact needs to be updated or created
            for(Case c : casesToProcessMap.values()){
                Boolean ccFound = false;
                Map<Id, Case_Contact__c> localCCMap = new Map<Id, Case_Contact__c>();
                
                if(caseConMap.get(c.Id) != null){
                    localCCMap = new Map<Id, Case_Contact__c>(caseConMap.get(c.Id));
                }
    
                if(localCCMap.isEmpty()){
                    //If none already exist create a new primary Case_Contact__c
                    Case_Contact__c newCC = (createNewCC(c.Id, c.ContactId, true, false));
					caseContactsToUpsert.add(newCC);               
                }
                //if already exists make previous primary as non primary
                else{
                    for(Case_Contact__c cc : localCCMap.values()){
                        //Find existing primary, set to false
                        if(cc.Case_Primary_Contact__c == true && cc.Contact__c != c.ContactId){
                            cc.Case_Primary_Contact__c = false;
                            caseContactsToUpsert.add(cc);
                        }
                        //If already existing Case_Contact__c find new primary, set to true
                        else if(cc.Contact__c == c.ContactId){
                            system.debug(logginglevel.WARN,'>>> caseTrigger in setPrimaryCaseContact setting is primary to true for: '+cc);
                            cc.Case_Primary_Contact__c = true;
                            caseContactsToUpsert.add(cc);
                            ccFound = True;                            
                        }
                    }
                    /*
                    //TODO: Will we ever get here?
                    //If cannot find new ContactId in Case_Contact__c table create new one
                    if(!ccFound && caseConMap.get(c.Id).get(c.ContactId) == null){
						Case_Contact__c newCC = (createNewCC(c.Id, c.ContactId, true, false));
                        caseContactsToUpsert.add(newCC);
                    }*/
                }
            }

            List<Case_Contact__c> ccToUpsert = new List<Case_Contact__C>(caseContactsToUpsert);
            try{
                upsert ccToUpsert;
            }
            catch(Exception e){
                System.enqueueJob(new exceptionHelperQueable(e,'Error on upserting Case Contacts: '+ccToUpsert));
                //Now rethrow exception to prevent partial code success
                throw new caseContactException(e.getMessage());

            }
		}
    }
    
    //Trigger validation to prevent more than one primary Case Contact existing for a Case
    public static void singlePrimaryCheck(List<Case_Contact__c> caseContacts){
        system.debug(logginglevel.WARN,'>>> caseContactTrigger in singlePrimaryCheck');
        Map<Id, List<Case_Contact__c>> ccMap = new Map<Id, List<Case_Contact__c>>();
          Set<Id> caseIds = new Set<Id>();
            List<Case_Contact__c> ccList = new List<Case_Contact__c>();
            
            for(Case_Contact__c cc1 : caseContacts){
                caseIds.add(cc1.Case__c);
            }
            
            ccList = [SELECT Id, Case__c, Case_Primary_Contact__c FROM Case_Contact__c WHERE Case_Primary_Contact__c = True AND Case__c IN : caseIds];
    
            //Populate map with case of caseId 
            for(Case_Contact__c cc2 : ccList){
                    if(ccMap.get(cc2.case__c) != null){
                        ccMap.get(cc2.case__c).add(cc2);
                    }
                    else{
                        List<Case_Contact__c> localCCList = new List<Case_Contact__c>();
                        localCCList.add(cc2);
                        ccMap.put(cc2.case__c, localCCList);
                    }
            }
            
            for(Case_Contact__c ccx : caseContacts){
                if(ccMap.get(ccx.Case__c) == null){
                    //TODO: Required? Also validation in sf_ContactInfoController
                    ccx.addError(System.label.Select_a_new_Primary_Contact);
                }
                else{
                    Integer primaryCount = ccMap.get(ccx.Case__c).size();
                    if(primaryCount > 1){
                        ccx.addError(system.label.More_than_one_primary_contact);
                    }
                }
            }            
    }

    //Resuable method for Salesforce for Outlook, API insert, V3, V4 and ContactInfo 
    //Inserts if from site as guest user loses access to Case
	public static Case_Contact__c createNewCC(Id caseId, Id conId, boolean isPrimary, boolean fromSite){
        Case_Contact__c newCaseCon = new Case_Contact__c(
            Case__c = caseId,
            Contact__c = conId,
            Contact_Status__c = 'Active',
            Case_Primary_Contact__c = isPrimary
        );
        if(fromSite){
            try{
                insert newCaseCon;
            }
            catch(Exception e){
                System.enqueueJob(new exceptionHelperQueable(e,'Error on creating Case Contact from Site: '+newCaseCon));
            }
            
        } 
        return newCaseCon;
    }

    public class caseContactException extends Exception{}

}