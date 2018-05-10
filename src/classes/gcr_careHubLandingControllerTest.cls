/*
* @author: 		 Accenture
* @date: 		 30/08/2016
* @description:  Test class for care hub landing page Controller
* CHANGE LOG
* DATE			NAME				CHANGE DESCRIPTION
* 30/08/2016	Accenture			Initial Draft
*/
@isTest(SeeAllData = false)
public class gcr_careHubLandingControllerTest {
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
	 * @description:  	LANDING PAGE CONSTRUCTOR TEST
     */
    static testmethod void landingPageConstructorTest() {
        // SETUP PAGE PARAMETERS
        ApexPages.currentPage().getParameters().put('language', gcr_TestUtility.DEFAULT_LANGUAGE_ISO);
        ApexPages.currentPage().getParameters().put('brand', gcr_TestUtility.DEFAULT_BRAND);
        ApexPages.currentPage().getParameters().put('country', gcr_TestUtility.DEFAULT_COUNTRY_ISO);
        
        Test.startTest();
        gcr_careHubLandingController chLandingController = new gcr_careHubLandingController();
        Test.stopTest();
        SYSTEM.assert(chLandingController.handshakeInstance.lCareHub != null && chLandingController.handshakeInstance.lCareHub.size() > 0);
        SYSTEM.assert(chLandingController.handshakeInstance.lCareHub.get(0).Brand__c.equalsIgnoreCase(gcr_TestUtility.DEFAULT_BRAND));
        SYSTEM.assert(chLandingController.handshakeInstance.lCareHub.get(0).CountryIsoCode__c.equalsIgnoreCase(gcr_TestUtility.DEFAULT_COUNTRY_ISO));
        SYSTEM.assert(chLandingController.handshakeInstance.lCareHub.get(0).LanguageIsoCode__c.equalsIgnoreCase(gcr_TestUtility.DEFAULT_LANGUAGE_ISO));
        SYSTEM.assert(chLandingController.handshakeInstance.lCareHub.get(0).GCRChannelContent__r != null 
                   && chLandingController.handshakeInstance.lCareHub.get(0).GCRChannelContent__r.size() > 0);
    }
    
	/*
     * @author: 		Accenture
	 * @date: 		 	30/08/2016
	 * @description:  	LANDING PAGE CONSTRUCTOR TEST EXCEPTION SCENARIO
     */
    static testmethod void landingPageConstructorExceptionTest() {
        // SETUP PAGE PARAMETERS
        ApexPages.currentPage().getParameters().put('language', 'ar');
        ApexPages.currentPage().getParameters().put('brand', gcr_TestUtility.DEFAULT_BRAND);
        ApexPages.currentPage().getParameters().put('country', gcr_TestUtility.DEFAULT_COUNTRY_ISO);
        
        Test.startTest();
        gcr_careHubLandingController chLandingController = new gcr_careHubLandingController();
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
}