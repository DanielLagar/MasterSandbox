/**
* @author: salesforce
* @date: 03/09/2015
*
* @description: Batch process to send image url requests to DAM
*/

public with sharing class sf_DAMService {
    public static final String SUCCESS_MESSAGE = 'Success';

    public static String republishAssetsByGTIN (List <String> gtins) {

        String requestJsonString = getRequestBody(gtins);
        System.debug(LoggingLevel.INFO, 'requestJsonString: \n' + requestJsonString);
        return sendRequestToDam (requestJsonString);
    }

    private static String sendRequestToDam (String jsonBody) {
        
        Http h = new Http ();
        HttpRequest req = new HttpRequest();
        req.setMethod ('POST');
        req.setEndpoint ('callout:DAM');
        req.setBody(jsonBody);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/xml');
    req.setTimeout(120000);

        HttpResponse resp = h.send(req);

        System.debug(LoggingLevel.INFO, resp);
        System.debug(LoggingLevel.INFO, resp.getBody());

        if (resp.getStatusCode() == 200) {
            return SUCCESS_MESSAGE;
        } else {
            return 'An error has occurred! '+ resp.getStatusCode() + ' - ' +  resp.getBody() ;
        }
    }


    private static String getRequestBody (List <String> gtinsList) {
        String jsonString = '';
        jsonString += '{"RepublishAssetsByGTIN": {';
        jsonString += '"ApplicationName": "sfdc",';
        jsonString += '"GTINs": [';

        for (String g: gtinsList) {
             jsonString += '"'+ g + '",';
        }

        jsonString = jsonString.removeEnd(',');
       
        //Per Ngoho, Vincent <vincent.ngoho@hp.com> 
        //Monday, May 11, 2015 10:21 PM
        //The filters are valid values, however the GTINs’ assets’ asset type/mimetype must not be that of in the request.
        //Please remove other filters and only populate for the Application name and GTIN.
        //jsonString += '], "AssetType": "Audio>Advertisement","MIMETypes": [ "image/jpeg" ],"Preference": "Y",';
        //jsonString += '"Views": [   "Front"]}}';  

        //per Max conversation on 7/8/2015 adding mime types and views filters back

        //jsonString +=   '],"MIMETypes": [  "image/jpeg", "image/jpg", "image/png", "image/tif", "image/psd"  ],"Preference": "Y",';
        jsonString +=   '],"MIMETypes": [ "jpeg", "jpg", "png", "tif", "psd" ],"Preference": "Y",';
        
        jsonString +=   '"Views": [   "Front","Back", "LeftSide", "RightSide"]}}';  

        //jsonString += ']}}';
        
        return jsonString;
    }

}


/*


{
    "RepublishAssetsByGTIN": {
        "ApplicationName": "sfdc",
        "GTINs": [
            "00037000357629"
        ],
        "MIMETypes": [
            "jpeg",
            "jpg", 
            "png",
            "tif",
            "psd"
        ],
        "Preference": "Y",
        "Views": [
            "Front",
            "Back",
            "LeftSide",
            "RightSide"
        ]
    }
}

*/