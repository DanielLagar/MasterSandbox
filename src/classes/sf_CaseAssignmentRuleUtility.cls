/**
* @author: salesforce.com
* @date: 09/04/2014
* @description:  US768 Utility class for Metadata Case Assignment Rule object
*/

//need without sharing because site user needs to be able to get values
public without sharing class sf_CaseAssignmentRuleUtility {
	
	private static Map<String, Schema.SObjectType> globalDescribeMap; 
	private static Map <String, Group> queueNameMap;

	static {
		globalDescribeMap = Schema.getGlobalDescribe(); 
		queueNameMap = new Map <String, Group> ();
		for (Group gr: [SELECT DeveloperName
								,Email
								,Id
								,Name 
						FROM Group 
						WHERE Type = 'Queue']) {
			queueNameMap.put (gr.DeveloperName.toLowerCase(), gr);
		}
	}

	public static String getRecordTypeIdByName (String sObjectApiName, String rtName) {
		Id rtId;
		Map <String, Schema.RecordTypeInfo> rtMap = globalDescribeMap.get(sObjectApiName).getDescribe().getRecordTypeInfosByName();

		if (rtMap.get(rtName) != null)
			rtId = rtMap.get(rtName).getRecordTypeId();

		return rtId;
	}

	public static String getQueueIdByName (String qName) {
		qName = qName != null ? qName.toLowerCase() : '';
		return queueNameMap.get(qName) != null ? queueNameMap.get(qName).Id : null;
	}

	/**
	 * Returns Metadata_Case_Assignment_Rule__c record. If none found, 
	 * it populates an empty one with default queue.
	 *
	 * @param  brand
	 * @param  language
	 * @param  country
	 * @param  priority
	 * @param  caseStatus
	 * @param  reasonForWriting as a order number
	 * @return   Metadata_Case_Assignment_Rule__c record
	 * @see      CaseUtility
	 */
	 
	public static Metadata_Case_Assignment_Rule__c getMCARRecord (String brand
																	,String language
																	,String country
																	,String priority
																	,String caseStatus
                                                                    ,String conEmail
                                                                    ,string caseOrigin //CDOY WR114 - Add case origin to MCAR Rules
																	,String reasonForWriting) { 
		System.debug(LoggingLevel.INFO, 'Searching for MCAR : ' + brand + ', ' + language + ', ' + country + ', ' + priority + ', ' + caseStatus + ', ' + conEmail + ', ' + caseOrigin + ', ' + reasonForWriting);
		Metadata_Case_Assignment_Rule__c mcar;  
		
		//This has been added to stop the Metadata_Case_Assignment_Rule__c object finding a match between 
		//contacts with an blank/empty email address and MCAR rules that have an empty email field. By
		//setting the conEmail to 'thisRandomText' it will never find a match to an MCAR email address.
		conEmail = String.isBlank(conEmail) ? 'thisRandomText' : conEmail; //CDOY WR275 Fix
		system.debug('*** CDOY conEmail ='+conEmail); //CDOY WR275 Fix

		List <Metadata_Case_Assignment_Rule__c> mcarList = new List <Metadata_Case_Assignment_Rule__c> ();
		mcarList = [SELECT Id
							,Brand__c
							,Language__c
							,Account_Record_Type_Name__c
							,Activity_Record_Type_Name__c
							,Queue_Name__c
							,Case_Record_Type_Name__c
                    		,Email__c
                    		,Case_Origin__c //CDOY WR114 - Add case origin to MCAR Rules
					FROM Metadata_Case_Assignment_Rule__c
					WHERE (
					(Brand__c INCLUDES (:brand) OR Brand__c = null)
					AND (Case_Origin__c INCLUDES (:caseOrigin) OR Case_Origin__c = null) //CDOY WR114 - Add case origin to MCAR Rules
					AND Language__c = :language
					AND Country__c INCLUDES (:country)
					AND Case_Status__c INCLUDES (:caseStatus)
					AND Priority__c INCLUDES (:priority)
					AND Reason_For_Writing__c INCLUDES (:reasonForWriting))
					OR Email__c =: conEmail //CDOY - 275 Email Blacklisting
					ORDER BY Rank__c ASC
					NULLS LAST
					LIMIT 1];

		system.debug('caseOrigin = '+caseOrigin);
		system.debug('language = '+language);
		system.debug('country = '+country);
		system.debug('caseStatus = '+caseStatus);
		system.debug('priority = '+priority);
		system.debug('reasonForWriting = '+reasonForWriting);

		system.debug('MCARList Equals = ' + mcarList);

		if (!mcarList.isEmpty()) {
			mcar = mcarList[0];
			system.debug('mcarList is Not Empty');
		} else { //create defaults
		    system.debug('mcarList is Empty');
			mcar = new Metadata_Case_Assignment_Rule__c ();
			mcar.Queue_Name__c = sf_Constants.DEFAULT_QUEUE_NAME;
		}


		System.debug(LoggingLevel.INFO, 'mcar found:  ' + mcar);
		return mcar;
	}
}