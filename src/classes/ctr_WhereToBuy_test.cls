@isTest
public class ctr_WhereToBuy_test {
    @testSetup
    static void setupData(){
        List<Country_Region_SMO__c> countriesToInsert = new List<Country_Region_SMO__c>();
        Country_Region_SMO__c us = new Country_Region_SMO__c(
            Name = 'UNITED STATES OF AMERICA',
            DisplayLabel__c = 'United States of America',
            DistanceUnit__c = 'miles',
            ISO_3166_1_Country_Code__c = 'US',
            WTB_Enabled__c = True
        );
        countriesToInsert.add(us);
		Country_Region_SMO__c uk = new Country_Region_SMO__c(
			Name = 'UNITED KINGDOM',
            DisplayLabel__c = 'United Kingdom',
            DistanceUnit__c = 'miles',
            ISO_3166_1_Country_Code__c = 'UK',
            WTB_Enabled__c = True
        );
        countriesToInsert.add(uk);
		Country_Region_SMO__c canada = new Country_Region_SMO__c(
			Name = 'CANADA',
            DisplayLabel__c = 'Canada',
            DistanceUnit__c = 'km',
            ISO_3166_1_Country_Code__c = 'CA',
            WTB_Enabled__c = True
        );
        countriesToInsert.add(canada);
        insert countriesToInsert;

        List<Global_Product__c> gpsToInsert = new List<Global_Product__c>();
        List<Local_Product__c> lpsToInsert = new List<Local_Product__c>();
        //Create global products
        Global_Product__c gp1 = new Global_Product__c(
            GCR_Product_ID__c = 'gp1',
            Path__c = 'Tide/Laundry Detergent/Liquid Pod/Not Applicable/Other/Spring Meadow/Other/35CT/Bag'
        );
        gpsToInsert.add(gp1);
		Global_Product__c gp2 = new Global_Product__c(
            GCR_Product_ID__c = 'gp2',
            Path__c = 'Tide/Laundry Detergent/Powder/High Suds/Cold Water/Fresh Scent/Ultra/98OZ/Carton'
        );
        gpsToInsert.add(gp2);
		Global_Product__c gp3 = new Global_Product__c(
            GCR_Product_ID__c = 'gp3',
            Path__c = 'Tide/Laundry Additive/Pouch with Liquid & Powder/Stain Remover (pH Booster)/Regular/Pouch/10CT/Non-Refill'
        );
        gpsToInsert.add(gp3);
		Global_Product__c gp4 = new Global_Product__c(
            GCR_Product_ID__c = 'gp4',
            Path__c = 'The Art of Shaving/Male Prestige Accessories/Shave Brush/3/Pure Badger/Ivory'
        );
        gpsToInsert.add(gp4);
        insert gpsToInsert;
        
		//Create local products
		Local_Product__c lp1 = new Local_Product__c(
            Global_Product__c = gp1.Id,
            Name = 'Bag',
            Brand__c = 'Tide',
            Consumer_Facing__c = True,
            Consumer_Facing_Brand__c = 'Tide',
			Consumer_Facing_Name__c = 'Tide Pods Spring Meadow HE Detergent 35 Pacs (31 oz) 876 g',
            Country__c = 'United States of America',
            GTIN_Number__c = '11111111111111',
            Translated_Path__c = 'Tide/Laundry Detergent/PODS/-/-/Spring Meadow/-/35ct/Bag'
            
        );
        lpsToInsert.add(lp1);
		Local_Product__c lp2 = new Local_Product__c(
            Global_Product__c = gp2.Id,
			Name = 'Carton',
            Brand__c = 'Tide',
            Consumer_Facing__c = True,
            Consumer_Facing_Brand__c = 'Tide',
			Consumer_Facing_Name__c = 'Tide for Coldwater Fresh Scent Acti-lift Crystals Powder Detergent 53 Loads (2.78 kg) 98 oz',
            Country__c = 'United States of America',
            GTIN_Number__c = '2222222222222',
            Translated_Path__c = 'Tide/Laundry Detergent/Powder/-/Cold Water/Fresh Scent/Ultra/98oz/Carton'
        );
        lpsToInsert.add(lp2);
		Local_Product__c lp3 = new Local_Product__c(
			Global_Product__c = gp3.Id,
			Name = 'Non-Refill',
            Brand__c = 'Tide',
            Consumer_Facing__c = True,
            Consumer_Facing_Brand__c = 'Tide',
			Consumer_Facing_Name__c = 'Tide Boost Stain Release, 10 Pacs',
            Country__c = 'United States of America',
            GTIN_Number__c = '333333333333333',
            Translated_Path__c = 'Tide/Laundry Additive/Pouch with Liquid & Powder/Stain Remover/Boost Vivid White + Bright/Pouch/10ct/Non-Refill'
        );
        lpsToInsert.add(lp3);
		Local_Product__c lp4 = new Local_Product__c(
            Global_Product__c = gp4.Id,
			Name = 'Ivory',
            Brand__c = 'The Art of Shaving',
            Consumer_Facing__c = True,
            Consumer_Facing_Brand__c = 'The Art of Shaving',
			Consumer_Facing_Name__c = 'The Art of Shaving Pure Badger Shaving Brush. Ivory',
            Country__c = 'United States of America',
            GTIN_Number__c = '444444444444444',
            Translated_Path__c = 'The Art of Shaving/Prestige Accessories/Shave Brush/3/Pure Badger/Ivory'
        );
        lpsToInsert.add(lp4);
        Insert lpsToInsert;       
    }
    
    @isTest
    static void coverage(){
		PageReference pageRef = Page.consoleWhereToBuy;
        Test.setCurrentPage(pageRef);
        
        ctr_WhereToBuy con = new ctr_WhereToBuy();
        
        con.consoleParam = false;
        con.brandParam = 'Tide';
        con.countryParam = 'United States of America';
        con.gtin = '123456';
        con.langParam = 'en';
        con.location = 'New York';
    }

	@isTest
    static void wtbStoreLocatorCalloutTest(){
        String gtin = '11111111111111';
        String latitude = '40.7127837';
        String longitude = '-74.0059413';
        String langCode = '';//Will default to EN-US
        
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('testStoreLocatorResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
		Test.setMock(HttpCalloutMock.class, mock);

        test.startTest();
        	Object locations = ctr_WhereToBuy.getStoreLocations(gtin, latitude, longitude,langCode);
        	system.assertNotEquals(null, locations);
        test.stopTest();
    }
    
    @isTest
    static void wtbStoreLocatorBadResponseTest(){
		String gtin = '11111111111111';
        String latitude = '40.7127837';
        String longitude = '-74.0059413';
        String langCode = '';//Will default to EN-US
        
  		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('testStoreLocatorResponse');
        mock.setStatusCode(503);
        mock.setHeader('Content-Type', 'application/json');
		Test.setMock(HttpCalloutMock.class, mock);

        Object locations;
        String errorMsg = '';
        
        test.startTest();
            try{
                locations = ctr_WhereToBuy.getStoreLocations(gtin, latitude, longitude,langCode);
            }
            catch(exception e){
                errorMsg = e.getMessage();
            }
            system.assertEquals('Service issue', errorMsg);
        test.stopTest();          
    }
    
	@isTest
    static void wtbStoreLocatorBadJSONTest(){
		String gtin = '11111111111111';
        String latitude = '40.7127837';
        String longitude = '-74.0059413';
        String langCode = '';//Will default to EN-US
        
  		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('DPRUploadCSS');//random text static resource not in JSON format
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
		Test.setMock(HttpCalloutMock.class, mock);

        Object locations;
        String errorMsg = '';
        
        test.startTest();
            try{
                locations = ctr_WhereToBuy.getStoreLocations(gtin, latitude, longitude,langCode);
            }
            catch(exception e){
                errorMsg = e.getMessage();
            }
            system.assertEquals('Service response issue', errorMsg);
        test.stopTest();          
    }
    
    
	@isTest
    static void wtbGeocodeCalloutTest(){
        String location = 'Silver Fox Way, Cobalt Business park, Newcastle upon Tyne NE27 0QW';
        String latlng = '55.0217569,-1.5023137';

		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('testGeocodeResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
		Test.setMock(HttpCalloutMock.class, mock);
        
        test.startTest();
        	String geocodeResult = ctr_WhereToBuy.geocodeAddress(location);
        	system.assertEquals(latlng, geocodeResult);
        test.stopTest();
    }
    
	@isTest
    static void getCountriesTest(){
        test.startTest();
        	List<String> countryList = new List<String>(ctr_WhereToBuy.getCountries('United States of America'));
        	system.assertEquals(3, countryList.size());
		test.stopTest();        
    }
    
	@isTest
    static void wtbGetCountryCodeTest(){
        test.startTest();
        	String countryCode = ctr_WhereToBuy.getCountryCode('United States of America');
    		system.assertEquals('US', countryCode);
        	countryCode = ctr_WhereToBuy.getCountryCode('United Kingdom');
        	system.assertEquals('UK', countryCode);
			countryCode = ctr_WhereToBuy.getCountryCode('Canada');
			system.assertEquals('CA', countryCode);
        test.stopTest();
    }

	@isTest
    static void wtbSOQLTest(){
		PageReference pageRef = Page.siteWhereToBuy;
        Test.setCurrentPage(pageRef);

        Test.startTest();
			List<Local_Product__c> lps = new List<Local_Product__c>();
        	//GTIN search
        	lps = ctr_WhereToBuy.productSearch('11111111111111', 'United States of America', 'Tide');
        	system.assertEquals(1, lps.size());
        	//String search
        	lps.clear();
        	lps = ctr_WhereToBuy.productSearch('cold', 'United States of America', 'Tide');
        	system.assertEquals(1, lps.size());        
        Test.stopTest();
    }
    
    @isTest
    static void wtbSOSLTest(){
        List<Local_Product__c> lps = new List<Local_Product__c>([SELECT Id, Translated_Path__c FROM Local_Product__c]);
        List<Id> soslResult = new List<Id>();
        for(local_product__c lp : lps){
            soslResult.add(lp.Id);
        }
        Test.setFixedSearchResults(soslResult);
        
        Test.startTest();
        	List<Local_Product__c> lpResults = new List<Local_Product__c>();
			lpResults = ctr_WhereToBuy.productSearch('Laundry Detergent', 'United States of America', 'Tide');
        	system.assertEquals(3, lpResults.size());
        Test.stopTest();
    }
    
    @isTest
    static void wtbReverseGeocodeTest(){
        String addressResult = '';
        Map<String, String> latlngMap = new Map<String, String>();
        latlngMap.put('lat', '55.0217569');
        latlngMap.put('lng', '-1.5023137');

		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('testReverseGeocodeJSON');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
		Test.setMock(HttpCalloutMock.class, mock);
        
        test.startTest();
        	addressResult = googleGeocode_Util.getReverseGeocode(latlngMap);
        	system.assertEquals('13A Silver Fox Way, Newcastle upon Tyne NE27 0QJ, UK', addressResult);
        test.stopTest();
    }

    @isTest
    static void wtbgetDistanceUnitTest(){
        test.startTest();
        	String distanceUnit = ctr_WhereToBuy.getDistanceUnit('Canada');
        	system.assertEquals('km', distanceUnit);
        
			distanceUnit = ctr_WhereToBuy.getDistanceUnit('United Kingdom');
        	system.assertEquals('miles', distanceUnit);
        test.stopTest();
    }

}