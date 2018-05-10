/**
  * @author: Stevie Ella
  * @date: 08/12/2014
  *
  * @description: Contact Info extension Unit Tests
  * 
  *  
  */
@isTest
private class sf_ContactInfoControllerTest {

    public static testMethod void setContactInfoObjectTest () {
        
        Contact contact = new Contact(
        	FirstName = 'First_Name',
        	LastName = 'Last_Name_Ellito'
        );
        insert contact;
        
    	Case c = new Case (
    		ContactId = contact.Id,
    		Contact = contact
    	);
    	insert c;
    	
    	ApexPages.StandardController sc = new ApexPages.StandardController (c);
    	sf_ContactInfoController contactInfoController = new sf_ContactInfoController (sc);

    	Test.startTest();
    	
    	// Verify the contactInfo var is set
    	System.assertEquals(contactInfoController.contactInfo.Id, contact.Id);

    	Test.stopTest();
    }
    
    public static testMethod void validateEmailAddressTest() {
    	User systemAdmin = [SELECT Id, Name FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
    	
    	Profile agentProfile = [SELECT Id, Name FROM Profile WHERE Name = 'EU1 User'];
		User agentUser = new User(alias = 'agent', email='testAgent@test.com',
						emailencodingkey='UTF-8', firstname='Test', lastname='User', languagelocalekey='en_US',
						localesidkey='en_US', profileid = agentProfile.id,
						timezonesidkey='America/Los_Angeles', username='guest@testpkg.com');
		insert agentUser;
    	
    	System.runAs(systemAdmin){
			
	        Contact contact = new Contact(
	        	FirstName = 'First_Name',
	        	LastName = 'Last_Name'
	        );
	        insert contact;
	        
	    	Case c = new Case (
	    		ContactId = contact.Id,
	    		Contact = contact,
	    		OwnerId = agentUser.Id
	    	);
	    	insert c;
    	}
		System.runAs(agentUser){
		
			sf_StrikeIronConfigurationUtil.initSettings();
			Test.setMock(HttpCalloutMock.class, new sf_MockStrikeIronEmailValidationImpl());
	
	    	PageReference pageRef = Page.sf_ContactInfo;
	        Test.setCurrentPage(pageRef);
	        
	        Case c = [SELECT Id, ContactId FROM Case LIMIT 1];
	    	ApexPages.StandardController sc = new ApexPages.StandardController (c);
	    	sf_ContactInfoController contactInfoController = new sf_ContactInfoController (sc);
	    	
			Test.startTest();
	
				contactInfoController.validateEmailAddress();
				System.assertEquals(contactInfoController.contactInfo.Email_Validation_Status__c, '');
				
				// Set an invalid email address
				contactInfoController.contactInfo.Email = 'cms234234@salesforce.com';
				contactInfoController.validateEmailAddress();
				System.assertEquals(contactInfoController.contactInfo.Email_Validation_Status__c, 'Invalid');		
		
				//Set a valid email address
				/*contactInfoController.contactInfo.Email = 'csouthworth@salesforce.com';
				contactInfoController.validateEmailAddress();
				System.assertEquals(contactInfoController.contactInfo.Email_Validation_Status__c, 'Valid');*/
			
			Test.stopTest();
		}
	}
    
    public static testMethod void saveContactTest(){
    	Case testCase = new Case (
            Subject='Case1'
        );
        insert testCase;
        
		ApexPages.StandardController sc = new ApexPages.StandardController (testCase);
    	sf_ContactInfoController contactInfoController = new sf_ContactInfoController (sc);

    	Test.startTest();
            contactInfoController.contactInfo.FirstName = 'Test_FirstName';
            contactInfoController.contactInfo.LastName = 'Test_LastName';
            contactInfoController.saveContact();
            
            // Verify that a contact is created and associated to the case.
            testCase = [SELECT Id, ContactId FROM Case WHERE Id = :testCase.Id LIMIT 1];
            System.assertNotEquals(testCase.ContactId, null);        
       	Test.stopTest();
        
    }
    
    public static testMethod void tagCasesTest(){
		Set<Id> caseIds = new Set<Id>();
        List<Case> casesToInsert = new List<Case>();
        
        Contact testCon = new Contact(
            firstName = 'Fred',
            lastName = 'Bassett'
        );
        insert testCon;

        Case testCase1 = new Case(
            Subject='Test Case 1',
            ContactId = testCon.Id
        );
        casesToInsert.add(testCase1);

        Case testCase2 = new Case(
			Subject='Test Case 2',
			ContactId = testCon.Id
        );
        casesToInsert.add(testCase2);
		
        insert casesToInsert;
 		caseIds.add(testCase1.Id);
        caseIds.add(testCase2.Id);
        update testCase1; //To set Child_Last_Modified_Date__c differently to testCase2

		ApexPages.StandardController sc = new ApexPages.StandardController (testCase2);
    	sf_ContactInfoController contactInfoController = new sf_ContactInfoController (sc);  
        
        Test.startTest();
			// Since contact exists, verify that it is updated
            contactInfoController.contactInfo.FirstName = 'Test_FirstName_2';
            contactInfoController.contactInfo.Email = 'jumbo@salesforce.com';
            contactInfoController.saveContact();
        
            // check that both c and c1 cases where both 'touched'
            list<Case> checkCases = [SELECT Id, Child_Last_Modified_Date__c FROM Case WHERE Id in :caseIds];
            system.assertEquals(checkCases[0].Child_Last_Modified_Date__c, checkCases[1].Child_Last_Modified_Date__c);       	
        Test.stopTest();      
    }  
    
    /*
    //To split into two methods, hitting too many SOQL
	public static testMethod void saveContactTest () {
        List<Case> casesToInsert = new List<Case>();
        
    	Case Case1 = new Case (
            Subject='Case1'
        );
    	casesToInsert.add(Case1);
		Case Case2 = new Case (
            Subject='Case2'
        );
    	casesToInsert.add(Case2);
        insert casesToInsert;

    	ApexPages.StandardController sc = new ApexPages.StandardController (Case1);
    	sf_ContactInfoController contactInfoController = new sf_ContactInfoController (sc);

    	Test.startTest();
    	
            System.assertEquals(Case1.ContactId, null);
            contactInfoController.contactInfo.FirstName = 'Test_FirstName';
            contactInfoController.contactInfo.LastName = 'Test_LastName';
            contactInfoController.saveContact();
            
            // Verify that a contact is created and associated to the case.
            Case1 = [SELECT Id, ContactId FROM Case WHERE Id = :Case1.Id LIMIT 1];
            System.assertNotEquals(Case1.ContactId, null);
            
            // create another case for the same contact to test updating of multiple cases
            Case2.contactId = Case1.ContactId;
            update Case2;
            
            // Since contact exists, verify that it is updated
            contactInfoController.contactInfo.FirstName = 'Test_FirstName_2';
            contactInfoController.contactInfo.Email = 'jumbo@salesforce.com';
            contactInfoController.saveContact();

    	Test.stopTest();
		// check that both c and c1 cases where both 'touched'
    	set<id> caseIds = new set<id>();
    	caseIds.add(Case1.id);
    	caseIds.add(Case2.id);
    	
    	list<Case> checkCases = [select Id, Child_Last_Modified_Date__c from Case where Id in :caseIds];
    	system.assertEquals(checkCases[0].Child_Last_Modified_Date__c, checkCases[1].Child_Last_Modified_Date__c);
    }*/
    
    /*Moved to removeContact_test
    public static testMethod void deleteContactTest () {
        
    	Case c = new Case (
    	);
    	insert c;
    	
    	ApexPages.StandardController sc = new ApexPages.StandardController (c);
    	sf_ContactInfoController contactInfoController = new sf_ContactInfoController (sc);

    	Test.startTest();
    	
    	System.assertEquals(c.ContactId, null);
    	contactInfoController.contactInfo.FirstName = 'Test_FirstName';
    	contactInfoController.contactInfo.LastName = 'Test_LastName';
    	contactInfoController.saveContact();
    	
    	// Verify that a contact is created and associated to the case.
    	 c = [
    	 		SELECT
    	 				Id,
    	 				ContactId,
    	 				AccountId
    	 		FROM
    	 				Case
    	 		WHERE
    	 				Id = :c.Id
    	 		LIMIT
    	 				1
    	 ];
    	 System.assertNotEquals(c.ContactId, null);
    	
    	
    	contactInfoController.deleteContact();
    	

    	Test.stopTest();
    }*/
    
	public static testMethod void addressMethodsTest() {
        Contact contact = new Contact(
        	FirstName = 'First_Name',
        	LastName = 'Last_Name_Ellito',
        	Country__c = 'TestCountry'
        );
        insert contact;
        
    	Case c = new Case (
    		ContactId = contact.Id,
    		Contact = contact
    	);
    	insert c;
    	
    	ApexPages.StandardController sc = new ApexPages.StandardController (c);
    	sf_ContactInfoController cic = new sf_ContactInfoController (sc);

    	Test.startTest();
    	
    		//Test UI address methods
    		cic.setUnverifiedPrimaryAddress();
    		System.assertEquals(true, cic.addressFieldManuallyUpdatedMap.get('Primary_Address_Invalid'));
    		
    		cic.setUnverifiedOtherAddress();
    		System.assertEquals(true, cic.addressFieldManuallyUpdatedMap.get('Other_Address_Invalid'));
    	
    		cic.setPrimaryAsShippingAddress();
    		System.assertEquals(sf_Constants.CONTACT_SHIPPING_ADDRESS_PRIMARY_ADDRESS, cic.contactInfo.Shipping_Address__c);
    		System.assertEquals(false, cic.isOtherAddressShipping);
    	
    		cic.setOtherAsShippingAddress();
    		System.assertEquals(sf_Constants.CONTACT_SHIPPING_ADDRESS_OTHER_ADDRESS, cic.contactInfo.Shipping_Address__c);
    		System.assertEquals(false, cic.isPrimaryAddressShipping);
    		
    		cic.setPrimaryAddressCountryOnContact();
    		System.assertEquals('TestCountry', cic.contactInfo.Primary_Country__c);
    		
    		cic.setOtherAddressCountryOnContact();
    		System.assertEquals('TestCountry', cic.contactInfo.Other_Country__c);
    		
    		cic.contactInfo.Override_Primary_Address__c = true;
    		cic.contactInfo.Primary_Address_Override_Reason__c = 'test';
    		cic.overridePrimaryAddress();
    		System.assertEquals(false, cic.contactInfo.Primary_Address_Validated__c);
    		System.assertEquals(false, cic.addressFieldManuallyUpdatedMap.get('Primary_Address_Valid'));
    		System.assertEquals(false, cic.addressFieldManuallyUpdatedMap.get('Primary_Address_Invalid'));
    		System.assertEquals(null, cic.contactInfo.Primary_Address_Override_Reason__c);
    		
    		cic.contactInfo.Override_Other_Address__c = true;
    		cic.contactInfo.Other_Address_Override_Reason__c = 'test';
    		cic.overrideOtherAddress();
    		System.assertEquals(false, cic.contactInfo.Other_Address_Validated__c);
    		System.assertEquals(false, cic.addressFieldManuallyUpdatedMap.get('Other_Address_Valid'));
    		System.assertEquals(false, cic.addressFieldManuallyUpdatedMap.get('Other_Address_Invalid'));
    		System.assertEquals(null, cic.contactInfo.Other_Address_Override_Reason__c);
    		
    		//Validate Zip Code for USA
    		

    		cic.lookUpPrimaryPostalCode();
            cic.lookUpOtherPostalCode();

            cic.contactInfo.Primary_Country__c = sf_Constants.COUNTRY_UNITED_STATES_AMERICA;
            cic.contactInfo.Primary_Postal_Code__c = '60626';
            cic.contactInfo.Other_Country__c = sf_Constants.COUNTRY_UNITED_STATES_AMERICA;
            cic.contactInfo.Other_Postal_Code__c = '444444';
    		
            cic.lookUpPrimaryPostalCode();
            cic.lookUpOtherPostalCode();

            cic.addressBean = new sf_StrikeIronValidateGblAddressRespBean();
            cic.validatePrimaryAddress();
            cic.validateOtherAddress();

    	Test.stopTest();
	}
    
}