global without sharing class BatchKnowledgeManager implements Database.Batchable<sObject>{

    global final string query;
    global final string articleType;
    global final string language;
    global final string operation;
    global final string assigneeId = '00580000008QpB9';
    global final Datetime dueDate = Datetime.newInstanceGmt(2012, 12,1);
    global final BatchKnowledgeManager nextRun;
    
    global BatchKnowledgeManager(String kavType,String languageCode,String operationType) {
        articleType = kavType;
        language = languageCode;
        operation = operationType;
        if(operation == 'translate') {
            query = 'SELECT Title, Id, KnowledgeArticleId, PublishStatus, VersionNumber, Language FROM '+articleType+' WHERE PublishStatus =\'Draft\' AND language =\''+language+'\' and Legacy_ID__c != null'; 
        }
  
        else if(operation == 'publish') {
            query = 'SELECT Id,KnowledgeArticleId,IsMasterLanguage, PublishStatus FROM '+articleType+' WHERE PublishStatus =\'Draft\' AND language = \''+language +'\' and Legacy_ID__c != null and Legacy_ID__c !=\'Remove\'' ;  
        }

        else if(operation == 'publishTranslations') {
           query = 'SELECT Id,KnowledgeArticleId,IsMasterLanguage, PublishStatus FROM '+articleType+' WHERE PublishStatus =\'Draft\' AND language = \''+language+'\' AND IsMasterLanguage = false  and Legacy_ID__c != null and Legacy_ID__c  !=\'Remove\'';          
        }    
    
        else if(operation == 'deleteOnline') {
            query = 'SELECT Id,KnowledgeArticleId, PublishStatus, IsMasterLanguage FROM '+articleType+' WHERE PublishStatus =\'Online\' AND language = \''+language +'\' and Legacy_ID__c != null';    
        }

        else if(operation == 'deleteArchived') {
            query = 'SELECT Id,KnowledgeArticleId, PublishStatus, IsMasterLanguage FROM '+articleType+' WHERE PublishStatus =\'Archived\' AND language = \''+language +'\' and Legacy_ID__c != null';            
        }

        else if(operation == 'deleteDrafts') {
            query = 'SELECT Id,KnowledgeArticleId, PublishStatus, IsMasterLanguage FROM '+articleType+' WHERE PublishStatus =\'Draft\' AND language = \''+language +'\' and Legacy_ID__c != null';            
        }


        else if(operation == 'unpublish') {
            query = 'SELECT Id,KnowledgeArticleId,PublishStatus,IsMasterLanguage FROM '+articleType+' WHERE PublishStatus = \'Online\' AND language = \''+language +'\' and Legacy_ID__c != null';
        }


    else if(operation == 'unpublishTranslations') {
            query = 'SELECT Id,KnowledgeArticleId,PublishStatus,IsMasterLanguage FROM '+articleType+' WHERE PublishStatus = \'Online\' AND language = \''+language+'\' AND IsMasterLanguage = false  and Legacy_ID__c != null';    
        }
        else if(operation == 'DeleteRemove') {
            query = 'SELECT Id,KnowledgeArticleId,PublishStatus,IsMasterLanguage FROM '+articleType+' WHERE PublishStatus = \'Draft\' AND language = \''+language+'\' and Legacy_ID__c =\'Remove\'';    
        }
        


       else {
            query = '';
        }
    }
 
    global BatchKnowledgeManager(String kavType,String languageCode,String operationType,BatchKnowledgeManager next) {
        articleType = kavType;
        language = languageCode;
        operation = operationType;
        nextRun = next;
        if(operation == 'translate') {
            query = 'SELECT Title, Id, KnowledgeArticleId, PublishStatus, VersionNumber, Language FROM '+articleType+' WHERE PublishStatus =\'Draft\' AND language =\''+language+'\' and Legacy_ID__c != null'; 
        }
        else if(operation == 'publish') {
            query = 'SELECT Id,KnowledgeArticleId,IsMasterLanguage, PublishStatus FROM '+articleType+' WHERE PublishStatus =\'Draft\' AND language = \''+language+'\' and Legacy_ID__c != null and Legacy_ID__c  !=\'Remove\'';  
        }

        else if(operation == 'publishTranslations') {
           query = 'SELECT Id,KnowledgeArticleId,IsMasterLanguage, PublishStatus FROM '+articleType+' WHERE PublishStatus =\'Draft\' AND language = \''+language+'\' AND IsMasterLanguage = false  and Legacy_ID__c != null and Legacy_ID__c  !=\'Remove\'';          
        }

        else if(operation == 'deleteOnline') {
            query = 'SELECT Id,KnowledgeArticleId, PublishStatus, IsMasterLanguage FROM '+articleType+' WHERE PublishStatus =\'Online\' AND language = \''+language+'\' and Legacy_ID__c != null';    
        }

        else if(operation == 'deleteDrafts') {
            query = 'SELECT Id,KnowledgeArticleId, PublishStatus, IsMasterLanguage FROM '+articleType+' WHERE PublishStatus =\'Draft\' AND language = \''+language+'\' and Legacy_ID__c != null';    
        }

        else if(operation == 'deleteArchived') {
            query = 'SELECT Id,KnowledgeArticleId, PublishStatus, IsMasterLanguage FROM '+articleType+' WHERE PublishStatus =\'Archived\' AND language = \''+language+'\'  and Legacy_ID__c != null';    
        }

        else if(operation == 'unpublish') {
            query = 'SELECT Id,KnowledgeArticleId,PublishStatus,IsMasterLanguage FROM '+articleType+' WHERE PublishStatus = \'Online\' AND language = \''+language+'\'  and Legacy_ID__c != null';
        }

        else if(operation == 'unpublishTranslations') {
            query = 'SELECT Id,KnowledgeArticleId,PublishStatus,IsMasterLanguage FROM '+articleType+' WHERE PublishStatus = \'Online\' AND language = \''+language+'\' AND IsMasterLanguage = false  and Legacy_ID__c != null';    
        } 
        else if(operation == 'DeleteRemove') {
            query = 'SELECT Id,KnowledgeArticleId,PublishStatus,IsMasterLanguage FROM '+articleType+' WHERE PublishStatus = \'Draft\' AND language = \''+language+'\' and Legacy_ID__c =\'Remove\'';    
        }  
     
      else {
            query = '';
        }
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext context) {
        system.debug('query:' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext context, List<sObject> scope) {
        for(sObject obj : scope) {
            String articleId = (String)obj.get('KnowledgeArticleId');
            if(operation == 'translate') {
                try {
                        String germanId = KbManagement.PublishingService.submitForTranslation(articleId, 'de', assigneeId, dueDate);
                }
               
                catch(Exception e) {
                    system.debug(e);   
                }        
                 try {
                        String spanishId = KbManagement.PublishingService.submitForTranslation(articleId, 'es', assigneeId, dueDate);
                }
               
                catch(Exception e) {
                    system.debug(e);   
                }        
                try {
                        String FrenchId = KbManagement.PublishingService.submitForTranslation(articleId, 'fr', assigneeId, dueDate);
                        }
               
               
                catch(Exception e) {
                    system.debug(e);   
                }
                try {       
                        String JapaneseId = KbManagement.PublishingService.submitForTranslation(articleId, 'ja', assigneeId, dueDate);
                        }
               
          
               
                catch(Exception e) {
                    system.debug(e);   
                }
                try {        
                        String ChinSimpId = KbManagement.PublishingService.submitForTranslation(articleId, 'zh_CN', assigneeId, dueDate);
                        }
               
                catch(Exception e) {
                    system.debug(e);   
                }
                try {        
                        String ProtBraId = KbManagement.PublishingService.submitForTranslation(articleId, 'pt_BR', assigneeId, dueDate);
                        }
               
                catch(Exception e) {
                    system.debug(e);   
                }
               try {        
                        String DutchId = KbManagement.PublishingService.submitForTranslation(articleId, 'nl_NL', assigneeId, dueDate);
                        }
               
                catch(Exception e) {
                    system.debug(e);   
                }
                try {        
                        String EnglishId = KbManagement.PublishingService.submitForTranslation(articleId, 'en_US', assigneeId, dueDate);
                        }
               
                catch(Exception e) {
                    system.debug(e);   
                }         
            }
            else if(operation == 'publish' || operation == 'publishTranslations') {
                if((Boolean)obj.get('IsMasterLanguage')) {
                  try {
                      KbManagement.PublishingService.publishArticle(articleId,true);
                  }
                  catch(Exception e) {
                      system.debug(e);   
                  }
             /*     try {
                      if((String)obj.get('Legacy_Status__c') == 'Archived') KbManagement.PublishingService.archiveOnlineArticle(articleId,null);
                  }
                  catch(Exception e) {
                      system.debug(e);   
                  }*/
                }
                else {
                  try {
                    KbManagement.PublishingService.completeTranslation((String)obj.get('Id'));
                  }
                  catch(Exception e) {
                    system.debug(e)  ;
                  }
                  
                }
            } 
            else if(operation == 'deleteOnline') {
                try {
                    KbManagement.PublishingService.archiveOnlineArticle(articleId,null);
                    KbManagement.PublishingService.deleteArchivedArticle(articleId);
                }
                catch(Exception e) {
                    system.debug(e);   
                }
            }
            else if(operation == 'deleteArchived') {
                try {
                    KbManagement.PublishingService.deleteArchivedArticle(articleId);                
                }
                catch(Exception e) {
                    system.debug(e);   
                }
            }
            else if(operation == 'deleteDrafts') {
                if((Boolean)obj.get('IsMasterLanguage')) {
                    try {
                        KbManagement.PublishingService.deleteDraftArticle(articleId);
                    }
                    catch(Exception e) {
                        system.debug(e);   
                    }
                }
                else {
                    try {
                        KbManagement.PublishingService.deleteDraftTranslation((String)obj.get('Id'));
                    }
                    catch(Exception e) {
                        system.debug(e);   
                    }                          
                }
            }
            
            else if(operation == 'DeleteRemove') {
                if((Boolean)obj.get('IsMasterLanguage')) {
                    try {
                        KbManagement.PublishingService.deleteDraftArticle(articleId);
                    }
                    catch(Exception e) {
                        system.debug(e);   
                    }
                }
                else {
                    try {
                        KbManagement.PublishingService.deleteDraftTranslation((String)obj.get('Id'));
                    }
                    catch(Exception e) {
                        system.debug(e);   
                    }                          
                }
            }
            
            else if(operation == 'unpublish' || operation == 'unpublishTranslations') {
                if((Boolean)obj.get('IsMasterLanguage')) {
                    try {
                        KbManagement.PublishingService.editOnlineArticle(articleId,true);
                    }
                    catch(Exception e) {
                        system.debug(e);   
                    }
                }
                else {
                    try {
                        KbManagement.PublishingService.editPublishedTranslation(articleId,language,true);
                    }
                    catch(Exception e) {
                        system.debug(e);   
                    }                          
                }               
            }
        }            
    }
    
    global void finish(Database.BatchableContext context) {
   
        if(nextRun != null) {
            Database.executeBatch(NextRun,50);
        }
     
    }  
    
}