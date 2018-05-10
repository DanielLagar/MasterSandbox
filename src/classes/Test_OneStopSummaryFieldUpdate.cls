@isTest
public class Test_OneStopSummaryFieldUpdate {
    
    public static testMethod void TestOneStopSummaryFieldUpdate(){
        
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
        
        //obj = [select name, Comment_Summary__c from one_stop__c where id =: obj.Id];
        //system.assertEquals(null, obj.Comment_Summary__c);
        
        
        OneSTOPComment__c obj1 = new OneSTOPComment__c(Comment1__c = 'other',X1STOP__c = obj.id);
        //obj1.Name = '123';
        
        
        insert obj1;
       // obj = [select name, Comment_Summary__c from one_stop__c where id =: obj.Id];
       // system.assertEquals(obj1.Comment1__c, obj.Comment_Summary__c);
       
        
    } 
}