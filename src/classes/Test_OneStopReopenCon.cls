@isTest
private class Test_OneStopReopenCon  
{
    public static testmethod void testOneStopReopenCon(){
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
        
        ApexPages.StandardController controller=new ApexPages.StandardController(obj);
        OneStopReopenCon con=new OneStopReopenCon(controller);
        con.Save();
    } 
}