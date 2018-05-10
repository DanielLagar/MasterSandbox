/*
 * Changes:
 * 16-10-2015 Updated to use @testSetup - christopher.macduff@accenture.com
 * 16-10-2015 Updated to include featured articles coverage - christopher.macduff@accenture.com
 * 
*/ 
@isTest
public class sf_ContactUsLanguageControllerTest {
    
    private static Contact_Us_Brand__c defaultBrand;
    private static Contact_Us_Brand__c otherBrand;
    private static Contact_Us_Language__c defaultLanguage;
    private static Contact_Us_Language__c otherLanguage;
    private static Contact_Us_Brand_Language__c defaultBrandDefaultLanguage;
    private static Contact_Us_Brand_Language__c defaultBrandOtherLanguage;

    @testSetup static void setupTestData() {
    	defaultBrand = new Contact_Us_Brand__c (
    	    name = 'Default',
    	    Brand__c = 'P&G'
    	);
        otherBrand = new Contact_Us_Brand__c (
            name = 'Tide',
            Brand__c = 'Tide'
        );
    	insert new list<Contact_Us_Brand__c>{defaultBrand, otherBrand};

    	defaultLanguage = new Contact_Us_Language__c (
    	    name = 'Default',
    	    Country__c = 'United States of America',
    	    Language__c = 'English',
    	    Language_Locale_Key__c = 'en-US',
			Article_Search_Button_Label__c = 'Article Search Button Label',
			Article_Search_Label__c = 'Article Search Label',
			Back_to_Results__c = 'Back to Results',
			Featured_Articles__c = 'Featured Articles',
			PKB_Page_Intro__c = 'PKB Page Intro',
			Search_Related__c = 'Search Related',
			Search_Results__c = 'Search Results',
			Select_Brand_Label__c = 'Select Brand Label',
			Helpful_Prompt__c = 'Helpful Prompt',
			Helpful_Yes__c = 'Helpful Yes',
			Helpful_No__c = 'Helpful No',
			Feedback_Title__c = 'Feedback Title',
			Feedback_Intro__c = 'Feedback Intro',
			Characters_Remaining__c = 'Characters Remaining',
			Submit__c = 'Submit',
			Cancel__c = 'Cancel',
			Search_Placeholder__c = 'Search Placeholder',
			No_Results__c = 'No Results',
			Previous__c = 'Previous',
			Next__c = 'Next',
			Helpful_Links__c = 'Helpful Links',
			Feedback_Thanks__c = 'Feedback Thanks',
			Close_Window__c = 'Close Window'
    	);
        otherLanguage = new Contact_Us_Language__c (
            name = 'US Spanish',
            Country__c = 'United States of America',
            Language__c = 'Spanish',
            Language_Locale_Key__c = 'es',
            Article_Search_Button_Label__c = 'SP Article Search Button Label',
            Article_Search_Label__c = 'SP Article Search Label',
            Back_to_Results__c = 'SP Back to Results',
            Featured_Articles__c = 'SP Featured Articles',
            PKB_Page_Intro__c = 'SP PKB Page Intro',
            Search_Related__c = 'SP Search Related',
            Search_Results__c = 'SP Search Results',
            Select_Brand_Label__c = 'SP Select Brand Label',
            Helpful_Prompt__c = 'SP Helpful Prompt',
            Helpful_Yes__c = 'SP Helpful Yes',
            Helpful_No__c = 'SP Helpful No',
            Feedback_Title__c = 'SP Feedback Title',
            Feedback_Intro__c = 'SP Feedback Intro',
            Characters_Remaining__c = 'SP Characters Remaining',
            Submit__c = 'SP Submit',
            Cancel__c = 'SP Cancel',
            Search_Placeholder__c = 'SP Search Placeholder',
            No_Results__c = 'SP No Results',
            Previous__c = 'SP Previous',
            Next__c = 'SP Next',
            Helpful_Links__c = 'SP Helpful Links',
            Feedback_Thanks__c = 'SP Feedback Thanks',
            Close_Window__c = 'SP Close Window'
        );
        insert new list<Contact_Us_Language__c> { defaultLanguage, otherLanguage };

    	defaultBrandDefaultLanguage = new Contact_Us_Brand_Language__c (
            Featured_Article_1__c = '',
            Featured_Article_2__c = '',
            Featured_Article_3__c = '',
            Featured_Article_4__c = '',
            Featured_Article_5__c = '',
            Display_Summary__c = False,
    	    Contact_Us_Brand__c = defaultBrand.id,
    	    Contact_Us_Language__c = defaultLanguage.id,
			Logo_Hover_Text__c = 'Logo Hover Text',
			Link_URL_Community_Site__c = 'http://example.com',
			Show_Live_Chat_Tab__c = true,
			Age_Capture_Style__c = sf_ContactUsLanguageController.AGE_CAPTURE_MMYYYY,
			Case_Submit_Minimum_Age__c = 18,
			Case_Submit_Ask_gender__c = true,
			Link_URL_Facebook__c = 'http://example.com/facebook',
			Link_URL_Twitter__c = 'http://example.com/twitter',
			Link_URL_Pinterest__c = 'http://example.com/pinterest',
			Link_Hover_Text_Facebook__c = 'Link Hover Text Facebook',
			Link_Hover_Text_Twitter__c = 'Link Hover Text Twitter',
			Link_Hover_Text_Pinterest__c = 'Link Hover Text Pinterest'
    	);

        defaultBrandOtherLanguage = new Contact_Us_Brand_Language__c (
            Featured_Article_1__c = '',
            Featured_Article_2__c = '',
            Featured_Article_3__c = '',
            Featured_Article_4__c = '',
            Featured_Article_5__c = '',
            Display_Summary__c = True,
            Contact_Us_Brand__c = defaultBrand.id,
            Contact_Us_Language__c = otherLanguage.id,
            Logo_Hover_Text__c = 'SP Logo Hover Text',
            Show_Live_Chat_Tab__c = false,
            Age_Capture_Style__c = sf_ContactUsLanguageController.AGE_CAPTURE_RANGES,
            Case_Submit_Minimum_Age__c = 17,
            Case_Submit_Ask_gender__c = false
        );

        insert new list<Contact_Us_Brand_Language__c> { defaultBrandDefaultLanguage, defaultBrandOtherLanguage };

    }

    @isTest
	static void testDefault() {
    	sf_ContactUsLanguageController ctrl = new sf_ContactUsLanguageController(null, null, null);
    	system.assertEquals('en-US', ctrl.languageCode);
    }

    @isTest
	static void testLanguage() {
        sf_ContactUsLanguageController ctrl = new sf_ContactUsLanguageController('Spanish', 'United States of America', null);
        system.assertEquals('es', ctrl.languageCode);
    }

    @isTest
	static void testLanguageGetter() {
        sf_ContactUsLanguageController ctrl = new sf_ContactUsLanguageController('Spanish', 'United States of America', null);
		system.assertEquals( 'SP Article Search Button Label', ctrl.language_config.Article_Search_Button_Label__c);
    }

    @isTest
	static void testBrandLanguage() {
        sf_ContactUsLanguageController ctrl = new sf_ContactUsLanguageController(null, null, 'Default');

		system.assertEquals('Logo Hover Text', ctrl.brand_language_config.Logo_Hover_Text__c);
		system.assert(ctrl.bl_show_facebook_link);
		system.assert(ctrl.bl_show_twitter_link);
		system.assert(ctrl.bl_show_pinterest_link);
		system.assert(ctrl.bl_show_community_tab);
		system.assert(ctrl.bl_show_live_chat_tab);
		system.assert(ctrl.bl_show_age_mmyyyy);
		system.assert(! ctrl.bl_show_age_ranges);
		system.assert(ctrl.bl_show_ask_gender);
		system.assertEquals(18, ctrl.bl_case_minimum_age);
    }

    @isTest
	static void testBrandLanguageOther() {
        otherLanguage = [SELECT Id, Language__c, Country__c FROM Contact_Us_Language__c WHERE Name = 'US Spanish' LIMIT 1];
        sf_ContactUsLanguageController ctrl = new sf_ContactUsLanguageController(otherLanguage.Language__c, otherLanguage.Country__c, 'Default');

        system.assertEquals('SP Logo Hover Text', ctrl.brand_language_config.Logo_Hover_Text__c);
        system.assert(! ctrl.bl_show_facebook_link);
        system.assert(! ctrl.bl_show_twitter_link);
        system.assert(! ctrl.bl_show_pinterest_link);
        system.assert(! ctrl.bl_show_community_tab);
        system.assert(! ctrl.bl_show_live_chat_tab);
        system.assert(! ctrl.bl_show_age_mmyyyy);
        system.assert( ctrl.bl_show_age_ranges);
        system.assert(! ctrl.bl_show_ask_gender);
        system.assertEquals(17, ctrl.bl_case_minimum_age);
    }
    
	@isTest
	static void testFeaturedArticles() {
        otherLanguage = [SELECT Id, Language__c, Country__c,Language_Locale_Key__c FROM Contact_Us_Language__c WHERE Name = 'US Spanish' LIMIT 1];
        sf_ContactUsLanguageController ctrl = new sf_ContactUsLanguageController(otherLanguage.Language__c, otherLanguage.Country__c, 'Default');
        List<pkb_Controller.KnowledgeArticleData> kadList = new List<pkb_Controller.KnowledgeArticleData>(pkb_Controller.getFeaturedArticles());
        system.assertEquals(0, kadList.size());
        
        /*To test properly need to create an article with data categories
         * and update Contact_Us_Brand_Language__c.Featured_Article_1__c
         * to use this article number */
        List<FAQ__kav> kavsToInsert = new List<FAQ__kav>();
        FAQ__kav featuredKA1 = new FAQ__kav(
            Title = 'Featured test Article 1',
            UrlName = 'Featured-test-Article-1',
            Summary = 'This is the summary of the featured test article 1',
            Language = otherLanguage.Language_Locale_Key__c
        );
        kavsToInsert.add(featuredKA1);
        
		FAQ__kav featuredKA2 = new FAQ__kav(
            Title = 'Featured test Article 2',
            UrlName = 'Featured-test-Article-2',
            Summary = 'This is the summary of the featured test article 2',
            Language = otherLanguage.Language_Locale_Key__c
        );
        kavsToInsert.add(featuredKA2);
        insert kavsToInsert;
        
        //Set Data Categories so article will be returned in pkb_controller
        List<FAQ__DataCategorySelection> dcsToInsert = new List<FAQ__DataCategorySelection>();
        FAQ__DataCategorySelection dc1 = new FAQ__DataCategorySelection(
            ParentId = featuredKA1.Id,
            DataCategoryGroupName = 'Brand',
            DataCategoryName = 'Tide'
        );
        dcsToInsert.add(dc1);
        FAQ__DataCategorySelection dc2 = new FAQ__DataCategorySelection(
            ParentId = featuredKA1.Id,
            DataCategoryGroupName = 'Region',
            DataCategoryName = 'United_States'
        );
        dcsToInsert.add(dc2);
        FAQ__DataCategorySelection dc3 = new FAQ__DataCategorySelection(
            ParentId = featuredKA2.Id,
            DataCategoryGroupName = 'Brand',
            DataCategoryName = 'Tide'
        );
        dcsToInsert.add(dc3);
        FAQ__DataCategorySelection dc4 = new FAQ__DataCategorySelection(
            ParentId = featuredKA2.Id,
            DataCategoryGroupName = 'Region',
            DataCategoryName = 'United_States'
        );
        dcsToInsert.add(dc4);        
        insert dcsToInsert;

        //Requery article to get ArticleNumber & KnowledgeArticleId
        featuredKA1 = [SELECT Id, ArticleNumber, KnowledgeArticleId FROM FAQ__kav WHERE Id = :featuredKA1.Id LIMIT 1];
        featuredKA2 = [SELECT Id, ArticleNumber, KnowledgeArticleId FROM FAQ__kav WHERE Id = :featuredKA2.Id LIMIT 1];
        
        //Publish article
        KbManagement.PublishingService.publishArticle(featuredKA1.KnowledgeArticleId, true);
        KbManagement.PublishingService.publishArticle(featuredKA2.KnowledgeArticleId, true);
        
        test.startTest();

        
        //Update brand language object with new article numbers
        Contact_Us_Brand_Language__c cuBrandLang = [SELECT Id FROM Contact_Us_Brand_Language__c WHERE Logo_Hover_Text__c = 'SP Logo Hover Text'];
        cuBrandLang.Featured_Article_1__c = featuredKA1.ArticleNumber;
        cuBrandLang.Featured_Article_2__c = featuredKA2.ArticleNumber;
        cuBrandLang.Featured_Article_3__c = '999999992';
        cuBrandLang.Featured_Article_4__c = '999999993';
        cuBrandLang.Featured_Article_5__c = '999999994';
        update cuBrandLang;

        //Now test controller again and kadList should be
        ctrl = new sf_ContactUsLanguageController(otherLanguage.Language__c, otherLanguage.Country__c, 'Default');
        kadList = new List<pkb_Controller.KnowledgeArticleData>(pkb_Controller.getFeaturedArticles());
        system.assertEquals(true, ctrl.bl_display_featured);
        system.assertEquals(true, ctrl.bl_display_summary);
        system.assertEquals(2, kadList.size());
        test.stopTest();
    }
}