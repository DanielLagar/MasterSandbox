@isTest
private class KnowledgeMigrationTest {

    static testMethod void knowledgeMigrationTest() {
    	String[] Language = new String[]{'en_US', 'fr','zh_CN', 'nl_NL','de', 'pt_BR', 'es'};
			String[] ArticleType = new String[]{'FAQ__KAV'};
			
			Test.startTest();
			knowledgeMigration.DeleteAllArticles (language, ArticleType );
			knowledgeMigration.TranslateAllArticles (language, ArticleType );
			knowledgeMigration.PublishAllTranslations (language, ArticleType );
			//knowledgeMigration.UnPublishAllTranslations (language, ArticleType );
      knowledgeMigration.PublishAllArticles (language, ArticleType );			
			knowledgeMigration.UnpublishAllArticles (language, ArticleType );
			Test.stopTest();    
    }
}