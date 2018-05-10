/*
 * Second part of unit tests for PKB
 * https://appexchange.salesforce.com/listingDetail?listingId=a0N300000059QxXEAU
 * These tests are specific to the FAQ_ka/kav objects
 * 
 * christopher.macduff@accenture.com
 * 26-10-2015
*/ 
@isTest
public class pkb_Test_Part2 {
    
    static String siteName = 'PKB_TEST_' + String.valueOf(Crypto.getRandomInteger());    // use this to set the siteName prop of the pkb_Controller class
    static String publishStatus = 'draft'; // use this to set the pub status prop of the pkb_Controller
    static String lang = 'en_US';
    
    //URL params
    static String queryParam = 'test';
    static String brandParam = 'Tide';
    static String langParam = 'English-US';
    static String countryParam = 'United States of America';

    @testSetup static void setupData() {
    /*
     * Create data
    */     
    List<FAQ__kav> kavsToInsert = new List<FAQ__kav>();
    FAQ__kav KA1 = new FAQ__kav(
        Title = 'Featured test Article 1',
        UrlName = 'Featured-test-Article-1',
        Summary = 'This is the summary of the featured test article 1',
        Answer__c = 'Answer body: This is the summary of the featured test article 1',
        IsVisibleInPkb = true,
        Language = lang
    );
    kavsToInsert.add(KA1);
        
    FAQ__kav KA2 = new FAQ__kav(
        Title = 'Featured test Article 2',
        UrlName = 'Featured-test-Article-2',
        Summary = 'This is the summary of the featured test article 2',
        Answer__c = 'Answer body: This is the summary of the featured test article 2',
        IsVisibleInPkb = true,
        Language = lang
    );
    kavsToInsert.add(KA2);
    insert kavsToInsert;
        
    //Set Data Categories so article will be returned in pkb_controller
    List<FAQ__DataCategorySelection> dcsToInsert = new List<FAQ__DataCategorySelection>();
    FAQ__DataCategorySelection dc1 = new FAQ__DataCategorySelection(
        ParentId = KA1.Id,
        DataCategoryGroupName = 'Brand',
        DataCategoryName = 'Tide'
    );
    dcsToInsert.add(dc1);
    FAQ__DataCategorySelection dc2 = new FAQ__DataCategorySelection(
        ParentId = KA1.Id,
        DataCategoryGroupName = 'Region',
        DataCategoryName = 'United_States'
    );
    dcsToInsert.add(dc2);
    FAQ__DataCategorySelection dc3 = new FAQ__DataCategorySelection(
        ParentId = KA1.Id,
        DataCategoryGroupName = 'Product',
        DataCategoryName = 'Laundry'
    );
    dcsToInsert.add(dc3);        
        
    FAQ__DataCategorySelection dc4 = new FAQ__DataCategorySelection(
        ParentId = KA2.Id,
        DataCategoryGroupName = 'Brand',
        DataCategoryName = 'Tide'
    );
    dcsToInsert.add(dc4);
    FAQ__DataCategorySelection dc5 = new FAQ__DataCategorySelection(
        ParentId = KA2.Id,
        DataCategoryGroupName = 'Region',
        DataCategoryName = 'United_States'
    );
    dcsToInsert.add(dc5);
    FAQ__DataCategorySelection dc6 = new FAQ__DataCategorySelection(
        ParentId = KA2.Id,
        DataCategoryGroupName = 'Product',
        DataCategoryName = 'Laundry'
    );
    dcsToInsert.add(dc6);          
    insert dcsToInsert;

    //Requery article to get ArticleNumber & KnowledgeArticleId
    KA1 = [SELECT Id, ArticleNumber, KnowledgeArticleId FROM FAQ__kav WHERE Id = :KA1.Id LIMIT 1];
    KA2 = [SELECT Id, ArticleNumber, KnowledgeArticleId FROM FAQ__kav WHERE Id = :KA2.Id LIMIT 1];
        
    //Publish article
    KbManagement.PublishingService.publishArticle(KA1.KnowledgeArticleId, true);
    KbManagement.PublishingService.publishArticle(KA2.KnowledgeArticleId, true);
    }
    
    @isTest
    static void pkbTests1() {
        PageReference pageRef = Page.pkb_Home;
        Test.setCurrentPage(pageRef);

        //Set all url params to null then load pkbCon
        pageRef.getParameters().put('q',null);
        pageRef.getParameters().put('l',null);
        pageRef.getParameters().put('country',null);
        pageRef.getParameters().put('language',null);
        pageRef.getParameters().put('brand',null);
        
        //Set SOSL return Ids - otherwise search will always return null
        //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_SOSL.htm
        List<FAQ__kav> kavList = [SELECT Id FROM FAQ__kav WHERE PublishStatus='online' AND Language='en_US'];
        List<Id> fixedSearchResults = new List<Id>();
        fixedSearchResults.add(kavList[0].Id);
        fixedSearchResults.add(kavList[1].Id);
        Test.setFixedSearchResults(fixedSearchResults);
        
        Test.startTest();
        pkb_Controller pkbCon = new pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        
        //Line converage...
        String testParam1 = pkbCon.brandParam;
        testParam1 = pkbCon.sessionParam;
        testParam1 = pkbCon.feedbackParam;
        testParam1 = pkbCon.feedbackSourceParam;
        testParam1 = pkbCon.pageNumParam;
        testParam1 = pkbCon.queryParam;
        testParam1 = pkbCon.languageParam;
        testParam1 = pkbCon.categoryParam;
        testParam1 = pkbCon.contactUsParam;
        testParam1 = pkbCon.brandSelectLabel;
        testParam1 = pkbCon.kavExtension;
        testParam1 = pkbCon.contactUsValue;
        testParam1 = pkbCon.feedbackShowYesNo;
        testParam1 = pkbCon.feedbackShowDialog;
        testParam1 = pkbCon.feedbackContactUs;
        testParam1 = pkbCon.feedbackSearch;
        testParam1 = pkbCon.feedbackRelated;
        testParam1 = pkbCon.publishStatus;
        testParam1 = pkbCon.chosenLanguage;
        //testParam1 = pkbCon.createCaseErrorMsg;
        //testParam1 = pkbCon.defaultCaseOrigin;
        testParam1 = pkbCon.backToSearchUrl;
        testParam1 = pkbCon.fbAppId;
        testParam1 = pkbCon.feedbackSource;
        testParam1 = pkbCon.feedbackComments;
        testParam1 = pkbCon.availableLanguages;
        
        pkb_Controller.ContactUsData newCUD = new pkb_Controller.ContactUsData();
        testParam1 = newCUD.email;
        testParam1 = newCUD.firstName;
        testParam1 = newCUD.lastName;
        testParam1 = newCUD.email;
        testParam1 = newCUD.reqType;
        testParam1 = newCUD.query;
        testParam1 = newCUD.User_Experience;
        
        decimal testDec = newCUD.location_Latitude;
        testDec = newCUD.location_Longitude;
            
        Boolean testBoo = pkbCon.displaySearchResultsLink;
        testBoo = pkbCon.displayCategory1;
        testBoo = pkbCon.displayCategory2;
        testBoo = pkbCon.displayCategory3;
        testBoo = pkbCon.displayNarrow;
        testBoo = pkbCon.displayFeedbackYesNo;
        testBoo = pkbCon.displayFeedbackDialog;
        testBoo = pkbCon.facebook;
        testBoo = pkbCon.showArticleSummary;
        testBoo = pkbCon.createAcctCon;
        testBoo = pkbCon.foundRecommended;
        //testBoo = pkbCon.caseCreateError;
        //testBoo = pkbCon.caseCreated;
        testBoo = pkbCon.feedbackRecorded;
        testBoo = pkbCon.multiLanguage;
        
        Integer testInt = pkbCon.popularArticles;
        testInt = pkbCon.relatedArticles;
        testInt = pkbCon.articlesPerPage;
        testInt = pkbCon.currPage;
        
        //Map<String, String> testMap = new Map<String, String>(pkbCon.caseOrigins);

        pkbCon.getCurrentLanguageDump();
        //pkbCon.getFeaturedKadsDump();
        system.assertEquals(true, pkb_Controller.isEmail('test@test.com'));
        
        User testUser = pkbCon.siteAdmin;
        List<SelectOption> testList = pkbCon.getBrandSelectList();
        system.assert(testList.size() > 0);

        //Set all url params with valid values then reload pkbCon
        pageRef.getParameters().put('q',queryParam);
        pageRef.getParameters().put('l',lang);
        pageRef.getParameters().put('country',countryParam);
        pageRef.getParameters().put('language',langParam);
        pageRef.getParameters().put('brand',brandParam);

        pkbCon = new pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));

        system.assertEquals(True, pkbCon.searchExecuted);
        //system.assertEquals(2, pkbCon.recommendedKads.size());

        //call the 3 methods below directly as no longer used or called by javascript?
        /*pkbCon.prepareSearchRSS();
        pkbCon.buildCategorySosl(); 
        pkbCon.buildRecommendedKads();*/

        pkbCon.updateBrand();
        system.assertEquals(null, pageRef.getParameters().get('q'));
        
        Test.stopTest();
    }
}