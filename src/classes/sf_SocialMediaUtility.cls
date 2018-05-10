/*
* @author: original PG class
* @date: 08/12/2014
* @description:  Utility class for SocialMediaService. 
  Class migrated from Temp org
*/

public class sf_SocialMediaUtility{
   
    public Id createTask(String description, 
                            String subject, 
                            String contactmethod, 
                            String status, 
                            String priority, 
                            Id caseId, 
                            String recTypeId, 
                            Id contactId, 
                            Id OwnerId ) {
        return createTask(description, subject, contactmethod, status, priority, caseId, recTypeId, contactId, OwnerId, System.today());
    }
   
    public Id createTask(String description, 
                            String subject, 
                            String contactmethod, 
                            String status, 
                            String priority, 
                            Id caseId, 
                            String recTypeId, 
                            Id contactId, 
                            Id OwnerId, 
                            Date activityDate ) {
    
        try {
            Task tsk = new Task();                   
            tsk.WhatId = CaseId;  
            
            if(string.isNotBlank(subject) && subject.length()>=80)
                subject = subject.substring(0,79);
            
            tsk.WhoId = contactId;        
            tsk.Subject = subject;                   
            tsk.Status = status;                    
            tsk.Priority = priority;  
            tsk.ActivityDate = activityDate;   
            tsk.RecordTypeId = recTypeId;                                 
            tsk.Description = description; 
            
            if(String.isNotBlank(OwnerId)) tsk.ownerId = OwnerId;
            
            tsk.IsReminderSet = true;       
            tsk.Contact_Method__c = contactmethod;
            insert tsk;
                
            return tsk.Id;
        } catch(Exception ex){
            System.debug(ex);  
            throw ex; 
        }  
    }
   
    public void handleException ( String ex, 
                                String subject, 
                                String moreinfo, 
                                Boolean includeExternal){
      
        Set <String> toAddresses = new Set <String>();
        if(includeExternal) 
            sendExceptionEmail (ex, subject, moreinfo, SocialMediaEmailAddresses__c.getall().keySet());
        
        else {
            for(SocialMediaEmailAddresses__c emailaddress : SocialMediaEmailAddresses__c.getall().values()){
                if(!emailaddress.isExternal__c)
                    toAddresses.add(emailaddress.name);
            } 
            //TODO: handle is there are no records 
            sendExceptionEmail (ex, subject, moreinfo, toAddresses);
        }         
    }
   
    public void sendExceptionEmail (String ex, 
                                String subject, 
                                String moreinfo, 
                                Set<String> toAddresses) {
     
        List <String> toaddressList = new List <String> (toAddresses);
        String msgbody='';
        msgbody=msgbody+'Exception:'+ex+'\n';
        msgbody=msgbody+'More Info:'+moreinfo+'\n';
        msgbody=msgbody+' Org Id:'+userInfo.getOrganizationId()+'\n';
        try {   
            // Sending email to system administrators to report the exception          
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();        
            
            //Specifying  the to Addresses 
            mail.setToAddresses(toaddressList);        
            mail.setSenderDisplayName('Salesforce Error Handling');         
            
            // Specify the subject line for your email address.
            mail.setSubject(subject);          
            mail.setBccSender(false);            
            
            // Optionally append the salesforce.com email signature to the email.
            // The email address of the user executing the Apex Code will be used.
            mail.setUseSignature(false);
            mail.setReplyTo('support@salesforce.com');
            mail.setPlainTextBody(msgbody);               
            
            // Send the email you have created.
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch(Exception ex1) {
            throw ex1;
            System.debug('Exception in user query'+ex1);
        }
    }
}