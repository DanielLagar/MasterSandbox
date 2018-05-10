@isTest
private class sf_PopOutProductSearchConsoleCompTest {
	
    public static testMethod void testAddProductComment () {

    	Case c = new Case ();
    	c.Country__c = 'China';
    	c.Language__c = 'Chinese';
    	insert c;

        Global_Product__c gp = new Global_Product__c();
        //gp.Name = 'test product';
        insert gp;

    	List <Local_Product__c> lpl = new List <Local_Product__c> ();

    	for (Integer i=0; i<200; i++) {
    		Local_Product__c lp = new Local_Product__c ();
	    	lp.Name = 'tester' + i;
	    	lp.Country__c = 'China';
	    	lp.Translated_Path__c = 'tester path ' + i;
            lp.Global_Product__c = gp.Id;

	    	lpl.add(lp);
    	}

    	insert lpl;

    	Global_Comment_Code__c gcc = new Global_Comment_Code__c ();
    	insert gcc;

    	Local_Comment_Code__c cc = new Local_Comment_Code__c ();
    	cc.Level_1__c = 'TestLevel1';
    	cc.Level_2__c = 'TestLevel2';
    	//cc.Name = 'test';
    	cc.Global_Comment_Code__c = gcc.Id;
    	cc.Translated_Language__c = 'Chinese';
    	cc.Inactive__c = false;
    	insert cc;
    	
    	Product_Comment_Code__c pcc = new Product_Comment_Code__c();
    	pcc.Global_Comment_Code__c = gcc.Id;
    	pcc.Global_Product__c = gp.Id;
    	pcc.Global_Product_Brand__c = 'TestBrand';
    	pcc.Global_Product_Segment__c = 'TestSegment';
    	insert pcc;

    	System.assertEquals(200, [SELECT Id FROM Local_Product__c].size(), 'Product was not created.');

    	ApexPages.StandardController sc = new ApexPages.StandardController (c);
    	sf_PopOutProductSearchConsoleCompCtrl ctrl = new sf_PopOutProductSearchConsoleCompCtrl (sc);

    	Test.startTest();

    	//verify object check
    	System.assertEquals('Case', sf_PopOutProductSearchConsoleCompCtrl.checkObjectId(c.Id), 'checkObjectId not returning Case');
    	
    	//verify case query by caseId
    	ctrl.caseId = c.Id;
    	ctrl.setCaseId();
    	System.assertEquals(ctrl.caseId, ctrl.caseRecord.Id, 'Case Id not set');

    	//verify language check
    	String caseLanguage = sf_PopOutProductSearchConsoleCompCtrl.getCaseLanguage(c.Id);
    	System.assertEquals('Chinese', caseLanguage, 'Case Language not set');
    	
    	//Verify product search results
		Id [] productResults = new Id[1];
   		productResults[0] = lpl[0].Id;
		Test.setFixedSearchResults(productResults);
    	List <sObject> lpList = sf_PopOutProductSearchConsoleCompCtrl.doSoslSearch('test', 'China', false);
    	System.assertEquals(1, lpList.size(), 'Search did not return expected results');
    	
    	//verify case comment code search
		Id [] commentResults = new Id[1];
   		commentResults[0] = cc.Id;
		Test.setFixedSearchResults(commentResults);
    	List <sObject> ccList = sf_PopOutProductSearchConsoleCompCtrl.doCaseCommentSoslSearch(gp.Id, 'TestBrand', 'TestSegment', 'test', 'China', c.Language__c, 'TestLevel1', 'TestLevel2');
    	//List <sObject> ccList2 = sf_PopOutProductSearchConsoleCompCtrl.doCaseCommentSoslSearch('', 'test', 'China', caseLanguage, 'TestLevel1', 'TestLevel2');
    	System.assertEquals(1, ccList.size(), 'Comment Code Search did not return expected results');

		//verify adding product
    	sf_PopOutProductSearchConsoleCompCtrl.addProduct([SELECT Id FROM Local_Product__c LIMIT 1].Id, c.Id);
    	System.assertEquals(1, [SELECT Id FROM Case_Product__c].size(), 'Product was not added.');
    	
    	//verify adding comment code
    	ctrl.refreshCaseProducts();
    	ctrl.localProductId = [SELECT Id FROM Case_Product__c LIMIT 1].Id;
    	sf_PopOutProductSearchConsoleCompCtrl.addCaseCommentCode(c.Id, cc.Id, ctrl.localProductId);
    	System.assertEquals(1, [SELECT Id FROM Case_Comment_Code__c].size(), 'Case Comment was not added.');
    	
    	//verify removing case comment code
    	ctrl.refreshCaseProducts();
    	ctrl.commentCodeId = [SELECT Id FROM Case_Comment_Code__c LIMIT 1].Id;
    	ctrl.removeCommentCode();
    	System.assertEquals(0, [SELECT Id FROM Case_Comment_Code__c].size(), 'Case Comment was not removed.');

    	//verify removing case product
    	ctrl.removeCaseProduct();
    	System.assertEquals(0, [SELECT Id FROM Case_Product__c].size(), 'Case Product was not removed.');

    	Test.stopTest();
    }


    public static testMethod void testExceptions () {

    	Case c = new Case ();
    	c.Country__c = 'China';
    	insert c;

    	ApexPages.StandardController sc = new ApexPages.StandardController (c);
    	sf_PopOutProductSearchConsoleCompCtrl ctrl = new sf_PopOutProductSearchConsoleCompCtrl (sc);

    	Test.startTest();

    	ctrl.removeCommentCode();
    	ctrl.removeCaseProduct();
    
    	ctrl.localProductId = 'sdas';
    	ctrl.commentCodeId = 'sdasd';
    	
    	ctrl.removeCommentCode();
    	ctrl.removeCaseProduct();

    	Test.stopTest();
    }	
    
    public static testMethod void testFilteringAndDictionary(){
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
    	insert lp;

    	Global_Comment_Code__c gcc = new Global_Comment_Code__c ();
    	insert gcc;

    	Local_Comment_Code__c lcc = new Local_Comment_Code__c();
    	lcc.Level_1__c = 'TestLevel1';
    	lcc.Level_2__c = 'TestLevel2';
    	lcc.Translated_Language__c = 'Chinese';
    	//cc.Name = 'test';
    	lcc.Global_Comment_Code__c = gcc.Id;
    	insert lcc;
    	
    	Product_Comment_Code__c pcc = new Product_Comment_Code__c();
    	pcc.Global_Comment_Code__c = gcc.Id;
    	pcc.Global_Product__c = gp.Id;
    	pcc.Global_Product_Brand__c = 'TestBrand';
    	pcc.Global_Product_Segment__c = 'TestSegment';
    	insert pcc;

    	ApexPages.StandardController sc = new ApexPages.StandardController (c);
    	sf_PopOutProductSearchConsoleCompCtrl ctrl = new sf_PopOutProductSearchConsoleCompCtrl (sc);

    	Test.startTest();

    	//verify object check
    	System.assertEquals('Case', sf_PopOutProductSearchConsoleCompCtrl.checkObjectId(c.Id), 'checkObjectId not returning Case');
    	
    	//Set filters
    	ctrl.levelOne = 'TestLevel1';
    	ctrl.levelTwo = 'TestLevel2';
    	
    	//verify case query by caseId
    	ctrl.caseId = c.Id;
    	ctrl.setCaseId();
    	System.assertEquals(ctrl.caseId, ctrl.caseRecord.Id, 'Case Id not set');
    	
    	//verify Map of filters are populated
    	System.assertEquals(true, ctrl.optionMap.size() > 0, 'Option Map is empty.');
    	List<SelectOption> levelOneOptions = ctrl.getLevelOneList();
    	System.assertEquals(true, levelOneOptions.size() > 0, 'Level 1 filter is empty');
    	
    	//Add a product and Add comment code through dictionary
    	sf_PopOutProductSearchConsoleCompCtrl.addProduct(lp.Id, c.Id);
    	ctrl.dictionaryProductId = [SELECT Id FROM Case_Product__c LIMIT 1].Id;
 		ctrl.addSelectedCommentCode();
 		System.assertEquals(1, [SELECT Id FROM Case_Comment_Code__c].size(), 'Case Comment was not added.');
 		
 		//Verify dictionary product name is found
 		ctrl.refreshCaseProducts();
 		ctrl.caseProductIndex = 0;
    	ctrl.openCommentCodeDictionary();
    	System.assertEquals('tester', ctrl.dictionaryProduct.Local_Product__r.Name, 'Dictionary Product Name not found');
    	
    	//verify comment code filtering by product
    	ctrl.globalProductId = gp.Id;
    	ctrl.levelOne = 'TestLevel1';
    	ctrl.levelTwo = 'TestLevel2';
    	ctrl.refreshCodeFilterList();
    	System.assertEquals(1, ctrl.localCodes.size(), 'Comment Code Filtering by Global Product results invalid');
    	
    	//verify sort direction flips to DESC
    	ctrl.sortBy = 'Level_1__c';
    	ctrl.lastSort = 'Level_1__c';
    	ctrl.sortDirection = 'ASC';
    	ctrl.setSortDirection();
    	System.assertEquals('DESC', ctrl.sortDirection, 'SortDirection should be DESC');
    	
    	//verify sort direction flips to ASC
    	ctrl.setSortDirection();
    	System.assertEquals('ASC', ctrl.sortDirection, 'SortDirection should be ASC');
    	
    	//verify sort resets on new field selection
    	ctrl.sortBy = 'Level_2__c';
    	ctrl.setSortDirection();
    	System.assertEquals('ASC', ctrl.sortDirection, 'SortDirection should be ASC');
    	System.assertEquals('Level_2__c', ctrl.lastSort, 'lastSort should be Level_2__c');
    	
    	//coverage for filter change
    	ctrl.globalProductId = '';
    	ctrl.levelOne = 'TestLevel1';
    	ctrl.levelTwo = 'TestLevel2';
    	ctrl.refreshCodeFilterList();
    	ctrl.filterByLevel1();
    	System.assertEquals('', ctrl.levelTwo, 'LevelTwo filter should be blank');

		Test.stopTest();
    }
    
    public static testMethod void testGtinAndIpmsSearch(){
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
    	ipms.Name = '12345';
    	ipms.Local_Product__c = lp.Id;
    	insert ipms;
    	
    	ApexPages.StandardController sc = new ApexPages.StandardController (c);
    	sf_PopOutProductSearchConsoleCompCtrl ctrl = new sf_PopOutProductSearchConsoleCompCtrl (sc);
    
    	test.startTest();
    		
    		//coverage for GTIN search
    		Id [] gtinResults = new Id[1];
       		gtinResults[0] = lp.Id;
    		Test.setFixedSearchResults(gtinResults);
    		List<Local_Product__c> gtinProdList = sf_PopOutProductSearchConsoleCompCtrl.doSoslSearch('12345', 'China', true);
    		System.assertEquals(1, gtinProdList.size(), 'Invalid results returned for GTIN search.');

			//Test IPMS search
			Id [] ipmsResults = new Id[3];
			ipmsResults[0] = ipms.Id;
       		ipmsResults[1] = lp.Id;
       		ipmsResults[2] = lp2.Id;
    		Test.setFixedSearchResults(ipmsResults);			
			List<Local_Product__c> ipmsProdList = sf_PopOutProductSearchConsoleCompCtrl.doSoslSearch('12345', 'China', false);
    		System.assertEquals(2, ipmsProdList.size(), 'Invalid results returned for IPMS search.');

    	test.stopTest();
    	
    }
}