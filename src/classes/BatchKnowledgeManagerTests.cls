@isTest
private class BatchKnowledgeManagerTests {

    static testMethod void testPublish() {
        generateTestArticles();
    	Test.startTest();
        Database.executeBatch(new BatchKnowledgeManager('FAQ__kav','en_US','publish'), 10);
        Database.executeBatch(new BatchKnowledgeManager('FAQ__kav','en_US','unpublish'), 10);
		Database.executeBatch(new BatchKnowledgeManager('FAQ__kav','en_US','publishTranslations'), 10);
        Database.executeBatch(new BatchKnowledgeManager('FAQ__kav','en_US','unpublishTranslations'), 10);
      	Test.stopTest();
    }
    
    static testMethod void testUnPublish() {
        generateTestArticles();
        BatchKnowledgeManager unpublish = new BatchKnowledgeManager('FAQ__kav','en_US','unpublish',null); 
        BatchKnowledgeManager publish = new BatchKnowledgeManager('FAQ__kav','en_US','publish',unpublish);
        
        BatchKnowledgeManager unpublishTranslations = new BatchKnowledgeManager('FAQ__kav','en_US','unpublishTranslations',null);
        BatchKnowledgeManager publishTranslations = new BatchKnowledgeManager('FAQ__kav','en_US','publishTranslations',unpublishTranslations);
        
        Test.startTest(); 
        Database.executeBatch(publish,10);
        Database.executeBatch(publishTranslations,10);
        Database.executeBatch(new BatchKnowledgeManager('FAQ__kav','en_US','unpublishTranslations'), 10);
        Test.stopTest(); 
    }
    
    static testMethod void testTranslate() {
        generateTestArticles();
    	Test.startTest();
        Database.executeBatch(new BatchKnowledgeManager('FAQ__kav','en_US','translate'), 10);
        BatchKnowledgeManager translate = new BatchKnowledgeManager('FAQ__kav','en_US','translate',null); 
        Database.executeBatch(translate, 10);
    Test.stopTest();
    }

     static testMethod void testDelete() {
        generateTestArticles();
        
        BatchKnowledgeManager deleteArchived = new BatchKnowledgeManager('FAQ__kav','en_US','deleteArchived');
        BatchKnowledgeManager deleteOnline = new BatchKnowledgeManager('FAQ__kav','en_US','deleteOnline',deleteArchived);
        BatchKnowledgeManager publish = new BatchKnowledgeManager('FAQ__kav','en_US','publish',deleteOnline); 
        Test.startTest(); 
        Database.executeBatch(publish,10);
        Database.executeBatch(new BatchKnowledgeManager('FAQ__kav','en_US','deleteOnline'), 10);
        Test.stopTest(); 
     }
  
    static testMethod void testDeleteDrafts() {
       	generateTestArticles();
        Test.startTest();
        BatchKnowledgeManager deleteDrafts = new BatchKnowledgeManager('FAQ__kav','en_US','deleteDrafts');
        Database.executeBatch(deleteDrafts,10);
        
        BatchKnowledgeManager deleteDraftsNext = new BatchKnowledgeManager('FAQ__kav','en_US','deleteDrafts',null);
        Database.executeBatch(deleteDraftsNext,10);
        Test.stopTest();
    }
    
    static testMethod void testDeleteArchived() {
       	generateTestArticles();
       	BatchKnowledgeManager deleteArchived = new BatchKnowledgeManager('FAQ__kav','en_US','deleteArchived',null);
        Test.startTest();
        Database.executeBatch(deleteArchived,10);
        Test.stopTest();
    }
    
    static testMethod void negativeResultTests() {
       	BatchKnowledgeManager negativeOne = new BatchKnowledgeManager('FAQ__Kav','en_US','fail');
        BatchKnowledgeManager negativeTwo = new BatchKnowledgeManager('FAQ__Kav','en_US','fail',new BatchKnowledgeManager('FAQ__kav','en_US','fail'));
    }
    
    static void generateTestArticles() {
      //List<Job_Aid__kav> jobaidsToInsert = new List<Job_Aid__kav>();
      List<FAQ__kav> faqsToInsert = new List<FAQ__kav>();
      //List<PIN__kav> pinsToInsert = new List<PIN__kav>();
      //List<PLS__kav> plsToInsert = new List<PLS__kav>();
      Integer articleNum = 1;
      for(Integer i = 0;i<10;i++) {
      
        /*Job_Aid__kav docArtA = new Job_Aid__kav(Title='Test Document '+articleNum,URLName = 'TestDocument'+articleNum,Language = 'en_US');
        articleNum++;
        Job_Aid__kav docArtB = new Job_Aid__kav(Title='Test Document '+articleNum,URLName = 'TestDocument'+articleNum,Language = 'en_US');
        articleNum++;
        Job_Aid__kav docArtC = new Job_Aid__kav(Title='Test Document '+articleNum,URLName = 'TestDocument'+articleNum,Language = 'en_US');
        articleNum++;
        jobaidsToInsert.add(docArtA);
        jobaidsToInsert.add(docArtB);
        jobaidsToInsert.add(docArtC);
        */
        FAQ__kav faqArtA = new FAQ__kav(Title='Test FAQ '+articleNum,URLName = 'TestFAQ'+articleNum,Language = 'en_US');
        articleNum++;
        FAQ__kav faqArtB = new FAQ__kav(Title='Test FAQ '+articleNum,URLName = 'TestFAQ'+articleNum,Language = 'en_US');
        articleNum++;
        FAQ__kav faqArtC = new FAQ__kav(Title='Test FAQ '+articleNum,URLName = 'TestFAQ'+articleNum,Language = 'en_US');       
       articleNum++;
       faqsToInsert.add(faqArtA);
       faqsToInsert.add(faqArtB);
       faqsToInsert.add(faqArtC);
       /*
       PIN__kav howArtA = new PIN__kav(Title='Test How_To '+articleNum,URLName = 'TestHowTo'+articleNum,Language = 'en_US');
        articleNum++;
        PIN__kav howArtB = new PIN__kav(Title='Test How_To '+articleNum,URLName = 'TestHowTo'+articleNum,Language = 'en_US');
        articleNum++;
        PIN__kav howArtC = new PIN__kav(Title='Test How_To '+articleNum,URLName = 'TestHowTo'+articleNum,Language = 'en_US');       
       articleNum++;
       pinsToInsert.add(howArtA);
       pinsToInsert.add(howArtB);
       pinsToInsert.add(howArtC);
       
       PLS__kav vidArtA = new PLS__kav(Title='Test Video '+articleNum,URLName = 'TestVideo'+articleNum,Language = 'en_US');
        articleNum++;
        PLS__kav vidArtB = new PLS__kav(Title='Test Video '+articleNum,URLName = 'TestVideo'+articleNum,Language = 'en_US');
        articleNum++;
        PLS__kav vidArtC = new PLS__kav(Title='Test Video '+articleNum,URLName = 'TestVideo'+articleNum,Language = 'en_US');       
        articleNum++;
        plsToInsert.add(vidArtA);
        plsToInsert.add(vidArtB);
        plsToInsert.add(vidArtC);
		*/
      }
      Database.insert(FAQsToInsert);
      //Database.insert(jobaidsToInsert);
      //Database.insert(pinsToInsert);
      //Database.insert(plsToInsert);

    }
}