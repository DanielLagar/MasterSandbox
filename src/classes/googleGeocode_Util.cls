/*
 * Extension for Where To Buy
 * Visualforce Component
 * Provides Google geocoding utility
 * WR277
*/
global class googleGeocode_Util {
    
    private static String googleAPIKey{
        get{
            if(googleAPIKey == null){
				bigData_Settings__c config = bigData_Settings__c.getInstance(UserInfo.getOrganizationId());
				googleAPIKey =  config.Google_Server_Key__c;
            }            
			return googleAPIKey;
		}
        set;  
    }
    
	public googleGeocode_Util(ctr_WhereToBuy ctrWTB){
        
    }
   
	//https://developers.google.com/maps/documentation/geocoding/intro#geocoding
    global static Map<String, Double> getLatLng(String address){
        Map<String, Double> latlng = new Map<String, Double>();
		String searchAddress = address.replaceAll(' ', '+');
        
        Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address='+searchAddress+'&key='+googleAPIKey);
		req.setMethod('GET');
        HttpResponse res = h.send(req);
        
		JSONParser parser = JSON.createParser(res.getBody());
        
        if(res.getStatusCode() == 200){
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)
                    && (parser.getText() == 'location')) {
                    //Jump to latitude and longtitude fields.
                    parser.nextToken();
                    while (parser.nextToken() != JSONToken.END_OBJECT) {
                        String text = parser.getText();
                        parser.nextToken();
                        if (text == 'lat'){
                            latlng.put('lat', parser.getDoubleValue());
                        } 
                        else if (text == 'lng'){
                            latlng.put('lng', parser.getDoubleValue());
                        } 
                    }
                }
            }               
        }
        else{
			//TODO: Error handling - if service is not available etc.
        }
    
        return latlng;
    }
    
    @remoteAction
    global static String getReverseGeocode(Map<String, String> latlngMap){
        String addressString = '';
        
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?latlng='+latlngMap.get('lat')+','+latlngMap.get('lng')+'&key='+googleAPIKey);
		req.setMethod('GET');
        HttpResponse res = h.send(req);
        
        JSONParser parser = JSON.createParser(res.getBody());
		
        
        if(res.getStatusCode() == 200){
            //formatted_address
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)
                    && (parser.getText() == 'formatted_address')) {
                    parser.nextToken();
                    addressString = parser.getText();
                    break; //First item in array should be the most accurate
                } 
            }             
        }
        else{
			//TODO: Error handling - if service is not available etc.
        }
   
        return addressString;
    }
}