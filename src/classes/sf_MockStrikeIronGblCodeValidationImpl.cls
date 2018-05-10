/*
  * @author: Oleg Rikkers
  * @date: 05/22/2014

  * @description: http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_classes_restful_http_testing_httpcalloutmock.htm
  * 
  */

global class sf_MockStrikeIronGblCodeValidationImpl implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse resp = new HttpResponse ();
        StaticResource siTestZip9Response = [SELECT Id, Body FROM StaticResource WHERE Name ='siTestGlobalCodeResponse'];

        resp.setBodyAsBlob(siTestZip9Response.body);
        resp.setStatusCode(200);
     
        return resp;
    }
}