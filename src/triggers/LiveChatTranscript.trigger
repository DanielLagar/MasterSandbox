/**
* @author: salesforce.com
* @date: 02/10/2015
*
* @description: update case summary field when transcript is created
* 
*/

trigger LiveChatTranscript on LiveChatTranscript (after insert) {

	List <Case> cases = new List <Case> ();

	for (LiveChatTranscript lct: trigger.new) {
		if (lct.CaseId != null) {
			String summaryText = lct.Body;
			summaryText = summaryText.replace('<p align="center">', '');
			summaryText = summaryText.replace('</p>', '\n');
			summaryText = summaryText.replace('<br>', '\n');
			summaryText = summaryText.replace('&amp;', '&');
			summaryText = summaryText.length() > 5000 ? summaryText.substring (0, 4999) : summaryText;
			
			cases.add (new Case (Id = lct.CaseId, Summary__c = summaryText));
		}
	}

	try {
		update cases;
	} catch (Exception e) {
		System.debug(e);
	}
}