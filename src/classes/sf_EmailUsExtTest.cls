/*
* @author: Lauren OMeara
* @date: 08/12/2014
* @description:  Test class for sf_EmailUsExt.cls
*
* Changes:
* Improved code coverage 27-10-2015 christopher.macduff@accenture.com
*/

@isTest
private class sf_EmailUsExtTest {
	
	@testSetup static void setup () {
		Contact_Us_Brand__c brand = new Contact_Us_Brand__c ();
		brand.name = sf_ContactUsHelperCtrl.DEFAULT_BRAND;
		brand.Brand__c = sf_ContactUsHelperCtrl.DEFAULT_BRAND;

		insert brand;

		Contact_Us_Language__c lang = new Contact_Us_Language__c ();
		lang.Name = 'Default';
		lang.Language__c = sf_ContactUsHelperCtrl.DEFAULT_LANGUAGE;
		lang.Country__c = sf_ContactUsHelperCtrl.DEFAULT_COUNTRY;
		lang.Country_Label__c = sf_ContactUsHelperCtrl.DEFAULT_COUNTRY;
		lang.Language_Locale_Key__c = 'en_US';
		lang.Reason_1__c = '1';
		lang.Reason_2__c = '2';
		lang.Reason_3__c = '3';
		lang.Reason_4__c = '4';
		lang.Reason_5__c = '5';
		lang.Reason_6__c = '6';
		lang.Reason_Please_Select__c = 'blah';

		insert lang;

		Contact_Us_Brand_Language__c brLang = new Contact_Us_Brand_Language__c ();
		brLang.Contact_Us_Brand__c = brand.Id;
		brLang.Contact_Us_Language__c = lang.Id;
		brLang.Q1_Question_Type__c = 'Text';
		brLang.Q2_Question_Type__c = 'Text';
		brLang.Q3_Question_Type__c = 'Text';
		brLang.Q4_Question_Type__c = 'Text';
		brLang.Q5_Question_Type__c = 'Text';
		brLang.Q6_Question_Type__c = 'Text';

		brLang.Q1_Question__c = 'blah blah';
		brLang.Q1_Reasons_For_Writing__c = 'blah;blah1';
		brLang.Case_Submit_Minimum_Age__c = 12;

		insert brLang;

		Notification_Templates__c templates = new Notification_Templates__c ();
		templates.Brand__c = sf_ContactUsHelperCtrl.DEFAULT_BRAND;
		templates.Language__c = sf_ContactUsHelperCtrl.DEFAULT_LANGUAGE;
		templates.Template_Id__c = [SELECT Id FROM EmailTemplate WHERE IsActive = true LIMIT 1].Id;
		templates.Template_Name__c = [SELECT Id, DeveloperName FROM EmailTemplate WHERE IsActive = true LIMIT 1].DeveloperName;
		templates.Name = 'blah';

		insert templates;

		Metadata_Site_Rule__c msr = new Metadata_Site_Rule__c ();
		msr.Reason_for_Writing__c = '1;2;3;4;5;6;7;8;9;10';
		msr.Keywords__c = 'pork';
		msr.Country__c = sf_ContactUsHelperCtrl.DEFAULT_COUNTRY;
		msr.Brand__c = sf_ContactUsHelperCtrl.DEFAULT_BRAND;
		msr.Language__c = sf_ContactUsHelperCtrl.DEFAULT_LANGUAGE;
		msr.Priority__c = '1;2;3;4;5;6;';

		insert msr;

		Global_Product__c gp = new Global_Product__c();
        insert gp;

    	List <Local_Product__c> lpl = new List <Local_Product__c> ();

    	for (Integer i=0; i<20; i++) {
    		Local_Product__c lp = new Local_Product__c ();
	    	lp.Name = 'tester' + i;
	    	lp.Country__c = sf_ContactUsHelperCtrl.DEFAULT_COUNTRY;
	    	lp.Brand__c = sf_ContactUsHelperCtrl.DEFAULT_BRAND;
	    	lp.Consumer_Facing_Brand__c = sf_ContactUsHelperCtrl.DEFAULT_BRAND;
	    	lp.Consumer_Facing__c = true;
	    	lp.Translated_Path__c = 'tester path ' + i;
            lp.Product_Description__c = 'tester path ' + i;
            lp.Global_Product__c = gp.Id;

	    	lpl.add(lp);
    	}

    	insert lpl;

	}

	@isTest static void testInit() {

		Test.setCurrentPage(Page.EmailUs);
		ApexPages.currentPage().getParameters().put('debug', '1');

		Test.startTest();

		sf_EmailUsExt ext = new sf_EmailUsExt (new sf_ContactUsTemplateController());
		ext.birthdate = '12/12/1922';
		sf_EmailUsExt.doSoqlGTINSearch('test', 'brand', 'brand', true);

		Test.setMock(HttpCalloutMock.class, new sf_MockStrikeIronGblAddressImpl());
		sf_EmailUsExt.validatePrimaryAddress('one', 'one', 'one', 'one', 'one', 'one', 'one');
		ext.submit_WithSuggestedAddress();
		ext.submit_WithUserInputAddress();

		String attid = sf_EmailUsExt.doUploadAttachment('foo', 'blah', 'xml', null);
		sf_EmailUsExt.doUploadAttachment('foo', 'blah', 'xml', attid);

		ext.save();

		System.assertNotEquals('null', ext.defaultProductImageUrl);
		System.assertNotEquals(0, ext.prodImageWidth);

		Test.stopTest();
	}

	@isTest static void testOtherStuff() {

		Test.setCurrentPage(Page.EmailUs);
		ApexPages.currentPage().getParameters().put('debug', '1');

		Test.startTest();

		sf_EmailUsExt ext = new sf_EmailUsExt (new sf_ContactUsTemplateController());

		Test.setMock(HttpCalloutMock.class, new sf_MockStrikeIronEmailValidationImpl());
		sf_EmailUsExt.validateEmailAddressString('test@test.com');
		
		ext.birthdate = '12/12/2014';
		ext.productSearchTermText = 'foo';
		sf_EmailUsExt.doSoqlGTINSearch('tester', sf_ContactUsHelperCtrl.DEFAULT_BRAND, sf_ContactUsHelperCtrl.DEFAULT_COUNTRY, false);
		ext.productId = [SELECT Id FROM Local_Product__c LIMIT 1].Id;
		ext.selectedGTIN = 'blah';
		ext.addCaseProduct();
		ext.caseProductWrapperList[0].isSelected = true;

		ext.save();

		System.assertNotEquals('null', ext.defaultProductImageUrl);
		System.assertNotEquals(0, ext.prodImageWidth);

		Test.stopTest();
	}
    
    @isTest static void strikeIronFormValidationTest(){
        String emailAddress = 'testemail@emailtest.net';
        String addressLine1 = 'Cobalt 12';
        String addressLine2 = 'Silver Fox Way';
        String addressLine3 = 'Cobalt Business Park';
        String addressZipPostalCode = 'NE27 0QW';
        String addressCityTown = 'Newcastle-upon-Tyne';
        String addressStateProvince = 'Newcastle-upon-Tyne';
        String addressCountry = 'UK';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new sf_MockStrikeIronGblAddressImpl());
        sf_EmailUsExt.strikeIronFormValidation(emailAddress, addressLine1, addressLine2, addressLine3, addressZipPostalCode, addressCityTown, addressStateProvince, addressCountry);
        Test.stopTest(); 
    }
    
    @isTest static void strikeIronFormValidationTestOption2(){
        String emailAddress = 'testemail@emailtest.net';
        String addressLine1 = 'Cobalt 12';
        String addressLine2 = 'Silver Fox Way';
        String addressLine3 = 'Cobalt Business Park';
        String addressZipPostalCode = 'NE27 0QW';
        String addressCityTown = 'Newcastle-upon-Tyne';
        String addressStateProvince = 'Newcastle-upon-Tyne';
        String addressCountry = 'Brazil';
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('siTestAddressResponseOption2');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'text/plain');
		Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new sf_MockStrikeIronGblAddressImpl());
        sf_EmailUsExt.strikeIronFormValidation(emailAddress, addressLine1, addressLine2, addressLine3, addressZipPostalCode, addressCityTown, addressStateProvince, addressCountry);
        Test.stopTest();
    }
    
    @isTest static void strikeIronFormValidationTestOption3(){
        String emailAddress = 'testemail@emailtest.net';
        String addressLine1 = 'Cobalt 12';
        String addressLine2 = 'Silver Fox Way';
        String addressLine3 = 'Cobalt Business Park';
        String addressZipPostalCode = 'NE27 0QW';
        String addressCityTown = 'Newcastle-upon-Tyne';
        String addressStateProvince = 'Newcastle-upon-Tyne';
        String addressCountry = 'Germany';
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('siTestAddressResponseOption3');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'text/plain');
		Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new sf_MockStrikeIronGblAddressImpl());
        sf_EmailUsExt.strikeIronFormValidation(emailAddress, addressLine1, addressLine2, addressLine3, addressZipPostalCode, addressCityTown, addressStateProvince, addressCountry);
        Test.stopTest();
    }
    
    @isTest static void strikeIronFormValidationTestOption4(){
        String emailAddress = 'testemail@emailtest.net';
        String addressLine1 = 'Cobalt 12';
        String addressLine2 = 'Silver Fox Way';
        String addressLine3 = 'Cobalt Business Park';
        String addressZipPostalCode = 'NE27 0QW';
        String addressCityTown = 'Newcastle-upon-Tyne';
        String addressStateProvince = 'Newcastle-upon-Tyne';
        String addressCountry = 'Japan';
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('siTestAddressResponseOption4');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'text/plain');
		Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new sf_MockStrikeIronGblAddressImpl());
        sf_EmailUsExt.strikeIronFormValidation(emailAddress, addressLine1, addressLine2, addressLine3, addressZipPostalCode, addressCityTown, addressStateProvince, addressCountry);
        Test.stopTest();
    }
    
    @isTest static void strikeIronFormValidationTestOption5(){
        String emailAddress = 'testemail@emailtest.net';
        String addressLine1 = 'Cobalt 12';
        String addressLine2 = 'Silver Fox Way';
        String addressLine3 = 'Cobalt Business Park';
        String addressZipPostalCode = 'NE27 0QW';
        String addressCityTown = 'Newcastle-upon-Tyne';
        String addressStateProvince = 'Newcastle-upon-Tyne';
        String addressCountry = 'China';
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('siTestAddressResponseOption5');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'text/plain');
		Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new sf_MockStrikeIronGblAddressImpl());
        sf_EmailUsExt.strikeIronFormValidation(emailAddress, addressLine1, addressLine2, addressLine3, addressZipPostalCode, addressCityTown, addressStateProvince, addressCountry);
        Test.stopTest();
    }
    
    
    
    
    
    
   @isTest static void emailUsExtCoverage(){
		String TOO_YOUNG_COOKIE = 'EmailUsTooYoung';
		String COOKIE_PATH_ANY = '/';
		Integer SESSION_COOKIE = -1;
		Boolean COOKIE_NOT_SECURE_ONLY = false;
        
        Case testCase = new Case();
        insert testCase;
        
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        Attachment att = new Attachment(
        	Name = 'Attach Name',
            Body = bodyBlob,
            ParentId = testCase.Id
        );
        insert att;

		PageReference pageRef = Page.EmailUs;
        Test.setCurrentPage(pageRef);

        test.startTest();
        sf_EmailUsExt ext = new sf_EmailUsExt (new sf_ContactUsTemplateController());
        
        //line coverage:
        String testString = ext.agerange;
        testString = ext.comment;
        testString = ext.productsearch;
        testString = ext.segment;
        testString = ext.formattedUserInputWithHTMLBreaksAndColors;
		testString = ext.formattedAddressWithHTMLBreaks;
		testString = ext.emailAboutProducts;
        Integer testInt = ext.prodImageHeight;
        testInt = ext.cpRowToRemove;
       	
        List<Integer> testList = new List<Integer>();
       	testList = ext.getCaseProductIndexes();
        
        /*CDOY WR172 - Remove DOB Validation from ContactUs Pages */
        /*
        ext.redirectIfTooYoung();
		Cookie testCookie = new Cookie(TOO_YOUNG_COOKIE, 'true', COOKIE_PATH_ANY, SESSION_COOKIE, COOKIE_NOT_SECURE_ONLY);
        ApexPages.currentPage().setCookies(new Cookie[]{testCookie});
        ext.redirectIfTooYoung();
        */
        
        Contact_Us_Brand_Language__c brLang = new Contact_Us_Brand_Language__c();
        brLang = [SELECT Id,Case_Submit_Minimum_Age__c, Age_Capture_Style__c FROM Contact_Us_Brand_Language__c LIMIT 1];
        brLang.Age_Capture_Style__c = 'MM/YYYY';
        update brLang;
        
        ext = new sf_EmailUsExt (new sf_ContactUsTemplateController());

        ext.firstName = 'firstTest';
        ext.lastName = 'lastTest';
        ext.email = 'firstTest.lastTest@test.com';
        ext.phone = '01400567567';
        ext.birthdate = '01/1950';
        ext.selectedReasonForWritingClass = 'blah';
        ext.overridePrimaryAddress = 'false';
		ext.productId = [SELECT Id FROM Local_Product__c LIMIT 1].Id;
		ext.selectedGTIN = 'blah';
        ext.newCase.summary__c = 'test summary';
		ext.attachmentErrors = 'test1,test2,test3';
        
		ext.addCaseProduct();
		ext.caseProductWrapperList[0].isSelected = true;
        
        Integer qSize = ext.additionalQuestions.size();
        system.assertEquals(1, qSize);
        
        //This is required to test the SOSL element of the product search
        List<Id> fixedSearchResults = new List<Id>();
        fixedSearchResults.add(ext.productId);
        Test.setFixedSearchResults(fixedSearchResults);

        //SOSL path test - requires more than one words
        List<Local_Product__c> lpTestList = sf_EmailUsExt.doSoslProductSearch('tester path', sf_ContactUsHelperCtrl.DEFAULT_BRAND, sf_ContactUsHelperCtrl.DEFAULT_COUNTRY, false);
		system.assertEquals(1, lpTestList.size());
        //Clear list and test with one word - SOQL
        lpTestList.clear();
        lpTestList = sf_EmailUsExt.doSoslProductSearch('tester', sf_ContactUsHelperCtrl.DEFAULT_BRAND, sf_ContactUsHelperCtrl.DEFAULT_COUNTRY, false);
		system.assertEquals(sf_ContactUsHelperCtrl.SOSL_PRODUCT_LIMIT, lpTestList.size());        
        
        ext.attachmentId = att.Id;
        ext.save();
        
        test.stopTest();
    }

}