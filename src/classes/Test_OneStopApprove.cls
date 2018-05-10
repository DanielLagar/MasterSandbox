@isTest
private class Test_OneStopApprove {
    public static testmethod void oneStopApprove(){
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
        
        obj.X1STOP_Approval__c = 'Approved';
         OneSTOPComment__c req = new OneSTOPComment__c(X1STOP__c = obj.Id);
        req.Comment1__c = 'other';
           //req.name__c = UserInfo.getName();            
            //req.send_email__c = true;        
           insert req;        
        
        
        ApexPages.StandardController Controller = new ApexPages.StandardController(obj);
        OneStopApprove con = new OneStopApprove(Controller);       
        con.save();
       
        
    }
     public static testmethod void oneStopApprove2(){
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
        
        obj.X1STOP_Approval__c = 'Admin Handled';
         OneSTOPComment__c req = new OneSTOPComment__c(X1STOP__c = obj.Id);
        req.Comment1__c = 'other';
           //req.name__c = UserInfo.getName();            
            //req.send_email__c = true;        
           insert req;        
        
        
        ApexPages.StandardController Controller = new ApexPages.StandardController(obj);
        OneStopApprove con = new OneStopApprove(Controller);       
        con.save();
       
        
    }
    
     public static testmethod void oneStopApprove1(){
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
        
        obj.X1STOP_Approval__c = 'Rejected';
         OneSTOPComment__c req = new OneSTOPComment__c(X1STOP__c = obj.Id);
        req.Comment1__c = 'other';
           //req.name__c = UserInfo.getName();            
            //req.send_email__c = true;        
           insert req;        
        
        
        ApexPages.StandardController Controller = new ApexPages.StandardController(obj);
        OneStopApprove con = new OneStopApprove(Controller);       
        con.save();
       
        
    }



}