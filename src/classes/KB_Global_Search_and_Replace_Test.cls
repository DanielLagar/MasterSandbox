@isTest
private class KB_Global_Search_and_Replace_Test {
    static List<String> getArticleTypes(){
        List<String> listArticleTypes = new List<String>();
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe(); 
        if(globalDescribe != null && !globalDescribe.isEmpty()){
            for(String key : globalDescribe.keySet()){
                if(key.endsWith('__kav')){
                    listArticleTypes.add(key);
                }
            }
        }
        return listArticleTypes;
    }
    
    static testMethod void runTestCase() {
       List<String> listArticleTypes = getArticleTypes();
       System.assertNotEquals(listArticleTypes.size(), 0);
       
       String strArticleType = listArticleTypes[0]; // Select arbitrary article type for testing

       //Use the PageReference Apex class to instantiate a page

       PageReference pageRef = Page.KB_Global_Search_and_Replace;

       //In this case, the Visualforce page named 'success' is the starting point of this test method.

       Test.setCurrentPage(pageRef);

       //Instantiate and construct the controller class.  

       KB_Global_Search_and_Replace controller = new KB_Global_Search_and_Replace();

       //Example of calling an Action method. Same as calling any other Apex method.
       //Normally this is executed by a user clicking a button or a link from the Visualforce
       //page, but in the test method, just test the action method the same as any
       //other method by calling it directly.

       //Add parameters to page URL

       ApexPages.currentPage().getParameters().put('strSearchString', 'xxxx');
       ApexPages.currentPage().getParameters().put('strReplacementString', 'yyyy');

       //Instantiate a new controller with all parameters in the page

       controller = new KB_Global_Search_and_Replace();

       //Example of calling the 'setter' method for several properties.
       //Normally these setter methods are initiated by a user interacting with the Visualforce page,
       //but in a test method, just call the setter method directly.

        controller.bSearchOnly = false;
        controller.bPublishNewVersion = false;
        controller.getArticleTypes();
        controller.getPublishStatus(); 
        controller.getLanguage();       
        controller.strArticleType = strArticleType;
        controller.getArticleFields();     
        
        Integer intSearched = 0;
        Integer intSelected = 0;
        Integer intUpdated = 0;
        String strApexBatchId = '0123456789ABCDE';
        String strReplacementApexBatchId = '0123456789FABCD';
        controller.strApexBatchId = strApexBatchId;
          
        KB_Global_Search_History__c historyRecord = 
            new KB_Global_Search_History__c(Articles_Searched__c=intSearched, Articles_Selected__c=intSelected,
                Articles_Updated__c=intUpdated, Apex_Replacement_BatchId__c=strReplacementApexBatchId, Apex_BatchId_List__c=strApexBatchId);
        insert historyRecord;

        controller.performSearch();
        controller.refresh();
    }
}