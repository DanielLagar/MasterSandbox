/**
* WR75 - Reworked by ChrisM - 22nd April 
* On inbound email create OPEN Task
* On outbound email create CLOSED Task
*/

/*
    EmailMessage Statuses
    0-New
    1-Read
    2-Replied
    3-Sent
    4-Forwarded
*/

public without sharing class sf_EmailMessageTriggerHelper {

    public static void processInboundEmails (List <EmailMessage> newMessages) {
        Set <Id> caseIdSet = new Set <Id> ();
        Set <Id> taskIdSet = new Set <Id> ();
        
        List<Task> tasksToInsert = new List<Task>();

        for (EmailMessage em: newMessages) {
            if (em.ParentId.getSObjectType().getDescribe().getName() == sf_Constants.SOBJECTTYPE_CASE) {
                caseIdSet.add (em.ParentId);
                taskIdSet.add (em.ActivityId);
            }
        }

        //map to get case data
        Map <Id, Case> caseMap = new Map <Id, Case> ([SELECT Id, ContactId FROM Case WHERE Id IN :caseIdSet LIMIT 1000]);
        Map <Id, Task> taskMap = new Map <Id, Task> ([SELECT Id, WhatId, WhoId FROM Task WHERE Id IN :taskIdSet LIMIT 1000]);

        //START - ICCS R2
        Set<Id> conIdSet = new Set<Id>();
        for(Case_Contact__c cc : [SELECT Id, Contact__c FROM Case_Contact__c WHERE Case__c IN :caseIdSet]){
            conIdSet.add(cc.Contact__c);
        }

        //Create a Map where the key is the email address - the value is a list of Contacts with that email address
        //Only add Contacts related to the associated Cases via the Case_Contact__c object - should reduce duplicate Contacts with the same email address
        //May be over engineered as inbound email will also be 1 record per transaction
        Map<String, List<Contact>> conMap = new Map<String, List<Contact>>();
        for(Contact c : [SELECT Id, Email FROM Contact WHERE Id IN : conIdSet]){
            //NOTE: This will dedupe on key (email)
            if(conMap.get(c.Email) != null){
                conMap.get(c.Email).add(c);
            }
            else{
                List<Contact> conList = new List<Contact>();
                conList.add(c);
                conMap.put(c.email, conList);
            }
        }
        //FIN - ICCS R2
        
        for (EmailMessage em: newMessages) {
            //Task t = taskMap.get(em.ActivityId);
            Task taskToInsert = new Task();
            
            if(taskMap.get(em.ActivityId) != null){
                taskToInsert = taskMap.get(em.ActivityId);
                system.debug(logginglevel.WARN, '!!!!!! Found matching Task: '+taskToInsert);
            }
 
            //Task fields common to inbound/outbound
            taskToInsert.Subject = em.Subject;
            taskToInsert.Type = 'Email';
            taskToInsert.Contact_Method__c = 'Email';
            taskToInsert.Description = '';
            //TODO: ICCS R2 - This means the associated Task is ALWAYS related to the Case.ContactId
            //taskToInsert.WhoId = caseMap.get(em.ParentId).ContactId; //Moved to outbound/inbound specific logic below
            taskToInsert.WhatId = em.ParentId;
            
            //Set description
            if (!String.isEmpty(em.TextBody)) {
                taskToInsert.Description = em.TextBody;
            } else if (!String.isEmpty(em.HtmlBody)) {
                taskToInsert.Description = em.HtmlBody.stripHtmlTags();
            }

            //If inbound INSERT an OPEN task
            if (em.Incoming) {
                taskToInsert.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(sf_Constants.TASK_CUSTOMER_ACTIVITY_RECORDTYPENAME).getRecordTypeId();  
                taskToInsert.Direction__c = 'Inbound';

                //START: ICCS R2 How to set WhoId?
                system.debug(logginglevel.WARN, '!!!!!! Inbound looking for existing Contact');
                if(conMap.get(em.FromAddress) != null && conMap.get(em.FromAddress).size() == 1){
                    system.debug(logginglevel.WARN, '!!!!!! Only 1 match found setting WhatId To: '+conMap.get(em.FromAddress)[0].Id);
                    taskToInsert.WhoId = conMap.get(em.FromAddress)[0].Id;
                }
                else{
                    system.debug(logginglevel.WARN, '!!!!!! More than one match on Email address - do nothing? '+conMap.get(em.FromAddress));
                }
                //FIN: ICCS R2 

                //WR361 Salesforce for Outlook support - makes the Task associated to the inbound email closed.
                if(checkRecursive.newCase){
                    taskToInsert.Status = 'Completed';
                }
            //If outbound UPDATE and CLOSE an existing Task
            } else if (!em.Incoming) {
                taskToInsert.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(sf_Constants.TASK_INTERNAL_ACTIVITY_RECORDTYPENAME).getRecordTypeId(); 
                taskToInsert.Direction__c = 'Outbound'; 
                taskToInsert.Status = 'Completed';
                taskToInsert.ActivityDate = Date.today();
                taskToInsert.Follow_Up_Category__c = ''; //For ecosystem prevents system generated outbound tasks going down stream
                //ICCS R2 WhoId - Leave as correctly set on outbound
            }
            tasksToInsert.add(taskToInsert);

        }//for loop close

        Upsert tasksToInsert;
    }

    public static void checkEmailMessageBeforeDelete (List <EmailMessage> triggerOld) {
        for (EmailMessage em: triggerOld) {
            if (em.ParentId.getSObjectType().getDescribe().getName() == sf_Constants.SOBJECTTYPE_CASE) {
                if (!Schema.sObjectType.Case.isDeletable())
                    em.addError ('You are not allowed to delete emails assigned to the case');
            }
        }
    }
    
	public static void checkSubjectLength (List <EmailMessage> newEmails) {
        for(emailMessage mes: newEmails){
            
            if (!String.isEmpty(mes.HtmlBody) && String.isEmpty(mes.TextBody)) {
                mes.textBody = mes.HtmlBody.stripHtmlTags();
            }
			if (
                String.isEmpty(mes.TextBody)) {
                mes.textBody = mes.subject;
			} 

            string tempSubject = mes.subject;

            if(string.isNotEmpty(tempSubject) && tempSubject.length() > 255){
                mes.subject = mes.subject.left(255); 
            } 

            system.debug(logginglevel.WARN,'***CDOY mes.textBody = '+ mes.textBody);
            system.debug(logginglevel.WARN,'***CDOY mes.subject = '+ mes.subject);
        }
    }
}