public with sharing class sf_ContactHelper {

	/**
	* @author: Chris Southworth
	* @date: 05/22/2014
	* @param: oldConMap: Map of original Contact before update
	* @param: newConMap: Map of updated Contact after update
	* @description:  If Email is bounced back, mark open cases with the flag Contact_s_Email_Bounced__c set to true.
	*			If email is corrected set Contact_s_Email_Bounced__c to false
	*/
	public static void flagCasesForBouncedContactEmails(Map<Id, Contact> oldConMap, Map<Id, Contact> newConMap){
		System.debug('***CHECKING CONTACT TO UPDATE FLAGS');
		Set<Id> bouncedContactSet = new Set<Id>();
		Set<Id> notBouncedSet = new Set<Id>();
		Set<Id> contactIdSet = new Set<Id>();
		for(Contact c : newConMap.values()){
			Contact oldC = oldConMap.get(c.Id);
			System.debug('****EmailBounceDate Old: ' + oldC.EmailBouncedDate);
			System.debug('****EmailBounceDate new: ' + c.EmailBouncedDate);
			if(c.EmailBouncedDate != null && oldC.EmailBouncedDate == null){
				bouncedContactSet.add(c.Id);
				contactIdSet.add(c.Id);
			} else if(c.EmailBouncedDate == null && oldC.EmailBouncedDate != null){
				notBouncedSet.add(c.Id);
				contactIdSet.add(c.Id);
			}
		}

		if(!contactIdSet.isEmpty()){
			List<Case> caseList = [SELECT Id, ContactId, Contact_s_Email_Bounced__c FROM Case 
							WHERE ContactId IN :contactIdSet AND Status = 'Open'];

			if(!caseList.isEmpty()){
				List<Case> updatedCases = new List<Case>();
				for(Case c : caseList){
					if(bouncedContactSet.contains(c.ContactId)){
						c.Contact_s_Email_Bounced__c = true;
						updatedCases.add(c);
					} else if(notBouncedSet.contains(c.ContactId)){
						c.Contact_s_Email_Bounced__c = false;
						updatedCases.add(c);
					}
				}

				if(!updatedCases.isEmpty()){
					try{
						update updatedCases;
					} catch (Exception e){
						System.debug('****Flag Case Error: ' + e.getMessage());
					}
				}
			}
		}

	}
    

    /* WR120 Contact Address Validation
     * Author: christopher.macduff@accenture.com
     * Apologies for massive ifs on one line - makes test coverage easier
     * 
    */ 
    public static void contactAddressValidation(List<Contact> newConList){
        //Set on/off switch
        Boolean validationSwitch = false;
        if(TriggerSwitch__c.getInstance('conValidation') != null){
            validationSwitch = TriggerSwitch__c.getInstance('conValidation').TriggerOn__c;
        }

        if (validationSwitch){
            for(contact c : newConList){
				if(!String.isBlank(c.Primary_Country__c) && c.Delete_PII__c == false){ //WR338 ChrisM 8/8/2016 Delete PII support & bypass

                    Country_Status__c defaultCountryStatus = new Country_Status__c();//Values to use if no matching record found
                    Country_Status__c countrystatus = new Country_Status__c();
                    countrystatus = Country_Status__c.getInstance(c.Primary_Country__c);
                    if(countryStatus == null){
                        //if no match found assume both post code and state required
                        defaultCountryStatus.Uses_States__c = True;
                        defaultCountryStatus.Uses_Postal_Codes__c = True;
                        countrystatus = defaultCountryStatus;
                    }
                    
                    String addressString = '';
                    
                    //If uses states and postal codes don't allow partial address
                    if(countrystatus.Uses_States__c && countrystatus.Uses_Postal_Codes__c){
    
                        addressString += !String.isBlank(c.Primary_Address_Line_1__c) ? c.Primary_Address_Line_1__c : '';
                        addressString += !String.isBlank(c.Primary_City__c) ? c.Primary_City__c : '';
                        addressString += !String.isBlank(c.Primary_State_Province__c) ? c.Primary_State_Province__c : '';
                        addressString += !String.isBlank(c.Primary_Postal_Code__c) ? c.Primary_Postal_Code__c : '';
                        addressString = addressString.trim();
                       
                        if(String.isNotBlank(addressString) && (String.isBlank(c.Primary_Address_Line_1__c) || String.isBlank(c.Primary_City__c) || String.isBlank(c.Primary_Postal_Code__c) || String.isBlank(c.Primary_State_Province__c))){
                            //Throw VR
                            c.addError(Label.Con_ADV_All_Fields);
                        }
                    }
                    //Allow null post and state
                    if(!countrystatus.Uses_States__c && !countrystatus.Uses_Postal_Codes__c){
    
                        addressString += !String.isBlank(c.Primary_Address_Line_1__c) ? c.Primary_Address_Line_1__c : '';
                        addressString += !String.isBlank(c.Primary_City__c) ? c.Primary_City__c : '';
                        addressString = addressString.trim();
                       
                        if(String.isNotBlank(addressString) && (String.isBlank(c.Primary_Address_Line_1__c) || String.isBlank(c.Primary_City__c))){
                            c.addError(Label.Con_ADV_No_State_Postcode);
                        }
                    }
                    //Allow null post code only
                    if(countrystatus.Uses_States__c && !countrystatus.Uses_Postal_Codes__c){
    
                        addressString += !String.isBlank(c.Primary_Address_Line_1__c) ? c.Primary_Address_Line_1__c : '';
                        addressString += !String.isBlank(c.Primary_City__c) ? c.Primary_City__c : '';
                        addressString += !String.isBlank(c.Primary_State_Province__c) ? c.Primary_State_Province__c : '';
                        addressString = addressString.trim();
                       
                        if(String.isNotBlank(addressString) && (String.isBlank(c.Primary_Address_Line_1__c) || String.isBlank(c.Primary_City__c) || String.isBlank(c.Primary_State_Province__c))){
                            c.addError(Label.Con_ADV_No_Postcode);
                        }
                    }
                    //Allow null state only
                    if(!countrystatus.Uses_States__c && countrystatus.Uses_Postal_Codes__c){
    
                        addressString += !String.isBlank(c.Primary_Address_Line_1__c) ? c.Primary_Address_Line_1__c : '';
                        addressString += !String.isBlank(c.Primary_City__c) ? c.Primary_City__c : '';
                        addressString += !String.isBlank(c.Primary_Postal_Code__c) ? c.Primary_Postal_Code__c : '';
                        addressString = addressString.trim();
                       
                        if(String.isNotBlank(addressString) && (String.isBlank(c.Primary_Address_Line_1__c) || String.isBlank(c.Primary_City__c) || String.isBlank(c.Primary_Postal_Code__c))){
                            //Throw VR
                            c.addError(Label.Con_ADV_No_State);
                        }
                    }                    
                }//if on country change check end
            }//for loop close
        }//If close triggerSwitch is on 	
    }//Method end
	
	/**
	* @author: Archana Sethuraman
	* @date: 08/29/2014
	* @description: 
		When a contact related to a case gets updated, update the Sent to CCM field on case to true unless the user 
		updating the contact has the profile, "Integration User".
		
		DEPRECATED. replaced by synchronous process on contact info page.
	
	*/
	/*public static void updateCaseField(Map <Id,Contact> newMap) {
		Id integrationUserId = [select Id from Profile where Name = 'Integration User'].Id;
		Map<Id, Contact> contactMap = new Map<Id, Contact>();
		set<Id> userIds = new set<Id>();
		Map<Id, Id> userIdToProfileId = new Map<Id, Id>();
		
		
		// build list of user ids
		for (Contact c : newMap.values()){
			userIds.add(c.LastModifiedById);
		}
		system.debug('*** UserIds = '+ userIds);
		
		// get profile ids of the above and build map of user id to profile id
		List<User> users = [select id, profileid from user where Id in :userIds];
		for (user u : users){
			userIdToProfileId.put(u.id, u.profileId);
		}
		system.debug('*** userIdToProfileId = '+ userIdToProfileId);
		
		// remove contacts from map where user.profile.id = integeration user id
		for (Contact c : newMap.values()){
			if (userIdToProfileId.get(c.LastModifiedById) != integrationUserId)
				contactMap.put(c.Id, c);	
		}
		system.debug('*** contactMap = '+ contactMap);
		
		// get cases for the remaining
		List<Case> casesToUpdateList = [
			select Sent_To_CCM__C
			  from Case
			 where ContactId in: contactMap.keySet()
			   and Sent_To_CCM__c !=: true
		];
		
		for (Case c: casesToUpdateList) {
			c.Sent_to_CCM__c = true;
		}
		system.debug('*** casesToUpdateList = '+ casesToUpdateList);
		
		update casesToUpdateList;
	  
	}*/
}