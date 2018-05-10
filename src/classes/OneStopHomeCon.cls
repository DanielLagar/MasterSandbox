public class OneStopHomeCon{

    public OneStopHomeCon() {

    }


    //public OneStopHomeCon(ApexPages.StandardController controller) {

    //}


    public List<One_Stop__c> getmyrequests(){
        return [select Id,Name,Status__c,Priority__c,Flag__c,Actual_Expected_Due_Date__c,CreatedDate from One_Stop__c where status__c!='Closed' and ownerId=:UserInfo.getUserId() order by Actual_Expected_Due_Date__c asc limit 1000];
    }
    
    public List<One_Stop__c> getapprovedrequests(){
        Id OneSTOPApprovedQueueId = [select Id from Group where name = '1STOP Approved'].Id;
        return [select Id,Name,Status__c,Priority__c,Flag__c,Actual_Expected_Due_Date__c,CreatedDate from One_Stop__c where ownerId=:OneSTOPApprovedQueueId order by Actual_Expected_Due_Date__c asc limit 1000];
    }
    
    public List<One_Stop__c> gettobeapprovedrequests(){
        Id OneSTOPNeedsApprovalQueueId = [select Id from Group where name = '1STOP Needs Approval'].Id;
        return [select Id,Name,Status__c,Priority__c,Flag__c,Actual_Expected_Due_Date__c,CreatedDate from One_Stop__c where ownerId=:OneSTOPNeedsApprovalQueueId order by Actual_Expected_Due_Date__c asc limit 1000];
    }
    
    public List<One_Stop__c> getRequestsCreatedByMe(){
        return [select Id,Name,Status__c,Priority__c,Flag__c,Actual_Expected_Due_Date__c,CreatedDate from One_Stop__c where createdById=:UserInfo.getUserId() order by Actual_Expected_Due_Date__c asc limit 1000];
    }
    
    

}