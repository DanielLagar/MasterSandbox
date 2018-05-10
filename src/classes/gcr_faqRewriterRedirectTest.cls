/*
* @author:       Accenture
* @date:         30/08/2016
* @description:  Test class for url rewriter class
* CHANGE LOG
* DATE			NAME				CHANGE DESCRIPTION
* 30/08/2016	Accenture			Initial Draft
* 27/04/2017	Accenture			WR500 - Additional assertions added for better testing of data
*/
@isTest(SeeAllData = false)
public class gcr_faqRewriterRedirectTest {
    /*
     * @author: 		Accenture
	 * @date: 		 	30/08/2016
	 * @description:  	TEST SETUP METHOD TO SETUP TEST DATA
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
	 * @date: 		 	30/08/2016
	 * @description:  	TEST METHOD FOR URLREWRITING
     */
    static testmethod void mapRequestUrlTest() {
        // URL REWRITING POSITIVE SCENARIO
        PageReference faqPageReference = new PageReference('/aussie/en-us/faq/');
        PageReference rewrittenUrl = (new gcr_careHubFAQRewriter()).mapRequestUrl(faqPageReference);
        SYSTEM.assertEquals('gcr_faqRedirectPage?pageUrl=' + EncodingUtil.urlEncode('/aussie/en-us/faq/', 'UTF-8'), rewrittenUrl.getUrl());
        // URL REWRITING NEGATIVE SCENARIO
        faqPageReference = new PageReference('/no/specified/url/');
        rewrittenUrl = (new gcr_careHubFAQRewriter()).mapRequestUrl(faqPageReference);
        SYSTEM.assert(rewrittenUrl == null);
        // FOLLOWING IS JUST TO COVER IMPLEMENTED METHOD. NO LOGIC AS OF NOW
        List<PageReference> lRewrittenUrl = (new gcr_careHubFAQRewriter()).generateUrlFor(new List<PageReference>());
        SYSTEM.assert(lRewrittenUrl == null);
    }

    /*
     * @author: 		Accenture
	 * @date: 		 	30/08/2016
	 * @description:  	TEST METHOD FOR REDIRECT TO BRAND.COM
     */
    static testmethod void redirectToBrandDotComTest() {
        // CREATE KNOWLEDGE ARTICLES
        List<KnowledgeArticleVersion> lArticle = gcr_TestUtility.createArticles('FAQ', 19, 'en_US');
        Database.insert(gcr_TestUtility.getDataCategoriesOther('FAQ', lArticle), true);
		List<KnowledgeArticleVersion> lKa = [ SELECT Id
                                             	   , UrlName 
                                              FROM KnowledgeArticleVersion 
                                              WHERE Language = 'en_US'
                                             	AND PublishStatus = 'Online' LIMIT 1 ];
        // SETUP PAGE PARAMETERS
        ApexPages.currentPage().getParameters().put('pageUrl', '/tide/en-us/faq/' + lKa.get(0).UrlName);
        gcr_faqRedirectController controller = new gcr_faqRedirectController();
        // TEST VALIDATION ASSERTION
        // WR500 - UPDATED ASSETION TO PICKUP BRANDSITE URL FROM CUSTOM SETTINGS
        SYSTEM.assertEquals('http://' + FaqBrandSiteMapping__c.getInstance('/tide/en-us/faq/').BrandSiteUrl__c
                          + '?articleId=' + lKa.get(0).UrlName, controller.urlToRediect);
        SYSTEM.assert(controller.article != null);
        SYSTEM.assert(String.isNotEmpty(controller.article.Id)
                   && controller.article.Id == lKa.get(0).Id);
        SYSTEM.assert(String.isNotEmpty(controller.article.Answer__c)
                   && controller.article.Answer__c.contains('Answer body:'));
        SYSTEM.assert(controller.rdTime == 5000);
    }
}