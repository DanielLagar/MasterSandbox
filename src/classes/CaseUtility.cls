/**
* @author: original PG class
* @date: 05/30/2014
* @description:  helps with contact us page logic
*
* @changes:
* 21-10-2015
* Removing meta site/auto response functionality
* as converting to standard auto response rules
* christopher.macduff@accenture.com
*/


global without sharing class CaseUtility {

    /**
    *   @author: orikkers@salesforce.com
    *   @date: 08/21/2014
    *   @description: US669 Email Handling: Setting Priority based on keywords in email
    */
    
    private static final String ALL_REASONS = '';
    private static final String ALL_PRODUCT_NAMES = '';


    //alm 1219
    webservice static void makeMeCaseOwner (String caseId) {
        Case c = [SELECT Id, Origin FROM Case WHERE Id = :caseId];
        List <Task> tasks;
        c.OwnerId = UserInfo.getUserId();

        //check tasks
        if (c.Origin == 'Email') {
            User u = [SELECT Department, Contact_Center__c, Username FROM User WHERE Id = :UserInfo.getUserId()];
            tasks = new List <Task> ([SELECT Id, User_Department__c, User_Contact_Center__c FROM Task WHERE WhatId = :c.Id AND Status = 'Completed' AND (User_Department__c = null OR User_Contact_Center__c = null)]);

            if (!tasks.isEmpty()) {
                for (Task t: tasks) {
                    t.User_Department__c =  u.Department;
                    t.User_Contact_Center__c = u.Contact_Center__c;
                    t.Username__c = u.Username;
                }
            }
        }

        update c;
        if (tasks != null)
            update tasks;
    }
    
    //CDOY WR089 - This code will be used on the Delete contact button
    webservice static void RemoveContactFromCase (String caseId) {
    	Case c = [SELECT Id, contact.name, ContactId, status, Origin FROM Case WHERE Id = :caseId];
        if(c.status != 'closed'){
        	c.ContactId = null;
            system.debug('Contact.name =: '+contact.name);
        }
        system.debug('Contact.name =: '+contact.name);
        update c;
    }

    public String getPriority(String summary, String country){
        System.debug(LoggingLevel.INFO, 'Getting priority for \n' + summary);
        System.debug(LoggingLevel.INFO, 'in country: ' + country);

        String priority='';
        
        summary = summary.stripHtmlTags();
        //ChrisM: prevents matches on languages using special characters for example: araña gets replaced with ara a
        //Is this really needed?
        //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_string.htm#apex_System_String_replaceAll
        //summary = summary.replaceAll('[^a-zA-Z0-9\\- ]', ' ');
        summary = summary.toLowerCase();  
        summary = String.escapeSingleQuotes(summary);

        System.debug(LoggingLevel.INFO, 'fixing summary \n' + summary);

        /* Chris Doyle WR243
        Set <String> setSummaryWords = new Set <String>();
        for(String strKeyword : summary.split(' ')){
            strKeyword = strKeyword.removeEnd('-');
            if(String.isEmpty(strKeyword)) continue;
            
            setSummaryWords.add(strKeyword.toLowerCase());
        } */ 
        
        List<Metadata_priority__c> casePriority = [SELECT Keywords__c
                                                        ,Priority__c
                                                        ,Country__c 
                                                    FROM Metadata_priority__c 
                                                    WHERE country__c = :country 
                                                    ORDER BY Priority__c DESC];

        for(Metadata_priority__c mp : casePriority) {
            for(String keyword :mp.keywords__c.split(',')) {

                keyword=keyword.trim().toLowerCase();

                // Chris Doyle WR243 if(!String.isEmpty(keyword) && setSummaryWords.contains(keyword)) { 
                if(!String.isEmpty(keyword) && summary.contains(keyword)) {   // Chris Doyle WR243 
                    priority = mp.Priority__c;
                
                System.debug(LoggingLevel.INFO, 'CDOY Priority>>>> \n' + priority);   // Chris Doyle WR243 
                    
                }    
            }
        }
        //Setting default priority
        if(String.isEmpty(priority)) priority = '5';
        return priority;
    }
    
    public Contact getContactByFNameLNameEmail(String firstname, String lastname, String email){
        
        try{
            List<Contact> cList = new List<Contact>([SELECT Id
                                                            ,Salutation
                                                            ,FirstName
                                                            ,LastName
                                                            ,Birthdate
                                                            ,Email
                                                            ,Country__c
                                                            ,Phone
                                                            ,Primary_Address_Line_1__c
                                                            ,Primary_Address_Line_2__c
                                                            ,Primary_Address_Line_3__c
                                                            ,Primary_City__c
                                                            ,Primary_State_Province__c
                                                            ,Primary_Country__c
                                                            ,Primary_Postal_Code__c
                                                    FROM Contact 
                                                    WHERE Email=:email 
                                                    AND FirstName=:firstname 
                                                    AND LastName=:lastname 
                                                    LIMIT 1]);

            if (cList.isEmpty()) cList.add(new Contact());

            return cList[0];

        } catch(Exception ex){
            throw new CaseUtilityException ('getContactByFNameLNameEmail method error: ' + ex);
        }
    }
    
    public Contact updateContact(Id contactId
                                    ,String address1
                                    ,String address2
                                    ,String address3
                                    ,String city
                                    ,String state
                                    ,String postalcode
                                    ,String country
                                    ,String salutation
                                    ,Date birthdate
                                    ,boolean optinChecked
                                    ,String phone){
        return updateContact(contactId
                                ,address1
                                ,address2
                                ,address3
                                ,city
                                ,state
                                ,postalcode
                                ,country
                                ,salutation
                                ,birthdate
                                ,optinChecked
                                ,phone,false);
    }

    public Contact updateContact (Contact con) {
        update con;
        return con;
    }
    
    public Contact updateContact(Id contactId
                                    ,String address1
                                    ,String address2
                                    ,String address3
                                    ,String city
                                    ,String state
                                    ,String postalcode
                                    ,String country
                                    ,String salutation
                                    ,Date birthdate
                                    ,Boolean optinChecked
                                    ,String phone
                                    ,Boolean influencer){
        try{
            Contact con = new Contact ();

            List<Contact> conList = [SELECT Id
                                        ,Salutation
                                        ,Phone
                                        ,Email
                                        ,Birthdate
                                        ,FirstName
                                        ,LastName
                                        ,Primary_State_Province__c
                                        ,Primary_Postal_Code__c
                                        ,Primary_Country__c
                                        ,Primary_City__c
                                        ,Primary_Address_Line_3__c
                                        ,Primary_Address_Line_2__c
                                        ,Primary_Address_Line_1__c
                                    FROM Contact 
                                    WHERE Id=:contactId 
                                    LIMIT 1];
            
            if(!conList.isEmpty()){
                con = conList[0];
            } else {
                throw new CaseUtilityException('Contact not found. Contact Id: '+contactId);
            }

            //address
            if(!String.isEmpty(address1) && !String.isEmpty(city)
                && !String.isEmpty(state) && !String.isEmpty(postalCode)
                && !String.isEmpty(country)){
                con.Primary_Address_Line_1__c=address1;
                con.Primary_Address_Line_2__c=address2;
                con.Primary_Address_Line_3__c=address3;
                con.Primary_City__c=city;
                con.Primary_State_Province__c=state;
                con.Primary_Postal_Code__c=postalCode;
                con.Primary_Country__c=country;
            }

            if(!String.isEmpty(phone)) con.Phone=phone;//phone
            if(!String.isEmpty(salutation)) con.Salutation = salutation;//salutation
            if(birthdate!=null) con.Birthdate=birthdate;//birthday
            if(influencer) con.Reporter_Type__c='Influencer';

            con.Email_Opt_In__c = optinChecked;
            update con;
            return con;
        }
        catch(Exception ex){
            throw new CaseUtilityException ('Error while trying to update contact: ' + ex);
        }
    }

    public void attachFileToCase (Attachment att) {
        insert att;
    }
    
    public Boolean isContactNeeded(string email){
        Integer index = email.indexOf('@',0);
        String domain = email.substring(index+1,email.length());
        List<TP_Email_Address__c> tp = new List<TP_Email_Address__C> ([SELECT Name 
                                                                        FROM TP_Email_Address__c 
                                                                        WHERE TP_Email_Address__c = :email 
                                                                        OR Domain_Address__c =:domain]);
        return tp.isEmpty();      
    }
    
	/* christopher.macduff@accenture.com
    public Messaging.SingleEmailMessage sendEmailToCustomer(Id contactId
                                                            ,Id caseId
                                                            ,String templateId
                                                            ,String toEmail
                                                            ,String fromName
                                                            ,String fromEmail
                                                            ,String replyTo) {
       
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();    
        OrgWideEmailAddress orgWideEmail;   
        try {             
            // Strings to hold the email addresses to which you are sending the email.
            String[] toAddresses = new String[] {toemail};  

            
            orgWideEmail = !String.isEmpty(fromemail) ? getOrgWideEmails(fromemail) : null; 
            
            if(orgWideEmail != null) {
                mail.setOrgWideEmailAddressId(orgWideEmail.Id);
            } else { 
                //http://salesforce.stackexchange.com/questions/47271/how-to-override-the-from-email-in-messaging-singleemailmessage
                mail.setSenderDisplayName(fromName);
            }

            // Specify the address used when the recipients reply to the email. 
            if(!String.isEmpty(replyto)) mail.setReplyTo(replyto);     
            
            mail.setBccSender(false);            
            // Optionally append the salesforce.com email signature to the email.
            // The email address of the user executing the Apex Code will be used.
            mail.setUseSignature(false);
            mail.setWhatId(caseid); 
            if(contactId!=null) mail.setTargetObjectId(contactId);
            //Setting Template Id 
            if(!String.isEmpty(templateId)) mail.setTemplateId(TemplateId);
                 
            // Send the email you have created.
            //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); //disabled while testing oob auto response christopher.macduff@accenture.com
            return mail;
        } catch(Exception e){
            throw new CaseUtilityException('Exception while sending email to consumer: ' + e);
            return null;
        }
    }
	*/

	/* christopher.macduff@accenture.com
    public Messaging.SingleEmailMessage sendEmailToThirdParty (Id conId
                                                                ,Case c
                                                                ,String toemail
                                                                ,String fromname
                                                                ,String fromemail
                                                                ,String replyto
                                                                ,String subject) {
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress orgWideEmail;
        List<Contact> cons = new List<Contact>();  
        List<Case> cases = new List<Case>();
        String emailbody='';    
        try{             
            // Strings to hold the email addresses to which you are sending the email.
            String[] toAddresses = new String[] {toemail};        
            //Assign the addresses for the To list to the mail object.
            //mail.setToAddresses(toAddresses); 

            cons = [SELECT Id, Salutation, FirstName, LastName, Birthdate, Email, Country__c, Phone,
                        Primary_Address_Line_1__c, Primary_Address_Line_2__c, Primary_Address_Line_3__c, 
                        Primary_City__c, Primary_State_Province__c, Primary_Country__c, Primary_Postal_Code__c
                        FROM Contact WHERE Id =:conId];

            emailbody = emailbody + '<br/>Hello,<br/><br/>';
            emailbody = emailbody + 'A new case has been logged. Here are the details of the case and contact.<br/><br/>';
            if(cons.size() > 0){
              emailbody = emailbody + '<b>Consumer Information:</b><br/><br/>';
              emailbody = emailbody + 'First Name: ' + cons[0].FirstName + '<br/>';
              emailbody = emailbody + 'Last Name: ' + cons[0].LastName + '<br/>';
              emailbody = emailbody + 'Address Line1: ' + cons[0].Primary_Address_Line_1__c + '<br/>';
              emailbody = emailbody + 'Address Line2: ' + cons[0].Primary_Address_Line_2__c + '<br/>';
              emailbody = emailbody + 'Address Line3: ' + cons[0].Primary_Address_Line_3__c + '<br/>';
              emailbody = emailbody + 'City: ' + cons[0].Primary_City__c + '<br/>';
              emailbody = emailbody + 'State: ' + cons[0].Primary_State_Province__c + '<br/>';
              emailbody = emailbody + 'Postal Code: ' + cons[0].Primary_Postal_Code__c + '<br/>';
              emailbody = emailbody + 'Country: ' + cons[0].Primary_Country__c + '<br/>';
              emailbody = emailbody + 'Email: ' + cons[0].Email + '<br/>';
            }
            
            //Case details
            cases = [select Id, CaseNumber, Summary__c, Brand__c from Case where Id=:C.Id];
            if(cases.size() > 0){
              emailbody = emailbody + '<br/><b>Case Information:</b><br/><br/>';
              emailbody = emailbody + 'Case Number: ' + cases[0].CaseNumber + '<br/>';
              emailbody = emailbody + 'Brand: ' + cases[0].Brand__c + '<br/>';
              emailbody = emailbody + 'Summary: ' + cases[0].Summary__c + '<br/>';
            }
            //Set from address
            if(string.isNotBlank(fromemail)) orgWideEmail = getOrgWideEmails(fromemail); 
            if(orgWideEmail != null) mail.setOrgWideEmailAddressId(orgWideEmail.Id);
            // Specify the address used when the recipients reply to the email. 
            if(string.isNotBlank(replyto)) mail.setReplyTo(replyto);     
            // Specify the name used as the display name.
            mail.setBccSender(false);
            if(string.isNotBlank(subject)) mail.setSubject(subject);
            // Optionally append the salesforce.com email signature to the email.
            // The email address of the user executing the Apex Code will be used.
            mail.setUseSignature(false);
            mail.setToAddresses(toAddresses);
            mail.setHtmlBody(emailbody); 
            mail.setSenderDisplayName (fromName);
                 
            // Send the email you have created.
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            return mail;
        }
        catch(Exception e){
            throw new CaseUtilityException('Exception while sending an email to third party: ' + e);
            return null;
        }
    }
	*/
    
	/* christopher.macduff@accenture.com
    public OrgWideEmailAddress getOrgWideEmails (String emailaddress){
        List<OrgWideEmailAddress> orgWideEmails;
        
        orgWideEmails = [SELECT Id, Address FROM OrgWideEmailAddress WHERE address=:emailaddress];
        if(!orgWideEmails.isEmpty())
          return orgWideEmails[0];
        else return null;
     }
	*/
    
    public Id createTask (Id contactId
                            ,Id caseId
                            ,String subject
                            ,String status
                            ,String priority
                            ,String method
                            ,String direction
                            ,String description
                            ,String recordtype){
        
        Task tsk = new Task();                  
        
        //5-27-15. Post launch log #3 commented out per Dave. 
        //User sysAdmin = sf_ContactUsHelperCtrl.getSysAdmin();
        //tsk.OwnerId = sysAdmin.Id;   // WEP Data owner                 
        
        if(caseId!=null)
            tsk.WhatId = caseId; 
        
        if(contactId!=null)  
            tsk.WhoId = contactId;                  
        
        tsk.Subject = subject;                    
        tsk.Status = status;  
        
        if(priority!=null && priority!='')
            tsk.Priority =priority; 
        else                 
            tsk.Priority = 'Normal';  
        
        tsk.Contact_Method__c = method;
		system.debug('>>> caseUtility setting tsk.direction: '+direction); //ChrisM WR75
        tsk.Direction__c = direction;
        tsk.ActivityDate = System.today();
                 
        tsk.Description = description; 

        tsk.RecordTypeId =  Schema.SObjectType.Task.getRecordTypeInfosByName().get(recordtype).getRecordTypeId();                  

        insert tsk;
        return tsk.Id;
    }
    
    /*
        EmailMessage Statuses
        0-New
        1-Read
        2-Replied
        3-Sent
        4-Forwarded
    */
    
	/* christopher.macduff@accenture.com
	* Keep this, used to create email message on initial submission
	*/
    public Id createEmailMessage(Id taskId
                                    ,Id caseId
                                    ,String subject
                                    ,String email
                                    ,String textbody
                                    ,String htmlBody
                                    ,Boolean isIncoming
                                    ,String status
                                    ,String fromName){   
        String tmpSubject='';
                                        
        //Creating email message    
        EmailMessage em = new EmailMessage();    
        try{   
            em.ParentId = caseId;    
            em.ActivityId = taskId;    
            em.FromAddress = email;
            if (String.isEmpty(fromName))
                fromName = sf_ContactUsHelperCtrl.DEFAULT_EMAIL_FROM_NAME;
            em.FromName = fromName;
            em.Incoming = isIncoming;    
            em.MessageDate =System.now();    
            em.Status = status;   
            em.ToAddress = !String.isEmpty(Global_Org_Settings__c.getInstance().Agent_Default_Email__c) ? Global_Org_Settings__c.getInstance().Agent_Default_Email__c : email;
            //em.ToAddress = email;
            em.Headers = 'APEX EMAIL MESSAGE';
            if(String.isEmpty(subject)){    
                subject = '[NO SUBJECT]';   
            }
            em.Subject = subject;
            em.HtmlBody = htmlBody;
            em.TextBody = textbody;
            insert em; 
            return em.Id;  
        }   
        catch(Exception ex){   
            throw new CaseUtilityException('Exception in createEmailMessage method: ' + ex);  
        }   
    }

    public Id createEmailMessage(Id taskId
                                    ,Id caseId
                                    ,String subject
                                    ,String email
                                    ,String textbody) {
        return createEmailMessage (taskId, caseId, subject, email, textbody, textbody, false, '4', null);
    }
    
    public Contact createContact(String fname
                                ,String lname
                                ,String add1
                                ,String city
                                ,String salutation
                                ,Date birthdate
                                ,String personrectype
                                ,boolean optinChecked
                                ,String country
                                ,String email
                                ,String add2
                                ,String add3
                                ,String state
                                ,String postalcode
                                ,String phone){

        return createContact(fname
                                ,lname
                                ,add1
                                ,city
                                ,salutation
                                ,birthdate
                                ,personrectype
                                ,optinChecked
                                ,country
                                ,email
                                ,add2
                                ,add3
                                ,state
                                ,postalcode
                                ,phone
                                ,false);
    }    
    
    public Contact createContact(String fname
                                ,String lname
                                ,String add1
                                ,String city
                                ,String salutation
                                ,Date birthdate
                                ,String personrectype
                                ,Boolean optinChecked
                                ,String country
                                ,String email
                                ,String add2
                                ,String add3
                                ,String state
                                ,String postalcode
                                ,String phone
                                ,boolean influencer){
        
        Contact newContact = new Contact();
        newContact.FirstName = fname;
        newContact.LastName = lname;
        newContact.Email= email;
        newContact.Primary_Address_Line_1__c = add1;
        newContact.Primary_Address_Line_2__c = add2;
        newContact.Primary_Address_Line_3__c = add3;
        newContact.Primary_State_Province__c=state;
        newContact.Primary_Postal_Code__c=postalcode;
        newContact.Phone=phone;
        if(String.isEmpty(city)){
            newContact.Primary_City__c = 'No value';
        }else{
            newContact.Primary_City__c = city;    
        }
        if(!String.isEmpty(salutation))
            newContact.Salutation = salutation;                
        if(birthdate!=null)
            newContact.Birthdate=birthdate; 

        newContact.Primary_Country__c=country;
        newContact.Email_Opt_In__c = true;

        if(influencer){
           newContact.Reporter_Type__c='Influencer';    
        }
        
        try {
            insert newContact;
            return newContact;
        } catch (Exception e) {
            throw new CaseUtilityException ('Error while creating new Contact ' + e);
        }
    }

    public Case insertNewCase (Case newCase) {
    /*adding support to use standard salesforce autoresponse rules
     *christopher.macduff@accenture.com
	*/
     	Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.EmailHeader.triggerAutoResponseEmail = true;

        try {
            //insert newCase;
            database.insert(newCase, dlo);
            System.debug(LoggingLevel.INFO, 'Inserted newCase: ' + newCase);
            return newCase;

        } catch (Exception e) {
            System.debug(e);
            throw new CaseUtilityException ('Error while creating case: ' + e);
        }
    }

    /*
    Stores the Relation between Queues and Recordtypes. Replica of Email Service Configuration
    */
    public QueueRecordType__c getQueueRecordType(String queueName){
        QueueRecordType__c queueRecordType;
        for(QueueRecordType__c qr : QueueRecordType__c.getall().values()){
            if(qr.name == queueName || qr.name.startsWith(queueName)){
                queueRecordType = qr;
                break;
            }
        }

        //TODO: handle if the default queue is not setup
        if(queueRecordType == null){
            queueRecordType = QueueRecordType__c.getValues('Dummy Queue'); //default queue id - hard coded 
        }

        return queueRecordType;
    }

    //this method is needed to avoid error when retrieving case details due to sharing enabled
    public Case getCaseById (Id caseId) {
        try {
            return [SELECT Id
                            ,CaseNumber
                            ,OwnerId
                    FROM Case
                    WHERE Id = :caseId];
        } catch (Exception e) {
            System.debug(e);
            throw new CaseUtilityException ('Cannot find case by id.' + e);
        }
    }

    //insert attachment
    public Attachment insertAttachment (Attachment att) {
        insert att;
        return att;
    }

    //insert case products
    public void insertCaseProducts (List <Case_Product__c> cpList) {
        insert cpList;
    }

    //get AccountId for Contact
    public String getAccountIdForContact (String contactId) {
        List <Contact> contacts = new List <Contact> ([SELECT AccountId FROM Contact WHERE Id=:contactId LIMIT 1]);

        if (!contacts.isEmpty()) {
            return contacts[0].AccountId;
        } else {
            return null;
        }
    }

    @future
    public static void populateProductReturnStatus (Map <Id, String> cpReturnStatusMap) {
        System.debug('populateProductReturnStatus called ' + cpReturnStatusMap);




        List <Case_Product__c> cpList = new List <Case_Product__c> ();
        if (!cpReturnStatusMap.isEmpty()) {
            for (Id cpId: cpReturnStatusMap.keySet()) {
                Case_Product__c cp = new Case_Product__c (Id = cpId);

                //US772 - add product availability
                if (cpReturnStatusMap.get(cpId) == '1') {
                    //' +  EncodingUtil.urlDecode ('\U2012', 'utf-8') + ' --> fix dash issue 06/25/2015
                    cp.Product_available_for_return__c = 'Yes - Product is available';  //1-28-15 per doug ALM 766
                } else {
                    cp.Product_available_for_return__c = 'No - Product cannot be returned';
                }



                //cp.Product_available_for_return__c = cp.Product_available_for_return__c.replace('/\u2013|\u2014/g', '-');
                cpList.add(cp);
            }

            update cpList;
        }
    }

    //################# INNER CLASSES #########################//

    
    public class CaseUtilityException extends Exception{}
}