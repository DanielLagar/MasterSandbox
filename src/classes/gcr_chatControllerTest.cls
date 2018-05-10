/*
* @author: 		 Accenture
* @date: 		 30/08/2016
* @description:  Test class for chat component Controller
* CHANGE LOG
* DATE				NAME				CHANGE DESCRIPTION
* 30/08/2016		Accenture			Initial Draft
* 19/10/2016		Accenture			Chat page name is retrieved from custom setting (config) instead of
* 										hardcoded value in redirectToUnauthenticatedChatPageTest() and 
*										redirectToAuthenticatedChatPageTest test methods.
*/
@isTest(SeeAllData = false)
public class gcr_chatControllerTest {
	/*
     * @author: 		Accenture
	 * @date: 		 	30/08/2016
	 * @description:  	METHOD TO SETUP TEST DATA
     */
    @testSetup
    static void setupTestData() {
        gcr_TestUtility.createCustomSettings();
        String brandConLangId = gcr_TestUtility.createContactUsObjectData();
        sObject careHub = gcr_TestUtility.getCareHubData(brandConLangId);
        Database.insert(careHub, true);
        List<sObject> lCareHubChannels = gcr_TestUtility.getCareHubChannels(careHub.Id);
        Database.insert(lCareHubChannels, true);
    }

	/*
     * @author: 		Accenture
	 * @date: 		 	30/08/2016
	 * @description:  	TEST METHOD FOR INITILIZE CHAT
     */
    static testmethod void initializeChatTest() {
        List<GCRCareHub__c> lCareHub = [ SELECT Id
                                              , GCRLabelNext__c
                                              , GCRLabelPrevious__c
                                         FROM GCRCareHub__c
                                         WHERE Brand__c = :gcr_TestUtility.DEFAULT_BRAND
                                             AND CountryIsoCode__c = :gcr_TestUtility.DEFAULT_COUNTRY_ISO 
                                             AND LanguageIsoCode__c = :gcr_TestUtility.DEFAULT_LANGUAGE_ISO ];
        Map<String, Schema.RecordTypeInfo> mRecordTypeInfoByName = GCRChannelContent__c.getSObjectType().getDescribe().getRecordTypeInfosByName();
        GCRChannelContent__c chatContent = [ SELECT Id 
                                             FROM GCRChannelContent__c
                                             WHERE CareHub__c = :lCareHub.get(0).Id
                                            	AND RecordTypeId = :mRecordTypeInfoByName.get('chat').getRecordTypeId() ];
        // INITILIZE CHAT CONTROLLER
        gcr_chatController chatController = new gcr_chatController();
        chatController.chlContentId = chatContent.Id;
        Test.startTest();
        Boolean tempBoolean = chatController.tempBoolean;
        Test.stopTest();
        SYSTEM.assert(chatController.chatChannelContent.CareHub__r.CountryIsoCode__c.equalsIgnoreCase(gcr_TestUtility.DEFAULT_COUNTRY_ISO));
        SYSTEM.assert(chatController.chatChannelContent.CareHub__r.LanguageIsoCode__c.equalsIgnoreCase(gcr_TestUtility.DEFAULT_LANGUAGE_ISO));
        SYSTEM.assert(chatController.chatChannelContent.CareHub__r.Brand__c.equalsIgnoreCase(gcr_TestUtility.DEFAULT_BRAND));
        SYSTEM.assert(chatController.isBusinessHrsActive);
    }
    
	/*
     * @author: 		Accenture
	 * @date: 		 	30/08/2016
	 * @description:  	TEST METHOD FOR REDIRECTING TO AUTHENTICATED CHAT PAGE
     */
    static testmethod void redirectToAuthenticatedChatPageTest() {
        List<GCRCareHub__c> lCareHub = [ SELECT Id
                                              , GCRLabelNext__c
                                              , GCRLabelPrevious__c
                                         FROM GCRCareHub__c
                                         WHERE Brand__c = :gcr_TestUtility.DEFAULT_BRAND
                                             AND CountryIsoCode__c = :gcr_TestUtility.DEFAULT_COUNTRY_ISO 
                                             AND LanguageIsoCode__c = :gcr_TestUtility.DEFAULT_LANGUAGE_ISO ];
        Map<String, Schema.RecordTypeInfo> mRecordTypeInfoByName = GCRChannelContent__c.getSObjectType().getDescribe().getRecordTypeInfosByName();
        GCRChannelContent__c chatContent = [ SELECT Id
                                            	  , CareHub__r.Brand__c
                                            	  , CareHub__r.CountryIsoCode__c
                                            	  , CareHub__r.LanguageIsoCode__c
                                             FROM GCRChannelContent__c
                                             WHERE CareHub__c = :lCareHub.get(0).Id
                                            	AND RecordTypeId = :mRecordTypeInfoByName.get('chat').getRecordTypeId() ];
        // INITILIZE CHAT CONTROLLER
        gcr_chatController chatController = new gcr_chatController();
        chatController.chlContentId = chatContent.Id;
        Boolean tempBoolean = chatController.tempBoolean;
        // SETUP CONTROLLER DATA AS IT IS COMING FROM CHAT PRECHAT PAGE
        chatController.isButtonAvailable = true;
        chatController.isTNCAgreed = true;
		chatController.isRightToLeft = true;
        chatController.strFirstName = 'fName';
		chatController.strLastName = 'lName';
		chatController.strEmail = 'fname.lname@email.com';
        
        PageReference pageRef = new PageReference('/apex/gcr_careHubLanding?country=us&language=en&brand=tide');
		Test.setCurrentPage(pageRef);
        
        Test.startTest();
        chatController.retrieveChatPageUrl();
        Test.stopTest();

        SYSTEM.assertEquals('/apex/gcr_chatRedirectPage?'
                            + 'fname=fName&lname=lName&email=' + EncodingUtil.urlEncode('fname.lname@email.com', 'UTF-8')
							+ '&brand=' + chatController.chatChannelContent.CareHub__r.Brand__c
                            + '&country=' + chatController.chatChannelContent.CareHub__r.CountryIsoCode__c
                            + '&language=' + chatController.chatChannelContent.CareHub__r.LanguageIsoCode__c
                            + '&type=Carehub'
                          , chatController.chatPageUrl);
    }
    
	/*
     * @author: 		Accenture
	 * @date: 		 	30/08/2016
	 * @description:  	TEST METHOD FOR REDIRECTING TO SITE (UNAUTHENTICATED) CHAT PAGE
     */
    static testmethod void redirectToUnauthenticatedChatPageTest() {
        List<GCRCareHub__c> lCareHub = [ SELECT Id
                                              , GCRLabelNext__c
                                              , GCRLabelPrevious__c
                                         FROM GCRCareHub__c
                                         WHERE Brand__c = :gcr_TestUtility.DEFAULT_BRAND
                                             AND CountryIsoCode__c = :gcr_TestUtility.DEFAULT_COUNTRY_ISO 
                                             AND LanguageIsoCode__c = :gcr_TestUtility.DEFAULT_LANGUAGE_ISO ];
        Map<String, Schema.RecordTypeInfo> mRecordTypeInfoByName = GCRChannelContent__c.getSObjectType().getDescribe().getRecordTypeInfosByName();
        GCRChannelContent__c chatContent = [ SELECT Id
                                            	  , CareHub__r.Brand__c
                                            	  , CareHub__r.CountryIsoCode__c
                                            	  , CareHub__r.LanguageIsoCode__c
                                             FROM GCRChannelContent__c
                                             WHERE CareHub__c = :lCareHub.get(0).Id
                                            	AND RecordTypeId = :mRecordTypeInfoByName.get('chat').getRecordTypeId() ];
        // INITILIZE CHAT CONTROLLER
        gcr_chatController chatController = new gcr_chatController();
        chatController.chlContentId = chatContent.Id;
        Boolean tempBoolean = chatController.tempBoolean;
        // SETUP CONTROLLER DATA AS IT IS COMING FROM CHAT PRECHAT PAGE
        chatController.strFirstName = 'fName';
		chatController.strLastName = 'lName';
		chatController.strEmail = 'fname.lname@email.com';
        
        PageReference pageRef = new PageReference('https://pgconsumersupport.force.com/carehub?country=us&language=en&brand=tide');
		Test.setCurrentPage(pageRef);
        
        Test.startTest();
        chatController.retrieveChatPageUrl();
        Test.stopTest();
        SYSTEM.assertEquals('/apex/gcr_chatRedirectPage?'
                            + 'fname=fName&lname=lName&email=' + EncodingUtil.urlEncode('fname.lname@email.com', 'UTF-8')
                            + '&brand=' + chatController.chatChannelContent.CareHub__r.Brand__c
                            + '&country=' + chatController.chatChannelContent.CareHub__r.CountryIsoCode__c
                            + '&language=' + chatController.chatChannelContent.CareHub__r.LanguageIsoCode__c
                            + '&type=Carehub'
                          , chatController.chatPageUrl);
        chatController.disableSubmit();
        SYSTEM.assert(chatController.isSubmitDisable);
    }
    
	/*
     * @author: 		Accenture
	 * @date: 		 	30/08/2016
	 * @description:  	TEST METHOD TO VALIDATE EMAIL VIA STRIKE IRON
     */
    static testmethod void validateEmailTest() {
        Test.setMock(HttpCalloutMock.class, new sf_MockStrikeIronEmailValidationImpl());
        Test.startTest();
        Boolean retVal = gcr_chatController.validateEmail('test@test.com');
		Test.stopTest();
        SYSTEM.assert(!retVal);
    }
    
	/*
     * @author: 		Accenture
	 * @date: 		 	30/08/2016
	 * @description:  	TEST METHOD TO VALIDATE EMAIL VIA STRIKE IRON
	 * TODO: LOOK TO COVER ALL SCENARIOS
     */
    static testmethod void redirectToChatTest() {
		GCRChannelContent__c channelContent = [ SELECT Id 
                                               		 , CareHub__r.Brand__c
                                               		 , CareHub__r.CountryIsoCode__c
                                               		 , CareHub__r.LanguageIsoCode__c
                                                FROM GCRChannelContent__c WHERE RecordType.Name = 'chat' ];
        ApexPages.currentPage().getParameters().put('brand', channelContent.CareHub__r.Brand__c);
        ApexPages.currentPage().getParameters().put('country', channelContent.CareHub__r.CountryIsoCode__c);
        ApexPages.currentPage().getParameters().put('language', channelContent.CareHub__r.LanguageIsoCode__c);
        ApexPages.currentPage().getParameters().put('fname', 'fname');
        ApexPages.currentPage().getParameters().put('lname', 'lname');
        ApexPages.currentPage().getParameters().put('email', 'fname.lname@gmail.com');

        gcr_chatRedirectController chatRedirect = new gcr_chatRedirectController();
        SYSTEM.assert(chatRedirect.getChatData());
    }
}