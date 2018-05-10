/*
* @author:       Accenture
* @date:         30/08/2016
* @description:  Test class for email us component Controller
* CHANGE LOG
* DATE          	NAME                CHANGE DESCRIPTION
* 30/08/2016    	Accenture           Initial Draft
* 21/06/2017        Accenture           WR530 - Defect fix: Crm checkbox default value to be controlled via configuration.
*/
@isTest(SeeAllData = false)
public class gcr_emailUsControllerTest {
    /*
     * @author:         Accenture
     * @date:           30/08/2016
     * @description:    TEST SETUP METHOD TO SETUP TEST DATA
     */
    @testSetup
    static void setupTestData() {
        gcr_TestUtility.createCustomSettings();
        String brandConLangId = gcr_TestUtility.createContactUsObjectData();
        sObject careHub = gcr_TestUtility.getCareHubData(brandConLangId);
        Database.insert(careHub, true);
        List<sObject> lCareHubChannels = gcr_TestUtility.getCareHubChannels(careHub.Id);
        Database.insert(lCareHubChannels, true);
        gcr_TestUtility.createProductData(120);
    }
    
    /*
     * @author:         Accenture
     * @date:           30/08/2016
     * @description:    TEST METHOD FOR INITILIZE EMAIL US COMPONENT
     */
    static testmethod void initializeEmailUsTest() {
        List<GCRCareHub__c> lCareHub = [ SELECT Id
                                              , GCRLabelNext__c
                                              , GCRLabelPrevious__c
                                              , Country__c
                                              , Brand__c
                                              , Language__c
                                         FROM GCRCareHub__c
                                         WHERE Brand__c = :gcr_TestUtility.DEFAULT_BRAND
                                             AND CountryIsoCode__c = :gcr_TestUtility.DEFAULT_COUNTRY_ISO 
                                             AND LanguageIsoCode__c = :gcr_TestUtility.DEFAULT_LANGUAGE_ISO ];
        Map<String, Schema.RecordTypeInfo> mRecordTypeInfoByName 
            = GCRChannelContent__c.getSObjectType().getDescribe().getRecordTypeInfosByName();
        GCRChannelContent__c emailContent = [ SELECT Id 
                                              FROM GCRChannelContent__c
                                              WHERE CareHub__c = :lCareHub.get(0).Id
                                                AND RecordTypeId = :mRecordTypeInfoByName.get('email us').getRecordTypeId() ];
        // INITIALIZE EMAIL US CONTROLLER AND ASSIGNE CONTENT RECORD ID
        gcr_emailUsController euController = new gcr_emailUsController();
        euController.chlContentId = emailContent.Id;
        // INITIALIZE CONTROLLER DATA
        Test.startTest();
        Boolean tempBoolean = euController.tempData;
        List<SelectOption> lReasonforWriting = euController.getLReasonForWriting();
        Test.stopTest();
        // VALIDATE DATA
        SYSTEM.assert(euController.chlContentRec.Country__c.equalsIgnoreCase(lCareHub.get(0).Country__c));
        SYSTEM.assert(euController.handshakeInstance != null);
        SYSTEM.assert(euController.handshakeInstance.newContact.Primary_Country__c.equalsIgnoreCase(lCareHub.get(0).Country__c));
        SYSTEM.assert(euController.chlContentRec.EmailReasonLabel__c.equalsIgnoreCase(euController.handshakeInstance.newCase.Reason));
        SYSTEM.assert(!euController.handshakeInstance.isProductSearch);
        SYSTEM.assert(euController.handshakeInstance.isStateMandatory);
        SYSTEM.assert(euController.handshakeInstance.isZipMandatory);
        SYSTEM.assert(lReasonforWriting != null && !lReasonforWriting.isEmpty());
        // WR530 - DEFECT FIX: INTILIZE CRM CHECKOX FROM CONFGURATION - TEST CONDITION ADDED
        SYSTEM.assert(euController.chlContentRec.crmChecked__c ? euController.handshakeInstance.newContact.Email_Opt_In__c 
                      : !euController.chlContentRec.crmChecked__c ? !euController.handshakeInstance.newContact.Email_Opt_In__c : false);
    }
    
    /*
     * @author:         Accenture
     * @date:           30/08/2016
     * @description:    TEST METHOD FOR INITILIZE EMAIL US COMPONENT
     */
    static testmethod void crmCheckboxTest() {
		List<GCRCareHub__c> lCareHub = [ SELECT Id
                                              , GCRLabelNext__c
                                              , GCRLabelPrevious__c
                                              , Country__c
                                              , Brand__c
                                              , Language__c
                                         FROM GCRCareHub__c
                                         WHERE Brand__c = :gcr_TestUtility.DEFAULT_BRAND
                                             AND CountryIsoCode__c = :gcr_TestUtility.DEFAULT_COUNTRY_ISO 
                                             AND LanguageIsoCode__c = :gcr_TestUtility.DEFAULT_LANGUAGE_ISO ];
        Map<String, Schema.RecordTypeInfo> mRecordTypeInfoByName 
            = GCRChannelContent__c.getSObjectType().getDescribe().getRecordTypeInfosByName();
        GCRChannelContent__c emailContent = [ SELECT Id 
                                              FROM GCRChannelContent__c
                                              WHERE CareHub__c = :lCareHub.get(0).Id
                                                AND RecordTypeId = :mRecordTypeInfoByName.get('email us').getRecordTypeId() ];
        // WR530 - DEFECT FIX: INTILIZE CRM CHECKOX FROM CONFGURATION
        emailContent.crmChecked__c = true;
        Database.update(emailContent);
        // INITIALIZE EMAIL US CONTROLLER AND ASSIGNE CONTENT RECORD ID
        gcr_emailUsController euController = new gcr_emailUsController();
        euController.chlContentId = emailContent.Id;
        // INITIALIZE CONTROLLER DATA
        Test.startTest();
        Boolean tempBoolean = euController.tempData;
        List<SelectOption> lReasonforWriting = euController.getLReasonForWriting();
        Test.stopTest();
        // VALIDATE CRM CHECKBOX DEFULT VALUE AVAILABLE
        SYSTEM.assert(euController.handshakeInstance.newContact.Email_Opt_In__c);
    }
    
    /*
     * @author:         Accenture
     * @date:           30/08/2016
     * @description:    TEST METHOD TO VALIDATE INPUT
     */
    static testmethod void validateNoInputTest() {
        List<GCRCareHub__c> lCareHub = [ SELECT Id
                                              , GCRLabelNext__c
                                              , GCRLabelPrevious__c
                                              , Country__c
                                              , Brand__c
                                              , Language__c
                                         FROM GCRCareHub__c
                                         WHERE Brand__c = :gcr_TestUtility.DEFAULT_BRAND
                                             AND CountryIsoCode__c = :gcr_TestUtility.DEFAULT_COUNTRY_ISO 
                                             AND LanguageIsoCode__c = :gcr_TestUtility.DEFAULT_LANGUAGE_ISO ];
        Map<String, Schema.RecordTypeInfo> mRecordTypeInfoByName 
            = GCRChannelContent__c.getSObjectType().getDescribe().getRecordTypeInfosByName();
        GCRChannelContent__c emailContent = [ SELECT Id 
                                              FROM GCRChannelContent__c
                                              WHERE CareHub__c = :lCareHub.get(0).Id
                                                AND RecordTypeId = :mRecordTypeInfoByName.get('email us').getRecordTypeId() ];
        // INITIALIZE EMAIL US CONTROLLER AND ASSIGNE CONTENT RECORD ID
        gcr_emailUsController euController = new gcr_emailUsController();
        euController.chlContentId = emailContent.Id;
        Boolean tempBoolean = euController.tempData;
        Test.startTest();
        euController.submitActionData();
        Test.stopTest();
        Boolean validationPassed = false;
        if (!euController.handshakeInstance.mValidationMap.get('caseReasonField')) {
            validationPassed = true;
        }
        if (!euController.handshakeInstance.mValidationMap.get('caseDescField')) {
            validationPassed = true;
        }
        if (!euController.handshakeInstance.mValidationMap.get('contactFirstName')) {
            validationPassed = true;
        }
        if (!euController.handshakeInstance.mValidationMap.get('contactLastName')) {
            validationPassed = true;
        }
        if (!euController.handshakeInstance.mValidationMap.get('contactEmail')) {
            validationPassed = true;
        }
        
        SYSTEM.assert(!validationPassed);
        SYSTEM.assert(!euController.isValidated);
    }
    
    /*
     * @author:         Accenture
     * @date:           30/08/2016
     * @description:    TEST METHOD TO VALIDATE INPUT
     */
    static testmethod void validateExceptRepAPrbReasonTest() {
        List<GCRCareHub__c> lCareHub = [ SELECT Id
                                              , GCRLabelNext__c
                                              , GCRLabelPrevious__c
                                              , Country__c
                                              , Brand__c
                                              , Language__c
                                         FROM GCRCareHub__c
                                         WHERE Brand__c = :gcr_TestUtility.DEFAULT_BRAND
                                             AND CountryIsoCode__c = :gcr_TestUtility.DEFAULT_COUNTRY_ISO 
                                             AND LanguageIsoCode__c = :gcr_TestUtility.DEFAULT_LANGUAGE_ISO ];
        Map<String, Schema.RecordTypeInfo> mRecordTypeInfoByName 
            = GCRChannelContent__c.getSObjectType().getDescribe().getRecordTypeInfosByName();
        GCRChannelContent__c emailContent = [ SELECT Id
                                                   , EmailReason1__c
                                              FROM GCRChannelContent__c
                                              WHERE CareHub__c = :lCareHub.get(0).Id
                                                AND RecordTypeId = :mRecordTypeInfoByName.get('email us').getRecordTypeId() ];
        // INITIALIZE EMAIL US CONTROLLER AND ASSIGNE CONTENT RECORD ID
        gcr_emailUsController euController = new gcr_emailUsController();
        euController.chlContentId = emailContent.Id;
        Boolean tempBoolean = euController.tempData;
        euController.handshakeInstance.newCase.Reason = emailContent.EmailReason1__c;
        Test.startTest();
        euController.submitActionData();
        Test.stopTest();
        Boolean validationPassed = false;
        if (!euController.handshakeInstance.mValidationMap.get('caseDescField')) {
            validationPassed = true;
        }
        if (!euController.handshakeInstance.mValidationMap.get('contactFirstName')) {
            validationPassed = true;
        }
        if (!euController.handshakeInstance.mValidationMap.get('contactLastName')) {
            validationPassed = true;
        }
        if (!euController.handshakeInstance.mValidationMap.get('contactEmail')) {
            validationPassed = true;
        }
        
        SYSTEM.assert(!validationPassed);
        SYSTEM.assert(!euController.isValidated);
    }
    
    /*
     * @author:         Accenture
     * @date:           31/08/2016
     * @description:    TEST METHOD TO VALIDATE INPUT
     */
    static testmethod void validateReportAPrbReasonTest() {
        List<GCRCareHub__c> lCareHub = [ SELECT Id
                                              , GCRLabelNext__c
                                              , GCRLabelPrevious__c
                                              , Country__c
                                              , Brand__c
                                              , Language__c
                                         FROM GCRCareHub__c
                                         WHERE Brand__c = :gcr_TestUtility.DEFAULT_BRAND
                                             AND CountryIsoCode__c = :gcr_TestUtility.DEFAULT_COUNTRY_ISO 
                                             AND LanguageIsoCode__c = :gcr_TestUtility.DEFAULT_LANGUAGE_ISO ];
        Map<String, Schema.RecordTypeInfo> mRecordTypeInfoByName 
            = GCRChannelContent__c.getSObjectType().getDescribe().getRecordTypeInfosByName();
        GCRChannelContent__c emailContent = [ SELECT Id
                                                  , EmailReason4__c
                                              FROM GCRChannelContent__c
                                              WHERE CareHub__c = :lCareHub.get(0).Id
                                                AND RecordTypeId = :mRecordTypeInfoByName.get('email us').getRecordTypeId() ];
        // INITIALIZE EMAIL US CONTROLLER AND ASSIGNE CONTENT RECORD ID
        gcr_emailUsController euController = new gcr_emailUsController();
        euController.chlContentId = emailContent.Id;
        Boolean tempBoolean = euController.tempData;
        euController.handshakeInstance.newCase.Reason = emailContent.EmailReason4__c;

        Test.startTest();
        gcr_emailUsPrbController eupController = new gcr_emailUsPrbController();
        eupController.chlContentRec = euController.chlContentRec;
        eupController.iHandshake = euController.handshakeInstance;
        eupController.iHandshake.isProductSearch = true;
        List<SelectOption> lCountry = eupController.lCountry;
        eupController.strProdSearch = 'Tide';
        List<Id> lFixedResult = new List<Id>();
        for(sObject eachsObject :[ SELECT Id FROM Local_Product__c LIMIT 100 ]) {
            lFixedResult.add(eachsObject.Id);
        }
        
        Test.setFixedSearchResults(lFixedResult);
        Integer iterator = 0;
        while (iterator < 3) {
            eupController.searchProducts();
            sObject eachSobject = eupController.lProduct.get(iterator);
            eupController.selectedProduct = eachSobject.Id;
            eupController.actionSelectProduct();
            iterator++;
        }
        // ENTER CORRECT EXPIRY DATE FOR ONE AND WRONG DATE FORMAT FOR ANOTHER
        eupController.iHandshake.lCaseProduct.get(0).expiryDate = '12/10/2012';
        eupController.iHandshake.lCaseProduct.get(1).expiryDate = '20/10/2012';
        eupController.selectedProduct = '0';
        eupController.actionRemoveProduct();
        
        euController.submitActionData();
        Test.stopTest();
        Boolean validationPassed = false;
        if (!euController.handshakeInstance.mValidationMap.get('caseDescField')) {
            validationPassed = true;
        }
        if (!euController.handshakeInstance.mValidationMap.get('contactFirstName')) {
            validationPassed = true;
        }
        if (!euController.handshakeInstance.mValidationMap.get('contactLastName')) {
            validationPassed = true;
        }
        if (!euController.handshakeInstance.mValidationMap.get('contactEmail')) {
            validationPassed = true;
        }
        if (!euController.handshakeInstance.mValidationMap.get('contactAddressLine1')) {
            validationPassed = true;
        }
        if (!euController.handshakeInstance.mValidationMap.get('contactAddressZipCode')) {
            validationPassed = true;
        }
        if (!euController.handshakeInstance.mValidationMap.get('contactAddressCity')) {
            validationPassed = true;
        }
        if (!euController.handshakeInstance.mValidationMap.get('contactAddressCounty')) {
            validationPassed = true;
        }
        
        SYSTEM.assert(!validationPassed);
        SYSTEM.assert(!euController.isValidated);
    }
    
    /*
     * @author:         Accenture
     * @date:           31/08/2016
     * @description:    TEST METHOD TO VALIDATE INPUT
     */
    static testmethod void validateEmailData() {
        List<GCRCareHub__c> lCareHub = [ SELECT Id
                                              , GCRLabelNext__c
                                              , GCRLabelPrevious__c
                                              , Country__c
                                              , Brand__c
                                              , Language__c
                                         FROM GCRCareHub__c
                                         WHERE Brand__c = :gcr_TestUtility.DEFAULT_BRAND
                                             AND CountryIsoCode__c = :gcr_TestUtility.DEFAULT_COUNTRY_ISO 
                                             AND LanguageIsoCode__c = :gcr_TestUtility.DEFAULT_LANGUAGE_ISO ];
        Map<String, Schema.RecordTypeInfo> mRecordTypeInfoByName 
            = GCRChannelContent__c.getSObjectType().getDescribe().getRecordTypeInfosByName();
        GCRChannelContent__c emailContent = [ SELECT Id
                                                  , EmailReason4__c
                                              FROM GCRChannelContent__c
                                              WHERE CareHub__c = :lCareHub.get(0).Id
                                                AND RecordTypeId = :mRecordTypeInfoByName.get('email us').getRecordTypeId() ];
        // INITIALIZE EMAIL US CONTROLLER AND ASSIGNE CONTENT RECORD ID
        gcr_emailUsController euController = new gcr_emailUsController();
        euController.chlContentId = emailContent.Id;
        Boolean tempBoolean = euController.tempData;
        euController.handshakeInstance.newCase.Reason = emailContent.EmailReason4__c;
        euController.caseDescription = 'Case Summary';
        euController.handshakeInstance.newContact.FirstName = 'fname';
        euController.handshakeInstance.newContact.LastName = 'lname';
        euController.handshakeInstance.newContact.Email = 'test@gmail.com';
        // SETUP MOCK CLASS FOR TESTING
        Test.setMock(HttpCalloutMock.class, new sf_MockStrikeIronEmailValidationImpl());
        Test.startTest();
        euController.submitActionData();
        Test.stopTest();
        Boolean validationPassed = false;
        if (!euController.handshakeInstance.mValidationMap.get('caseDescField')) {
            validationPassed = true;
        }
        if (!euController.handshakeInstance.mValidationMap.get('contactFirstName')) {
            validationPassed = true;
        }
        if (!euController.handshakeInstance.mValidationMap.get('contactLastName')) {
            validationPassed = true;
        }
        
        SYSTEM.assert(validationPassed);
        SYSTEM.assert(!euController.isValidated);
        SYSTEM.assert(euController.isEmailFormat);
        SYSTEM.assert(!euController.isEmailValid);
    }
    
    /*
     * @author:         Accenture
     * @date:           31/08/2016
     * @description:    TEST METHOD TO VALIDATE INPUT
     */
    static testmethod void submitCaseWithoutProduct() {
        List<GCRCareHub__c> lCareHub = [ SELECT Id
                                              , GCRLabelNext__c
                                              , GCRLabelPrevious__c
                                              , Country__c
                                              , Brand__c
                                              , Language__c
                                         FROM GCRCareHub__c
                                         WHERE Brand__c = :gcr_TestUtility.DEFAULT_BRAND
                                             AND CountryIsoCode__c = :gcr_TestUtility.DEFAULT_COUNTRY_ISO 
                                             AND LanguageIsoCode__c = :gcr_TestUtility.DEFAULT_LANGUAGE_ISO ];
        Map<String, Schema.RecordTypeInfo> mRecordTypeInfoByName 
            = GCRChannelContent__c.getSObjectType().getDescribe().getRecordTypeInfosByName();
        GCRChannelContent__c emailContent = [ SELECT Id
                                                  , EmailReason4__c
                                              FROM GCRChannelContent__c
                                              WHERE CareHub__c = :lCareHub.get(0).Id
                                                AND RecordTypeId = :mRecordTypeInfoByName.get('email us').getRecordTypeId() ];
        // WR530 - DEFECT FIX: INTILIZE CRM CHECKOX FROM CONFGURATION
        emailContent.crmChecked__c = true;
        Database.update(emailContent);
        // INITIALIZE EMAIL US CONTROLLER AND ASSIGNE CONTENT RECORD ID
        gcr_emailUsController euController = new gcr_emailUsController();
        euController.chlContentId = emailContent.Id;
        Boolean tempBoolean = euController.tempData;
        euController.handshakeInstance.newCase.Reason = emailContent.EmailReason4__c;
        euController.caseDescription = 'Case Summary';
        euController.handshakeInstance.newContact.FirstName = 'fname';
        euController.handshakeInstance.newContact.LastName = 'lname';
        euController.handshakeInstance.newContact.Email = 'test.data@gmail.com';
        euController.handshakeInstance.newContact.Primary_Address_Line_1__c = 'Address Line 1';
        euController.handshakeInstance.newContact.Primary_Postal_Code__c = 'NE59HN';
        euController.handshakeInstance.newContact.Primary_City__c = 'Newcastle';
        euController.handshakeInstance.newContact.Primary_State_Province__c = 'Tyne and Wear';
        euController.handshakeInstance.newContact.Primary_Country__c = 'United Kingdom';
        // SETUP MOCK CLASS FOR TESTING
        Test.setMock(HttpCalloutMock.class, new gcr_mockApiClass.gcr_strikeIronMock());
        Test.startTest();
        euController.submitActionData();
        Test.stopTest();
        
        List<Contact> lContact = [ SELECT Id, Email_Opt_In__c FROM Contact WHERE Email = 'test.data@gmail.com' ];
        SYSTEM.assert(euController.isValidated);
        SYSTEM.assert(euController.isEmailFormat);
        SYSTEM.assert(euController.isEmailValid);
        SYSTEM.assert(lContact.size() == 1);
        // WR530 - DEFECT FIX: INTILIZE CRM CHECKOX FROM CONFGURATION
        SYSTEM.assert(lContact.get(0).Email_Opt_In__c);
        SYSTEM.assert([ SELECT Id FROM Case WHERE ContactId = :lContact.get(0).Id ].size() == 1);
    }
    
    /*
     * @author:         Accenture
     * @date:           31/08/2016
     * @description:    TEST METHOD TO VALIDATE INPUT
     */
    static testmethod void submitCaseWithProduct() {
        List<GCRCareHub__c> lCareHub = [ SELECT Id
                                              , GCRLabelNext__c
                                              , GCRLabelPrevious__c
                                              , Country__c
                                              , Brand__c
                                              , Language__c
                                         FROM GCRCareHub__c
                                         WHERE Brand__c = :gcr_TestUtility.DEFAULT_BRAND
                                             AND CountryIsoCode__c = :gcr_TestUtility.DEFAULT_COUNTRY_ISO 
                                             AND LanguageIsoCode__c = :gcr_TestUtility.DEFAULT_LANGUAGE_ISO ];
        Map<String, Schema.RecordTypeInfo> mRecordTypeInfoByName 
            = GCRChannelContent__c.getSObjectType().getDescribe().getRecordTypeInfosByName();
        GCRChannelContent__c emailContent = [ SELECT Id
                                                  , EmailReason4__c
                                              FROM GCRChannelContent__c
                                              WHERE CareHub__c = :lCareHub.get(0).Id
                                                AND RecordTypeId = :mRecordTypeInfoByName.get('email us').getRecordTypeId() ];
        // INITIALIZE EMAIL US CONTROLLER AND ASSIGNE CONTENT RECORD ID
        gcr_emailUsController euController = new gcr_emailUsController();
        euController.chlContentId = emailContent.Id;
        Boolean tempBoolean = euController.tempData;
        euController.handshakeInstance.newCase.Reason = emailContent.EmailReason4__c;
        euController.caseDescription = 'Case Summary';
        euController.handshakeInstance.newContact.FirstName = 'fname';
        euController.handshakeInstance.newContact.LastName = 'lname';
        euController.handshakeInstance.newContact.Email = 'test.data@gmail.com';
        euController.handshakeInstance.newContact.Primary_Address_Line_1__c = 'Address Line 1';
        euController.handshakeInstance.newContact.Primary_Postal_Code__c = 'NE55HN';
        euController.handshakeInstance.newContact.Primary_City__c = 'Newcastle';
        euController.handshakeInstance.newContact.Primary_State_Province__c = 'Tyne and Wear';
        euController.handshakeInstance.newContact.Primary_Country__c = 'United Kingdom';
        // SETUP DATA FOR SELECTED PRODUCTS
        gcr_emailUsPrbController eupController = new gcr_emailUsPrbController();
        eupController.chlContentRec = euController.chlContentRec;
        eupController.iHandshake = euController.handshakeInstance;
        eupController.iHandshake.isProductSearch = true;
        List<SelectOption> lCountry = eupController.lCountry;
        eupController.strProdSearch = 'Tide';
        List<Id> lFixedResult = new List<Id>();
        for(sObject eachsObject :[ SELECT Id FROM Local_Product__c LIMIT 100 ]) {
            lFixedResult.add(eachsObject.Id);
        }
        eupController.searchProducts();
        eupController.next();
        eupController.firstPage();
        eupController.next();
        eupController.previous();
        eupController.next();
        eupController.intCurrentPage = 4;
        eupController.displaySelectedPage();
        eupController.next();
        eupController.previous();
        //eupController.lastPage();
        eupController.getLNumProdOption();
        eupController.getLStillHaveProd();
        eupController.getLProdUsed();
        eupController.changeCountry();
        
        Test.setFixedSearchResults(lFixedResult);
        Integer iterator = 0;
        while (iterator < 3) {
            eupController.searchProducts();
            sObject eachSobject = eupController.lProduct.get(iterator);
            eupController.selectedProduct = eachSobject.Id;
            eupController.actionSelectProduct();
            iterator++;
        }
        eupController.iHandshake.lCaseProduct.get(0).stillHaveProd = 'No';
        eupController.iHandshake.lCaseProduct.get(0).usedBefore = 'No';
        eupController.iHandshake.lCaseProduct.get(1).stillHaveProd = 'Yes';
        eupController.iHandshake.lCaseProduct.get(1).usedBefore = 'No';
        eupController.iHandshake.lCaseProduct.get(2).stillHaveProd = 'N0';
        eupController.iHandshake.lCaseProduct.get(2).usedBefore = 'Yes';
        // SETUP MOCK CLASS FOR TESTING
        Test.setMock(HttpCalloutMock.class, new gcr_mockApiClass.gcr_strikeIronMock());
        Test.startTest();
        euController.submitActionData();
        euController.selectedAddress = 'suggested';
        euController.continueAddressSel();
        Test.stopTest();
        
        List<Contact> lContact = [ SELECT Id FROM Contact WHERE Email = 'test.data@gmail.com' ];
        SYSTEM.assert(euController.isValidated);
        SYSTEM.assert(euController.isEmailFormat);
        SYSTEM.assert(euController.isEmailValid);
        SYSTEM.assert(lContact.size() == 1);
        SYSTEM.assert([ SELECT Id FROM Case WHERE ContactId = :lContact.get(0).Id ].size() == 1);
        eupController.isActionMethod();
    }
    
    /*
     * @author:         Accenture
     * @date:           01/09/2016
     * @description:    TEST METHOD TO TEST CREATE ATTACHMENT
     */
    static testmethod void createAttachmentTest() {
        String attachmentId = gcr_emailUsController.createAttachment('', 'attachedFile', 'application/pdf', 'bodydataforpdffilefistiter');
        gcr_emailUsController.createAttachment(attachmentId, 'attachedFile', 'application/pdf', 'bodydataforpdffilefistiter');
        SYSTEM.assert([SELECT Id FROM Attachment WHERE Id = :attachmentId ].size() > 0);
    }
}