//without sharing to allow PII user to find Case/Case Products
public without sharing class ctr_DPRUploadForm{
    String artNum = '';
    String artLang = '';
    String instructionsQuery = 'SELECT Id, ArticleNumber, Digital_Return_Instructions__c, No_of_Photos_Required__c FROM Return_Instructions__kav WHERE ArticleNumber = :artNum AND PublishStatus = \'Online\' AND Language = :artLang';

    //Props
    public String instructionText {get;set;} //Keep HTML from Article
    public Integer photoCount {get;set;} //Number of photos requested
    public Integer uploadedCount {get;set;} //Number of files uploaded
    public Case_Product__c caseCP {get;set;}
    public String cpReturnLink {get;set;}//Means we don't need to grant access to Case Product for the site user
    public List<Integer> loopCount {get;set;}//for use with apex repeat //TODO: Is this used?
    public Boolean showInstructions {get;set;}
    public String errorMessage {get;set;}//Not just errors, also used to display confirmations
    public Auto_Communication_Rule__c acr;
    
    public Boolean initialised = false;
    public Boolean pii {get;set;}
    public String uid{
        get;
        set{
            if(uid==null){
                system.debug('>>> uid setter value: '+value);
                uid = value;
                if(!initialised){
                    try{
                        init();
                    }
                    catch(exception e){
                        errorMessage = System.label.Invalid_URL;
                        system.debug(logginglevel.WARN,'>>> UID Unhandled exception:'+e.getMessage()+' :  '+e.getStackTraceString()+' uid: '+uid);
                        
                    }
                }                
            }
        }
    }
    
    //V4 Upload Button
    //VARIABLE RELATED TO ATTACHMENT
    public transient String attachmentName {get; set;}
    
    public String srtAttachmentErr {get; set;}

    public String remAttachmentIndex {get;set;}
    public List<String> lAttachmentName {get; set;}
    public String srtAttachmentId {get; set;}
    public void removeAttachment() {
        try{
            lAttachmentName.remove(Integer.valueOf(remAttachmentIndex));
            if (String.isNotEmpty(srtAttachmentId)) {
                String attachId = srtAttachmentId.split(',').get(Integer.valueOf(remAttachmentIndex));
                delete new Attachment(Id = attachId);
                srtAttachmentId = srtAttachmentId.replace(attachId + ',', '');
            }
        }
        catch(exception e){
            //TODO: Replace with consumer friendly label
            //ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, 'Something went wrong, more details: '+e.getMessage()+' :  '+e.getStackTraceString()));
            System.enqueueJob(new exceptionHelperQueable(e,'DPR Upload Form - Error removing attachment. Case number:  '+String.valueOf(caseCP.case__r.CaseNumber)));
        }
    }

    
    //Do actual processing here
    public void init(){
        initialised = true;//Prevent extra processing
        lAttachmentName = new List<String>();
        acr = new Auto_Communication_Rule__c();
        Return_Instructions__kav theInstructions = new Return_Instructions__kav();
        Contact_Us_Language__c langSettings = new Contact_Us_Language__c();
        loopCount = new List<Integer>();
        showInstructions = false;
        system.debug('>>> ctr_digiReturn_poc init method: '+uid);
		if(String.isBlank(uid)){
			uid = ApexPages.currentPage().getParameters().get('uid');
        }
		uid = String.escapeSingleQuotes(uid);
            
		caseCP = [SELECT Id, Case__c, ACR_Info__c, Status__c, Local_Product__r.Consumer_Facing_Name__c, case__r.language__c,
                  		Case__r.Language_code__c, Case__r.ContactId, Case__r.Contact.email, case__r.CaseNumber, Case__r.Country__c, Digital_Returns_Link__c
                      FROM Case_Product__c WHERE Digital_Return_Id__c = :uid LIMIT 1];
        cpReturnLink = caseCP.Digital_Returns_Link__c;

		//langSettings = [SELECT Id, Language_Locale_Key__c FROM Contact_Us_Language__c WHERE Language__c = :caseCP.Case__r.Language__c LIMIT 1];
		langSettings = [SELECT Id, Language_Locale_Key__c FROM Contact_Us_Language__c WHERE Language__c = :caseCP.Case__r.Language__c AND Country__C = :caseCP.Case__r.Country__c LIMIT 1];
		artLang = langSettings.Language_Locale_Key__c;
		acr = [SELECT Id, Digital_Instructions__c, Digital_Thankyou_Email__c FROM Auto_Communication_Rule__c WHERE Name = :caseCP.ACR_Info__c LIMIT 1];

        //Also allow if blank so that advisors can share the link prior to submitting the Case, e.g. live chat.
        if(trg_AutoComRuleHelper.digitalProductReturnStatuses.contains(caseCP.Status__c) || String.IsBlank(caseCP.Status__c)){
            artNum = acr.Digital_Instructions__c;

			theInstructions = database.query(instructionsQuery);
			instructionText = theInstructions.Digital_Return_Instructions__c;
			photoCount = Integer.valueOf(theInstructions.No_of_Photos_Required__c);
			uploadedCount = 0;
                
			//Build the collection for the VF page to loop through
			Integer tempInt = 1;
			for (Integer i = 0; i < photoCount; i++) {
				loopCount.add(tempInt);
				tempInt ++;
			}
			showInstructions = true;
        }
        else{
            showInstructions = false;
            errorMessage = system.label.Photos_Already_Received;
        }
    }
    
    //controller init
    public ctr_DPRUploadForm(){
        //Use init(); -> Works better with components in VF pages: //http://salesforce.stackexchange.com/questions/9941/setter-method-in-vf-component-being-called-after-the-constructor-has-retured
    }
    
    @RemoteAction
    public static String doUploadAttachment(String attachmentBody, String attachmentName, String attachmentType, String attachmentId, String uid) {
        system.debug('>>> in doUploadAttachment uid: '+uid);
        if(attachmentBody != null) {
            Attachment att = getAttachment(attachmentId, uid);
            String newBody = '';
            if(String.valueOf(att.Body) != '') {
                newBody = EncodingUtil.base64Encode(att.Body);
            }
            newBody += attachmentBody;
            att.Body = EncodingUtil.base64Decode(newBody);
            att.Name = attachmentName;
            att.ContentType = attachmentType;

            upsert att;
            return att.Id;
        }
        else{
            return null;
        }
    }

    private static Attachment getAttachment(String attId, String uid) {
        if(String.isEmpty(attId)){
            Attachment att = new Attachment ();
            att.Name = String.valueOf(System.now());
    
            Case_Product__c caseCP = [SELECT Id, Case__c FROM Case_Product__c WHERE Digital_Return_Id__c = :uid LIMIT 1];
            att.ParentId = caseCP.Case__c;
                
            att.Body = Blob.valueOf('');
            insert att;
            return att;
        }
        else{
            List<Attachment> attachments = new List<Attachment>([SELECT Id, Body FROM Attachment WHERE Id = :attId]);
            if(attachments.isEmpty()){
                return null;
            }
            else{
                return attachments[0];
            }
            
        }
    }
    
	public void saveAttachment() {
        if (String.isNotEmpty(attachmentName)) {
            lAttachmentName.add(attachmentName.substring(attachmentName.lastIndexOf('\\') + 1));
        }
    }
    
    public String submitErrorMsg {get;set;}
    
    public void submit(String dprId){
        //TODO: How to get email address here from PII?
        caseCP = [SELECT Id, ACR_Info__c, Case__r.Contact.email FROM Case_Product__c WHERE Digital_Return_Id__c = :dprId LIMIT 1];
        acr = [SELECT Id, Digital_Instructions__c, Digital_Thankyou_Email__c FROM Auto_Communication_Rule__c WHERE Name = :caseCP.ACR_Info__c LIMIT 1];
        submit();
    }
    
    public void submit(){
        system.debug(logginglevel.WARN,'^^^ Submitting DPR Form');
        caseCP.Status__c = 'Photo Received';
        //TODO: Should we reopen Case as well?
        try{
            update caseCP;
			sendConfirmationEmail();
        }
        catch(exception e){//TODO: What exceptions could this cause?
            submitErrorMsg = system.label.DPR_Submit_Error;
            System.enqueueJob(new exceptionHelperQueable(e,'DPR Form - error on submitting Case: '+String.ValueOf(caseCP.case__r.CaseNumber)));
        }
        errorMessage = system.label.DPR_Thankyou;
        showInstructions = false;        
    }
    
	public void sendConfirmationEmail(){
        try{
            EmailTemplate confirmationTemplate = [SELECT Id, subject, body FROM EmailTemplate WHERE developerName = :acr.Digital_Thankyou_Email__c];
            List <Messaging.SendEmailResult> emailResults = new List <Messaging.SendEmailResult>();
            List <Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            Messaging.Singleemailmessage msg = new Messaging.Singleemailmessage();
            
            msg.setOrgWideEmailAddressId(sf_GlobalUtilityClass.orgEmailMap.get('consumercare.im@pg.com').Id);//Id will be different in DEV/ACC unless they are refreshed
            msg.setTemplateId(confirmationTemplate.Id);//Get email Template Id FROM ACR
            msg.setTargetObjectId(caseCP.Case__r.ContactId);//contactId
            msg.setWhatId(caseCP.Case__c);//CaseId
            msg.setSaveAsActivity(True); //if TRUE, each email generates a task which fires the task trigger - can do this here as one record at a time
            emails.add(msg);
            
            emailResults = Messaging.sendEmail(emails, false); // allOrNothing = false
            
            emailMessage emToInsert = new emailMessage();
            task errorTask = new Task();
            
            for(integer i = 0; i<emailResults.size(); i++){
                Messaging.SendEmailResult result = emailResults[i];
                if(result.isSuccess()){
                    emailMessage em = new emailMessage(); 
                    em.ParentId = caseCP.case__c;
                    em.FromName = 'System Generated';
                    em.FromAddress = 'consumercare.im@pg.com';
                    em.MessageDate = System.now(); 
                    em.ToAddress = caseCP.Case__r.Contact.email;
                    em.Subject = confirmationTemplate.Subject;
                    em.HtmlBody = confirmationTemplate.Body;
                    emToInsert = em;
                }
                else{
                    System.enqueueJob(new exceptionHelperQueable('DPR Upload Form - Failure on confirmation email. Case:  '+String.valueOf(caseCP.Case__c)+' errors: '+String.valueOf(result.getErrors())));
                }
            }//for loop end
        }
        catch(exception e){
            System.enqueueJob(new exceptionHelperQueable(e,'DPR Upload Form - Failure on confirmation email. Case:  '+String.valueOf(caseCP.Case__c)));
        }
    }
}