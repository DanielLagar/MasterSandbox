@isTest
private class Test_OneStopHistoryRelatedListController 
{
    public static testmethod void testOneStopHistoryRelatedListController(){
        OneStopSettings__c csobj=new OneStopSettings__c();
        csobj.Category__c='Other';
        csobj.Sub_Category__c='Other';
        csobj.Priority__c='1';
        csobj.SLA__c=120;
        csobj.name='Dataset1';
        insert csobj;
        
        One_Stop__c obj=new One_Stop__c();
        obj.Request_Category__c='Other';
        obj.Request_Subcategory__c='Other';
        insert obj;
        
        OneStopHistoryRelatedListController.historyWrapper wrapper =new OneStopHistoryRelatedListController.historyWrapper('Test','TestOld','TestNew','updatedbywho',obj.Id,system.now(),'fldlabel');
        OneStopHistoryRelatedListController con=new OneStopHistoryRelatedListController();
        con.oneStop=new One_Stop__c();
        con.getHistoryDetails();
        con.returnFieldLabel('Request_Category__c');
        con.returnFieldLabel('Test');
    } 
}