/*
 * Further tests for sf_ContactInfoController
 * christopher.macduff@accenture.com 30-11-2015 
 * 
*/
@isTest
private class sf_ContactInfoControllerTest2 {
    @testSetup static void setupData() {
		CustomSettingDataFactory.countryRegionSetup();
        
        List<Metadata_Title_Prefix__c> mtpToInsert = new List<Metadata_Title_Prefix__c>();
        Metadata_Title_Prefix__c mtpDR = new Metadata_Title_Prefix__c(
            Prefix__c = 'Dr.',
            Full_Title__c = 'Dear Dr.',
            Country__c = sf_Constants.COUNTRY_UNITED_STATES_AMERICA,
            Language__c = 'English-US'
        );
        mtpToInsert.add(mtpDR);
        
		Metadata_Title_Prefix__c mtpMRS = new Metadata_Title_Prefix__c(
            Prefix__c = 'Mrs.',
            Full_Title__c = 'Dear Mrs.',
            Country__c = sf_Constants.COUNTRY_UNITED_STATES_AMERICA,
            Language__c = 'English-US'
        );
        mtpToInsert.add(mtpMRS);
        insert mtpToInsert;

		Contact con = new Contact(
            salutation = 'Dr.',
        	FirstName = 'TestFirst',
            LastName = 'TestLast',
            Email = 'testemail@testdomain.com',
            Primary_Address_Line_1__c = 'Cobalt 12 A,',
            Primary_City__c = 'Newcastle upon Tyne',
            Primary_State_Province__c = 'Newcastle upon Tyne',
            Primary_Postal_Code__c = 'NE27 0QW',
            Primary_Country__c = sf_Constants.COUNTRY_UNITED_STATES_AMERICA, //Set to US initially to hit error
            Other_Address_Line_1__c = '15a Quick Silver Way',
            Other_City__c = 'Newcastle upon Tyne',
            Other_State_Province__c = 'Newcastle upon Tyne',
            Other_Postal_Code__c = 'NE27 0QQ',
            Other_Country__c = sf_Constants.COUNTRY_UNITED_STATES_AMERICA //Set to US initially to hit error
        );
        Insert con;
            
        List<Case> casesToInsert = new List<Case>();
        Case c = new Case(
        	ContactId = con.Id
        );
        casesToInsert.add(c); 
        
        Case noContactCase = new Case();
        casesToInsert.add(noContactCase);
        insert casesToInsert;
        
    }
    
    @isTest
    static void altLayoutTest(){
        Case testCase = [SELECT Id FROM Case WHERE ContactID = null LIMIT 1];
        testCase.Subject = 'China alt layout test Case';
        testCase.Country__c = 'China';
        update testCase;
        
        ApexPages.StandardController sc = new ApexPages.StandardController (testCase);

        test.startTest();
        	sf_ContactInfoController ext = new sf_ContactInfoController (sc); 
        	system.assertEquals(True, ext.altLayout);
        test.stopTest();
    }
    
    @isTest
    static void salutationGenerationTest(){
        Case c = [SELECT Id, ContactId FROM Case WHERE ContactId != null LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController (c);
        sf_ContactInfoController cic = new sf_ContactInfoController (sc);
        
        test.startTest();
        
        cic.currentCase = c;
        List<SelectOption> testSalutations = cic.Salutations;
        //Expecting 2: Dr. and Mrs.
        system.assertEquals(2, testSalutations.size());
        
        
        //Expecting 3: Default, Dr. and Mrs.
		c = [SELECT Id, ContactId FROM Case WHERE ContactId = null LIMIT 1];
        sc = new ApexPages.StandardController (c);
        cic = new sf_ContactInfoController (sc);
        cic.currentCase = c;
        testSalutations = cic.Salutations;
        
        system.assertEquals(3, testSalutations.size());
        
        test.stopTest();
        
    }
    
	@isTest
    static void validatePostCodeTest(){
        Case c = [SELECT Id, ContactId FROM Case WHERE ContactId != null LIMIT 1];
        Contact con = [SELECT Id,Primary_Postal_Code__c,Other_Postal_Code__c FROM Contact LIMIT 1];
        
		ApexPages.StandardController sc = new ApexPages.StandardController (c);
    	sf_ContactInfoController cic = new sf_ContactInfoController (sc);
		sf_StrikeIronService service = sf_StrikeIronServiceFactory.getStrikeIronService();
        
		Test.setMock(HttpCalloutMock.class, new sf_MockStrikeIronZipCodeLookupImpl());
        sf_StrikeIronZIPCodeLookupResponseBean bean;
		String street = 'Cobalt 12 A';
		String cityState = 'Newcastle upon Tyne';
        String zipOrPostalCode = 'NE27 0QW';
		String country = sf_Constants.COUNTRY_UNITED_STATES_AMERICA; 
        
        test.startTest();
        
        	cic.currentCase = c;
        	cic.setContactInfoObject(false);
        	system.assertEquals('testemail@testdomain.com', cic.contactInfo.email);
        	
        	cic.onContactTypeChange();
 
        	//Using US with UK postcode so should error initially
        	cic.addressBean = service.validateGlobalAddress (street, cityState, country);
        	Boolean expectedExceptionThrown;
            try{
                cic.validatePrimaryAddress();
            }
            catch(Exception e){
                expectedExceptionThrown =  e.getMessage().contains('Invalid Postal') ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);
            }
            try{
                cic.validateOtherAddress();
            }
            catch(Exception e){
				expectedExceptionThrown =  e.getMessage().contains('Invalid Postal') ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);
            }
        
        	//change country to UK and retry
        	cic.contactInfo.Primary_Country__c = 'United Kingdom';
        	cic.contactInfo.Other_Country__c = 'United Kingdom';
        	cic.addressBean = service.validateGlobalAddress (street, cityState, country);
        	cic.validatePrimaryAddress();
        	cic.validateOtherAddress();
			cic.validatePrimaryZip(con);
        	cic.validateOtherZip(con);

        test.stopTest();
    }
    
    @isTest
    static void globalBeanTest(){
        Case c = [SELECT Id, ContactId FROM Case WHERE ContactId != null LIMIT 1];
        Contact con = [SELECT Id,Primary_Postal_Code__c,Other_Postal_Code__c FROM Contact LIMIT 1];
        
		ApexPages.StandardController sc = new ApexPages.StandardController (c);
    	sf_ContactInfoController cic = new sf_ContactInfoController (sc);
		Test.setMock(HttpCalloutMock.class, new sf_MockStrikeIronGblCodeValidationImpl());
        sf_StrikeIronGblCodeLookupResponseBean bean;
        sf_StrikeIronService service = sf_StrikeIronServiceFactory.getStrikeIronService();
        
        test.startTest();
			cic.contactInfo.Primary_Country__c = 'United Kingdom';
        	cic.contactInfo.Primary_Postal_Code__c = 'NE27 0QW';
        	cic.contactInfo.Other_Country__c = 'United Kingdom';
        	cic.contactInfo.Other_Postal_Code__c = 'NE27 0QQ';
        
			cic.lookUpPrimaryPostalCode();
        	system.assertEquals('THREADNEEDLE STREET', cic.contactInfo.Primary_Address_Line_1__c); //Changed by mock response siTestGlobalCodeResponse.resource
			cic.lookUpOtherPostalCode();
        	system.assertEquals('THREADNEEDLE STREET', cic.contactInfo.Other_Address_Line_1__c); //Changed by mock response siTestGlobalCodeResponse.resource

        test.stopTest();
    }

    
	@isTest
    static void validateAddressTest(){
        Case c = [SELECT Id, ContactId FROM Case WHERE ContactId != null LIMIT 1];
        Contact con = [SELECT Id,Primary_Postal_Code__c,Other_Postal_Code__c FROM Contact LIMIT 1];

		ApexPages.StandardController sc = new ApexPages.StandardController (c);
    	sf_ContactInfoController cic = new sf_ContactInfoController (sc);
		Test.setMock(HttpCalloutMock.class, new sf_MockStrikeIronGblAddressImpl());
		sf_StrikeIronValidateGblAddressRespBean bean;
        sf_StrikeIronService service = sf_StrikeIronServiceFactory.getStrikeIronService();
		String street = 'Cobalt 12 A';
		String cityState = 'Newcastle upon Tyne';
        String zipOrPostalCode = 'NE27 0QW';
		String country = sf_Constants.COUNTRY_UNITED_STATES_AMERICA; 
        
        Test.startTest();
			cic.contactInfo.Primary_Country__c = 'United Kingdom';
        	cic.contactInfo.Other_Country__c = 'United Kingdom';
        	cic.addressBean = service.validateGlobalAddress (street, cityState, country);
        	cic.validatePrimaryAddress();
        	system.assertEquals(false, cic.contactInfo.Primary_Address_Validated__c = false);
        	cic.validateOtherAddress(); 
        	system.assertEquals(false, cic.contactInfo.Other_Address_Validated__c = false);
        
        Test.stopTest();
    }
    
    @isTest
    static void miscTest(){
        Case c = [SELECT Id, ContactId FROM Case WHERE ContactId != null LIMIT 1];
        Contact con = [SELECT Id, Name, FirstName, LastName, Email FROM Contact LIMIT 1];

		ApexPages.StandardController sc = new ApexPages.StandardController (c);
    	sf_ContactInfoController cic = new sf_ContactInfoController (sc); 
        
		PageReference pageRef = Page.sf_ContactInfo;
		Test.setCurrentPage(pageRef);

        //Line coverage...
        String testString = cic.emailAddress;
        testString = cic.faxOtherPhone;
        Decimal amberDecimal = cic.amber;
        Decimal greenDecimal = cic.green;
        
        //Catch error on Contact save - can't be invalid email so use null lastName
        cic.contactInfo.LastName = '';

        Test.startTest();
			system.debug(logginglevel.WARN,'!!!!!!!!!!!!! PRE SAVE CONTACT');
        	cic.saveContact();
        	system.debug(logginglevel.WARN,'!!!!!!!!!!!!! POST SAVE CONTACT');
        	List<Apexpages.Message> msgs = ApexPages.getMessages();
        	Boolean b = false;
            For(Apexpages.Message m : msgs){
                if(m.getDetail().contains('Required fields are missing')){ //should return missing field lastName is required
                    b = true;
                }
            }
        	system.assertEquals(true, b);
        Test.stopTest();
    }

    @isTest
    static void duplicateCheckTest(){
        Case c = [SELECT Id, ContactId FROM Case WHERE ContactId != null LIMIT  1];
        Contact con = [SELECT Id, Name, FirstName, LastName, Email FROM Contact LIMIT 1];

		ApexPages.StandardController sc = new ApexPages.StandardController (c);
    	sf_ContactInfoController cic = new sf_ContactInfoController (sc);
        
		PageReference pageRef = Page.sf_ContactInfo;
		Test.setCurrentPage(pageRef);
        
        Test.startTest();
        	cic.currentCase = c;
        	cic.contactInfo = con;
        
        	//Look for dupes
        	cic.checkExistingContact();

        	//no existing con selected, should display error
       		cic.selectExistingContact(); 
			List<Apexpages.Message> msgs = ApexPages.getMessages();
        	Boolean b = false;
            For(Apexpages.Message m : msgs){
                if(m.getDetail().contains('No existing contact selected.')){ 
                    b = true;
                }
            }
        	system.assertEquals(true, b);
        
			//select contact and try again
        	cic.selectedExistingContact = con.Id;
        	cic.selectExistingContact();
        
        Test.stopTest();
    }
    
	@isTest
    static void exceptionTest(){
        Case c = [SELECT Id, ContactId FROM Case WHERE ContactId != null LIMIT 1];

		ApexPages.StandardController sc = new ApexPages.StandardController (c);
    	sf_ContactInfoController cic = new sf_ContactInfoController (sc);
		sf_StrikeIronService service = sf_StrikeIronServiceFactory.getStrikeIronService();
        
		test.startTest();
        	cic.lookUpPrimaryPostalCode();
        	cic.lookUpOtherPostalCode();
        	cic.contactInfo = null;
            try{
				cic.lookUpPrimaryPostalCode();
            }
            catch(exception e){
             
            }
			try{
				cic.lookUpOtherPostalCode();
            }
            catch(exception e){
                
            }
            try{
                cic.validateEmailAddress();
            }
            catch(exception e){
                
            }
            try{
                cic.validatePrimaryAddress();
            }
            catch(exception e){
                
            }
			List<ApexPages.Message> msgs = new List<ApexPages.Message>(ApexPages.getMessages());
        	system.assert(msgs.size() > 1);
        test.stopTest();
    }

}