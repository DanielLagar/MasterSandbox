@isTest
private class BatchKnowledgeGlobalSearchAndReplaceTest {
    static List<String> getArticleTypes(){
        List<String> listArticleTypes = new List<String>();
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe(); 
        if(globalDescribe != null && !globalDescribe.isEmpty()){
            for(String key : globalDescribe.keySet()){
                if(key.endsWith('__kav')){
                    System.debug('Article Type='+key);
                    sObject sArticleType = Schema.getGlobalDescribe().get(key).newSObject();
                    Schema.DescribeSObjectResult r = sArticleType.getSObjectType().getDescribe();                    
                    Map<String, Schema.SObjectField> mapFields = r.fields.getMap();
                    for (Schema.SObjectField field : mapFields.values()) {
                        Schema.DescribeFieldResult f = field.getDescribe();
                        System.debug('Field Name='+f.getName());
                        System.debug('Field Type='+f.getType());
                        if (f.getName().equalsIgnoreCase('Title')) continue;
                        if (f.getName().equalsIgnoreCase('UrlName')) continue;
                        if (f.getName().equalsIgnoreCase('ArticleNumber')) continue;
                        if (f.getName().toLowerCase().endsWith('name__s')) continue;
                        if (f.getType() == Schema.DisplayType.String || 
                            f.getType() == Schema.DisplayType.TextArea) {
                            listArticleTypes.add(key+','+f.getName());
                            break; // Only need first text field for test
                        }
                    }
                }
            }
        }
        
        return listArticleTypes;
    }
    
    static testMethod void runPositiveTestCase() {
    
        List<String> listArticleTypes = getArticleTypes();
        System.assertNotEquals(listArticleTypes.size(), 0);
        
        String strArticleType = listArticleTypes[0].substring(0,listArticleTypes[0].indexOf(','));
        String strSearchField = listArticleTypes[0].substring(listArticleTypes[0].indexOf(',')+1);
        
        System.debug('strArticleType='+strArticleType);
        System.debug('strSearchField='+strSearchField);
        
        String strPublishStatus = 'Draft';
        String strLanguage = 'en_US';
        Boolean bPublishNewVersion = false;
    
        // Create a new draft article for testing purposes
        
        String strArticleTitle = 'Knowledge Global Search and Replace Test Article';
        String strArticleUrlName = 'Knowledge-Global-Search-and-Replace-Test-Article';
        String strSearchString = 'is for testing purposes only';
        String strReplacementString = 'was modified during test';
        String strOriginalFieldValue = 'This article '+strSearchString; 
        String strFinalFieldValue = 'This article '+strReplacementString; 
      
        sObject objNewArticle = Schema.getGlobalDescribe().get(strArticleType).newSObject();
        
        objNewArticle.put('Title',strArticleTitle);
        objNewArticle.put('UrlName',strArticleUrlName);
        objNewArticle.put(strSearchField, strOriginalFieldValue);
        
        insert(objNewArticle);

        // Retrieve new draft article
        sObject[] listDraftArticle = 
            Database.query('SELECT Id, '+strSearchField+' FROM '+strArticleType
                + ' WHERE Title=\''+strArticleTitle+'\''
                + ' AND PublishStatus=\''+strPublishStatus+'\''
                + ' AND Language=\''+strLanguage+'\' LIMIT 1');
        
        System.assertEquals(listDraftArticle.size(), 1);
        Id draftArticleId = listDraftArticle[0].Id;
        
        // Perform search and replace operation
        Id batchId = null;
        Boolean bSearchOnly = false;

        BatchKnowledgeGlobalSearch batch =
            new BatchKnowledgeGlobalSearch(bSearchOnly, bPublishNewVersion,
            	strArticleType, strPublishStatus, strLanguage,
                strSearchField, strSearchString, strReplacementString);
                
        batchId = Database.executeBatch(batch, 500); 
        System.assertNotEquals(batchId, null);        

        // Perform search only on daisy-chain constructor        
        batchId = null;
        bSearchOnly = true;
        List<String> listTitles = new List<String>();
        
        batch =
            new BatchKnowledgeGlobalSearch('000000001', bSearchOnly, bPublishNewVersion,
            	strArticleType, strPublishStatus, strLanguage,
                strSearchField, strSearchString, strReplacementString, '', 0, 0, listTitles);
                
        batchId = Database.executeBatch(batch, 500); 
        System.assertNotEquals(batchId, null);
    }
}