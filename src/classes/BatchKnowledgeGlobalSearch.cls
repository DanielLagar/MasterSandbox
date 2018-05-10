global class BatchKnowledgeGlobalSearch implements Database.Batchable<sObject>, Database.Stateful {
    Public String strFirstArticleNumber;
    Public String strLastArticleNumber;
    Public String strArticleType;
    Public String strPublishStatus;
    Public String strLanguage;
    
    Private Integer nBatchSize = 9999;
    Private Boolean bDaisyChain = false;
    Private String strApexSearchJobId = ''; 
    Private String strApexSearchJobIdList = '';  
    Private String strApexReplacementJobId = ''; 
    Private Boolean bSearchOnly = false;
    Private Boolean bPublishNewVersion = true;

    Private List<String> listSelectedArticles;
    Private integer nMaxSizePlainTextBody = 16384; // Arbitrary - Have no idea how large the plain text body can be
        
    public String SOQL = '';
    public String strSearchFields = ''; 
    public List<String> listSearchFields; 
    public String strSearchString = '';
    public String strReplacementString = '';

    public Integer UpdateCount = 0;
    public Integer TotalCount = 0;
    
    global BatchKnowledgeGlobalSearch(
        Boolean bSearchOnly, Boolean bPublishNewVersion, 
        String strArticleType, String strPublishStatus, String strLanguage,
        String strSearchFields, String strSearchString, String strReplacementString) {
        
        //Future use: Date dateLastModifiedFrom, Date dateLastModifiedTo) {
        
        // Initialize starting article number
        this.strFirstArticleNumber = '000000999'; // 1000-1
        this.bSearchOnly = bSearchOnly;
        this.bPublishNewVersion = bPublishNewVersion;

        this.strArticleType = strArticleType;
        this.strPublishStatus = strPublishStatus;
        this.strLanguage = strLanguage;
        this.strSearchFields = strSearchFields;    
        this.listSearchFields = strSearchFields.split(',');
        this.strSearchString = strSearchString;
        this.strReplacementString = strReplacementString;
        this.strApexSearchJobIdList = '';
        this.listSelectedArticles = new List<String>();
        
        this.TotalCount = 0;
        this.UpdateCount = 0;        
        
        this.bDaisyChain = false;
    } 
    
    global BatchKnowledgeGlobalSearch(String strFirstArticleNumber, 
    	Boolean bSearchOnly, Boolean bPublishNewVersion,
        String strArticleType, String strPublishStatus, String strLanguage,
        String strSearchFields, String strSearchString, String strReplacementString,
        String strApexSearchJobIdList, Integer nTotalCount, Integer nUpdateCount,
        List<String> listSelectedArticles) {
        
        //Future use: Date dateLastModifiedFrom, Date dateLastModifiedTo) {
        
        // Initialize starting article number
        this.strFirstArticleNumber = strFirstArticleNumber;
        this.bSearchOnly = bSearchOnly;
        this.bPublishNewVersion = bPublishNewVersion;        

        this.strArticleType = strArticleType;
        this.strPublishStatus = strPublishStatus;
        this.strLanguage = strLanguage;        
        this.strSearchFields = strSearchFields;    
        this.listSearchFields = strSearchFields.split(',');
        this.strSearchString = strSearchString;
        this.strReplacementString = strReplacementString;
        this.strApexSearchJobIdList = strApexSearchJobIdList;
        this.listSelectedArticles = listSelectedArticles;
        
        this.TotalCount += nTotalCount;
        this.UpdateCount += nUpdateCount;
        
        this.bDaisyChain = false;
    } 
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        this.strApexSearchJobId = BC.getJobId();
        if (this.strApexSearchJobIdList.length() > 0) this.strApexSearchJobIdList +=',';
        this.strApexSearchJobIdList += strApexSearchJobId;
        
        definePayload();   
        determineNextScope(); 

        String strQuery = 'SELECT ArticleId__c from KB_Global_Search_Scope__c';
        strQuery += ' WHERE Apex_BatchId__c=\''+this.strApexSearchJobId+'\'';

        return database.getquerylocator(strQuery);      
    }
    
    private void definePayload() {
        String strQuery = '';
        strQuery += 'SELECT Id, KnowledgeArticleId, ArticleNumber FROM '+this.strArticleType;
        strQuery += ' WHERE PublishStatus = \''+this.strPublishStatus+'\'';
        strQuery += ' AND Language = \''+this.strLanguage+'\'';
        strQuery += ' AND ArticleNumber > \''+this.strFirstArticleNumber+'\'';
        strQuery += ' ORDER BY ArticleNumber LIMIT '+nBatchSize;
        
        List <sObject> articles = Database.query(strQuery);
        
        List <KB_Global_Search_Scope__c> listGSS = new List<KB_Global_Search_Scope__c>();
        Integer nCount = 0;
        this.strLastArticleNumber = '000000000';        
        
        if (articles != null && articles.size() > 0) {
            For (sObject article : articles) {
                String strArticleNumber = (String)article.get('ArticleNumber'); 
                
                KB_Global_Search_Scope__c searchScopeArticle = new KB_Global_Search_Scope__c();
                searchScopeArticle.ArticleId__c = article.Id;
                searchScopeArticle.KnowledgeArticleId__c = (String)article.get('KnowledgeArticleId');
                searchScopeArticle.ArticleNumber__c = strArticleNumber;
                searchScopeArticle.Apex_BatchId__c = this.strApexSearchJobId;
                listGSS.add(searchScopeArticle);

                this.strLastArticleNumber = strArticleNumber;
            }
        
            try {
                Database.insert(listGSS);
            } catch (Exception ex){
                String errMsg = ex.getMessage();
                system.Debug(errMsg);
            } 
        }
        
        return;
    }
   
    private void determineNextScope() {
        String strQuery = '';
        strQuery += 'SELECT Id, KnowledgeArticleId, ArticleNumber FROM '+this.strArticleType;
        strQuery += ' WHERE PublishStatus = \''+this.strPublishStatus+'\'';
        strQuery += ' AND Language = \''+this.strLanguage+'\'';
        strQuery += ' AND ArticleNumber > \''+this.strLastArticleNumber+'\'';
        strQuery += ' ORDER BY ArticleNumber LIMIT 1';
        
        List <sObject> articles = Database.query(strQuery);
        
        // Determine if more articles exist - if so, configure daisy chain  
        if (articles != null && articles.size() > 0) {
            this.bDaisyChain = true;
        }
    }
       
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        String strScopeIds = '';
        for (sObject scopeObject : scope) {
            if (strScopeIds.length()>0) strScopeIds += ',';
            strScopeIds += '\''+(String)scopeObject.get('ArticleId__c')+'\'';
        }        
        
        // Base SOQL construct
        String strQuery = '';
        if (strSearchFields.toLowerCase().indexOf('title')<0) strSearchFields = 'Title, '+strSearchFields;
        
        strQuery += 'SELECT Id, KnowledgeArticleId, ArticleNumber, IsMasterLanguage';        
        if (strSearchFields != null && strSearchFields.length()>0) strQuery += ','+strSearchFields;
        strQuery += ' FROM '+this.strArticleType;          
        strQuery += ' WHERE Id IN ('+strScopeIds+')';

        List <sObject> articles = new List<sObject>();
        articles = Database.query(strQuery);
        
        try {
            globalSearchandReplace(articles);
        } catch (Exception ex){
            String errMsg = ex.getMessage();
            system.Debug(errMsg);
        } 
    }
    
    public void globalSearchAndReplace(List<sObject> batchArticles){
        String strRegEx = this.strSearchString;
        Pattern strSearchStringPattern = Pattern.compile(strRegEx);  
        
        List<KB_Global_Search_And_Replace__c> listGSR = new List<KB_Global_Search_And_Replace__c>();
        
        for(sObject article : batchArticles) {
            this.TotalCount++;
            
            // Perform search on selected field(s)
            String strReplacementFields = '';              
            if (listSearchFields.size() > 0) {
                for (String strFieldName: listSearchFields) {
                    String strFieldValue = (String)article.get(strFieldName);
                    if (strFieldValue == null) continue;
                    Matcher matcher = strSearchStringPattern.matcher(strFieldValue);

                    if (matcher.find()) {
                        if (strReplacementFields.length()>0) strReplacementFields += ',';
                        strReplacementFields +=strFieldName;
                    }
                }
            }
            if (strReplacementFields.length()>0) {
                this.UpdateCount++;  

                this.listSelectedArticles.add('Article Number='+(String)article.get('ArticleNumber')+
                    ' Title='+(String)article.get('Title')+' Language='+strLanguage+'\n');
                
                if (!bSearchOnly) {         
                    KB_Global_Search_And_Replace__c modifyArticle = new KB_Global_Search_And_Replace__c();
                    
                    // Copy metadata from batch article to work queue
                    modifyArticle.Apex_BatchId__c = this.strApexSearchJobId;
                    modifyArticle.ArticleId__c = article.Id;
                    modifyArticle.Article_Type__c = this.strArticleType;
                    modifyArticle.ArticleNumber__c = (String)article.get('ArticleNumber'); 
                    modifyArticle.KnowledgeArticleId__c = (String)article.get('KnowledgeArticleId'); 
                    modifyArticle.PublishStatus__c = this.strPublishStatus;
                    modifyArticle.PublishNewVersion__c = String.valueOf(this.bPublishNewVersion);
                    modifyArticle.Language__c = String.valueOf(this.strLanguage);
                    modifyArticle.IsMasterLanguage__c = String.valueOf((Boolean)article.get('IsMasterLanguage'));
                    modifyArticle.Field_Names__c = strReplacementFields;
                    modifyArticle.Search_String__c = this.strSearchString;
                    modifyArticle.Replacement_String__c = this.strReplacementString;

                    listGSR.add(modifyArticle);
                }                
            }
        }
        
        if (!bSearchOnly && listGSR != null && listGSR.size() > 0) {
            try {
                Database.insert(listGSR);      
            } catch (Exception ex){
                String errMsg = ex.getMessage();
                system.Debug(errMsg);
            } 
         }        

    }
    
    
    global void finish(Database.BatchableContext BC){
        // Clean up all scope records processed in this batch
        List <KB_Global_Search_Scope__c> listGSS = [select Id from KB_Global_Search_Scope__c where Apex_BatchId__c = :strApexSearchJobId];
        try {
            Database.delete(listGss);
        } catch (Exception ex){
            String errMsg = ex.getMessage();
            system.Debug(errMsg);
        }         

        if (bDaisyChain) {
            // If more articles of this type remain to be processed,
            // perform iterative call of search batch class
            BatchKnowledgeGlobalSearch b = new BatchKnowledgeGlobalSearch(
            this.strLastArticleNumber, this.bSearchOnly, this.bPublishNewVersion,
            this.strArticleType, this.strPublishStatus, this.strLanguage,
            this.strSearchFields, this.strSearchString, this.strReplacementString,
            this.strApexSearchJobIdList, this.TotalCount, this.UpdateCount,
            this.listSelectedArticles);
            database.executebatch(b,500);
        } else {
            // Otherwise immediately launch physical replace batch class
            
            if (!bSearchOnly) {
                BatchKnowledgeGlobalReplace batch = new BatchKnowledgeGlobalReplace(this.strApexSearchJobIdList);
                this.strApexReplacementJobId = Database.executeBatch(batch, 50);              
            } else {
                this.strReplacementString = '**Search Only - No Replacement**';
            }
       
            KB_Global_Search_History__c searchHistory = new KB_Global_Search_History__c();
            // In parent controller, the Database.executebatch method only returns first 15 characters of job id
            searchHistory.Apex_BatchId_List__c = this.strApexSearchJobIdList;
            searchHistory.Articles_Searched__c = TotalCount;
            searchHistory.Articles_Selected__c = UpdateCount; 
            searchHistory.Apex_Replacement_BatchId__c = this.strApexReplacementJobId;
            searchHistory.Search_String__c = this.strSearchString;
            searchHistory.Replacement_String__c = this.strReplacementString;
            searchHistory.Field_Names__c = this.strSearchFields;
            searchHistory.Article_Type__c = this.strArticleType;
            searchHistory.PublishStatus__c = this.strPublishStatus;
            searchHistory.Language__c = this.strLanguage;
            searchHistory.PublishNewVersion__c = String.valueOf(this.bPublishNewVersion);
            
            try {
                Database.insert(searchHistory);      
            } catch (Exception ex){
                String errMsg = ex.getMessage();
                system.Debug(errMsg);
            }                          
                                    
            // Query the AsyncApexJob object to retrieve the current job's metadata.
            AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
               TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :this.strApexSearchJobId];             
               
            // Email the Batch Job's submitter that the Job is finished.
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Salesforce Knowledge Global Search and Replace-Search Complete');
            String strPlainTextBody = 

             'Article Type='+this.strArticleType+'\n'+
             'Publish Status='+this.strPublishStatus+'\n'+
             'PublishNewVersion='+String.valueOf(this.bPublishNewVersion)+'\n'+
             'Language='+this.strLanguage+'\n'+             
             'Search Fields='+this.strSearchFields+'\n'+
             'Search String='+this.strSearchString+'\n'+
             'Replacement String='+this.strReplacementString+'\n\n\n'+
             'Total number of articles searched='+TotalCount+'\n'+
             'Total number of articles selected for update='+UpdateCount+'\n\n\n'+
             'Salesforce.com Job Statistics:\n'+
             'Number of Errors='+a.NumberOfErrors+'\n'+
             'Status='+a.Status+'\n\n'+
             'Articles Identified for Replacement:\n';
             
            Integer nLogTitleCount = 0;
            if (this.listSelectedArticles != null && this.listSelectedArticles.size() > 0) {
                for (String strArticleLog : this.listSelectedArticles) {
                    if (strPlainTextBody.length()<nMaxSizePlainTextBody ) {
                        nLogTitleCount++;
                        strPlainTextBody += strArticleLog+'\n';
                    } else {
                        strPlainTextBody += '...'+(UpdateCount-nLogTitleCount)+' titles omitted';
                        break;
                    }
                }
            } else {
                strPlainTextBody += 'None';
            }
             
            mail.setPlainTextBody(strPlainTextBody);
              
            if (!Test.isRunningTest()) {  
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });         
            }
        }      
    }
}