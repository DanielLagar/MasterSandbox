public class OneStopApprove {   
    One_Stop__c request;       
    ApexPages.StandardController currentcontroller;
    public string stopApprove{get; set;}
    public string xComment{get; set;}
    string status;

    public boolean AdminHandled{get; set;}

    public OneStopApprove(ApexPages.StandardController controller) {
        request = (One_Stop__c)controller.getRecord();         
        status= [select id, Send_Email__c, Status__c , Sub_Status__c from one_stop__c where id = : request.Id].status__c;
        currentcontroller = controller;
    }
    public PageReference Save(){
         OneSTOPComment__c req = new OneSTOPComment__c(X1STOP__c = request.Id);
       if(status=='Closed'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This request has already been closed'));
                return null;
       }
        else{
            if(request.X1STOP_Approval__c == 'Approved'){                    
           req.Comment1__c = 'Approved Comments\n\n'+xComment;
           req.name__c = UserInfo.getName();
                request.Send_Email__c = true;
                               
           insert req;
           
            }
        
       
        else if(request.X1STOP_Approval__c == 'Admin Handled'){              
                req.comment1__c = 'CLOSE REQUEST COMMENTS \n\n'+ xComment;
                req.name__c = UserInfo.getName();  
            request.Send_Email__c = true;
                insert req;
                                             
        }
        else if(request.X1STOP_Approval__c == 'Rejected'){           
            req.comment1__c = 'REQUEST Reject COMMENTS \n\n'+ xComment;
            req.name__c = UserInfo.getName();
            request.Send_Email__c = true;
            insert req;
            
        }
       update request;
        return currentcontroller.view();
            
     }
    }
}