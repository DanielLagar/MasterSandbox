@isTest
private class Test_OneStopHomeCon 
{
    public static testmethod void testOneStopHomeCon(){
        OneStopHomeCon con=new OneStopHomeCon();
        con.getmyrequests();
        con.getapprovedrequests();
        con.gettobeapprovedrequests();
        con.getRequestsCreatedByMe();
    } 
}