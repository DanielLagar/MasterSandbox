/*
* @author:       Accenture
* @date:         11/08/2016
* @description:  Controller class of Landing page of GCR care hub widget
* DATE              NAME                CHANGE DESCRIPTION
* 11/08/2016        Accenture           Initial Draft
* 10/01/2017        Accenture           WR440 - Retrieve additional field "noPrechatCarehub__c" in channel content query query in 
*                                       getChatData() method.
* 01/06/2017        Accenture           WR508 - Chat Redesign: Additional fields added to be queried to display message to the user
                                        and branding of redirect page.
                                        Additional logic added to check if chat/agent is still available before redirecting to chat.
* 05/09/2017        Accenture           WR552 - Populate Loyalty ID passed from the parameter  - so pass on the parameter through the chat transaction                                      
*/
global class gcr_chatRedirectController {
    private class chatException extends Exception {}
    public GCRChannelContent__c chatChannelContent { public get; private set; }
    // WR508 CHAT REVAMP - SELF REFERENCE CREATED TO PASS PICKLIST VALUES TO CHILD COMPONENT (VF LIMITATION)
    public gcr_chatRedirectController sefReference { public get; private set; }
    // WR508 CHAT REVAMP - TO HOLD ALL POSSIBLE COUNTRY OPTIONS
    public Map<String, String> mCountryPlOption { public get; private set; }
    public String endpoint { get; set; }
    // WR508 CHAT REVAMP - ADDED ADDITIONAL VARIABLE TO IDENTIFY CHAT AVAILABILITY BEFORE REDIRECT
    public Boolean isChatAvailable { public get; private set; }
    
    public Boolean isZipMandatory { public get; private set; }
    public Boolean isStateMandatory { public get; private set; }

    public String privacyPolicyFull { public get; private set; }
    public String privacyPolicy2 { public get; private set; }
    public integer currentYear { public get; private set; }
    public string TsAndCs { public get; private set; }
    public string TsAndCsURL { public get; private set; }
    public string country { public get; private set; }
    public string language { public get; private set; }
    public string handover {public get; public set;}
    public string chatbotCase {public get; public set;}
    public boolean useChatbot { public get; public set; }
    public string handoverChat { public get; public set; }
    public case transcriptCase { public get; public set; }
    public string transcript { public get; public set; }
    public string chatbotAccountId { public get; private set; }
    
    public string source { public get; private set; }

    //CHARSET STRING WHICH WOULD BE USED TO SEND THE MAIL FOR DIFFERENT LANGUAGES
    public string charSet {public get;private set;}
    
    // CONSTRUCTORS
    public gcr_chatRedirectController(Map<String, String> mInput) {
        mCountryPlOption = mInput;
    }

    public gcr_chatRedirectController() {
        getChatData();
    } 
    
    public Boolean getChatData() {
        // WR508 CHAT REVAMP - CHANGED QUERY INTO DYNAMIC QUERY
        String queryString = gcr_helperClass.createQueryString('SELECT', gcr_helperClass.getAllFieldsForQuery('GCRChannelContent__c') 
                                                               + ',CareHub__r.Brand__c, CareHub__r.Country__c, CareHub__r.LanguageLocaleKey__c,CareHub__r.OrgWideEmail__c ' +
                                                               + ',CareHub__r.BrandCountryLanguage__r.Contact_Us_Language__r.Language__c,CareHub__r.AddressFieldSet__c'
                                                               + ',CareHub__r.PrivacyPolicyLink__c, CareHub__r.PrivacyPolicyLabel__c,CareHub__r.Privacy_Policy_Label_2__c,CareHub__r.isLastNameFirst__c'
                                                               + ',CareHub__r.BrandCountryLanguage__r.Contact_Us_Language__r.Terms_and_Conditions__c'
                                                               + ',CareHub__r.BrandCountryLanguage__r.Contact_Us_Language__r.URL_Terms_and_Conditions__c'
                                                               + ',CareHub__r.LanguageIsoCode__c,CareHub__r.CountryIsoCode__c,CareHub__r.ValidationErrorMessage__c', 'GCRChannelContent__c')
                    + ' WHERE CareHub__r.Brand__c = \'' + String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('brand')) + '\''
                    + ' AND (CareHub__r.CountryIsoCode__c = \'' + String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('country')) + '\''
                    + ' OR CareHub__r.Country__c = \'' + String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('country'))  + '\'' + ')'

                    + ' AND (CareHub__r.LanguageIsoCode__c = \'' + String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('language')) + '\''
                    + ' OR CareHub__r.Language__c = \'' + String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('language')) + '\'' + ')' 

                    + ' AND RecordType.Name = \'chat\' AND isActive__c = true';

        // GET CHANNEL CONTENT
        chatChannelContent = (GCRChannelContent__c) Database.query(queryString).get(0);
        // ASSIGN COUNTRY FOR INPUT DEFAULT FIELD VALUE
        chatChannelContent.Country__c = chatChannelContent.CareHub__r.Country__c;

        //Put the Privacy Policy together to display on the chat page - Chris Doyle 04/08/2017 START
        privacyPolicy2 = chatChannelContent.CareHub__r.Privacy_Policy_Label_2__c == null ? ' ' : chatChannelContent.CareHub__r.Privacy_Policy_Label_2__c; //CDOYs
        privacyPolicyFull = chatChannelContent.CareHub__r.PrivacyPolicyLabel__c + ' '+ privacyPolicy2; //CDOY

        integer leftBracket = privacyPolicyFull.indexOf('[');
        //system.debug ('result : '+leftBracket);
        integer rigthBracket = privacyPolicyFull.indexOf(']')+1;
        //system.debug ('result : '+rigthBracket);
        privacyPolicyFull = privacyPolicyFull.substring(leftBracket, rigthBracket);
        //system.debug('PPFul : '+privacyPolicyFull);

        currentYear = System.Today().year();

        TsAndCs = chatChannelContent.CareHub__r.BrandCountryLanguage__r.Contact_Us_Language__r.Terms_and_Conditions__c;
        TsAndCsURL = chatChannelContent.CareHub__r.BrandCountryLanguage__r.Contact_Us_Language__r.URL_Terms_and_Conditions__c;
        //Put the Privacy Policy together to display on the chat page - Chris Doyle 04/08/2017 END

        // GET CHAT PAGE NAME FROM CONFIGURATION
        String chatPage = ChatPage__c.getInstance().CareHubChat__c;
        
        if (System.Site.getBaseUrl().toLowerCase().contains('carehub')) {
            endpoint = System.Site.getBaseUrl() + '/' + chatPage;
        } else {
            endpoint = System.Site.getBaseUrl() + '/apex/' + chatPage;
        }

        if (chatChannelContent != null) {
            system.debug('***ChatContentchannel not equal to NULL');
            // CHECK FOR LEGACY (V3) PAGE
            if (String.isNotEmpty(chatPage) && chatPage.equalsIgnoreCase('sf_ContactUsChat')) {
                endpoint += String.isNotEmpty(chatChannelContent.CareHub__r.BrandCountryLanguage__r.Contact_Us_Language__r.Language__c) 
                        ? '?language=' + EncodingUtil.urlEncode(chatChannelContent.CareHub__r.BrandCountryLanguage__r.Contact_Us_Language__r.Language__c, 'UTF-8') : '';
                endpoint += String.isNotEmpty(chatChannelContent.CareHub__r.Brand__c) 
                        ? '&brand=' + EncodingUtil.urlEncode(chatChannelContent.CareHub__r.Brand__c, 'UTF-8') : null;
                endpoint += String.isNotEmpty(chatChannelContent.CareHub__r.Country__c)
                        ? '&country=' + EncodingUtil.urlEncode(chatChannelContent.CareHub__r.Country__c, 'UTF-8') : null;
                mapUrlParameters(chatChannelContent
                               , ApexPages.currentPage().getParameters().get('fname')
                               , ApexPages.currentPage().getParameters().get('lname')
                               , ApexPages.currentPage().getParameters().get('email')
                               //WR552 - Populate the Loyalty ID 
                               , ApexPages.currentPage().getParameters().get('loyaltyID'));
                               //WR552 END
            } else {
                system.debug('***ChatContentchannel Equals NULL');
                endpoint += String.isNotEmpty(chatChannelContent.CareHub__r.Brand__c) 
                    ? '?brand=' + EncodingUtil.urlEncode(chatChannelContent.CareHub__r.Brand__c, 'UTF-8') : '';
                endpoint += String.isNotEmpty(chatChannelContent.CareHub__r.CountryIsoCode__c) 
                    ? '&country=' + EncodingUtil.urlEncode(chatChannelContent.CareHub__r.CountryIsoCode__c, 'UTF-8') : '';
                endpoint += String.isNotEmpty(chatChannelContent.CareHub__r.LanguageIsoCode__c) 
                    ? '&language=' + EncodingUtil.urlEncode(chatChannelContent.CareHub__r.LanguageIsoCode__c, 'UTF-8') : '';
                mapUrlParameters(chatChannelContent
                               , ApexPages.currentPage().getParameters().get('fname')
                               , ApexPages.currentPage().getParameters().get('lname')
                               , ApexPages.currentPage().getParameters().get('email')
                               //WR552 - Populate the Loyalty ID 
                               , ApexPages.currentPage().getParameters().get('loyaltyID'));
                               //WR552 END
            }
        }
        if(String.isNotEmpty(ApexPages.currentPage().getParameters().get('handover'))){
            system.debug('***handover = '+true);
            chatChannelContent.Has_Chatbot__c = false;

        }

        if(String.isNotEmpty(ApexPages.currentPage().getParameters().get('chatbotCase'))){
            string a = ApexPages.currentPage().getParameters().get('chatbotCase');
            transcriptCase = [SELECT Chatbot_HTML_Transcript__c from case where ID =: a ];
            transcript = transcriptCase.Chatbot_HTML_Transcript__c;
            system.debug('chatBotCase : '+ a);
        }

        string source = ApexPages.currentPage().getParameters().get('Source');

        if(source!=NULL && source.containsIgnoreCase('Chatbot') && chatChannelContent.Has_Chatbot__c ){
            useChatbot=TRUE;
            chatbotAccountId = chatChannelContent.Chatbot_Account_Id__c;
        }
        else{
            useChatbot=FALSE;
        }
        system.debug('***useChatbot : '+useChatbot);
        
        //WR 545 - SET THE CHARSET TO JAPAN TRANSLATION 
        charSet = 'jp'.equalsIgnoreCase(chatChannelContent.CareHub__r.LanguageIsoCode__c)? 'Shift_JIS' :'';
        
        // WR508 - Chat Redesign: CHECK IF CHAT IS STILL AVAILABLE
        // TODO: UNCOMMENT THIS
        // isChatAvailable = gcr_helperClass.ischatBtnAvailable(chatChannelContent.Id);
        // WR508 - Chat Redesign: GET COUNTRY PICKLIST VALUES
        sefReference = new gcr_chatRedirectController(gcr_helperClass.getAllPicklistValues('GCRChannelContent__c', 'Country__c'));
        evaluateMandatoryFields(chatChannelContent.Country__c);
        return true;


    }


    public void mapUrlParameters(GCRChannelContent__c chatChannelContent, String preFName, String preLName, String preEmail, String preLoyaltyID) {
        endpoint += String.isNotEmpty(preFName) ? '&fname=' + EncodingUtil.urlEncode(preFName, 'UTF-8') : '';
        endpoint += String.isNotEmpty(preLName) ? '&lname=' + EncodingUtil.urlEncode(preLName, 'UTF-8') : '';
        endpoint += String.isNotEmpty(preEmail) ? '&email=' + EncodingUtil.urlEncode(preEmail, 'UTF-8') : '';
        //WR552 - Populate the Loyalty ID 
        endpoint += String.isNotEmpty(preLoyaltyID) ? '&loyaltyID=' + EncodingUtil.urlEncode(preLoyaltyID, 'UTF-8') : '';
        //WR552 END
        endpoint += '#deployment_id=' + chatChannelContent.LADeploymentId__c;
        endpoint += '&org_id=' + UserInfo.getOrganizationId().substring(0, 15);
        endpoint += '&button_id=' + chatChannelContent.LAButtonId__c;
        endpoint += '&session_id=';
    }
    
    public void evaluateMandatoryFields(String country) {
        isZipMandatory = Country_Status__c.getInstance(country).Uses_Postal_Codes__c;
        isStateMandatory = Country_Status__c.getInstance(country).Uses_States__c;
    }
    
    @RemoteAction
    global static String validateAddress(String strAddress) {
        String retVal = '';
        
        Contact piiContact = gcr_helperClass.mapAddressDetails(strAddress, null);
        // CALL STRIKE IRON
        piiContact = gcr_helperClass.validateCareHubAddress(piiContact);
        
        if (piiContact != null) {
            retVal += String.isNotEmpty(piiContact.Primary_Address_Line_1__c) ? 
                piiContact.Primary_Address_Line_1__c + ';' : '';
            retVal += String.isNotEmpty(piiContact.Primary_Address_Line_2__c) ? 
                piiContact.Primary_Address_Line_2__c + ';' : '';
            retVal += String.isNotEmpty(piiContact.Primary_City__c) ? 
                piiContact.Primary_City__c + ';' : '';
            retVal += String.isNotEmpty(piiContact.Primary_State_Province__c) ? 
                piiContact.Primary_State_Province__c + ';' : '';
            retVal += String.isNotEmpty(piiContact.Primary_Country__c) ? 
                piiContact.Primary_Country__c + ';' : '';
            retVal += String.isNotEmpty(piiContact.Primary_Postal_Code__c) ? 
                piiContact.Primary_Postal_Code__c : '';
        }

        return retVal;
    }

    /** ACCEPT THE PARAMETER HANDOFF REASON  - WILL BE SPECIFIC FOR CHATBOT OOH HANDOFF CASES**/
    
    @RemoteAction
    global static String submitPiiData(String strFName, String strLName, String strEmail, String strPhone, String strAddress, String caseId, String agentTranscript) {
        String returnVal = '';
        if (String.isNotEmpty(caseId)) {
            //CMD - rewritten if caseId is not a valid id will get query exception, chatCase cannot be null
            /*Case chatCase = [ SELECT Id
                                   , ContactId
                                   , AccountId
                                   , Language__c
                              FROM Case WHERE Id = :caseId ];
            if (chatCase != null) {*/
            Boolean updateCase = false;
            List<Case> chatCases = new List<Case>([SELECT Id, ContactId, AccountId, Language__c FROM Case WHERE Id = :caseId]);
            if(!chatCases.isEmpty()){
                Case chatCase = chatCases[0];  
                //WR:545 - POPULATE THE AGENT TRANSCRIPT IF THE PII FORM IS SUBMITTED AS A PART OF OOO HANDOFF 
                if(String.isNotBlank(agentTranscript)){
                    chatCase.Chatbot_Transcript_for_Agent__c = agentTranscript;
                    updateCase = true;
                    returnVal = 'PII_OUT_OF_HOURS_HANDOFF_SUCCESS';
                }                      
                Contact updatedContact;
                if (String.isNotEmpty(chatCase.ContactId)) {
                    updatedContact = (Contact) Contact.getSObjectType().newSObject(chatCase.ContactId);
                    gcr_helperClass.mapContactData(strFName, strLName, strEmail, strPhone, strAddress, updatedContact);
                    Database.update(updatedContact);
                } else {
                    updatedContact = new Contact();
                    Date birthday;
                    CaseUtility caseUtil = new CaseUtility();
                    //gcr_helperClass.mapContactData(strFName, strLName, strEmail, strPhone, strAddress, updatedContact);
                    if (String.isNotEmpty(strFName) && String.isNotEmpty(strLName) && String.isNotEmpty(strEmail)) {
                        updatedContact = caseUtil.getContactByFNameLNameEmail(strFName, strLName, strEmail);
                    }
                    Contact tempCon = gcr_helperClass.mapAddressDetails(strAddress, null);
                    if (String.isNotEmpty(updatedContact.Id)) {
                        caseUtil.updateContact(updatedContact.Id, tempCon.Primary_Address_Line_1__c, tempCon.Primary_Address_Line_2__c, null
                                             , tempCon.Primary_City__c, tempCon.Primary_State_Province__c, tempCon.Primary_Postal_Code__c
                                             , tempCon.Primary_Country__c, null, birthday, false, String.isNotEmpty(strPhone) ? strPhone : '');
                    } else {
                        QueueRecordType__c accQueueRecType = gcr_helperClass.getRecordType(tempCon.Primary_Country__c, chatCase.Language__c);
                        updatedContact = caseUtil.createContact(strFName, strLName, tempCon.Primary_Address_Line_1__c, tempCon.Primary_City__c
                                                                , null, birthday
                                                                , accQueueRecType != null ? accQueueRecType.Account_Record_Type_Id__c : ''
                                                                , false, tempCon.Primary_Country__c, strEmail
                                                                , tempCon.Primary_Address_Line_2__c, null, tempCon.Primary_State_Province__c
                                                                , tempCon.Primary_Postal_Code__c, tempCon.Phone);
                                                                            
                    }
                    if (String.isNotEmpty(updatedContact.Id)) {
                        tempCon = [ SELECT Id, AccountId FROM Contact WHERE Id = :updatedContact.Id ];
                        chatCase.AccountId = tempCon.AccountId;
                        chatCase.ContactId = tempCon.Id;
                        updateCase = true;
                    }
                }
                //WR 545 - UPDATE ONLY WHEN IT IS NEEDED ie - FOR A CASE WITHOUT CONTACT AND OUTOFHOURS REASON IS POPULATED
                if(updateCase){
                    Database.update(chatCase);
                }
            } else {
                returnVal = '';
                throw new chatException();
            }
        } else {
            returnVal = '';
            throw new chatException();
        }
        return returnVal;
    }
    
     @RemoteAction
    global static Country_Status__c changeCountry(String country) {
        return Country_Status__c.getInstance(country);
    }
    
    @RemoteAction
    global static void sendTrascript(String emailAddress, String emailContent, String channelId,  String charSet) {
        
        //CMD removed - rewritten to prevent List has no rows for assignment to SObject
        /*GCRChannelContent__c channelContent = [ SELECT Id 
                                                     , CareHub__r.OrgWideEmail__c
                                                     , TranscriptEmailSubject__c
                                                FROM GCRChannelContent__c 
                                                WHERE Id = :channelId ];*/
        
        List<GCRChannelContent__c> channelContentList = new List<GCRChannelContent__c>();
        channelContentList = [SELECT Id , CareHub__r.OrgWideEmail__c, TranscriptEmailSubject__c
            FROM GCRChannelContent__c 
            WHERE Id = :channelId ];
        if(!channelContentList.isEmpty()){                
            Messaging.SingleEmailMessage mailObj = new Messaging.SingleEmailMessage();
            mailObj.setToAddresses(new String[]{ emailAddress });
            List<OrgWideEmailAddress> lOwa = [ SELECT Id
                                                    , DisplayName
                                               FROM OrgWideEmailAddress
                                               WHERE Address = :channelContentList[0].CareHub__r.OrgWideEmail__c

                                               LIMIT 1 ];
            if (lOwa != null && !lOwa.isEmpty()) {
                // HTML BREAK ELEMENT HAS BEEN PLACED TO BREAK THE CONVERSATION TO APPEAR IN THE EMAIL TEMPLATE
                // NOTE: STYLE CLASS DEPENDS ON THE STYLES APPLIED IN CHAT PAGE
                emailContent = emailContent.replace('<span class="client">','</br><span class="client">');
                emailContent = emailContent.replace('<span class="operator">','</br><span class="operator">');
                mailObj.setOrgWideEmailAddressId(lOwa.get(0).Id);
                //mailObj.setSenderDisplayName(lOwa.get(0).DisplayName);
                mailObj.setSubject(channelContentList[0].TranscriptEmailSubject__c);
                //WR 545 - SET THE CHARSET FOR JAPAN TRANSLATION 
                if(String.isNotBlank(charSet)){
                    mailObj.setCharset(charSet);
                }
                mailObj.setBccSender(false);
                mailObj.setUseSignature(false);
                mailObj.setUseSignature(false);
                mailObj.setHtmlBody(emailContent);
    
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mailObj });
            } else {
               System.enqueueJob(new exceptionHelperQueable('gcr_chatRedirectController.sendTrascript - Organization wide address not found. ChannelId: '+channelId));
                throw new chatException('Organization wide address not found');
            }
        } else {
            System.enqueueJob(new exceptionHelperQueable('gcr_chatRedirectController.sendTrascript : Channel content not found. ChannelId: '+channelId));
            throw new chatException('Channel content not found');
        
        }
    }

    @RemoteAction
    global static string createCaseForChatbot(String chatBotSource,String country, String language, String brand) {

        CaseUtility util = new CaseUtility();

        Case c = new Case();
        c.country__c = country;
        c.language__c = language;
        c.origin = 'Chat';
        c.chatType__c = chatBotSource;
        c.Brand__c = brand;
        c.Not_handled_reason__c = 'Chatbot Handled';
        util.insertNewCase(c);
        string cn = c.id;
        return cn;

    }

    @RemoteAction
    global static void closeChatbotCase(String chatbotcaseId, String fullChatDiv, Boolean agentHandoff, String agentTranscript,String pii_Result) {

        Case chatbotCase = [ SELECT Id, status FROM Case WHERE Id = :chatbotcaseId ]; 
        fullChatDiv = fullChatDiv.replace('\r\n', ' ');
        fullChatDiv = fullChatDiv.replace('\n', ' ');
        fullChatDiv = fullChatDiv.replace('\r', ' ');
        if (chatbotCase != null) {
            //CLOSE THE CASE INCASE IF THERE IS NO PII HANDOFF HAPPENED
            if(String.isBlank(pii_Result)){
                chatbotCase.status = 'Closed';   
            }
            chatbotCase.Chatbot_HTML_Transcript__c = fullChatDiv;
            // STAMP THE VALUE ONLY IN CASE OF TRUE SINCE THE SAME METHOD IS CALLED TWICE FROM THE PAGE - WITH THE END BUTTON WITHOUT HANDOFF
            if(agentHandoff){
                chatbotCase.Agent_Handoff__c = agentHandoff;   
            }
            chatbotCase.Chatbot_Transcript_for_Agent__c = agentTranscript;
            system.debug('***agentTranscript : '+ chatbotCase.Chatbot_Transcript_for_Agent__c);

            update chatbotCase;    
        }
    }

     /*
     * @author:         Accenture
     * @date:           03/10/2017
     * @description:    AMEND THE AGENT TRANSCRIPT WHEN BEFORE THE PII FORM FOR OOH HANDOFF
     * @input:          String, String
     * @return:         String
     */
    @RemoteAction
    global static String updateCaseOnOOHHandOff(String cBotCaseId,String agentTranscript, String previuosResponse) {
        String returnVal = '';

        if(String.isNotBlank(cBotCaseId)){
            SObject sobjToUpdate = Id.valueOf(cBotCaseId).getSObjectType().newSObject(cBotCaseId);
            sobjToUpdate.put('Chatbot_Transcript_for_Agent__c', agentTranscript);
            sobjToUpdate.put('Priority', '1');
            if(String.isBlank(previuosResponse)){
                sobjToUpdate.put('reassign_Case__c', true);
            }
            Database.update(sobjToUpdate);
            returnVal = 'OUT_OF_HOURS_HANDOFF_CASE_UPDATE_SUCCESS';
        }else{
            System.enqueueJob(new exceptionHelperQueable('gcr_chatRedirectController.sendTrascript : Case not found. Case ID: '+cBotCaseId));
            throw new chatException('Case detail not found');
        }
        return returnVal;

     }


}