/*
* @author:       Accenture
* @date:         27/06/2016
* @description:  Controller class for email us component of gcr widget
* CHANGE LOG
* DATE              NAME                CHANGE DESCRIPTION
* 27/06/2016        Accenture           Initial Draft
* 29/09/2016        Accenture           DEFECT FIX - Queue assignment is not working propery as country used for queue assignment
*                                       was page variable but it should be country coming from Brand.com website. "chlContentRec.Country__c" 
*                                       Commented and "handshakeInstance.newCase.Country__c" inserted for method call gcr_helperClass.assignmentRuleQueue
* 30/09/2016        Accenture           DEFECT FIX - TO MATCH WITH LEGACY AS TIBCO PICKS UP FROM CASE PRODUCT HISTORY RECORD    
*                                       Introduced page veriable mProdRetStatus and set the varalbe with helper class method call after
*                                       inserting Case Products. And call "CaseUtility.populateProductReturnStatus" method to create case product history
* 21/11/2016        Accenture           Added referer attribute to capture referer details
* 20/03/2017        Accenture           WR476 added to handle the product search when the consumer selects Product Availability/ Where to Buy
* 21/06/2017        Accenture           WR530 - Defect fix: Crm checkbox default value to be controlled via configuration.
*/
global class gcr_emailUsController {
    public Boolean tempData { get {
        if (chlContentRec == null) {
            String queryString = gcr_helperClass.createQueryString('SELECT'
                                                                 , gcr_helperClass.getAllFieldsForQuery('GCRChannelContent__c')
                                                                   + ',CareHub__r.ValidationErrorMessage__c,CareHub__r.isLastNameFirst__c,CareHub__r.Country__c,CareHub__r.Language__c,CareHub__r.PrivacyPolicyLink__c'
                                                                   + ',CareHub__r.CountryIsoCode__c,CareHub__r.LanguageIsoCode__c,CareHub__r.PrivacyPolicyLabel__c,CareHub__r.Privacy_Policy_Label_2__c'
                                                                   + ',CareHub__r.LanguageLocaleKey__c,CareHub__r.Brand__c,CareHub__r.SearchMinCharMsg__c,RecordType.Name'
                                                                 , 'GCRChannelContent__c')
                + ' WHERE Id = \'' + chlContentId + '\'' ;
            chlContentRec = (GCRChannelContent__c) Database.query(queryString).get(0);
            chlContentRec.Country__c = chlContentRec.CareHub__r.Country__c;
            handshakeInstance = new gcr_WidgetHandshake(new List<gcr_emailUsPrbController.CaseProductWrapper>(), new Case(), new Contact());
            // INITALIZE COUNTRY OF CONTACT AND CASE TO CURRENT COUNTRY
            handshakeInstance.newContact.Primary_Country__c = chlContentRec.CareHub__r.Country__c;
            handshakeInstance.newCase.Country__c = chlContentRec.CareHub__r.Country__c;
            // INITALIZE CASE REASON
            handshakeInstance.newCase.Reason = chlContentRec.EmailReasonLabel__c;
            // INSTANTIATE VALIDATION MAP TO VALIDATE DATA
            handshakeInstance.mValidationMap = new Map<String, Boolean>();
            handshakeInstance.isProductSearch = false;
            createValidationMap();
            // CHECK IF COUNTRY HAVE POSTCODES AND/OR STATE/COUNTY
            Country_Status__c countryStatus = Country_Status__c.getInstance(chlContentRec.CareHub__r.Country__c);
            if (countryStatus != null) {
                handshakeInstance.isStateMandatory = countryStatus.Uses_States__c ? true : false;
                handshakeInstance.isZipMandatory = countryStatus.Uses_Postal_Codes__c ? true : false;
            } else {
                handshakeInstance.isStateMandatory = true;
                handshakeInstance.isZipMandatory = true;
            }
            // WR530 - DEFECT FIX: INTILIZE CRM CHECKOX FROM CONFGURATION
			handshakeInstance.newContact.Email_Opt_In__c = chlContentRec.crmChecked__c;
            privacyPolicy2 = chlContentRec.CareHub__r.Privacy_Policy_Label_2__c == null ? ' ' : chlContentRec.CareHub__r.Privacy_Policy_Label_2__c; //CDOYs

            privacyPolicyFull = chlContentRec.CareHub__r.PrivacyPolicyLabel__c + ' '+ privacyPolicy2; //CDOY
        }
        return false;
    } set; }

    // TODO: REMOVE 'EMAIL US' HARDCODING FROM CONTROLLER AND VIEW BOTH
    // HANDSHAKE CLASS INSTANCE TO COMMUNICATE DATA IN VISUALFORCE COMPONENTS
    public gcr_WidgetHandshake handshakeInstance { get; set; }
    public Boolean isValidated { get; private set; }
    public Boolean isEmailFormat { get; private set; }
    public Boolean isEmailValid { get; private set; }
    public String caseDescription { get; set; }
    public Contact validatedContact { get; private set; }
    //public Contact selectedAddress { get; private set; }
    public String selectedAddress { get; set; }
    // VARIABLE RELATED TO ATTACHMENT
    public List<String> lAttachmentName { get; set; }
    public transient String attachmentName { get; set; }
    public String srtAttachmentId { get; set; }
    public String srtAttachmentErr { get; set; }
    // VARIABLE RELATED TO ADDRESS SELECTION
    public Boolean isMain { get; set; }
    public Boolean isSelectAdd { get; set; }
    public Boolean isCaseSubmit { get; set; }
    public Boolean isAddValidated { get; set; }
    public String remAttachmentIndex { get; set; }
    
    public Boolean isRightToLeft { get; set; }
    public Boolean addressNotSelected { get; set; }

    public GCRChannelContent__c chlContentRec { get; set; }
    public String chlContentId { get; set; }
    // DEFECT FIX - TO MATCH WITH LEGACY AS TIBCO PICKS UP FROM CASE PRODUCT HISTORY RECORD
    private Map<Id, String> mProdRetStatus { private get; private set; }
    // ADDED ADDITIONAL ATTRIBUTE TO CAPTURE REFERER ATTRIBUTE
    public String referer {get;set;}

    public String privacyPolicyFull {get;set;}
    public String privacyPolicy2 {get;set;}
    
    // CONSTRUCTOR CODE FOR CONTROLLER
    public gcr_emailUsController() {
        // INITIALIZE VARIABLES ON PAGE LOAD
        isValidated = true;
        isEmailFormat = true;
        isEmailValid = true;
        srtAttachmentErr = '';
        srtAttachmentId = '';
        isMain = true;
        isSelectAdd = false;
        isCaseSubmit = false;
        isAddValidated = false;
        addressNotSelected = false;
        lAttachmentName = new List<String>();
    }

    /*
     * @author:         Accenture
     * @date:           27/06/2016
     * @description:    METHOD TO RETRIEVE SELECT OPTIONS FOR REASON FOR WRITING DROPDOWN
     * @param:          none 
     * @return:         List<SelectOption>
     */
    public List<SelectOption> getLReasonForWriting() {
        List<SelectOption> retVal = new List<SelectOption>();
        if (String.isNotEmpty(chlContentRec.EmailReasonLabel__c)) {
            retVal.add(new SelectOption(chlContentRec.EmailReasonLabel__c, chlContentRec.EmailReasonLabel__c, true));
        }
        if (String.isNotEmpty(chlContentRec.EmailReason1__c)) {
            retVal.add(new SelectOption(chlContentRec.EmailReason1__c, chlContentRec.EmailReason1__c));
        }
        if (String.isNotEmpty(chlContentRec.EmailReason2__c)) {
            retVal.add(new SelectOption(chlContentRec.EmailReason2__c, chlContentRec.EmailReason2__c));
        }
        if (String.isNotEmpty(chlContentRec.EmailReason3__c)) {
            retVal.add(new SelectOption(chlContentRec.EmailReason3__c, chlContentRec.EmailReason3__c));
        }
        if (String.isNotEmpty(chlContentRec.EmailReason4__c)) {
            retVal.add(new SelectOption(chlContentRec.EmailReason4__c, chlContentRec.EmailReason4__c));
        }
        if (String.isNotEmpty(chlContentRec.EmailReason5__c)) {
            retVal.add(new SelectOption(chlContentRec.EmailReason5__c, chlContentRec.EmailReason5__c));
        }
        if (String.isNotEmpty(chlContentRec.EmailReason6__c)) {
            retVal.add(new SelectOption(chlContentRec.EmailReason6__c, chlContentRec.EmailReason6__c));
        }

        return retVal;
    }
    
    /*
     * @author:         Accenture
     * @date:           27/06/2016
     * @description:    METHOD TO SUBMIT AND VALIDATE DATA AT SERVER
     * @param:          none 
     * @return:         void
     */
    public void submitActionData() {
        isValidated = true;
        isEmailFormat = true;
        isEmailValid = true;
        createValidationMap();
        handshakeInstance.newCase.Summary__c = caseDescription;
        // ASSIGN COUNTRY VALUE
        handshakeInstance.newContact.Primary_Country__c = chlContentRec.Country__c;
        if (String.isNotEmpty(handshakeInstance.newCase.Reason)
        && handshakeInstance.newCase.Reason.equalsIgnoreCase(chlContentRec.EmailReasonLabel__c)) {
            handshakeInstance.mValidationMap.put('caseReasonField', true);
            isValidated = false;
        }
        if (String.isEmpty(handshakeInstance.newCase.Summary__c)) {
            handshakeInstance.mValidationMap.put('caseDescField', true);
            isValidated = false;
        }
        if (String.isEmpty(handshakeInstance.newContact.FirstName)) {
            handshakeInstance.mValidationMap.put('contactFirstName', true);
            isValidated = false;
        }
        if (String.isEmpty(handshakeInstance.newContact.LastName)) {
            handshakeInstance.mValidationMap.put('contactLastName', true);
            isValidated = false;
        }
        if (String.isEmpty(handshakeInstance.newContact.Email)) {
            handshakeInstance.mValidationMap.put('contactEmail', true);
            isValidated = false;
        } else {
            if(!gcr_helperClass.validateEmailFormat(handshakeInstance.newContact.Email)) {
                handshakeInstance.mValidationMap.put('contactEmail', true);
                isEmailFormat = false;
            } else {
                if(!gcr_helperClass.isEmailAddressValid(handshakeInstance.newContact.Email)) {
                    handshakeInstance.mValidationMap.put('contactEmail', true);
                    isEmailValid = false;
                }
            }
        }
        if (String.isNotEmpty(handshakeInstance.newCase.Reason)
        && handshakeInstance.newCase.Reason.equalsIgnoreCase(chlContentRec.EmailReason4__c)) {
            if (String.isEmpty(handshakeInstance.newContact.Primary_Address_Line_1__c)) {
                handshakeInstance.mValidationMap.put('contactAddressLine1', true);
                isValidated = false;
            }
            if (String.isEmpty(handshakeInstance.newContact.Primary_Postal_Code__c) && handshakeInstance.isZipMandatory) {
                handshakeInstance.mValidationMap.put('contactAddressZipCode', true);
                isValidated = false;
            }
            if (String.isEmpty(handshakeInstance.newContact.Primary_City__c)) {
                handshakeInstance.mValidationMap.put('contactAddressCity', true);
                isValidated = false;
            }
            if (String.isEmpty(handshakeInstance.newContact.Primary_State_Province__c) && handshakeInstance.isStateMandatory) {
                handshakeInstance.mValidationMap.put('contactAddressCounty', true);
                isValidated = false;
            }
            if (String.isEmpty(handshakeInstance.newContact.Primary_Country__c)) {
                handshakeInstance.mValidationMap.put('contactAddressCountry', true);
                isValidated = false;
            }
            if (handshakeInstance.isProductSearch) {
                if(handshakeInstance.lCaseProduct != null && !handshakeInstance.lCaseProduct.isEmpty()) {
                    for (gcr_emailUsPrbController.CaseProductWrapper eachCasePrd :handshakeInstance.lCaseProduct) {
                        if(eachCasePrd.usedBefore.equalsIgnoreCase('0')) {
                            handshakeInstance.mValidationMap.put('prodUse' + String.valueOf(eachCasePrd.uniqueId), true);
                            isValidated = false;
                        }
                        if(eachCasePrd.stillHaveProd.equalsIgnoreCase('0')) {
                            handshakeInstance.mValidationMap.put('stillHave' + String.valueOf(eachCasePrd.uniqueId), true);
                            isValidated = false;
                        }
                        if(String.isNotEmpty(eachCasePrd.expiryDate)) {
                            try {
                                List<String> lDateSplit = eachCasePrd.expiryDate.split('/');
                                eachCasePrd.caseProduct.Expiration_Date__c 
                                    = Date.valueOf(lDateSplit.get(2) + '-' + lDateSplit.get(0) + '-' + lDateSplit.get(1));
                            } catch (System.TypeException caughtException) {
                                handshakeInstance.mValidationMap.put('expiryDate' + String.valueOf(eachCasePrd.uniqueId), true);
                                isValidated = false;
                            }
                        }
                    }
                }
            }
            if(isValidated && isEmailFormat && isEmailValid) {
                // ADDRESS LINE 3 - NOT REQUIRED FOR CAREHUB BUT MANDATORY FOR STRIKEIRON
                if (!isAddValidated) {
                    handshakeInstance.newContact.Primary_Address_Line_3__c = '';
                    validatedContact = gcr_helperClass.validateCareHubAddress(handshakeInstance.newContact);
                    if(validatedContact == null) {
                        submitCase();
                    } else {
                        isMain = false;
                        isSelectAdd = true;
                        isCaseSubmit = false;
                    }
                    isAddValidated = true;
                } else {
                    submitCase();
                }
            }
        }
        if (isValidated && isEmailFormat && isEmailValid) {
            if (String.isNotEmpty(handshakeInstance.newCase.Reason)
            && !handshakeInstance.newCase.Reason.equalsIgnoreCase(chlContentRec.EmailReason4__c)) {
                submitCase();
            }
        }
    }

    /*
     * @author:         Accenture
     * @date:           27/06/2016
     * @description:    EXECUTION AFTER ADDRESS SELECTION AND CONTINUE WITH EMAIL SUBMIT
     * @param:          none 
     * @return:         void
     */
    public void continueAddressSel() {
        if (String.isNotEmpty(selectedAddress)) {
            if (selectedAddress.equalsIgnoreCase('suggested')) {
                handshakeInstance.newContact.Primary_Address_Line_1__c = validatedContact.Primary_Address_Line_1__c;
                handshakeInstance.newContact.Primary_Address_Line_2__c = validatedContact.Primary_Address_Line_2__c;
                handshakeInstance.newContact.Primary_City__c = validatedContact.Primary_City__c;
                handshakeInstance.newContact.Primary_State_Province__c = validatedContact.Primary_State_Province__c;
                handshakeInstance.newContact.Primary_Country__c = validatedContact.Primary_Country__c;
                handshakeInstance.newContact.Primary_Postal_Code__c = validatedContact.Primary_Postal_Code__c;
            }
            submitCase();
        } else {
            addressNotSelected = true;
        }
    }
    
    /*
     * @author:         Accenture
     * @date:           27/06/2016
     * @description:    CASE CREATION LOGIC AFTER SUCCESSFUL SERVER AND CLIENT SIDE VALIDATION
     * @param:          none 
     * @return:         void
     */
    public void submitCase() {
        Savepoint dbSavePoint = Database.setSavepoint();
        // GET CASE UTILITY ADDRESS
        CaseUtility utilInstance = new CaseUtility();
        List<Case_Product__c> lCaseProduct = new List<Case_Product__c>();

        try {
            // TODO: FOR FUTURE RELEASES BRAND CAN BE P&G
            // MAP CASE FIELDS (BRAND, STATUS AND PRIORITY)
            // WR552 - STAMP THE LOYALTY ID TO THE NEWLY CREATED CASE - LOYALTY ID WOULD BE PASSED IN THE PAGE PARAMETER
            handshakeInstance.newCase.Loyalty_ID__c = ApexPages.currentPage().getParameters().get('loyaltyID')!=NULL
                												?ApexPages.currentPage().getParameters().get('loyaltyID'):'';
            //END WR552 
            handshakeInstance.newCase.Brand__c = chlContentRec.CareHub__r.Brand__c;
            handshakeInstance.newCase.Status = sf_Constants.EMAILUS_DEFAULT_STATUS;
            handshakeInstance.newCase.Priority = utilInstance.getPriority(handshakeInstance.newCase.Summary__c
                                                                        , String.escapeSingleQuotes(chlContentRec.CareHub__r.Country__c));
            // AS PER LEGACY REQUIREMENT
            Map<String, String> reasonsMap = createReasonMap();
            handshakeInstance.newCase.Reason_For_Writing_Number__c 
                =  reasonsMap.get(handshakeInstance.newCase.Reason) != null ? reasonsMap.get(handshakeInstance.newCase.Reason) : '0';
            
            //CDOY Wr467 removed - handshakeInstance.newContact.Email_Opt_In__c = false;
            Contact exContact = utilInstance.getContactByFNameLNameEmail(handshakeInstance.newContact.FirstName
                                                                       , handshakeInstance.newContact.LastName
                                                                       , handshakeInstance.newContact.Email);
            handshakeInstance.newCase.Subject 
                = String.isNotEmpty(handshakeInstance.newCase.Summary__c) && handshakeInstance.newCase.Summary__c.length() > 255 
                    ? handshakeInstance.newCase.Summary__c.substring(0, 255) : handshakeInstance.newCase.Summary__c;
            // IF CASE IS REPORT A PROBLEM
            if (String.isNotEmpty(handshakeInstance.newCase.Reason)
            && handshakeInstance.newCase.Reason.equalsIgnoreCase(chlContentRec.EmailReason4__c)) {
                //handshakeInstance.newContact.Override_Primary_Address__c = true;
                handshakeInstance.newContact.Primary_Address_Override_Reason__c = chlContentRec.AddressOverrideReason__c;
                if (handshakeInstance.isProductSearch) {
                    if (handshakeInstance.lCaseProduct != null && !handshakeInstance.lCaseProduct.isEmpty()) {
                        handshakeInstance.newCase.Summary__c += '\n\n' + chlContentRec.EmailProductQuantities__c + '\n'; 
                        handshakeInstance.newCase.Summary__c += '====================\n\n';
                        for (gcr_emailUsPrbController.CaseProductWrapper eachCaseProd :handshakeInstance.lCaseProduct) {
                            handshakeInstance.newCase.Summary__c += eachCaseProd.productName + ': ' + eachCaseProd.numberProd + '\n'; 
                        }
                    }
                }
            }
            // UPDATE OR CREATE NEW CONTACT
            if (exContact.Id != null) {
                handshakeInstance.newContact.Id = exContact.Id;
                utilInstance.updateContact(handshakeInstance.newContact);
            } else if(utilInstance.isContactNeeded(handshakeInstance.newContact.Email)) {                 
                insert handshakeInstance.newContact;
            }
            // ASSOCIATE CONTACTID WITH CASE
            handshakeInstance.newCase.ContactId = handshakeInstance.newContact.Id;
            // GET ACCOUNT ID FOR CONTACT
            handshakeInstance.newCase.AccountId = utilInstance.getAccountIdForContact(handshakeInstance.newContact.Id);

            handshakeInstance.newCase.Origin = sf_Constants.EMAILUS_CASE_ORIGIN; //CDOY WR114 Moved position                                                                                                

            //START LEGACY QUEUE ASSIGNMENT LOGIC
            gcr_helperClass.assignmentRuleQueue(handshakeInstance.newContact.Email
                                                  , chlContentRec.CareHub__r.Language__c
                                                  // CHANGED AS COUNTRY SHOULD BE WHAT WE GET FROM BRAND.COM WEBSITE
                                                  //, chlContentRec.Country__c
                                                  , handshakeInstance.newCase.Country__c
                                                  , reasonsMap.get(handshakeInstance.newCase.Reason)
                                                  , handshakeInstance.newCase);           
            //FIN LEGACY QUEUE ASSIGNMENT LOGIC
            handshakeInstance.newCase.Integration_Flag__c = true;
            handshakeInstance.newCase.Language__c = chlContentRec.CareHub__r.Language__c;
          //handshakeInstance.newCase.Origin = sf_Constants.EMAILUS_CASE_ORIGIN; 
          //CDOY WR114 Moved Position
            handshakeInstance.newCase.Received_Date__c = SYSTEM.now();
            for (String eachStr :new Set<String>(srtAttachmentErr.split(','))) {
                if (String.isNotEmpty(eachStr)) {
                    if (String.isEmpty(handshakeInstance.newCase.Attachment_Errors__c)) {
                        handshakeInstance.newCase.Attachment_Errors__c = eachStr;
                    } else {
                        handshakeInstance.newCase.Attachment_Errors__c += ',' + eachStr;
                    }
                }
            }
            handshakeInstance.newCase.Lowercase_Summary__c = handshakeInstance.newCase.Summary__c.toLowerCase();
            if (handshakeInstance.lCaseProduct != null && !handshakeInstance.lCaseProduct.isEmpty()) {
                handshakeInstance.newCase.Unable_To_Find_Product__c = '';
            }
            handshakeInstance.newCase.Terms_and_Conditions_Accepted__c = true;
            // ADD REFERRER
            handshakeInstance.newCase.HTTP_Referrer__c = referer;
            handshakeInstance.newCase = utilInstance.insertNewCase(handshakeInstance.newCase);
            // IF CASE IS REPORT A PROBLEM
            if (String.isNotEmpty(handshakeInstance.newCase.Reason)
            && (handshakeInstance.newCase.Reason.equalsIgnoreCase(chlContentRec.EmailReason4__c) 
            ||handshakeInstance.newCase.Reason.equalsIgnoreCase(chlContentRec.EmailReason3__c))) {
                // GET AND CREATE CASE PRODUCTS
                if (handshakeInstance.lCaseProduct != null && !handshakeInstance.lCaseProduct.isEmpty()) {
                    for (gcr_emailUsPrbController.CaseProductWrapper eachCaseProd :handshakeInstance.lCaseProduct) {
                        eachCaseProd.caseProduct.Case__c = handshakeInstance.newCase.Id;
                        eachCaseProd.caseProduct.Same_Version__c = eachCaseProd.usedBefore != '0' ? eachCaseProd.usedBefore : 'Unknown';
                        if (String.isNotEmpty(eachCaseProd.productionCode)) {
                            eachCaseProd.caseProduct.Production_Code__c = eachCaseProd.productionCode;
                        }
                        if (String.isNotEmpty(eachCaseProd.stillHaveProd) && eachCaseProd.stillHaveProd.equalsIgnoreCase('yes')) {
                            // DEFECT FIX - TO MATCH WITH LEGACY AS TIBCO PICKS UP FROM CASE PRODUCT HISTORY RECORD
                            //eachCaseProd.caseProduct.Product_available_for_return__c = 'Yes - Product is available';
                            eachCaseProd.caseProduct.Product_available_for_return__c = '1';
                        } else {
                            // DEFECT FIX - TO MATCH WITH LEGACY AS TIBCO PICKS UP FROM CASE PRODUCT HISTORY RECORD
                            //eachCaseProd.caseProduct.Product_available_for_return__c = 'No - Product cannot be returned';
                            eachCaseProd.caseProduct.Product_available_for_return__c = '0';
                        }
                        lCaseProduct.add(eachCaseProd.caseProduct);
                    }
                    Database.insert(lCaseProduct, true);
                    // DEFECT FIX - TO MATCH WITH LEGACY AS TIBCO PICKS UP FROM CASE PRODUCT HISTORY RECORD
                    mProdRetStatus = gcr_helperClass.createCaseProductHistory(lCaseProduct);
                }
            }
            postSubmitCase(dbSavePoint);
        } catch (Exception caughtException) {
            Database.rollback(dbSavePoint);
            // CLEAN UP ATTACHMENTS
            gcr_helperClass.manageAttachment(srtAttachmentId, handshakeInstance.newCase.Id, false);
            // SHOW ERROR MESSAGE ON PAGE
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL
                                                     , GCRGenericProperties__c.getInstance('GCR_FATAL_ERRMSG').value__c));
        }
    }
    
    /*
     * @author:         Accenture
     * @date:           27/06/2016
     * @description:    LOGIC AFTER CASE CREATION - TASK, EMAIL MESSAGE AND ATTACHMENT CREATION
     * @param:          Savepoint 
     * @return:         void
     */
    public void postSubmitCase(Savepoint dbSavePoint) {
        CaseUtility utilInstance = new CaseUtility();
        try {
            Id taskId = utilInstance.createTask(handshakeInstance.newCase.ContactId, handshakeInstance.newCase.Id
                                               ,'Initial Case Creation', 'Completed', handshakeInstance.newCase.Priority
                                               , sf_Constants.EMAILUS_CASE_ORIGIN, 'Inbound', handshakeInstance.newCase.Summary__c
                                               , sf_Constants.TASK_CUSTOMER_ACTIVITY_RECORDTYPENAME);
            Id emailMessageId = utilInstance.createEmailMessage(taskId, handshakeInstance.newCase.Id, handshakeInstance.newCase.subject
                                                              , handshakeInstance.newContact.Email, handshakeInstance.newCase.Summary__c
                                                              , handshakeInstance.newCase.Summary__c, true, '0'
                                                              , sf_ContactUsHelperCtrl.DEFAULT_EMAIL_FROM_NAME);
            // CREATE AND CLEAN UP ATTACHMENTS
            gcr_helperClass.manageAttachment(srtAttachmentId, emailMessageId, true);
            if (handshakeInstance.newCase != null && String.isNotEmpty(handshakeInstance.newCase.Id)) {
                handshakeInstance.newCase = [ SELECT Id, CaseNumber, Reason FROM Case WHERE Id = :handshakeInstance.newCase.Id ];
            }
            isMain = false;
            isSelectAdd = false;
            isCaseSubmit = true;
            // LEGACY: CALL FUTURE METHOD TO CREATE PRODUCT HISTORY RECORDS
            if (mProdRetStatus != null && !mProdRetStatus.isEmpty()) {
                CaseUtility.populateProductReturnStatus(mProdRetStatus);
            }
        } catch (Exception caughtException) {
            Database.rollback(dbSavePoint);
            // CLEAN UP ATTACHMENTS
            gcr_helperClass.manageAttachment(srtAttachmentId, handshakeInstance.newCase.Id, false);
            // SHOW ERROR MESSAGE ON PAGE
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL
                                                     , GCRGenericProperties__c.getInstance('GCR_FATAL_ERRMSG').value__c));
        }
    }
    
    /*
     * @author:         Accenture
     * @date:           27/06/2016
     * @description:    CREATE TO USE LEGACY CASE CREATION PROCESS
     * @param:          none 
     * @return:         Map<String, String>
     */
    private Map<String, String> createReasonMap() {
        Map <String, String> retVal = new Map <String, String>();
        retVal.put ('', '0'); //just in case :)
        retVal.put (chlContentRec.EmailReason1__c, '1');
        retVal.put (chlContentRec.EmailReason2__c, '2');
        retVal.put (chlContentRec.EmailReason3__c, '3');
        retVal.put (chlContentRec.EmailReason4__c, '4');
        retVal.put (chlContentRec.EmailReason5__c, '5');
        retVal.put (chlContentRec.EmailReason6__c, '6');
        return retVal;
    }
    
    /*
     * @author:         Accenture
     * @date:           27/06/2016
     * @description:    CREATION OF VALIDATION MAP FOR SERVER SIDE FIELD VALIDATIONS
     * @param:          none 
     * @return:         void
     */
    private void createValidationMap() {
        handshakeInstance.mValidationMap.put('caseReasonField', false);
        handshakeInstance.mValidationMap.put('caseDescField', false);
        handshakeInstance.mValidationMap.put('contactFirstName', false);
        handshakeInstance.mValidationMap.put('contactLastName', false);
        handshakeInstance.mValidationMap.put('contactEmail', false);
        handshakeInstance.mValidationMap.put('contactAddressLine1', false);
        handshakeInstance.mValidationMap.put('contactAddressZipCode', false);
        handshakeInstance.mValidationMap.put('contactAddressCity', false);
        handshakeInstance.mValidationMap.put('contactAddressCounty', false);
        handshakeInstance.mValidationMap.put('contactAddressCountry', false);
        handshakeInstance.mValidationMap.put('contactPhone', false);
        //handshakeInstance.mValidationMap.put('productCode', false);
        handshakeInstance.mValidationMap.put('productExpiryDate', false);
        handshakeInstance.mValidationMap.put('prodUsedBefore', false);
        handshakeInstance.mValidationMap.put('stillHaveProd', false);
    }
    
    /*
     * @author:         Accenture
     * @date:           27/06/2016
     * @description:    Save ATTACHMENT
     * @param:          none 
     * @return:         void
     */
    public void saveAttachment() {
        if (String.isNotEmpty(attachmentName)) {
            lAttachmentName.add(attachmentName.substring(attachmentName.lastIndexOf('\\') + 1));
        }
    }
    
    /*
     * @author:         Accenture
     * @date:           27/06/2016
     * @description:    REMOVE ATTACHMENT
     * @param:          none 
     * @return:         void
     */
    public void removeAttachment() {
        lAttachmentName.remove(Integer.valueOf(remAttachmentIndex));
        if (String.isNotEmpty(srtAttachmentId)) {
            String attachId = srtAttachmentId.split(',').get(Integer.valueOf(remAttachmentIndex));
            delete new Attachment(Id = attachId);
            srtAttachmentId = srtAttachmentId.replace(attachId + ',', '');
        }
    }
    
    /*
     * @author:         Accenture
     * @date:           27/06/2016
     * @description:    ACTION METHOD FOR BACK BUTTON WITHOUT ADDRESS SELECTION
     * @param:          none 
     * @return:         void
     */
    public void backForAddressChange() {
        isMain = true;
        isSelectAdd = false;
        isCaseSubmit = false;
    }
    
    /*
     * @author:         Accenture
     * @date:           27/06/2016
     * @description:    REMOTE ACTION METHOD EMAIL VALIDATION VIA STRIKE IRON
     * @param:          String 
     * @return:         String
     */
    @RemoteAction
    global static String validateEmail(String strEmailAddress) {
        return gcr_helperClass.validateEmailAddressString(strEmailAddress);
    }
    
    /*
     * @author:         Accenture
     * @date:           27/06/2016
     * @description:    REMOTE ACTION METHOD FOR ATTACHMENT CREATION
     * @param:          String, String, String, String
     * @return:         String
     */
    @RemoteAction
    global static String createAttachment(String strAttId, String strAttName, String strAttType, String strAttBody) {
        String retVal = null;
        if (String.isNotEmpty(strAttBody)) {
            Attachment attach = gcr_helperClass.getAttachment(strAttId, strAttName, strAttType, strAttBody);
            retVal = attach.Id;
        }
        return retVal;
    }
}