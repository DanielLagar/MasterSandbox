public class OneSTOPCommentAddCom {
   
    public string xComment {get;set;}   
   
    One_Stop__c request;       
    ApexPages.StandardController currentcontroller;    
    
   public OneSTOPCommentAddCom(ApexPages.StandardController controller) {
       request = (One_Stop__c)controller.getRecord();
        currentcontroller = controller;                    
    }
    
    public PageReference Save(){
       OneSTOPComment__c req = new OneSTOPComment__c(X1STOP__c = request.Id );              
                req.comment1__c = xComment;
                req.name__c = UserInfo.getName();
                insert req;
                update request;             
                return currentcontroller.view();
    }


}