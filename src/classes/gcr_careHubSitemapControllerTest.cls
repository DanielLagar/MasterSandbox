/*
* @author:       Accenture
* @date:         16/01/2017
* @description:  Controller class of care hub sitemap
* DATE              NAME                CHANGE DESCRIPTION
* 16/01/2017       Accenture           Initial Draft
*/
@isTest(SeeAllData = false)
public class gcr_careHubSitemapControllerTest {
    /*
     * @author:         Accenture
     * @date:           16/01/2017
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
    static testmethod void allArticleTest() {
        // CREATE ARTICLE DATA
        List<KnowledgeArticleVersion> lArticle = gcr_TestUtility.createArticles('FAQ', 19, 'en_US');
        Database.insert(gcr_TestUtility.getDataCategoriesOther('FAQ', lArticle), true);
        // CREATE EXPECTED DATA
        Set<String> sArticleExpUrl = new Set<String>();
        String articleUrl = gcr_TestUtility.BRAND_DATA;
        sArticleExpUrl.add(articleUrl);
        articleUrl += '/' +  gcr_TestUtility.LANGUAGE_ISO + '-' + gcr_TestUtility.COUNTRY_ISO;
        sArticleExpUrl.add(articleUrl);
        articleUrl += '/faq';
        sArticleExpUrl.add(articleUrl);
		List<KnowledgeArticleVersion> lKa = [ SELECT Id
                                             	   , UrlName 
                                              FROM KnowledgeArticleVersion 
                                              WHERE Language = 'en_US'
                                             	AND PublishStatus = 'Online' ];
        
        for (KnowledgeArticleVersion eachArticle :lKa) {
            sArticleExpUrl.add(articleUrl + '/' + eachArticle.UrlName);
        }
        // SEUTP PAGE PARAMETERS
        ApexPages.currentPage().getParameters().put('brand', gcr_TestUtility.BRAND_DATA);
        ApexPages.currentPage().getParameters().put('country', gcr_TestUtility.COUNTRY_ISO);
        ApexPages.currentPage().getParameters().put('language', gcr_TestUtility.LANGUAGE_ISO);
        // START TEST
        Test.startTest();
        gcr_careHubSiteMapController controller = new gcr_careHubSiteMapController();
        Test.stopTest();
        for (String eachUrl :controller.lKaExtUrl) {
            SYSTEM.assert(sArticleExpUrl.contains(eachUrl));
        }
    }
    
	/*
     * @author: 		Accenture
	 * @date: 		 	25/01/2017
	 * @description:  	TEST METHOD TO TEST SITE MAP WITHOUT ARTICLE URLs
     */
    static testmethod void noArticleTest() {
        // CREATE EXPECTED DATA
        Set<String> sArticleExpUrl = new Set<String>();
        String articleUrl = gcr_TestUtility.BRAND_DATA;
        sArticleExpUrl.add(articleUrl);
        articleUrl += '/' +  gcr_TestUtility.LANGUAGE_ISO + '-' + gcr_TestUtility.COUNTRY_ISO;
        sArticleExpUrl.add(articleUrl);
        articleUrl += '/faq';
        sArticleExpUrl.add(articleUrl);
		List<KnowledgeArticleVersion> lKa = [ SELECT Id
                                             	   , UrlName 
                                              FROM KnowledgeArticleVersion 
                                              WHERE Language = 'en_US'
                                             	AND PublishStatus = 'Online'
                                            	WITH DATA CATEGORY Region__c ABOVE_OR_BELOW United_Kingdom__c ];
        SYSTEM.assert(lKa == null || (lKa != null && lKa.isEmpty()));
		// SEUTP PAGE PARAMETERS
        ApexPages.currentPage().getParameters().put('brand', gcr_TestUtility.BRAND_DATA);
        ApexPages.currentPage().getParameters().put('country', gcr_TestUtility.COUNTRY_ISO);
        ApexPages.currentPage().getParameters().put('language', gcr_TestUtility.LANGUAGE_ISO);
        // START TEST
        Test.startTest();
        gcr_careHubSiteMapController controller = new gcr_careHubSiteMapController();
        Test.stopTest();
        Set<String> sAllUrls = new Set<String>();
        sAllUrls.addAll(controller.lKaExtUrl);
        for (String eachUrl :sArticleExpUrl) {
            SYSTEM.assert(sAllUrls.contains(eachUrl));
        }
    }
}