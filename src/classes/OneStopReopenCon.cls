public class OneStopReopenCon {
    public string xComment{get; set;}
    One_Stop__c request;
    ApexPages.StandardController currentcontroller;
    Decimal reopencount;
    
    public OneStopReopenCon(ApexPages.StandardController controller) {
        request = (One_Stop__c) controller.getRecord();
        reopencount = [select Reopened_Count__c, Status__c,Send_Email__c from One_Stop__c where id=:request.Id].Reopened_Count__c;        
        currentcontroller = controller;
    }
    
    public PageReference Save(){        
        OneSTOPComment__c req = new OneSTOPComment__c(X1STOP__c = request.Id );
        request.Status__c='Open';        
        req.Comment1__c='REQUEST HAS BEEN REOPENED. \n\n'+xComment;
        request.Send_Email__c=true;
        req.name__c = UserInfo.getName();
        if(reopencount==null) request.Reopened_Count__c=1;
        else request.Reopened_Count__c=reopencount+1;        
        insert req;
        update request;
        return currentcontroller.view();        
    }

}