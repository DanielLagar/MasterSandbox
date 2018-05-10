/*
* @author:       Accenture
* @date:         25/01/2017
* @description:  Controller class of care hub sitemap index
* DATE              NAME                CHANGE DESCRIPTION
* 25/01/2017       Accenture           Initial Draft
*/
@isTest(SeeAllData = false)
public class gcr_careHubSitemapIndexControllerTest {
    /*
     * @author:         Accenture
     * @date:           25/01/2017
     * @description:    TEST SETUP METHOD TO SETUP TEST DATA
     */
    @testSetup
    static void setupTestData() {
        gcr_TestUtility.createCustomSettings();
        String brandConLangId = gcr_TestUtility.createContactUsObjectData();
        String brandConLangStdId = gcr_TestUtility.createContactUsObjectStdData();
        
        List<sObject> lCareHub = new List<sObject>();
        lCareHub.add(gcr_TestUtility.getCareHubData(brandConLangId));
        lCareHub.add(gcr_TestUtility.getCareHubData(brandConLangStdId));
        Database.insert(lCareHub, true);
        
        List<GCRChannelContent__c> lCareHubChannels = gcr_TestUtility.getCareHubChannels(lCareHub.get(0).Id);
        lCareHubChannels.addAll((List<GCRChannelContent__c>) gcr_TestUtility.getCareHubChannels(lCareHub.get(1).Id));
        Database.insert(lCareHubChannels, true);
    }
    
	/*
     * @author: 		Accenture
	 * @date: 		 	23/01/2017
	 * @description:  	TEST METHOD TO TEST SITE MAP WITH ALL ARTICLE URLs
     */
    static testmethod void allSitemapTest() {
        // CREATE EXPECTED DATA
        Set<String> sExpected = new Set<String>();
        sExpected.add('gcr_careHubSiteMap?brand=' + gcr_TestUtility.DEFAULT_BRAND + '&amp;country='
                    + gcr_TestUtility.DEFAULT_COUNTRY_ISO + '&amp;language=' + gcr_TestUtility.DEFAULT_LANGUAGE_ISO);
        sExpected.add('gcr_careHubSiteMap?brand=' + gcr_TestUtility.BRAND_DATA + '&amp;country='
                    + gcr_TestUtility.COUNTRY_ISO + '&amp;language=' + gcr_TestUtility.LANGUAGE_ISO);
        // BEGIN TEST
        Test.startTest();
        gcr_careHubSitemapIndexController controller = new gcr_careHubSitemapIndexController();
        Test.stopTest();
        for (String eachUrl :sExpected) {
            SYSTEM.assert(controller.mSitemaps.keySet().contains(eachUrl));
        }
    }
    
	/*
     * @author: 		Accenture
	 * @date: 		 	23/01/2017
	 * @description:  	TEST METHOD TO TEST SITE MAP WITH ALL ARTICLE URLs
     */
    static testmethod void sitemapNoChannelTest() {
        // REMOVE ALL FAQ CHANNEL CONTENT
        List<GCRChannelContent__c> lChCont = [ SELECT Id FROM GCRChannelContent__c WHERE RecordType.Name = 'faq' ];
        Database.delete(lChCont);
        // BEGIN TEST
        Test.startTest();
        gcr_careHubSitemapIndexController controller = new gcr_careHubSitemapIndexController();
        Test.stopTest();
		SYSTEM.assert(controller.mSitemaps == null || (controller.mSitemaps != null && controller.mSitemaps.isEmpty()));
    }
}