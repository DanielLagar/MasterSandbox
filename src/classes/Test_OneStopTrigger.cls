@isTest
private class Test_OneStopTrigger 
{
    public static testmethod void testOneStopTrigger1(){    
    
        OneStopSettings__c csobj=new OneStopSettings__c();
        csobj.Category__c='Other';
        csobj.Sub_Category__c='Other';
        csobj.Priority__c='1';
        csobj.SLA__c=120;
        csobj.name='Dataset1';
        csobj.Approval_Needed__c=false;
        insert csobj;
        
        OneStopSettings__c csobj2=new OneStopSettings__c();
        csobj2.Category__c='Email';
        csobj2.Sub_Category__c='Setup HTML email';
        csobj2.Priority__c='1';
        csobj2.SLA__c=120;
        csobj2.name='Dataset2';
        csobj2.Approval_Needed__c=true;
        insert csobj2;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', ProfileId = p.Id, X1STOP_Approver__c = true,
                    TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg2.pandg.com');
                    
        User u2 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', ProfileId = p.Id, X1STOP_Approver__c = false,
                    TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.pandg.com');
                    
        System.runAs(u1) {
            
            One_Stop__c obj=new One_Stop__c();
            obj.Request_Category__c='Other';
            obj.Request_Subcategory__c='Other';
            insert obj;
            
             One_Stop__c obj2=new One_Stop__c();
            obj2.Request_Category__c='Email';
            obj2.Request_Subcategory__c='Setup HTML email';
            insert obj2;
            
            One_Stop__c obj4=new One_Stop__c();
            obj4.Request_Category__c='Email';
            obj4.Request_Subcategory__c='Setup HTML email';
            obj4.Requested_Due_Date__c=system.now()-1;
            insert obj4;
            
            One_Stop__c obj5=new One_Stop__c();
            obj5.Request_Category__c='Email';
            obj5.Request_Subcategory__c='Setup HTML email';
            obj5.Requested_Due_Date__c=system.now()+100;
            insert obj5;
          

        }             
                    
        System.runAs(u2) {
            One_Stop__c obj3=new One_Stop__c();
            obj3.Request_Category__c='Email';
            obj3.Request_Subcategory__c='Setup HTML email';
            insert obj3;
            
             One_Stop__c obj2=new One_Stop__c();
            obj2.Request_Category__c='Email';
            obj2.Request_Subcategory__c='Setup HTML email';
            insert obj2;
            
            One_Stop__c obj4=new One_Stop__c();
            obj4.Request_Category__c='Email';
            obj4.Request_Subcategory__c='Setup HTML email';
            obj4.Requested_Due_Date__c=system.now()-1;
            insert obj4;
            
            One_Stop__c obj5=new One_Stop__c();
            obj5.Request_Category__c='Email';
            obj5.Request_Subcategory__c='Setup HTML email';
            obj5.Requested_Due_Date__c=system.now()+100;
            insert obj5;
            
          
        }

    }
    
     public static testmethod void testOneStopTrigger2(){    
    
        OneStopSettings__c csobj=new OneStopSettings__c();
        csobj.Category__c='Other';
        csobj.Sub_Category__c='Other';
        csobj.Priority__c='1';
        csobj.SLA__c=120;
        csobj.name='Dataset1';
        csobj.Approval_Needed__c=false;
        insert csobj;
        
        OneStopSettings__c csobj2=new OneStopSettings__c();
        csobj2.Category__c='Email';
        csobj2.Sub_Category__c='Setup HTML email';
        csobj2.Priority__c='1';
        csobj2.SLA__c=120;
        csobj2.name='Dataset2';
        csobj2.Approval_Needed__c=true;
        insert csobj2;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', ProfileId = p.Id, X1STOP_Approver__c = true,
                    TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg2.pandg.com');
                    
        User u2 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', ProfileId = p.Id, X1STOP_Approver__c = false,
                    TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.pandg.com');
                    
        System.runAs(u1) {
            One_Stop__c obj=new One_Stop__c();
            obj.Request_Category__c='Other';
            obj.Request_Subcategory__c='Other';
            insert obj;
            
            obj.X1STOP_Approval__c = 'Approved';
            update obj;
            
              One_Stop__c obj2=new One_Stop__c();
            obj2.Request_Category__c='Email';
            obj2.Request_Subcategory__c='Setup HTML email';
            insert obj2;
            
            obj2.X1STOP_Approval__c = 'Approved';
            update obj2;
            
            One_Stop__c obj4=new One_Stop__c();
            obj4.Request_Category__c='Email';
            obj4.Request_Subcategory__c='Setup HTML email';
            obj4.Requested_Due_Date__c=system.now()-1;
            insert obj4;
            
            obj4.X1STOP_Approval__c = 'Approved';
            update obj4;
            
            
            One_Stop__c obj5=new One_Stop__c();
            obj5.Request_Category__c='Email';
            obj5.Request_Subcategory__c='Setup HTML email';
            obj5.Requested_Due_Date__c=system.now()+100;
            insert obj5;
            
            obj5.X1STOP_Approval__c = 'Approved';
            update obj5;
        

        }             
                    
        System.runAs(u2) {
            One_Stop__c obj3=new One_Stop__c();
            obj3.Request_Category__c='Email';
            obj3.Request_Subcategory__c='Setup HTML email';
            insert obj3;
            
            system.runAs(u1){
                
            obj3.X1STOP_Approval__c = 'Approved';
            update obj3;
            }
            
          
        }

    }
    
    public static testmethod void testOneStopTrigger3(){    
    
        OneStopSettings__c csobj=new OneStopSettings__c();
        csobj.Category__c='Other';
        csobj.Sub_Category__c='Other';
        csobj.Priority__c='1';
        csobj.SLA__c=120;
        csobj.name='Dataset1';
        csobj.Approval_Needed__c=false;
        insert csobj;
        
        OneStopSettings__c csobj2=new OneStopSettings__c();
        csobj2.Category__c='Email';
        csobj2.Sub_Category__c='Setup HTML email';
        csobj2.Priority__c='1';
        csobj2.SLA__c=120;
        csobj2.name='Dataset2';
        csobj2.Approval_Needed__c=true;
        insert csobj2;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', ProfileId = p.Id, X1STOP_Approver__c = true,
                    TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg2.pandg.com');
                    
        User u2 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', ProfileId = p.Id, X1STOP_Approver__c = false,
                    TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.pandg.com');
                    
        
                    
        System.runAs(u2) {
            One_Stop__c obj3=new One_Stop__c();
            obj3.Request_Category__c='Email';
            obj3.Request_Subcategory__c='Setup HTML email';
            insert obj3;
            
            
            
            system.runAs(u1){
                
            obj3.X1STOP_Approval__c = 'Admin Handled';
            update obj3;
            }
        }

    }
    public static testmethod void testOneStopTrigger4(){    
    
        OneStopSettings__c csobj=new OneStopSettings__c();
        csobj.Category__c='Other';
        csobj.Sub_Category__c='Other';
        csobj.Priority__c='1';
        csobj.SLA__c=120;
        csobj.name='Dataset1';
        csobj.Approval_Needed__c=false;
        insert csobj;
        
        OneStopSettings__c csobj2=new OneStopSettings__c();
        csobj2.Category__c='Email';
        csobj2.Sub_Category__c='Setup HTML email';
        csobj2.Priority__c='1';
        csobj2.SLA__c=120;
        csobj2.name='Dataset2';
        csobj2.Approval_Needed__c=true;
        insert csobj2;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', ProfileId = p.Id, X1STOP_Approver__c = true,
                    TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg2.pandg.com');
                    
        User u2 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', ProfileId = p.Id, X1STOP_Approver__c = false,
                    TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.pandg.com');
                    
        
                    
        System.runAs(u2) {
            One_Stop__c obj3=new One_Stop__c();
            obj3.Request_Category__c='Email';
            obj3.Request_Subcategory__c='Setup HTML email';
            insert obj3;
            
             system.runAs(u1){
                
           obj3.X1STOP_Approval__c = 'Rejected';
            update obj3;
            }
            
           
        }

    }
}