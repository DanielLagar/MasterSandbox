/*
 * Controller for Where To Buy
 * Visualforce Component
 * Supports Site and Service Console usage
 * WR277
*/

global class ctr_WhereToBuy {
	//Page Params

    public String gtin {get;set;}//bound to product search input field
    public String countryParam {get;set;}
    public String brandParam {get;set;}
    public Boolean consoleParam {get;set;}//In the console?
    public String langParam {get;set;}//supports both site and console usage
    public String location {get;set;}//bound to address search input field

    //Display Booleans
    public Boolean showProductResults {get;set;}
    public Boolean showSearch {get;set;}

    //For Product Search
    public List<Local_Product__c> searchProducts {get; private set;}
    
    // DECEMBER16 CHANGE - WTB ANALYTICS
    public Integer productCount { get; set; }
    //Country list
    public String selectedCountry {get;set;}
    
    @remoteAction
    global static List<String> getCountries(String country){
        List<String> countries = new List<String>();//List to display
        Set<String> dedupeCountries = new Set<String>();//Deduped list
        Map<String, Country_Region_SMO__c> countryMap = Country_Region_SMO__c.getAll();

        //Only add those with WTB enabled
		for(Country_Region_SMO__c c : countryMap.values()){
			if(c.WTB_Enabled__c){
				dedupeCountries.add(c.displaylabel__c);
			}
		}
        countries.add(country);//Make the country passed to the page default
        dedupeCountries.remove(country);//Don't readd the country passed to the page
        countries.addAll(dedupeCountries);
        
       	return countries;
    }

	public ctr_WhereToBuy(){
        selectedCountry = '';
        searchProducts = new list<Local_Product__c>();
        showProductResults = false;
        showSearch = True;
    }

    @remoteAction
    global static List<Local_Product__c> productSearch(String searchTerm, String country, String brand){
        String products = '';
		List<Local_Product__c> searchProducts = new List<Local_Product__c>();
        //validations
        //searchString > 3
        //Country valid?
        //Brand valid
		
        String term = String.escapeSingleQuotes(searchTerm);
		List<String> wordCount = term.split('\\s'); 
        if(wordCount.size() > 1){
            //Use SOSL if two or more words provided
            term = String.escapeSingleQuotes(searchTerm)+'*';
            String searchquery='FIND \'';
			searchquery += term;
			searchquery += '\' IN ALL FIELDS RETURNING Local_Product__c (Id, Name, Image_Url__c, Image_Url_Thumb__c, Consumer_Facing_Name__c, GTIN_Number__c, Product_Description__c, Translated_Path__c';
			searchquery += ' WHERE';
			
            if (country != null && country !=''){
				searchquery += ' Country__c = \''+ country + '\' AND';
			}

            if (!String.isEmpty(brand) && brand != sf_ContactUsHelperCtrl.DEFAULT_BRAND){
				searchquery += ' Consumer_Facing_Brand__c = \''+ brand + '\' AND';
			}

            searchquery += ' Consumer_Facing__c = true';
			searchquery += ' AND Inactive__c = false';
			searchquery += ' AND GTIN_Number__c != null';//WTB
            searchquery += ' ORDER BY Translated_Path__c ASC ';
            searchquery += ') LIMIT 50';
            system.debug(logginglevel.WARN,'searchquery ' + searchquery);
            
			List<List<SObject>> searchList = search.query(searchquery);
			System.debug(LoggingLevel.INFO, 'searchresults ' + searchList);
			
            if (!searchList.isEmpty()) {
				searchProducts = searchList.get(0);
			} else {
				searchProducts = new List<Local_Product__c>();
			}            
            
        } else {
            //Use SOQL if only one word is provided
			String searchquery = 'SELECT Id, Name, Image_Url__c, Image_Url_Thumb__c, Consumer_Facing_Name__c, GTIN_Number__c, Product_Description__c, Translated_Path__c FROM Local_Product__c WHERE';

            if (country != null && country !=''){
				searchquery += ' Country__c = \''+ country + '\' AND';
			}

            if (!String.isEmpty(brand) && brand != sf_ContactUsHelperCtrl.DEFAULT_BRAND){
				searchquery += ' Consumer_Facing_Brand__c = \''+ brand + '\' AND';
			}

            searchquery += ' Consumer_Facing__c = true AND Inactive__c = false';
                
			//Is it a GTIN search?
			system.debug('>>> is it a gtin only? '+term+' : '+term.isNumeric());
			if(term.isNumeric()){
				searchquery += ' AND GTIN_Number__c = \''+term+'\'';
			} else {
				searchquery += ' AND GTIN_Number__c != null';//WTB
				searchquery += ' AND (Consumer_Facing_Name__c LIKE \''+'%'+term+'%\'';
				searchquery += ' OR Product_Description__c LIKE \''+'%'+term+'%\''+')';                
			}
			
            searchquery += ' ORDER BY Translated_Path__c ASC';
			searchquery += ' LIMIT 50';
			
            system.debug(logginglevel.WARN,'searchquery ' + searchquery);
			searchProducts = database.query(searchquery);
        }
        
        //products = JSON.serialize(searchProducts);//Do not need to do this remote action does this for us
        gcr_helperClass.getImageUrl(searchProducts,'Image_Url_Thumb__c');
        return searchProducts;
    }
    
	//WR513 - To Support Google Places Autocomplete, need two-character, ISO 3166-1 Alpha-2 Country code
    //https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
	//https://developers.google.com/maps/documentation/javascript/examples/places-autocomplete-hotelsearch
	//https://developers.google.com/maps/documentation/javascript/places-autocomplete
    @remoteAction
    global static String getCountryCode(String country){
        String countryCode = '';
		Map<String, Country_Region_SMO__c> countryMap = Country_Region_SMO__c.getAll();
        for(Country_Region_SMO__c c : countryMap.values()){
            if(c.WTB_Enabled__c && c.DisplayLabel__c == country){
                countryCode = c.ISO_3166_1_Country_Code__c;
                break;
            }
        }
        return countryCode;
    }
    
    @remoteAction
    global static String getDistanceUnit(String country){
        String countryDistance = 'miles'; //'miles' or 'km'
        country = country.toUpperCase();
		Country_Region_SMO__c countrySetting = Country_Region_SMO__c.getInstance(country);
		if(countrySetting != null){
			countryDistance = countrySetting.DistanceUnit__c.toLowerCase();
		}
		return countryDistance;
    }
    
	@remoteAction
    global static String geocodeAddress(String address){
        String geocodeAddress = '';
        Map<String, Double> latlngMap = new Map<String, Double>();
        latlngMap = googleGeocode_Util.getLatLng(address);
        
        if(latlngMap.get('lat') != null && latlngMap.get('lng') != null){
            geocodeAddress = latlngMap.get('lat')+','+latlngMap.get('lng');
        }
        
        return geocodeAddress;
    }//geocodeAddress end

    //Sibling endpoint example:
    //https://gcrpatqa.pg.com/gcrpat/productAvailability/read?gtin=00037000820277&pt=34.120005,-117.5584223&d=100&token=<TOKEN>&siblings=1&locale=EN-US
    @remoteAction
    global static Object getStoreLocations(String gtin, String latitude, String longitude, String langCode){
        if(String.isBlank(langCode)){
            langCode = 'EN-US';
        }
        
        List<wtbJSONHelper.Docs> docs = new List<wtbJSONHelper.Docs>();
        Object locations = '';//JSON to pass back to javascript
        
		//Build http request
		bigData_Settings__c config = bigData_Settings__c.getInstance(UserInfo.getOrganizationId());
		String token =  config.token__c;
        Integer siblingOn = 0;
        if(config.include_siblings__c){
            siblingOn = 1;
        }
    
        String reqEndPoint = config.bigData_Endpoint__c;
        reqEndPoint += '?gtin='+gtin;
		reqEndPoint += '&pt='+latitude;
        reqEndPoint += ','+longitude;          
        reqEndPoint += '&d='+100;//Note: Km not miles
        //reqEndPoint += '&start=0&rows='+500;//If not set defaults to return first (closest) 20 rows                                         
        reqEndPoint += '&token='+token;
        reqEndPoint += '&siblings='+siblingOn;
        reqEndPoint += '&locale='+langCode;

        Http h = new Http ();
        HttpRequest req = new HttpRequest ();
        req.setEndpoint(reqEndPoint);
		req.setMethod ('GET');
        
		//Send http request
        HttpResponse res = new HttpResponse();

        try{
            res = h.send(req);
            //Note invalid token still gets 200 response, body = 'Invalid token'
            //No GPS data = 'Invalid parameters: 0'
            //No GTIN = 'Invalid parameters: For input string: ""'
            //No Distance = 'Invalid parameters: For input string: ""'
            //Wrong endpoint = 'Unauthorized. Full authentication is required to access this resource'
        }
        catch(CalloutException e){
            system.enqueueJob(new exceptionHelperQueable(e,'Where To Buy error on call out to big data'));
            throw new bigDataException('Service not available');
        }
        String responseJSON = res.getBody();
        boolean goodResponse = false;
		
		if(res.getStatusCode() == 200){
            //use a try catch to make sure response is well formed - errors tend to come back 200 + String 
            //e.g. Invalid token returns StatusCode = 200 and body of 'Invalid token'
            try{
                Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(responseJSON);
                goodResponse = true;
            }
            catch(JSONException e){
                system.debug('>>> Invalid JSON returned. Body: '+responseJSON);
                //WTB-014
                //Note: GACK if pass exception to exception handler, string only works
                System.enqueueJob(new exceptionHelperQueable('Where To Buy error on getting store locations from big data. \n *The request: '+reqEndPoint+'\n *The message: '+e.getMessage()+'\n *The stack: '+e.getStackTraceString()+'\n *The response: '+responseJSON));
                throw new bigDataException('Service response issue');
            }
            if(goodResponse){
				//Note: Docs is an inner class of response
                wtbJSONHelper jsonParser = wtbJSONHelper.parse(responseJSON);
                locations = jsonParser.response.docs;
            }//no else required as locations already instantiated
        }
		else{
			System.enqueueJob(new exceptionHelperQueable('Where To Buy error on getting store locations from big data non 200 response: '+res));
			throw new bigDataException('Service issue');
		}
        return locations;
    }
    
    public class bigDataException extends Exception {}
}