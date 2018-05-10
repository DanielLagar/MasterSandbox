@isTest
private class sf_ProductSearchSubtabControllerTest {

    static testMethod void searchProductAndAddProductTest() {
    	Product_Search_Configuration__c psc = new Product_Search_Configuration__c();
    	psc.Max_Search_Results_Returned__c = 100;
    	insert psc;
    	
    	Case c = new Case ();
    	c.Country__c = 'United States of America';
    	c.Language__c = 'English-US';
    	insert c;

        Global_Product__c gp = new Global_Product__c();
        //gp.Name = 'test product';
        insert gp;

    	List <Local_Product__c> lpl = new List <Local_Product__c> ();

    	for (Integer i=0; i<200; i++) {
    		Local_Product__c lp = new Local_Product__c ();
	    	lp.Name = 'tester' + i;
	    	lp.Country__c = 'United States of America';
	    	lp.Translated_Path__c = 'tester path ' + i;
            lp.Global_Product__c = gp.Id;
            lp.Consumer_Facing_Brand__c = 'test';

	    	lpl.add(lp);
    	}

    	insert lpl;

		//Verify Products inserted
    	System.assertEquals(200, [SELECT Id FROM Local_Product__c].size(), 'Product was not created.');

    	ApexPages.StandardController sc = new ApexPages.StandardController (c);
    	sf_ProductSearchSubtabController ctrl = new sf_ProductSearchSubtabController (sc);

	    Test.startTest();
	    	
	    	//verify case query by caseId
	    	System.assertEquals(c.Id, ctrl.caseRecord.Id, 'Case Id not set');
	    	System.assertEquals('United States of America', ctrl.caseRecord.Country__c, 'Case Country not set');
	    	System.assertEquals('English-US', ctrl.caseRecord.Language__c, 'Case Language not set');
        
        	List<SelectOption> countries = ctrl.getCountries();
        	System.assert(countries.size() > 0);

	    	//Verify product search results
			Id [] productResults = new Id[1];
	   		productResults[0] = lpl[0].Id;
			Test.setFixedSearchResults(productResults);
	    	List <sf_ProductSearchSubtabController.SearchResult> lpList = sf_ProductSearchSubtabController.doSoslSearch('test', 'United States of America', 'freeText');
	    	System.assertNotEquals(1, lpList.size(), 'Search did not return expected results');
	
	    	//Verify product search results with IPMS

			//verify adding product
	    	Integer successCount = sf_ProductSearchSubtabController.addProduct([SELECT Id FROM Local_Product__c LIMIT 1].Id, 'test', c.Id, 'test', '', '');
	    	System.assertEquals(1, [SELECT Id FROM Case_Product__c].size(), 'Product was not added.');
	    	System.assertEquals(1, successCount, 'Test Error: Expecting 1 Product to be added.');
	    	
	    	//verify add product error for blank Local_Product__c.Id
	    	Integer failCount = sf_ProductSearchSubtabController.addProduct('', 'test', c.Id, 'test', '', '');
	    	System.assertEquals(-1, failCount, 'Test Error: Expecting Add Product Failure (-1)');

    	Test.stopTest();
    }
    
	public static testMethod void gtinAndIpmsSearchTest(){
		Product_Search_Configuration__c psc = new Product_Search_Configuration__c();
    	psc.Max_Search_Results_Returned__c = 100;
    	insert psc;
    	
    	Case c = new Case ();
    	c.Country__c = 'China';
    	c.Language__c = 'Chinese';
    	insert c;

        Global_Product__c gp = new Global_Product__c();
        insert gp;

    	Local_Product__c lp = new Local_Product__c ();
	    lp.Name = 'tester';
	    lp.Country__c = 'China';
	    lp.Translated_Path__c = 'tester path 1';
        lp.Global_Product__c = gp.Id;
        lp.GTIN_Number__c = '0000012345';
    	insert lp;
    	
    	Local_Product__c lp2 = new Local_Product__c ();
	    lp2.Name = '12345';
	    lp2.Country__c = 'China';
	    lp2.Translated_Path__c = 'tester path 1';
        lp2.Global_Product__c = gp.Id;
        lp2.GTIN_Number__c = '0000012345';
    	insert lp2;
    	
    	IPMS__c ipms = new IPMS__c();
    	ipms.Name = '0012345';
    	ipms.Local_Product__c = lp.Id;
    	insert ipms;

    	IPMS__c ipms2 = new IPMS__c();
    	ipms2.Name = '0012345678';
    	ipms2.Local_Product__c = lp.Id;
    	insert ipms2;
    	
        GTIN__c gtin = new GTIN__c();
    	gtin.Name = '0012345';
    	gtin.Local_Product__c = lp.Id;
    	insert gtin;
    	
    	ApexPages.StandardController sc = new ApexPages.StandardController (c);
    	sf_ProductSearchSubtabController ctrl = new sf_ProductSearchSubtabController (sc);
    
    	test.startTest();
    		
    		//coverage for GTIN search
    		Id [] gtinResults = new Id[2];
       		gtinResults[0] = lp.Id;
       		gtinResults[1] = gtin.Id;
    		Test.setFixedSearchResults(gtinResults);
    		List<sf_ProductSearchSubtabController.SearchResult> gtinProdList = sf_ProductSearchSubtabController.doSoslSearch('12345', 'China', 'barCode');
    		System.assertEquals(1, gtinProdList.size(), 'Invalid results returned for GTIN search.');

			//Test IPMS search
			Id [] ipmsResults = new Id[4];
			ipmsResults[0] = lp.Id;
       		ipmsResults[1] = lp2.Id;
       		ipmsResults[2] = ipms.Id;
       		ipmsResults[3] = ipms2.Id;
    		Test.setFixedSearchResults(ipmsResults);			
			List<sf_ProductSearchSubtabController.SearchResult> ipmsProdList = sf_ProductSearchSubtabController.doSoslSearch('12345', 'China', 'ipmsSearch');
    		System.assertEquals(2, ipmsProdList.size(), 'Invalid results returned for IPMS search.');

    	test.stopTest();	
    }
}