public class KnowledgeMigration{
    
    public static void DeleteAllArticles(String[] languages, String[] Articles) {
        //get all languages
        //execute batches one after another
        List<String> operations = new List<String>{'deleteDrafts','deleteArchived','deleteOnline'};
        List<Operation> ops = new List<Operation>();
        for(String articleType : Articles){
            for(String operation : operations) {
                for(String language : languages) {
                    ops.add(new Operation(articleType,language,operation));
                }
            }
        }
        List<BatchKnowledgeManager> batches = generateBatches(ops);
        Database.executeBatch(batches[batches.size()-1],10); 
    }
    
    public static void TranslationAllRecords(String[] languages,String[] articleTypes) {
        //get all languages
        //get all article types
        //execute batches one after another  
        
        List<Operation> ops = new List<Operation>();

        for(String language : languages) {
            for(String art : articleTypes) {
                ops.add(new Operation(art,language,'translate'));
            }
        }

        List<BatchKnowledgeManager> batches = generateBatches(ops);
        Database.executeBatch(batches[batches.size()-1],7);               
    }
    
    private static List<BatchKnowledgeManager> generateBatches(Operation[] ops) {
         List<BatchKnowledgeManager> batches = new List<BatchKnowledgeManager>();
         for(Integer i = ops.size()-1;i>=0;i--) {
            BatchKnowledgeManager batch;
            if(i == ops.size()-1) {
                    batch = new BatchKnowledgeManager(ops[i].articleType,ops[i].language,ops[i].operation);
                    batches.add(batch);
            }   
            else {
                batch = new BatchKnowledgeManager(ops[i].articleType,ops[i].language,ops[i].operation,batches[batches.size()-1]);
                batches.add(batch); 
            }
        }
        return batches;     
    }
    
    public static void TranslateAllArticles(String[] languages,String[] articleTypes) {
        //get all languages
        //get all article types
        //execute batches one after another
 
        List<Operation> ops = new List<Operation>();

        for(String language : languages) {
            for(String art : articleTypes) {
                ops.add(new Operation(art,language,'translate'));
            }
        }

        List<BatchKnowledgeManager> batches = generateBatches(ops);
        Database.executeBatch(batches[batches.size()-1],7); 
    }
    
    public static void PublishAllArticles(String[] languages,String[] articleTypes) {
        //get all languages
        //get all article types
        //execute batches one after another  
        
        List<Operation> ops = new List<Operation>();

        for(String language : languages) {
            for(String art : articleTypes) {
                ops.add(new Operation(art,language,'publish'));
            }
        }

        List<BatchKnowledgeManager> batches = generateBatches(ops);
        Database.executeBatch(batches[batches.size()-1],10);               
    }
    
    public static void PublishAllTranslations(String[] languages,String[] articleTypes) {
        //get all languages
        //get all article types
        //execute batches one after another  
        
        List<Operation> ops = new List<Operation>();

        for(String language : languages) {
            for(String art : articleTypes) {
                ops.add(new Operation(art,language,'publishTranslations'));
            }
        }

        List<BatchKnowledgeManager> batches = generateBatches(ops);
        Database.executeBatch(batches[batches.size()-1],10);               
    }
    
    public static void DeleteExtraTranslations(String[] languages,String[] articleTypes) {
        //get all languages
        //get all article types
        //execute batches one after another  
        
        List<Operation> ops = new List<Operation>();

        for(String language : languages) {
            for(String art : articleTypes) {
                ops.add(new Operation(art,language,'DeleteRemove'));
            }
        }

        List<BatchKnowledgeManager> batches = generateBatches(ops);
        Database.executeBatch(batches[batches.size()-1],10);               
    }    

    public static void UnpublishAllArticles(String[] languages,String[] articleTypes) {
        //get all languages
        //get all article types
        //execute batches one after another  
        
        List<Operation> ops = new List<Operation>();

        for(String language : languages) {
            for(String art : articleTypes) {
                ops.add(new Operation(art,language,'unpublish'));
            }
        }

        List<BatchKnowledgeManager> batches = generateBatches(ops);
        Database.executeBatch(batches[batches.size()-1],10);               
    }

    public static void UnpublishAllTranslations(String[] languages,String[] articleTypes) {
        //get all languages
        //get all article types
        //execute batches one after another  
        
        List<Operation> ops = new List<Operation>();

        for(String language : languages) {
            for(String art : articleTypes) {   
                ops.add(new Operation(art,language,'unpublishTranslations'));
            }
        }

        List<BatchKnowledgeManager> batches = generateBatches(ops);
        Database.executeBatch(batches[batches.size()-1],10);               
    }    
    
    private class Operation {
        public String articleType {get;set;}
        public String language {get;set;}
        public String operation {get;set;}
        public Operation(String artType,String lang,String op) {
            articleType = artType;
            language = lang;
            operation = op; 
        } 
    }
}