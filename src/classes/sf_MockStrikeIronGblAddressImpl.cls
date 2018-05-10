/*
  * @author: Oleg Rikkers
  * @date: 05/19/2014

  * @description: http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_classes_restful_http_testing_httpcalloutmock.htm
  * 
  */

global class sf_MockStrikeIronGblAddressImpl implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse resp = new HttpResponse ();
        StaticResource siTestAddressResponse	  = [SELECT Id, Body FROM StaticResource WHERE Name ='siTestAddressResponse'];

        resp.setBodyAsBlob(siTestAddressResponse.body);
        resp.setStatusCode(200);
     
        return resp;
    }
}