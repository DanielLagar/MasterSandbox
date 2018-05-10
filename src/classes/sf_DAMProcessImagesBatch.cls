/**
* @author: salesforce
* @date: 03/09/2015
*
* @description: Batch process to send image url requests to DAM
*/

global class sf_DAMProcessImagesBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
	
	String query = 'SELECT Id, GTIN_Number__c, Do_Not_Override_Images__c FROM Local_Product__c WHERE Last_Dam_Request__c = null';

	String error = '';
	List <String> emailAddressesToNotify;

	global sf_DAMProcessImagesBatch(String q, List <String> emailAddressesToNotify) {
		if (!String.isEmpty(q))
			query = q;

		if (Test.isRunningTest())  {
			query += ' LIMIT 1';
			error +='test';
		}

		this.emailAddressesToNotify = emailAddressesToNotify;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Local_Product__c> scope) {
   		List <String> gtinList = new List <String> ();
   		System.debug(LoggingLevel.INFO, 'Processing records: ' + scope);
		
		for (Local_Product__c lp : scope) {
			if (lp.GTIN_Number__c != null)
				gtinList.add(lp.GTIN_Number__c);

			lp.Last_DAM_Request__c = System.now();
			lp.Retrieve_Images__c = false;
			lp.DAM_Error_Message__c = '';

			//////////////////////////////////////////////
			//Commented out below by CDOY as part of WR484
			//////////////////////////////////////////////

			/*if (!lp.Do_Not_Override_Images__c) {
				lp.Image_Url__c = null;
				lp.Image_Url_2__c = null;
				lp.Image_Url_3__c = null;
				lp.Image_Url_4__c = null;
				
				lp.Image_Url_Thumb__c = null;
				lp.Image_Url_2_Thumb__c = null;
				lp.Image_Url_3_Thumb__c = null;
				lp.Image_Url_4_Thumb__c = null;
			}*/ 
			


		}

		try {

			String message = !gtinList.isEmpty () ? sf_DamService.republishAssetsByGTIN (gtinList): 'No records in batch contain GTIN numbers. Callout skipped.';
			
			//check for errors	
			if (sf_DamService.SUCCESS_MESSAGE != message) {
				System.debug(message);
				error += 'Error for gtins: ' + gtinList + '\n';
				error += message + '\n';
				for (Local_Product__c lp : scope) {
					lp.DAM_Error_Message__c = message.abbreviate(255);
				}
			}

			update scope;
		} catch (Exception e) {
			System.debug(e);
			error += '\n ' + e.getMessage() + ' \n' + e.getStackTraceString();
		}

	}
	
	global void finish(Database.BatchableContext BC) {

		AsyncApexJob job = [select ApexClassId, CompletedDate, CreatedById, CreatedDate, ExtendedStatus
			, Id, JobItemsProcessed, JobType, LastProcessed, LastProcessedOffset, MethodName, NumberOfErrors, ParentJobId, Status, TotalJobItems 
				from AsyncApexJob WHERE Id = :bc.getJobId()];

		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email.setSubject('Org: ' + UserInfo.getOrganizationId() + ': sf_DAMProcessImagesBatch status for ' + System.now().format());
        email.setToAddresses(emailAddressesToNotify);
        String messageBody = '';
        messageBody += 'Batch ' + bc.getJobId() + ' has completed. \n';
        messageBody += '\n\n items processed: ' + job.JobItemsProcessed;
        email.setPlainTextBody(messageBody);

		if (!String.isEmpty(error) || Test.isRunningTest()) {
			Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
			Blob att = Blob.valueOf(error);
			efa.setFileName ('Errors for batch ' + bc.getJobId() + '.txt');
			efa.setBody(att);
			email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
		}


		try {
			Messaging.SendEmailResult [] r = 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        } catch (Exception e) {
        	System.debug (e);
        }

	}
}