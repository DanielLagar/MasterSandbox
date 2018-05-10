/*
* @author: Oleg Rikkers
* @date: 07/22/2014
* @description: 

US428
*/


trigger Attachment on Attachment (before insert, before update, after insert, after update) {

   if (trigger.isBefore) {
		sf_AttachmentTriggerHelper.checkAttachmentName (Trigger.new);
   } else if (trigger.isAfter){
   	
   	sf_AttachmentTriggerHelper.updateCaseField (Trigger.newMap);
   }
}