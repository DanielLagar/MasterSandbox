@isTest
private class InternalActivityUtilityTest {
    @testSetup
    static void setupData(){
        List<Internal_Activity__c> activityList = new List<Internal_Activity__c>();
        for(Integer i = 0; i < 10; i++){
            activityList.add(new Internal_Activity__c(Status__c = 'Open'));
        }
        insert activityList;            
    }
    
    @isTest
    static void closeActivityTest() {
        List<String> activityListIds = new List<String>();
        List<Internal_Activity__c> activityList = new List<Internal_Activity__c>([SELECT Id, Status__c FROM Internal_Activity__c]);
        system.assertEquals(10, activityList.size());
        for(Internal_Activity__c ia : activityList){
            activityListIds.add(ia.Id);
        }
        
        test.startTest();
        
        InternalActivityUtility.CloseActivity(activityListIds);

        //now assert they all closed
        activityList = new List<Internal_Activity__c>([SELECT Id, Status__c FROM Internal_Activity__c]);
        for(Internal_Activity__c activity : activityList){
            System.assertEquals('Closed', activity.Status__c);
        }
        
        //now cause an exception
        activityListIds = new List<String>();
        activityListIds.add('notanid');
        
        System.assertEquals(0, InternalActivityUtility.CloseActivity(activityListIds));
        
        test.stopTest();
    }
}