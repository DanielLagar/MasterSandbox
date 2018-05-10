@isTest
public class ctr_knowledgeReview_test {
    static String lang = 'en_US';
    
    
    @testSetup static void setupData(){
        //Create a number of Articles with a mixture of Articles types
        //Assign to relevant data categories
        /****************************
         * ArticleType: FAQ__kav	*
         ***************************/
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
        
        
        List<FAQ__DataCategorySelection> dcsToInsert = new List<FAQ__DataCategorySelection>();
        //DCs for first FAQ__kav
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
       
        //DCs for second FAQ__kav
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
        
        
        /****************************
        * ArticleType: Product facts*
        ****************************/
        List<Product_Facts__kav> pfKAsToInsert = new List<Product_Facts__kav>();
        Product_Facts__kav pfKA1 = new Product_Facts__kav(
			Title = 'Product Fact Test Article 1',
            UrlName = 'Product-Fact-Test-Article-1',
            Summary = 'This is the summary of the Product Fact Test Article 1',
			AAI_Guidelines__c = 'Article 1: Some AAI guidelines here.',
			AMR_Guidelines__c = 'Article 1: Some AMR guidelines here.',
            IsVisibleInPkb = true,
            Language = lang
        );
       	pfKAsToInsert.add(pfKA1);
        
		Product_Facts__kav pfKA2= new Product_Facts__kav(
			Title = 'Product Fact Test Article 2',
            UrlName = 'Product-Fact-Test-Article-2',
            Summary = 'This is the summary of the Product Fact Test Article 2',
			AAI_Guidelines__c = 'Article 2: Some AAI guidelines here.',
			AMR_Guidelines__c = 'Article 2: Some AMR guidelines here.',
            IsVisibleInPkb = true,
            Language = lang
        );
       	pfKAsToInsert.add(pfKA2);
        
        insert pfKAsToInsert;
        
            
		List<Product_Facts__DataCategorySelection > pfDCsToInsert = new List<Product_Facts__DataCategorySelection >();
        //DCs for first Product_Facts__kav
        Product_Facts__DataCategorySelection  pfDC1 = new Product_Facts__DataCategorySelection (
            ParentId = pfKA1.Id,
            DataCategoryGroupName = 'Brand',
            DataCategoryName = 'Tide'
        );
        pfDCsToInsert.add(pfDC1);
        Product_Facts__DataCategorySelection  pfDC2 = new Product_Facts__DataCategorySelection (
            ParentId = pfKA1.Id,
            DataCategoryGroupName = 'Region',
            DataCategoryName = 'United_States'
        );
        pfDCsToInsert.add(pfDC2);
        Product_Facts__DataCategorySelection  pfDC3 = new Product_Facts__DataCategorySelection (
            ParentId = pfKA1.Id,
            DataCategoryGroupName = 'Product',
            DataCategoryName = 'Laundry'
        );
        pfDCsToInsert.add(pfDC3);        
       
        //DCs for second Product_Facts__kav
        Product_Facts__DataCategorySelection  pfDC4 = new Product_Facts__DataCategorySelection (
            ParentId = pfKA2.Id,
            DataCategoryGroupName = 'Brand',
            DataCategoryName = 'Tide'
        );
        pfDCsToInsert.add(pfDC4);
        Product_Facts__DataCategorySelection  pfDC5 = new Product_Facts__DataCategorySelection (
            ParentId = pfKA2.Id,
            DataCategoryGroupName = 'Region',
            DataCategoryName = 'United_States'
        );
        pfDCsToInsert.add(pfDC5);
        Product_Facts__DataCategorySelection  pfDC6 = new Product_Facts__DataCategorySelection (
            ParentId = pfKA2.Id,
            DataCategoryGroupName = 'Product',
            DataCategoryName = 'Laundry'
        );
        pfDCsToInsert.add(pfDC6);        
        insert pfDCsToInsert;
        
        //Need this as we have to provide the ids to query on KnowledgeArticleVersion
        List<Id> kaIDs = new List<Id>{KA1.Id, KA2.Id, pfKA1.Id, pfKA2.Id};

        //Publish articles
		for(KnowledgeArticleVersion kav : [SELECT Id, ArticleNumber,KnowledgeArticleId FROM KnowledgeArticleVersion WHERE Id In :kaIDs]){
			KbManagement.PublishingService.publishArticle(kav.KnowledgeArticleId, true); //DML in a for loop as we can't publish a list...
		}
        
    }
    
    @isTest
    static void cloneTest(){
		PageReference pageRef = Page.KnowledgeReview;
        Test.setCurrentPage(pageRef);
        
        ctr_knowledgeReview con = new ctr_knowledgeReview();
        
        test.startTest();
        //Null searchString check
        con.executeSearch();
        List<ApexPages.Message> msgs = new List<ApexPages.Message>(ApexPages.getMessages());
        system.assertEquals(1, msgs.size());
        msgs.clear();

        //Search test
        con.searchString = 'Article';
		//Note Controller is using SOSL - which cannot be truly test need to use the below if required:
		//https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_SOSL.htm
		con.executeSearch();
        
        con.searchString = 'Article';
        con.brandCat = 'Tide';
        con.executeSearch();
		
        //test no id if
        con.cloneArticle();
		msgs = new List<ApexPages.Message>(ApexPages.getMessages());
		system.assert(msgs.size() > 0);
        
        List<FAQ__kav> faqKAVs = [SELECT Id, ArticleNumber, Answer__c, ArticleType, KnowledgeArticleId
                                                 FROM FAQ__kav
                                                 WHERE PublishStatus = 'Online'
                                                 AND Language = 'en_US']; //Can't use a bind on the language filter
        
		List<Product_Facts__kav> pfKAVs = [SELECT Id, ArticleNumber, ArticleType, AAI_Guidelines__c, AMR_Guidelines__c, KnowledgeArticleId
                                                 FROM Product_Facts__kav
                                                 WHERE PublishStatus = 'Online'
                                                 AND Language = 'en_US']; //Can't use a bind on the language filter
        
        con.reviewArticle();
        con.reviewArticleId = faqKAVs[0].Id;
        con.reviewArticle();

        //FAQ clone test + asserts
        con.cloneArticleNumber = faqKAVs[0].ArticleNumber;
        con.cloneArticle();
        
        FAQ__kav newFAQ = [SELECT Id, ArticleNumber, KnowledgeArticleId, ArticleType, Answer__c FROM FAQ__kav WHERE PublishStatus = 'Draft' AND Language = 'en_US' ORDER BY ArticleNumber DESC LIMIT 1];
        system.assertEquals(faqKAVs[0].ArticleType, newFAQ.ArticleType);
        system.assertEquals(faqKAVs[0].Answer__c, newFAQ.Answer__c);
        system.assertNotEquals(faqKAVs[0].Id, newFAQ.Id);
		system.assertNotEquals(faqKAVs[0].KnowledgeArticleId, newFAQ.KnowledgeArticleId); //Can't use articleNumber - not consistently set in unit tests
        
        //FAQ DC asserts...
        List<FAQ__DataCategorySelection> originalFAQDCList = [SELECT Id FROM FAQ__DataCategorySelection WHERE ParentId = :faqKAVs[0].Id];
        List<FAQ__DataCategorySelection> newFAQDCList = [SELECT Id FROM FAQ__DataCategorySelection WHERE ParentId = :newFAQ.Id];
        
        system.assertEquals(originalFAQDCList.size(), newFAQDCList.size());

        //Product Fact clone test + assert
        con.cloneArticleNumber = pfKAVs[0].ArticleNumber;
        con.cloneArticle();

		Product_Facts__kav newPF= [SELECT Id, ArticleNumber, KnowledgeArticleId, ArticleType, AAI_Guidelines__c, AMR_Guidelines__c FROM Product_Facts__kav WHERE PublishStatus = 'Draft' AND Language = 'en_US' ORDER BY ArticleNumber DESC LIMIT 1];
        system.assertEquals(pfKAVs[0].ArticleType, newPF.ArticleType);
        system.assertEquals(pfKAVs[0].AAI_Guidelines__c, newPF.AAI_Guidelines__c);
        system.assertEquals(pfKAVs[0].AMR_Guidelines__c, newPF.AMR_Guidelines__c);
        system.assertNotEquals(pfKAVs[0].Id, newPF.Id);
		system.assertNotEquals(pfKAVs[0].KnowledgeArticleId, newPF.KnowledgeArticleId); //Can't use articleNumber - not consistently set in unit tests

        //PF DC asserts...
		List<Product_Facts__DataCategorySelection> originalPFDCList = [SELECT Id FROM Product_Facts__DataCategorySelection WHERE ParentId = :pfKAVs[0].Id];
        List<Product_Facts__DataCategorySelection> newPFDCList = [SELECT Id FROM Product_Facts__DataCategorySelection WHERE ParentId = :newPF.Id];
        
        system.assertEquals(originalFAQDCList.size(), newFAQDCList.size());
        
		test.stopTest();
    }
    
    @isTest
    static void pageSetupTest(){

       	PageReference pageRef = Page.KnowledgeReview;
        Test.setCurrentPage(pageRef);
        
        ctr_knowledgeReview con = new ctr_knowledgeReview();
        
        test.startTest();
        List<SelectOption> testLanguages = con.Languages;
        system.assert(testLanguages.size() > 0 );
		List<SelectOption> testPubStatuses = con.pubStatuses;
        system.assert(testPubStatuses.size() > 0 );
        test.stopTest();
    }
    
}