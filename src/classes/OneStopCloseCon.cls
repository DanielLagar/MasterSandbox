public class OneStopCloseCon {

    One_Stop__c request;       
    ApexPages.StandardController currentcontroller;
    String status;
    public string xComment{get; set;}
    //public string NotificaComment {set; get;}
    
    public OneStopCloseCon(ApexPages.StandardController controller) {
        request = (One_Stop__c)controller.getRecord();
        status = [select Status__c from One_Stop__c where id=:request.Id].Status__c;  
        system.debug('################# Status: '+status);      
        currentcontroller = controller;
    }
    
    public PageReference Save(){
        if(request != null){
            if(status=='Closed'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This request has already been closed'));
                return null;
            }
            else {
                OneSTOPComment__c req = new OneSTOPComment__c(X1STOP__c = request.Id );
                req.comment1__c = 'CLOSE REQUEST COMMENTS \n\n'+ xComment;
                req.name__c = UserInfo.getName();
                request.Status__c='Closed';
                request.Request_Closed_Date__c=System.now();
                request.Send_Email__c = true;
                
                insert req;
                update request;
                return currentcontroller.view();
            }
        }
        else return null;
    }

}