/**
* @author: salesforce.com
* @date: 03/09/2015
*
* @description: Schedule process to send image url requests to DAM
* String jobID = system.schedule('DAM Image Retrieval', '0 18 * * * ?', new sf_DAMProcessImagesScheduleable ());
*
*/

global class sf_DAMProcessImagesScheduleable implements Schedulable {
	global void execute(SchedulableContext sc) {
		String notificationemails = DAM_Brandstore_Settings__c.getInstance().Brandstore_Retrieval_Notification_Emails__c;
		String queryString = !String.isEmpty(DAM_Brandstore_Settings__c.getInstance().Dam_Image_Retrieval_Query__c) ? 'SELECT Id, GTIN_Number__c, Do_Not_Override_Images__c FROM Local_Product__c WHERE ' + DAM_Brandstore_Settings__c.getInstance().Dam_Image_Retrieval_Query__c : '';
		List <String> emails = !String.isEmpty(notificationemails) ? notificationemails.split(',') : new List <String> {'orikkers+pgDAMprocess@salesforce.com'};
		

		Integer batchSize = DAM_Brandstore_Settings__c.getInstance().Batch_Size__c != null ? Integer.valueOf(DAM_Brandstore_Settings__c.getInstance().Batch_Size__c) : 2000;

		sf_DAMProcessImagesBatch b = new sf_DAMProcessImagesBatch (queryString, emails);
		Database.executebatch(b, batchSize);
	}
}