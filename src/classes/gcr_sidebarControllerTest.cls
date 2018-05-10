/*
* @author: 		 Accenture
* @date: 		 30/08/2016
* @description:  Test class for sidebar Controller
* CHANGE LOG
* DATE			NAME				CHANGE DESCRIPTION
* 30/08/2016	Accenture			Initial Draft
*/
@isTest(SeeAllData = false)
public class gcr_sidebarControllerTest {
	/*
     * @author: 		Accenture
	 * @date: 		 	30/08/2016
	 * @description:  	TEST SETUP METHOD TO SETUP TEST DATA
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
	 * @description:  	TEST METHOD TO GET ALL SIDEBAR ICONS WITH THEIR FUNCTIONALITIES
     */
    static testmethod void preparePageRecordsTest() {
		// SETUP HANDSHAKE INSTANCE
        gcr_WidgetHandshake iHandshake = new gcr_WidgetHandshake();
        iHandshake.lCareHub = [ SELECT Id
                               		 , GCRLabelNext__c
                               		 , GCRLabelPrevious__c
                                FROM GCRCareHub__c
                               	WHERE Brand__c = :gcr_TestUtility.DEFAULT_BRAND
                              		AND CountryIsoCode__c = :gcr_TestUtility.DEFAULT_COUNTRY_ISO 
                              		AND LanguageIsoCode__c = :gcr_TestUtility.DEFAULT_LANGUAGE_ISO ];
        // INITIALIZE CONTROLLER METHOD
        gcr_sidebarController sbController = new gcr_sidebarController();
        sbController.iHandshake = iHandshake;
        // TRIGGER PREPARE RECORD METHOD FROM GETTER
        Test.startTest();
        Boolean tempBoolean = sbController.controlConstructor;
        Test.stopTest();
        Integer pageSize = Integer.valueOf(GCRGenericProperties__c.getInstance('gcr_ChannelCount').value__c);
        List<GCRChannelContent__c> lChannel = [ SELECT Id
                                               		 , RecordType.Name
                                              		 , DisplayName__c
                                               	FROM GCRChannelContent__c WHERE CareHub__c = :iHandshake.lCareHub.get(0).Id ];
        if (lChannel.size() > pageSize) {
        	SYSTEM.assert(sbController.lResourceData != null && sbController.lResourceData.size() == pageSize);
        } else {
            SYSTEM.assert(sbController.lResourceData != null 
                       && sbController.lResourceData.size() > 0 
                       && sbController.lResourceData.size() <= pageSize);
        }
        SYSTEM.assert(String.isEmpty(sbController.iHandshake.gcrFunctionality));
        // CHECK MAP VALUES SET TO CORRECT DISPLAY VALUES
        for (GCRChannelContent__c eachContent :lChannel) {
			if (sbController.mDisplayName.get(eachContent.RecordType.Name) != null) {
            	SYSTEM.assert(eachContent.DisplayName__c.equalsIgnoreCase(sbController.mDisplayName.get(eachContent.RecordType.Name)));
			}
        }
    }
    
    /*
     * @author: 		Accenture
	 * @date: 		 	30/08/2016
	 * @description:  	TEST METHOD TO GET ALL SIDEBAR ICONS WITH THEIR FUNCTIONALITIES
     */
    static testmethod void preparePageRecordsErrorTest() {
		// SETUP HANDSHAKE INSTANCE
        gcr_WidgetHandshake iHandshake = new gcr_WidgetHandshake();
        iHandshake.lCareHub = [ SELECT Id
                                FROM GCRCareHub__c
                               	WHERE Brand__c = :gcr_TestUtility.DEFAULT_BRAND
                              		AND CountryIsoCode__c = :gcr_TestUtility.DEFAULT_COUNTRY_ISO 
                              		AND LanguageIsoCode__c = :gcr_TestUtility.DEFAULT_LANGUAGE_ISO ];
        // INITIALIZE CONTROLLER METHOD
        gcr_sidebarController sbController = new gcr_sidebarController();
        sbController.iHandshake = iHandshake;
        // TRIGGER PREPARE RECORD METHOD FROM GETTER
        Test.startTest();
        Boolean tempBoolean = sbController.controlConstructor;
        Test.stopTest();
        List<ApexPages.Message> lPageMessage = ApexPages.getMessages();
        Boolean messageFound = false;
        for (ApexPages.Message eachMessage :lPageMessage) {
            if(eachMessage.getSummary().contains(GCRGenericProperties__c.getInstance('GCR_FATAL_ERRMSG').value__c)) {
                messageFound = true;
            }
        }
        SYSTEM.assert(messageFound);
    }
    
    /*
     * @author: 		Accenture
	 * @date: 		 	30/08/2016
	 * @description:  	TEST METHOD TO TEST PAGINATION ON THE SIDEBAR PAGE
     */
    static testmethod void paginationTest() {
		// SETUP HANDSHAKE INSTANCE
        gcr_WidgetHandshake iHandshake = new gcr_WidgetHandshake();
        iHandshake.lCareHub = [ SELECT Id
                               		 , GCRLabelNext__c
                               		 , GCRLabelPrevious__c
                                FROM GCRCareHub__c
                               	WHERE Brand__c = :gcr_TestUtility.DEFAULT_BRAND
                              		AND CountryIsoCode__c = :gcr_TestUtility.DEFAULT_COUNTRY_ISO 
                              		AND LanguageIsoCode__c = :gcr_TestUtility.DEFAULT_LANGUAGE_ISO ];
        // INITIALIZE CONTROLLER METHOD
        gcr_sidebarController sbController = new gcr_sidebarController();
        sbController.iHandshake = iHandshake;
        // TRIGGER PREPARE RECORD METHOD FROM GETTER
        Boolean tempBoolean = sbController.controlConstructor;
        // NEXT WILL ONLY APPLICABLE IF RESOURCES ARE GREATER THAN PAGESIZE
        Boolean isNextTest = false;
        Boolean isPrvTest = false;
        Integer pageSize = Integer.valueOf(GCRGenericProperties__c.getInstance('gcr_ChannelCount').value__c);
        List<GCRChannelContent__c> lChannel = [ SELECT Id FROM GCRChannelContent__c WHERE CareHub__c = :iHandshake.lCareHub.get(0).Id ];
        if (lChannel.size() > pageSize) {
            for (GCRChannelProperties__c channelProperty :sbController.lResourceData) {
                if(channelProperty.isNext__c) isNextTest = true;
            }
            SYSTEM.assert(isNextTest);
            // GOTO NEXT PAGE
            sbController.next();
            for (GCRChannelProperties__c channelProperty :sbController.lResourceData) {
                if(channelProperty.isPrevious__c) isPrvTest = true;
            }
            SYSTEM.assert(isPrvTest);
            // GOTO PREVIOUS PAGE
            isNextTest = false;
            sbController.previous();
			for (GCRChannelProperties__c channelProperty :sbController.lResourceData) {
                if(channelProperty.isNext__c) isNextTest = true;
            }
            SYSTEM.assert(isNextTest);
        }
    }
    
	/*
     * @author: 		Accenture
	 * @date: 		 	30/08/2016
	 * @description:  	TEST METHOD TO TEST SELECTED CHANNEL
     */
    static testmethod void selectChannelTest() {
		// SETUP HANDSHAKE INSTANCE
        gcr_WidgetHandshake iHandshake = new gcr_WidgetHandshake();
        iHandshake.lCareHub = [ SELECT Id
                               		 , GCRLabelNext__c
                               		 , GCRLabelPrevious__c
                                FROM GCRCareHub__c
                               	WHERE Brand__c = :gcr_TestUtility.DEFAULT_BRAND
                              		AND CountryIsoCode__c = :gcr_TestUtility.DEFAULT_COUNTRY_ISO 
                              		AND LanguageIsoCode__c = :gcr_TestUtility.DEFAULT_LANGUAGE_ISO ];
        // INITIALIZE CONTROLLER METHOD
        gcr_sidebarController sbController = new gcr_sidebarController();
        sbController.iHandshake = iHandshake;
        // TRIGGER PREPARE RECORD METHOD FROM GETTER
        Boolean tempBoolean = sbController.controlConstructor;
        List<String> lChannel = new List<String>(GCRChannelContent__c.getSObjectType().getDescribe().getRecordTypeInfosByName().keyset());
        Test.startTest();
        sbController.selectedChannel = lChannel.get(0);
        sbController.process();
        Test.stopTest();
        SYSTEM.assert(sbController.iHandshake.gcrFunctionality.equalsIgnoreCase(lChannel.get(0)));
    }
    
	/*
     * @author: 		Accenture
	 * @date: 		 	30/08/2016
	 * @description:  	TEST METHOD TO TEST SELECTED DEFAULT CHANNEL
     */
    static testmethod void defaultChannelTest() {
		// SETUP HANDSHAKE INSTANCE
        gcr_WidgetHandshake iHandshake = new gcr_WidgetHandshake();
        iHandshake.lCareHub = [ SELECT Id
                               		 , GCRLabelNext__c
                               		 , GCRLabelPrevious__c
                                FROM GCRCareHub__c
                               	WHERE Brand__c = :gcr_TestUtility.DEFAULT_BRAND
                              		AND CountryIsoCode__c = :gcr_TestUtility.DEFAULT_COUNTRY_ISO 
                              		AND LanguageIsoCode__c = :gcr_TestUtility.DEFAULT_LANGUAGE_ISO ];
		// GET ALL CHANNELS FROM CARE HUB
        List<GCRChannelContent__c> lChannel = [ SELECT Id FROM GCRChannelContent__c WHERE CareHub__c = :iHandshake.lCareHub.get(0).Id ];
        GCRChannelContent__c channelUpdate = lChannel.get(0);
        // UPDATE DEFAULT FLAG ON CHANNEL
        channelUpdate.Default__c = true;
        Database.update(channelUpdate, true);
        channelUpdate = [ SELECT Id, RecordType.Name FROM GCRChannelContent__c WHERE Id = :channelUpdate.Id ];
        // INITIALIZE CONTROLLER METHOD
        gcr_sidebarController sbController = new gcr_sidebarController();
        sbController.iHandshake = iHandshake;
        // TRIGGER PREPARE RECORD METHOD FROM GETTER
        Test.startTest();
        Boolean tempBoolean = sbController.controlConstructor;
        Test.stopTest();
        SYSTEM.assert(sbController.iHandshake.gcrFunctionality.equalsIgnoreCase(channelUpdate.RecordType.Name));
    }
    
	/*
     * @author: 		Accenture
	 * @date: 		 	30/08/2016
	 * @description:  	TEST METHOD TO TEST DEFUALT ARTICLE VIEW
     */
    static testmethod void faqArticleViewTest() {
		// SETUP HANDSHAKE INSTANCE
        gcr_WidgetHandshake iHandshake = new gcr_WidgetHandshake();
        iHandshake.lCareHub = [ SELECT Id
                               		 , GCRLabelNext__c
                               		 , GCRLabelPrevious__c
                                FROM GCRCareHub__c
                               	WHERE Brand__c = :gcr_TestUtility.DEFAULT_BRAND
                              		AND CountryIsoCode__c = :gcr_TestUtility.DEFAULT_COUNTRY_ISO 
                              		AND LanguageIsoCode__c = :gcr_TestUtility.DEFAULT_LANGUAGE_ISO ];
		iHandshake.strKaUrlName = '/en_Us/faq/';
        // INITIALIZE CONTROLLER METHOD
        gcr_sidebarController sbController = new gcr_sidebarController();
        sbController.iHandshake = iHandshake;
        // TRIGGER PREPARE RECORD METHOD FROM GETTER
        Test.startTest();
        Boolean tempBoolean = sbController.controlConstructor;
        Test.stopTest();
        SYSTEM.assert(sbController.iHandshake.gcrFunctionality.equalsIgnoreCase('faq'));
    }
}