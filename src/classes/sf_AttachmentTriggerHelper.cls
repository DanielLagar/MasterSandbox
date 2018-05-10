/**
* @author: Oleg Rikkers
* @date: 07/22/2014
* @description: 
	Helper class for attachment trigger
US428
*/


public with sharing class sf_AttachmentTriggerHelper {
	

	/**
	* @author John Casimiro
	* @date 08/01/2014
	* @description Trims the attachment’s name if it is greater than 80 characters to 80 characters including the file extension.
	*/
	public static void checkAttachmentName (List <Attachment> newList) {
		for (Attachment att: newList) {
			if (att.Name.length()>80) {
				
				// split by "."
				String[] parts = att.Name.split('\\.');
				
				// get the last split for the file extension
				string fileExt = parts[parts.size() - 1];
				
				//account for the file extension's length
				integer maxLength = 80 - (fileExt.length() +1);
				
				// finally grab the first part of the name up to the maxLength and add the extenstion to it
				att.Name = att.Name.left(maxLength) + '.' + fileExt;
			}
		}
	}
	
/**
* @author: Archana Sethuraman
* @date: 08/29/2014
* @description: 
	When an attachment related to a case gets updated, update Case to trigger an update to Case.lastModifiedDate
US428
*/
	public static void updateCaseField(Map <Id,Attachment> newMap) {
		List<Attachment> updatedAttach = [ 
			select 
				Id, Name, ParentId
			from 
				Attachment 
			where 
				id in: newMap.keySet() 
			and
			   Parent.Type =: sf_Constants.SOBJECTTYPE_CASE];
	   
	   Set<Id> caseIds = new Set<Id>();
		for (Attachment a: updatedAttach) {
			caseIds.add(a.parentId); 
		}
		
		List<Case> casesToUpdateList = [
			Select
				Child_Last_Modified_Date__c
			from
				Case
			where
				id in: caseIds
		];
		
		for (Case c: casesToUpdateList) {
			c.Child_Last_Modified_Date__c = datetime.now();
		}
		
		update casesToUpdateList;
	  
	}
}