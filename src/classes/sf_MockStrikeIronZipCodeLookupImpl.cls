/*
  * @author: Oleg Rikkers
  * @date: 05/19/2014

  * @description: http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_classes_restful_http_testing_httpcalloutmock.htm
  * 
  */

global class sf_MockStrikeIronZipCodeLookupImpl implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse resp = new HttpResponse ();
        StaticResource siTestZip9Response = [SELECT Id, Body FROM StaticResource WHERE Name ='siTestZip9Response'];

        resp.setBodyAsBlob(siTestZip9Response.body);
        resp.setStatusCode(200);
     
        return resp;
    }
}