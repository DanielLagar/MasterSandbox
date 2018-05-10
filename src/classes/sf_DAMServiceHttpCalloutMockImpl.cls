/**
* @author: salesforce
* @date: 03/16/2015
*
* @description: Mock http response for sf_DAMService
*/

global class sf_DAMServiceHttpCalloutMockImpl implements HttpCalloutMock {
	
	public Boolean isError = false;
	public sf_DAMServiceHttpCalloutMockImpl () {}

	public sf_DAMServiceHttpCalloutMockImpl (Boolean isError) {
		this.isError = isError;
	}

	global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"foo":"bar"}');
        if (!isError) {
        	res.setStatusCode(200);
    	} else {
    		res.setStatusCode(500);
    	}
        return res;
    }
}