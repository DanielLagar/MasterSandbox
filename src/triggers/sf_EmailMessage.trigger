/*
    EmailMessage Statuses
    0-New
    1-Read
    2-Replied
    3-Sent
    4-Forwarded
*/

trigger sf_EmailMessage on EmailMessage (before insert, after insert, before delete) {
    if(checkRecursive.triggerStatus('sf_EmailMessage__c')){
        
		if (Trigger.isBefore && Trigger.isInsert) {
            sf_EmailMessageTriggerHelper.checkSubjectLength(Trigger.new);
        }
        
        if (Trigger.isAfter && Trigger.isInsert) {
            sf_EmailMessageTriggerHelper.processInboundEmails(Trigger.new);
        }
    
        if (Trigger.isBefore && Trigger.isDelete) {
            sf_EmailMessageTriggerHelper.checkEmailMessageBeforeDelete(Trigger.old);
        }        
    }
}