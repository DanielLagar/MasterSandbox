global class BatchKnowledgeGlobalReplace implements Database.Batchable<sObject>, Database.Stateful {
    Private Integer nBatchSize = 100;
    Private String strApexBatchJobId = '';    
    Private String strSearchJobIdList = '';

    Private String strArticleType = '';
    Private String strPublishStatus = '';
    Private Boolean bPublishNewVersion = false;
    Private String strLanguage = '';
    Private Boolean bIsMasterLanguage = true;
    Private String strSearchString = '';
    Private String strReplacementString = '';
    Private String strFieldNames = '';
    
    public Integer UpdateCount = 0;
    public Integer TotalCount = 0;
    public String  strReplacementLog = '';
    
	Private integer nMaxSizePlainTextBody = 16384; // Arbitrary - Have no idea how large the plain text body can be
    
    global BatchKnowledgeGlobalReplace(String strSearchJobIdList) { 

        List<String> listSearchJobIds = strSearchJobIdList.split(',');
        String strFormattedSearchJobIds = '';
        for (String strSearchJobId : listSearchJobIds) {
            if (strFormattedSearchJobIds.length()>0) strFormattedSearchJobIds += ',';
            strFormattedSearchJobIds += '\''+strSearchJobId+'\'';
        }        
        
        this.strSearchJobIdList = strFormattedSearchJobIds;
        System.debug('strFormattedSearchJobIds='+strFormattedSearchJobIds);
        
        this.strReplacementLog = '';
    } 
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        this.strApexBatchJobId = BC.getJobId();

        String strQuery = 'SELECT Id from KB_Global_Search_And_Replace__c';
        strQuery += ' WHERE Apex_BatchId__c IN ('+this.strSearchJobIdList+') ';
        System.debug('this.strSearchJobIdList='+this.strSearchJobIdList);
        return database.getquerylocator(strQuery);      
    }
   
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        String strScopeIds = '';
        for (sObject scopeObject : scope) {
            if (strScopeIds.length()>0) strScopeIds += ',';
            strScopeIds += '\''+(String)scopeObject.get('Id')+'\'';
        }        
        
        // Base SOQL construct
        String strQuery = '';
        strQuery += 'SELECT Id, ArticleId__c, KnowledgeArticleId__c, Article_Type__c, ';
        strQuery += ' Language__c, IsMasterLanguage__c, ';   
        strQuery += ' PublishStatus__c, PublishNewVersion__c, ';
        strQuery += ' Search_String__c, Replacement_String__c, Field_Names__c '; 
        strQuery += ' FROM KB_Global_Search_And_Replace__c';          
        strQuery += ' WHERE Id IN ('+strScopeIds+')';

        List <sObject> tasks = new List<sObject>();
        tasks = Database.query(strQuery);
        
        try {
            globalReplace(tasks);
        } catch (Exception ex){
            String errMsg = ex.getMessage();
            system.Debug(errMsg);
            //AppLogModel.addLogError('BatchKnowledgeGlobalReplace', 'Exception Caught '+errMsg+' at Line '+ex.getLineNumber(), 
            //    ex.getStackTraceString());
        } finally {
            //AppLogModel.flushLogs();            
        }
    }
    
    public void globalReplace(List<sObject> searchAndReplaceTasks){
        for(sObject task: searchAndReplaceTasks) {
            this.TotalCount++;
            
            String strTaskId = task.Id;
            String strArticleId = (String)task.get('ArticleId__c');
            String strKnowledgeArticleId = (String)task.get('KnowledgeArticleId__c');
            this.strArticleType = (String)task.get('Article_Type__c');       
            this.strLanguage = (String)task.get('Language__c'); 
            this.bIsMasterLanguage = Boolean.valueOf((String)task.get('IsMasterLanguage__c'));                              
            this.strFieldNames = (String)task.get('Field_Names__c');
            this.strPublishStatus = (String)task.get('PublishStatus__c');
            this.bPublishNewVersion = Boolean.valueOf((String)task.get('PublishNewVersion__c'));            
            List <String> listFieldNames = this.strFieldNames.split(',');
            
            // Create new draft of article to be updated (if required)
            String strDraftId = '';
            String strQuery = '';
            String strArticleNumber = '';
            String strArticleTitle = '';
            
            if (this.strPublishStatus.equals('Online')) {
                // Determine if draft of published article already exists
                strQuery = 'SELECT Id, ArticleNumber, Title';
                strQuery += ' FROM '+this.strArticleType;
                strQuery += ' WHERE KnowledgeArticleId = \''+strKnowledgeArticleId +'\' ';
                strQuery += ' AND PublishStatus = \'Draft\' ';
                strQuery += ' AND Language = \''+strLanguage+'\' ';

                List <sObject> listExistingDrafts = Database.query(strQuery); 
                
                if (listExistingDrafts != null && listExistingDrafts.size() >= 1) {
                    strDraftId = listExistingDrafts[0].Id;
                    strArticleNumber = (String)listExistingDrafts[0].get('ArticleNumber');
                    strArticleTitle = (String)listExistingDrafts[0].get('Title');
                    
                    this.strPublishStatus = 'Draft';
                    strReplacementLog += 'Draft exists for article '+strArticleNumber+' Title='+strArticleTitle+' Language='+strLanguage+' (will be kept as Draft)\n';   
                } else {
                	if (bIsMasterLanguage) {
                    	strDraftId = KbManagement.PublishingService.editOnlineArticle(strKnowledgeArticleId, false);
                	} else {
                		strDraftId = KbManagement.PublishingService.editPublishedTranslation(strKnowledgeArticleId, strLanguage, false);
                	}    
                }
            } else {
                strDraftId = strArticleId;
            }

            // Get new (or existing) draft of article
	        if (this.strFieldNames.toLowerCase().indexOf('title')<0) this.strFieldNames = 'Title, '+this.strFieldNames;
            
            strQuery = 'SELECT ArticleNumber, '+this.strFieldNames;
            strQuery += ' FROM '+this.strArticleType;
            strQuery += ' WHERE Id = \''+strDraftId+'\'';
            
            List <sObject> listDrafts = Database.query(strQuery);
            
            // Iterate through fields and perform string replacement(s)
            if (listDrafts != null && listDrafts.size() == 1) {
                sObject draft = listDrafts[0];
                
                strArticleNumber = (String)draft.get('ArticleNumber');
                strArticleTitle = (String)draft.get('Title');
                
                this.strSearchString = (String)task.get('Search_String__c');
                this.strReplacementString = (String)task.get('Replacement_String__c');
                
                System.debug('*** Batch Knowledge Global Replace *** Search String='+this.strSearchString);
                System.debug('*** Batch Knowledge Global Replace *** Replacement String='+this.strReplacementString);
                
                String strRegEx = this.strSearchString;
                Pattern strSearchStringPattern = Pattern.compile(strRegEx);
                              
                for (String strFieldName: listFieldNames) {
                    String strFieldValue = (String)draft.get(strFieldName);
                    
                    System.debug('*** Batch Knowledge Global Replace *** Field Name='+strFieldName);
                    System.debug('*** Batch Knowledge Global Replace *** Field Value='+strFieldValue);
                    
                    Matcher matcher = strSearchStringPattern.matcher(strFieldValue);

                    draft.put(strFieldName, matcher.replaceAll(this.strReplacementString));
                    
                    System.debug('*** Batch Knowledge Global Replace *** Field='+strFieldName+' New Value='+draft.get(strFieldName));
                }
                this.UpdateCount++;
                Database.SaveResult results = Database.update(draft);
                
                // Republish updated Draft article (if article was originally published)
                if (results.isSuccess()) {
                    if (strPublishStatus.equals('Online')) {
                    	if (bIsMasterLanguage) {
                    		KbManagement.PublishingService.publishArticle(strKnowledgeArticleId, bPublishNewVersion);
                    	} else {
                    		// Mark translation as complete - this actually publishes the translation
                    		KbManagement.PublishingService.completeTranslation(strDraftId);
                    	} 
                    	strReplacementLog += 'Modified and republished article '+strArticleNumber+' Title='+strArticleTitle+' Language='+strLanguage+'\n';                  		
                    } else {
                    	strReplacementLog += 'Modified and retained draft article '+strArticleNumber+' Title='+strArticleTitle+' Language='+strLanguage+'\n';
                    }
                } else {
                    strReplacementLog += 'Unable to update draft article '+strArticleNumber+' Title='+strArticleTitle+' Language='+strLanguage+'\n';
                }
            } 
        }
    }
    
    
    global void finish(Database.BatchableContext BC){
        // Clean up
        List <KB_Global_Search_And_Replace__c> listGSR = [select Id from KB_Global_Search_And_Replace__c where Apex_BatchId__c IN (:this.strSearchJobIdList)];
        Database.delete(listGSR);  
             
        String strQuery = '';
        List<KB_Global_Search_History__c> listSearchStatus = new List<KB_Global_Search_History__c>();
        
        strQuery += 'SELECT Id, Articles_Searched__c, Articles_Updated__c';
        strQuery += ' FROM KB_Global_Search_History__c';
        strQuery += ' WHERE Apex_Replacement_BatchId__c LIKE \'%'+this.strApexBatchJobId.substring(0,15)+'%\' ';
        
        listSearchStatus = Database.query(strQuery);             

        if (listSearchStatus != null && listSearchStatus.size() > 0) {
            KB_Global_Search_History__c searchStatus = listSearchStatus[0];
            
            searchStatus.Articles_Updated__c = this.UpdateCount;
            this.TotalCount = Integer.valueOf(searchStatus.Articles_Searched__c);
            Database.update(searchStatus);
        }
                                
        // Query the AsyncApexJob object to retrieve the current job's metadata.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
           TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :this.strApexBatchJobId];             
           
        // Email the Batch Job's submitter that the Job is finished.
        if (strReplacementLog.length()>nMaxSizePlainTextBody) {
        	strReplacementLog = strReplacementLog.substring(0,nMaxSizePlainTextBody) + '...truncated';
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Salesforce Knowledge Global Search and Replace-Replacement Complete');
        mail.setPlainTextBody(
         'Article Type='+this.strArticleType+'\n'+
         'Publish Status='+this.strPublishStatus+'\n'+
         'Search Fields='+this.strFieldNames+'\n'+
         'Search String='+this.strSearchString+'\n'+
         'Replacement String='+this.strReplacementString+'\n\n\n'+
         'Total number of articles searched='+this.TotalCount+'\n'+
         'Total number of articles updated='+this.UpdateCount+'\n\n\n'+
         'Salesforce.com Job Statistics:\n'+
         'Number of Errors='+a.NumberOfErrors+'\n'+
         'Status='+a.Status+'\n\n'+
         'Replacement Log:'+'\n'+
         strReplacementLog         
         );
          
          
        if (!Test.isRunningTest()) {  
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}