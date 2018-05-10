/*
* @author:       Accenture
* @date:         25/08/2016
* @description:  Test class for faq component's Controller
* CHANGE LOG
* DATE          NAME                CHANGE DESCRIPTION
* 29/08/2016    Accenture           Initial Draft
*/
@isTest(SeeAllData = false)
public class gcr_knowledgeArticleControllerTest {
    
    /*
     * @author:         Accenture
     * @date:           29/08/2016
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
    }
    
    /*
     * @author:         Accenture
     * @date:           29/08/2016
     * @description:    TEST METHOD TO GET FEATURED ARTICLES
     */
    static testmethod void getFeaturedArticleTest() {
        Set<String> sExpectedFeatured = new Set<String>();
        Map<String, Schema.RecordTypeInfo> mRecordTypeInfo = GCRChannelContent__c.getSObjectType().getDescribe().getRecordTypeInfosByName();

        gcr_knowledgeArticleController kaController = new gcr_knowledgeArticleController();
        GCRChannelContent__c chlContentExpected = [ SELECT Id
                                                         , FAQFeaturedArticle1__c
                                                         , FAQFeaturedArticle2__c
                                                         , FAQFeaturedArticle3__c
                                                         , FAQFeaturedArticle4__c
                                                         , FAQFeaturedArticle5__c
                                                    FROM GCRChannelContent__c
                                                    WHERE RecordTypeId = :mRecordTypeInfo.get('faq').getRecordTypeId()
                                                        AND CareHub__r.Brand__c = :gcr_TestUtility.DEFAULT_BRAND
                                                        AND CareHub__r.CountryIsoCode__c = :gcr_TestUtility.DEFAULT_COUNTRY_ISO
                                                        AND CareHub__r.LanguageIsoCode__c = :gcr_TestUtility.DEFAULT_LANGUAGE_ISO ].get(0);
        kaController.chlContentId = chlContentExpected.Id;
        // ASSIGNED FEATURED ARTICLES
        sExpectedFeatured.add(chlContentExpected.FAQFeaturedArticle1__c);
        sExpectedFeatured.add(chlContentExpected.FAQFeaturedArticle2__c);
        sExpectedFeatured.add(chlContentExpected.FAQFeaturedArticle3__c);
        sExpectedFeatured.add(chlContentExpected.FAQFeaturedArticle4__c);
        sExpectedFeatured.add(chlContentExpected.FAQFeaturedArticle5__c);
        // CHANNEL CONTENT RECEIVED FROM KA CONTROLLER
        GCRChannelContent__c chlContentReturend = kaController.chlContentRec;
        SYSTEM.assert(String.valueOf(chlContentReturend.Id).equalsIgnoreCase(chlContentExpected.Id));
        Test.startTest();
        Boolean tempBool = kaController.blnTemp;
        Test.stopTest();
        SYSTEM.assert(!tempBool);
        SYSTEM.assert(kaController.lKnowledgeArticle != null && !kaController.lKnowledgeArticle.isEmpty());
        SYSTEM.assert(kaController.showArticleList);
        for (sObject eachArticle :kaController.lKnowledgeArticle) {
            SYSTEM.assert(sExpectedFeatured.contains(((KnowledgeArticleVersion) eachArticle).ArticleNumber));
        }
    }
    
    /*
     * @author:         Accenture
     * @date:           29/08/2016
     * @description:    TEST METHOD FOR SEARCH KNOWLEDGE ARTICLE
     */     
    static testmethod void searchKnowledgeArticleTest() {
        Map<String, Schema.RecordTypeInfo> mRecordTypeInfo = GCRChannelContent__c.getSObjectType().getDescribe().getRecordTypeInfosByName();

        gcr_knowledgeArticleController kaController = new gcr_knowledgeArticleController();
        GCRChannelContent__c chlContentExpected = [ SELECT Id FROM GCRChannelContent__c
                                                    WHERE RecordTypeId = :mRecordTypeInfo.get('faq').getRecordTypeId()
                                                        AND CareHub__r.Brand__c = :gcr_TestUtility.DEFAULT_BRAND
                                                        AND CareHub__r.CountryIsoCode__c = :gcr_TestUtility.DEFAULT_COUNTRY_ISO
                                                        AND CareHub__r.LanguageIsoCode__c = :gcr_TestUtility.DEFAULT_LANGUAGE_ISO ].get(0);
        kaController.chlContentId = chlContentExpected.Id;
        GCRChannelContent__c chlContentReturend = kaController.chlContentRec;
        Boolean tempBool = kaController.blnTemp;
        // TEST FOR SEARCH CHARACTERS LESS THAN 3 CHARS
        //CDOY WR367 - Changed Minimum character search to 2 Chars. Test class changed accordingly
        //CDOY WR367 kaController.strSearch = 'fe';
        kaController.strSearch = 'f'; //CDOY WR367
        kaController.getSearchResult();
        SYSTEM.assert(kaController.isMinCharError);
        // TEST FOR SEARCH ARTICLES NO RESULTS FOUND
        List<KnowledgeArticleVersion> lFeaturedArticle = gcr_TestUtility.createArticles('FAQ', 19, 'en_US');
        Database.insert(gcr_TestUtility.getDataCategories('FAQ', lFeaturedArticle), true);
        kaController.strSearch = 'feat';
        kaController.getSearchResult();
        SYSTEM.assert(!kaController.isMinCharError);
        SYSTEM.assert(kaController.totalSearchArticles == 0);
        // TEST FOR SEARCH ARTICLES WITH RESULTS
        List<Id> lSearchId = new List<Id>();
        for (KnowledgeArticleVersion eachArticle :lFeaturedArticle) {
            lSearchId.add(eachArticle.Id);
        }
        Test.setFixedSearchResults(lSearchId);
        kaController.getSearchResult();
        SYSTEM.assert(kaController.totalSearchArticles == 19);
        SYSTEM.assert(kaController.totalPages == 4);
        for (Integer itr = 1; itr <= 3; itr++) {
            SYSTEM.assert(itr == Integer.valueOf(kaController.lPageNumbers.get(itr - 1)));
        }
    }
    
    /*
     * @author:         Accenture
     * @date:           29/08/2016
     * @description:    TEST METHOD FOR PAGINATION FOR KA SEARCH RESULTS
     */
    static testmethod void kaSearchPaginationTest() {
        Map<String, Schema.RecordTypeInfo> mRecordTypeInfo = GCRChannelContent__c.getSObjectType().getDescribe().getRecordTypeInfosByName();

        gcr_knowledgeArticleController kaController = new gcr_knowledgeArticleController();
        GCRChannelContent__c chlContentExpected = [ SELECT Id FROM GCRChannelContent__c
                                                    WHERE RecordTypeId = :mRecordTypeInfo.get('faq').getRecordTypeId()
                                                        AND CareHub__r.Brand__c = :gcr_TestUtility.DEFAULT_BRAND
                                                        AND CareHub__r.CountryIsoCode__c = :gcr_TestUtility.DEFAULT_COUNTRY_ISO
                                                        AND CareHub__r.LanguageIsoCode__c = :gcr_TestUtility.DEFAULT_LANGUAGE_ISO ].get(0);
        kaController.chlContentId = chlContentExpected.Id;
        GCRChannelContent__c chlContentReturend = kaController.chlContentRec;
        Boolean tempBool = kaController.blnTemp;
        List<KnowledgeArticleVersion> lFeaturedArticle = gcr_TestUtility.createArticles('FAQ', 19, 'en_US');
        Database.insert(gcr_TestUtility.getDataCategories('FAQ', lFeaturedArticle), true);
        kaController.strSearch = 'feat';
        List<Id> lSearchId = new List<Id>();
        for (KnowledgeArticleVersion eachArticle :lFeaturedArticle) {
            lSearchId.add(eachArticle.Id);
        }
        Test.setFixedSearchResults(lSearchId);
        kaController.getSearchResult();
        // TEST FOR SELECTED PAGE - SELECT PAGE 2
        kaController.currentPage = 2;
        kaController.displaySelectedPage();
        for (Integer itr = 1; itr <= 3; itr++) {
            SYSTEM.assert(itr == Integer.valueOf(kaController.lPageNumbers.get(itr - 1)));
        }
        SYSTEM.assert(kaController.offsetValue == 5);
        // TEST FOR SELECTED PAGE - SELECT PAGE 4
        kaController.currentPage = 4;
        kaController.displaySelectedPage();
        for (Integer itr = 2; itr <= 4; itr++) {
            SYSTEM.assert(itr == Integer.valueOf(kaController.lPageNumbers.get(itr - 2)));
        }
        SYSTEM.assert(kaController.offsetValue == 15);
        // TEST FOR SELECTED PAGE - GO TO PREVIOUS
        kaController.previous();
        SYSTEM.assert(kaController.currentPage == 3);
        for (Integer itr = 2; itr <= 4; itr++) {
            SYSTEM.assert(itr == Integer.valueOf(kaController.lPageNumbers.get(itr - 2)));
        }
        SYSTEM.assert(kaController.offsetValue == 10);
        // TEST FOR SELECTED PAGE - GO TO PREVIOUS
        kaController.previous();
        SYSTEM.assert(kaController.currentPage == 2);
        for (Integer itr = 1; itr <= 3; itr++) {
            SYSTEM.assert(itr == Integer.valueOf(kaController.lPageNumbers.get(itr - 1)));
        }
        SYSTEM.assert(kaController.offsetValue == 5);
        // TEST FOR SELECTED PAGE - GO TO PREVIOUS
        kaController.previous();
        SYSTEM.assert(kaController.currentPage == 1);
        for (Integer itr = 1; itr <= 3; itr++) {
            SYSTEM.assert(itr == Integer.valueOf(kaController.lPageNumbers.get(itr - 1)));
        }
        SYSTEM.assert(kaController.offsetValue == 0);
        // TEST FOR SELECTED PAGE - GO TO NEXT
        kaController.next();
        SYSTEM.assert(kaController.currentPage == 2);
        for (Integer itr = 1; itr <= 3; itr++) {
            SYSTEM.assert(itr == Integer.valueOf(kaController.lPageNumbers.get(itr - 1)));
        }
        SYSTEM.assert(kaController.offsetValue == 5);
        // TEST FOR SELECTED PAGE - GO TO NEXT
        kaController.next();
        SYSTEM.assert(kaController.currentPage == 3);
        for (Integer itr = 2; itr <= 4; itr++) {
            SYSTEM.assert(itr == Integer.valueOf(kaController.lPageNumbers.get(itr - 2)));
        }
        SYSTEM.assert(kaController.offsetValue == 10);
        // TEST FOR SELECTED PAGE - GO TO NEXT
        kaController.next();
        SYSTEM.assert(kaController.currentPage == 4);
        for (Integer itr = 2; itr <= 4; itr++) {
            SYSTEM.assert(itr == Integer.valueOf(kaController.lPageNumbers.get(itr - 2)));
        }
        SYSTEM.assert(kaController.offsetValue == 15);
        // TEST FOR SELECTED PAGE - GO TO FIRST PAGE
        kaController.firstPage();
        SYSTEM.assert(kaController.currentPage == 1);
        for (Integer itr = 1; itr <= 3; itr++) {
            SYSTEM.assert(itr == Integer.valueOf(kaController.lPageNumbers.get(itr - 1)));
        }
        SYSTEM.assert(kaController.offsetValue == 0);
        // TEST FOR SELECTED PAGE - GO TO LAST PAGE
        kaController.lastPage();
        SYSTEM.assert(kaController.currentPage == 4);
        for (Integer itr = 2; itr <= 4; itr++) {
            SYSTEM.assert(itr == Integer.valueOf(kaController.lPageNumbers.get(itr - 2)));
        }
        SYSTEM.assert(kaController.offsetValue == 15);
    }
    
    /*
     * @author:         Accenture
     * @date:           29/08/2016
     * @description:    TEST METHOD FOR VIEW ARTICLE TEST
     */
    static testmethod void viewArticleTest() {
        Map<String, Schema.RecordTypeInfo> mRecordTypeInfo = GCRChannelContent__c.getSObjectType().getDescribe().getRecordTypeInfosByName();

        gcr_knowledgeArticleController kaController = new gcr_knowledgeArticleController();
        GCRChannelContent__c chlContentExpected = [ SELECT Id FROM GCRChannelContent__c
                                                    WHERE RecordTypeId = :mRecordTypeInfo.get('faq').getRecordTypeId()
                                                        AND CareHub__r.Brand__c = :gcr_TestUtility.DEFAULT_BRAND
                                                        AND CareHub__r.CountryIsoCode__c = :gcr_TestUtility.DEFAULT_COUNTRY_ISO
                                                        AND CareHub__r.LanguageIsoCode__c = :gcr_TestUtility.DEFAULT_LANGUAGE_ISO ].get(0);
        kaController.chlContentId = chlContentExpected.Id;
        GCRChannelContent__c chlContentReturend = kaController.chlContentRec;
        Boolean tempBool = kaController.blnTemp;
        // TEST FOR ARTICLE VIEW POSITIVE SCENARIO
        kaController.kArticleId = kaController.lKnowledgeArticle.get(0).KnowledgeArticleId;
        Test.startTest();
        kaController.getArticleDetail();
        Test.stopTest();
        SYSTEM.assert(!kaController.showArticleList);
        SYSTEM.assert(kaController.kArticleView != null);
        SYSTEM.assert(kaController.lKnowledgeArticle.size() == 0);
        SYSTEM.assert(kaController.lPageNumbers.size() == 0);
        // TEST FOR GO BACK TO FEATURED ARTICLE
        kaController.goToLanding();
        SYSTEM.assert(kaController.isLanding);
        SYSTEM.assert(kaController.showArticleList);
        SYSTEM.assert(kaController.offsetValue == 0);
        // TEST FOR ARTICLE VIEW NEGATIVE SCENARIO
        kaController.kArticleId = kaController.lKnowledgeArticle.get(0).Id;
        kaController.getArticleDetail();
        List<ApexPages.Message> lPageMessage = ApexPages.getMessages();
        Boolean messageFound = false;
        for (ApexPages.Message eachMessage :lPageMessage) {
            if(eachMessage.getSummary().contains(LABEL.errMsgGeneric)) {
                messageFound = true;
            }
        }
        SYSTEM.assert(messageFound);
    }
    
    /*
     * @author:         Accenture
     * @date:           29/08/2016
     * @description:    TEST METHOD FOR VIEW ARTICLE TEST
     */
    static testmethod void submitFeedbackTest() {
        Map<String, Schema.RecordTypeInfo> mRecordTypeInfo = GCRChannelContent__c.getSObjectType().getDescribe().getRecordTypeInfosByName();

        gcr_knowledgeArticleController kaController = new gcr_knowledgeArticleController();
        GCRChannelContent__c chlContentExpected = [ SELECT Id FROM GCRChannelContent__c
                                                    WHERE RecordTypeId = :mRecordTypeInfo.get('faq').getRecordTypeId()
                                                        AND CareHub__r.Brand__c = :gcr_TestUtility.DEFAULT_BRAND
                                                        AND CareHub__r.CountryIsoCode__c = :gcr_TestUtility.DEFAULT_COUNTRY_ISO
                                                        AND CareHub__r.LanguageIsoCode__c = :gcr_TestUtility.DEFAULT_LANGUAGE_ISO ].get(0);
        kaController.chlContentId = chlContentExpected.Id;
        GCRChannelContent__c chlContentReturend = kaController.chlContentRec;
        Boolean tempBool = kaController.blnTemp;
        tempBool = kaController.blnTempFeedback;
        // VIEW A ARTICLE AND SUBMIT POSITIVE FEEDBACK
        kaController.kArticleId = kaController.lKnowledgeArticle.get(0).KnowledgeArticleId;
        kaController.getArticleDetail();
        kaController.positiveFeedback();
        SYSTEM.assert(kaController.feedbackInit);
        SYSTEM.assert(kaController.feedbackProvided);
        SYSTEM.assert(kaController.sPrvArticleId != null && kaController.sPrvArticleId.size() == 1);
        List<PKB_Article_Feedback_Deflection__c> lAFbDeflection = [ SELECT Id FROM PKB_Article_Feedback_Deflection__c ];
        SYSTEM.assert(lAFbDeflection != null && lAFbDeflection.size() == 1);
        // VIEW ANOTHER ARTICLE AND SUBMIT FEEDBACK
        kaController.strFaqUrl = null;
        kaController.blnTemp = null;
        kaController.lKnowledgeArticle = null;
        tempBool = kaController.blnTemp;
        tempBool = kaController.blnTempFeedback;
        kaController.kArticleId = kaController.lKnowledgeArticle.get(1).KnowledgeArticleId;
        kaController.getArticleDetail();
        // INITIATE NEGATIVE FEEDBACK
        kaController.negativeFeedback();
        SYSTEM.assert(kaController.feedbackInit);
        SYSTEM.assert(!kaController.feedbackProvided);
        // CANCEL NEGATIVE FEEDBACK
        kaController.cancelFeedback();
        SYSTEM.assert(!kaController.feedbackInit);
        SYSTEM.assert(!kaController.feedbackProvided);
        // INITIATE NEGATIVE FEEDBACK
        kaController.negativeFeedback();
        // SUBMIT NEGATIVE FEEDBACK
        kaController.submitNegativeFeedback();
        tempBool = kaController.blnTempFeedback;
        lAFbDeflection = [ SELECT Id FROM PKB_Article_Feedback_Deflection__c ];
        SYSTEM.assert(lAFbDeflection != null && lAFbDeflection.size() == 2);
        SYSTEM.assert(kaController.feedbackProvided);
    }
    
    /*
     * @author:         Accenture
     * @date:           29/08/2016
     * @description:    TEST METHOD FOR VIEW ARTICLE TEST
     */
    static testmethod void defaultArticleViewTest() {
        Map<String, Schema.RecordTypeInfo> mRecordTypeInfo = GCRChannelContent__c.getSObjectType().getDescribe().getRecordTypeInfosByName();

        gcr_knowledgeArticleController kaController = new gcr_knowledgeArticleController();
        GCRChannelContent__c chlContentExpected = [ SELECT Id FROM GCRChannelContent__c
                                                    WHERE RecordTypeId = :mRecordTypeInfo.get('faq').getRecordTypeId()
                                                        AND CareHub__r.Brand__c = :gcr_TestUtility.DEFAULT_BRAND
                                                        AND CareHub__r.CountryIsoCode__c = :gcr_TestUtility.DEFAULT_COUNTRY_ISO
                                                        AND CareHub__r.LanguageIsoCode__c = :gcr_TestUtility.DEFAULT_LANGUAGE_ISO ].get(0);
        kaController.chlContentId = chlContentExpected.Id;
        GCRChannelContent__c chlContentReturend = kaController.chlContentRec;
        List<KnowledgeArticleVersion> lArticle = gcr_TestUtility.createArticles('FAQ', 1, 'en_US');
        Database.insert(gcr_TestUtility.getDataCategories('FAQ', lArticle), true);
        kaController.strKaUrlName = lArticle.get(0).UrlName;
        kaController.isRightToLeft = true;
        Test.startTest();
        Boolean tempBool = kaController.blnTemp;
        Test.stopTest();
        SYSTEM.assert(kaController.kArticleView != null 
                      && ((String) kaController.kArticleView.Id).equalsIgnoreCase(lArticle.get(0).Id));
        SYSTEM.assert(!kaController.showArticleList);
    }
}