public class onestopNewCon{
    public One_Stop__c onestopobj;
    public onestopNewCon(ApexPages.StandardController stdController){
        onestopobj = (One_Stop__c)stdController.getRecord();
        onestopobj.Send_Email__c=true;
    }
}