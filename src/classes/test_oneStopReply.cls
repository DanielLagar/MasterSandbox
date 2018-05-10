@isTest
public class test_oneStopReply {
    static testMethod void replyOnestop(){
        
        
        
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
        //obj.Name = '1234567';   
        insert obj;
        system.debug('----'+obj.id);
        
        One_Stop__c ones = [select name, id from One_Stop__c where id =: obj.id];
        system.debug('++++++'+ones);
         OneSTOPComment__c req = new OneSTOPComment__c(X1STOP__c = ones.id);
        req.Name__c = 'other';
        req.Comment1__c ='other';
        insert req;
        
        OneSTOPComment__c comment = [select comment1__c, name__c from OneSTOPComment__c where id =: req.Id];
        
        system.debug('++++++'+comment);
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        messaging.InboundEnvelope envelope = new messaging.InboundEnvelope();
        string user12 =  userInfo.getUserId();
        system.debug(',.,.,.,.'+user12);
        email.fromName = 'test';
        email.subject = 'RE: Sandbox: Request - Open - #'+ones.Name;
        user user1 = [select id, name,email from user where id =: userInfo.getUserId()];
        envelope.fromAddress =user1.Email;
        list<string> toAddress = new string[]{'test@test.com'};
        list<string> ccAddress = new string[]{'noreply.im@pg.com'};
        email.ToAddresses = toAddress;
        email.CcAddresses = ccAddress;
        //email.fromName = '';
        string plainTextBody = comment.Comment1__c;
         Messaging.InboundEmail.header head = new messaging.InboundEmail.header();
        email.headers = new messaging.InboundEmail.header[1];
        head.name = 'X-SFDC-DOMAINKEYS';
        head.value ='None';
        email.headers[0] = head;
        
        oneStopReply testObj = new oneStopReply();
            email.plainTextBody = testObj.stripResponse(plainTextBody);  
        
        testobj.handleInboundEmail(email, envelope);                        
        
    }
    static testMethod void replyOnestop1(){
        
        
        
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
        //obj.Name = '1234567';   
        insert obj;
        system.debug('----'+obj.id);
        
        One_Stop__c ones = [select name, id from One_Stop__c where id =: obj.id];
        system.debug('++++++'+ones);
         OneSTOPComment__c req = new OneSTOPComment__c(X1STOP__c = ones.id);
        req.Name__c = 'other';
        req.Comment1__c ='other';
        insert req;
        
        OneSTOPComment__c comment = [select comment1__c, name__c from OneSTOPComment__c where id =: req.Id];
        
        system.debug('++++++'+comment);
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        messaging.InboundEnvelope envelope = new messaging.InboundEnvelope();
        string user12 =  userInfo.getUserId();
        system.debug(',.,.,.,.'+user12);
        email.fromName = 'test';
        email.subject = 'RE: Sandbox: Request - Open - #'+ones.Name;
        //user user1 = [select id, name,email from user where id =: userInfo.getUserId()];
        envelope.fromAddress ='Personal Email';
        list<string> toAddress = new string[]{'test@test.com'};
        list<string> ccAddress = new string[]{'noreply.im@pg.com'};
        email.ToAddresses = toAddress;
        email.CcAddresses = ccAddress;
        //email.fromName = '';
        string plainTextBody = comment.Comment1__c;
         Messaging.InboundEmail.header head = new messaging.InboundEmail.header();
        email.headers = new messaging.InboundEmail.header[1];
        head.name = 'X-SFDC-DOMAINKEYS';
        head.value ='None';
        email.headers[0] = head;
        
        oneStopReply testObj = new oneStopReply();
            email.plainTextBody = testObj.stripResponse(plainTextBody);  
        
        testobj.handleInboundEmail(email, envelope);                        
        
    }

}