/*
 * CR47 Multiple Contacts 
 * christopher.macduff@accenture.com
 */ 
@isTest
public class multipleContacts_test {
    @testSetup
    static void setupData(){
        CustomSettingDataFactory.countryRegionSetup(); //Country/Region custom setting records
        
        Map<String, Id> rtMap = sf_GlobalUtilityClass.recordTypeMap;
        Account exAccount = new Account(
            RecordTypeId = rtMap.get('Household'),
            Address_Line_1__c = '1 Procter & Gamble Plaza',
			Address_Line_2__c = '',
			City__c = 'Cincinnati',
			State_Province__c = 'OH',
			Postal_Code__c = '45202',
			Country__c = 'United States of America',
            name = 'Test existing Consumer Account'
        );
        insert exAccount;
        
        Contact exCon = new Contact(
            RecordTypeId = rtMap.get('Consumer'),
            AccountId = exAccount.Id,
            FirstName = 'Ringo',
            LastName = 'Starr',
            Email = math.random()+'@pgdev.org',
            Primary_Address_Line_1__c = 'Procter & Gamble Plaza',
            Primary_Address_Line_2__c = '',
			Primary_City__c = 'Cincinnati',
			Primary_State_Province__c = 'OH',
			Primary_Postal_Code__c = '45202',            
			Primary_Country__c = 'United States of America'
        );
        insert exCon;
        
        List<Case> testCases = new List<Case>();
        
        Case testCase1 = new Case(
            RecordTypeId = rtMap.get('NA'),
            contactId = exCon.Id,
            accountId = exAccount.Id,
            Subject = 'Multiple Contact Test Case',
            Summary__c = 'Summary for the Multiple Contact Test Case',
            Priority = '3',
            Origin = 'Email'
        );
        testCases.add(testCase1);
        
		Case testCase2 = new Case(
            RecordTypeId = rtMap.get('NA'),
            Subject = 'Empty Case',
            Summary__c = 'Blank Cases with no Contact/Account',
            Priority = '3',
            Origin = 'Email'
        );
        testCases.add(testCase2);
        insert testCases;
    }

    /****************************************************************
     * Covers:                                                      *
     * Case.ContactId being manually updated with a Contact not     *
     * in the existing Case Contact list                            *
    ****************************************************************/ 
    @isTest
    static void updateCaseContactIdTest(){
        Case testCase = [SELECT Id, ContactId, Contact.Name FROM Case WHERE ContactId != null LIMIT 1];
        Id origConId = testCase.ContactId;
        Contact newPrimCon = new Contact(
            lastName = 'A wild new primary Contact appears'
        );
        insert newPrimCon;

        testCase.ContactId = newPrimCon.Id;
        test.startTest();
            try{
                update testCase;
            }
            catch(exception e){
                //what to assert here...
            }
        test.stopTest();

        testCase = [SELECT Id, ContactId, Contact.Name FROM Case WHERE Id = :testCase.Id];
        //Assert Case.ContactId has NOT changed
        system.assertEquals(origConId, testCase.ContactId);
    }

	/****************************************************************
     * Covers:														*
     * Multiple Primary test										*
	****************************************************************/ 
    @isTest
    static void multiplePrimaryTest(){
        Contact secCon = new Contact(
            lastName = 'A wild new primary Contact appears'
        );
        insert secCon;

        Case testCase = [SELECT Id, ContactId FROM Case WHERE Subject = 'Multiple Contact Test Case'];
        Contact primCon = [SELECT Id FROM Contact WHERE Id = :testCase.ContactId];
        
        List<Case_Contact__c> ccList = [SELECT Id, Contact__c, Case__c, Case_Primary_Contact__c FROM Case_Contact__c WHERE Case__c = :testCase.Id];
        system.assertEquals(1, ccList.size());

        Case_Contact__c newPrimCC = new Case_Contact__c(
            Contact__c = secCon.Id,
            Case__c = testCase.Id,
            Case_Primary_Contact__c = True
        );

        test.startTest();
            try{
                insert newPrimCC;
            }
            catch(Exception e){
                system.assert(e.getMessage().contains(system.label.More_than_one_primary_contact));
            }
        test.stopTest();

        system.assertEquals(1, [SELECT Count() FROM Case_Contact__c WHERE Case__c = :testCase.Id AND Case_Primary_Contact__c = True]);
    }   
    
	/****************************************************************
     * Covers:														*
     * Creating CC from site/API									*
	****************************************************************/ 
    @isTest
    static void createSiteCCTest(){
		Case testCase = [SELECT Id, ContactId, Contact.Name FROM Case WHERE ContactId = null LIMIT 1];  
        Contact testCon = [SELECT Id, Name, AccountId, RecordTypeId FROM Contact WHERE LastName = 'Starr'];  
        
        test.startTest();
			caseContactHelper.createNewCC(testCase.Id, testCon.Id, True, True);
			Case_Contact__c primCC = [SELECT Id, Contact__c, Case__c, Case_Primary_Contact__c
                                  FROM Case_Contact__c WHERE Case__c = :testCase.Id AND Case_Primary_Contact__c = True LIMIT 1];
        
        	system.assertEquals(testCon.Id, primCC.Contact__c);
        test.stopTest();
    }
    
	/****************************************************************
     * Covers:														*
     * Changing ContactId directly On Case							*
	****************************************************************/ 
    @isTest
    static void changeCaseConTest(){
		Case testCase = [SELECT Id, ContactId, Contact.Name FROM Case WHERE ContactId != null LIMIT 1];  
        Contact testCon = [SELECT Id, Name, AccountId, RecordTypeId FROM Contact WHERE LastName = 'Starr'];
		Case_Contact__c exPrimCC = [SELECT Id, Contact__c, Case__c, Case_Primary_Contact__c
                                  FROM Case_Contact__c WHERE Case__c = :testCase.Id AND Case_Primary_Contact__c = True LIMIT 1];
        
        Contact newCon = new Contact(
			RecordTypeId = testCon.RecordTypeId,
            AccountId = testCon.AccountId,
            FirstName = 'George	',
            LastName = 'Harrison',
            Email = math.random()+'@pgdev.org'
        );
        insert newCon;
        
        Case_Contact__c newPrimCC = new Case_Contact__c(
            Contact__c = newCon.Id,
            Case__c = testCase.Id,
            //Case_Primary_Contact__c = True//Two primaries at same time!
            Case_Primary_Contact__c = False
        );
        insert newPrimCC;
        
        test.startTest();
            testCase.ContactId = newCon.Id;
            update testCase;
            
            List<Case_Contact__c> caseCCs = new List<Case_Contact__c>([SELECT Id, Contact__c, Case__C, Case_Primary_Contact__c FROM Case_Contact__c WHERE Case__C = :testCase.Id]);
            system.debug(logginglevel.WARN, '!!!!!!!! caseCCs: '+caseCCs);
            system.assertEquals(2, caseCCs.size());
            
            newPrimCC = [SELECT Id, Contact__c, Case__c, Case_Primary_Contact__c
                                      FROM Case_Contact__c WHERE Id = :newPrimCC.Id];
            system.assertEquals(True, newPrimCC.Case_Primary_Contact__c);
            
            exPrimCC = [SELECT Id, Contact__c, Case__c, Case_Primary_Contact__c
                                      FROM Case_Contact__c WHERE Id = :exPrimCC.Id];
            system.assertEquals(False, exPrimCC.Case_Primary_Contact__c);        
		test.stopTest();
    }
    
	/****************************************************************
     * Covers:														*
     * Adding an existing Contact to a Case							*
	****************************************************************/ 
	@isTest
    static void addExistingContact(){
		Case testCase = [SELECT Id, ContactId, Contact.Name FROM Case WHERE ContactId = null LIMIT 1];  
        Contact testCon = [SELECT Id, Name FROM Contact WHERE LastName = 'Starr'];
		PageReference pageRef = Page.sf_ContactInfo;
        Test.setCurrentPage(pageRef);
		ApexPages.StandardController sc = new ApexPages.StandardController (testCase);
        
        test.startTest();
			sf_ContactInfoController ctr = new sf_ContactInfoController (sc);
        	system.assertEquals(1, ctr.contactOptions.size());//Should always say "Add new Contact"
        	
        	ctr.contactInfo.lastName = 'Starr';
        	//ctr.checkExistingContact();//No point doing this doesn't return a result in apex test
        	system.debug(Logginglevel.WARN,'!!! existingContactList: '+ctr.existingContactList);
        	
        	ctr.selectedExistingContact = testCon.Id;
        	ctr.selectExistingContact();
        	testCase = [SELECT Id, ContactId, Contact.Name FROM Case WHERE Id = :testCase.Id];  
        	system.assertEquals(testCon.Id, testCase.ContactId);
        
        test.stopTest();
    }
    
	/****************************************************************
     * Covers:														*
     * Opening ctr with existing Primary Contact					*
     * Creating new Prim Contact (changing primary at same time)	*
     * Creating new non-Prim Contact								*
	****************************************************************/ 
	@isTest
    static void addNewPrimaryConTest(){
        Case testCase = [SELECT Id, ContactId, Contact.Name FROM Case WHERE ContactId != null LIMIT 1];
        system.assertEquals('Ringo Starr', testCase.Contact.Name);
		PageReference pageRef = Page.sf_ContactInfo;
        Test.setCurrentPage(pageRef);

		ApexPages.StandardController sc = new ApexPages.StandardController (testCase);
        
        test.startTest();
        	sf_ContactInfoController ctr = new sf_ContactInfoController (sc);
        	system.assertEquals(2, ctr.contactOptions.size());//Ringo plus "Add new Contact"
        	system.assertEquals('Starr',ctr.contactInfo.LastName);//Confirm page defaults to current Primary Contact
        
        	//Create and save a new prim Contact
        	ctr.selectedConId = 'newCon';//Select add a new Contact
        	ctr.setContactId();
        	ctr.contactInfo.firstName = 'Bob';
        	ctr.contactInfo.lastName = 'Marley';
        	ctr.contactInfo.email = 'bob.marley@pgdev.org';
        	ctr.isPrimary = True;
        	ctr.saveContact();
        
            testCase = [SELECT Id, ContactId, Contact.Name FROM Case WHERE Id = :testCase.Id];
            system.assertEquals('Bob Marley', testCase.Contact.Name);
        	system.assertEquals(3, ctr.contactOptions.size());//Ringo, Bob plus "Add new Contact"
        
        	//Create and a save a new non-prim Contact
        	ctr.selectedConId = 'newCon';//Select add a new Contact
        	ctr.setContactId();
        	ctr.setContactOptions();
        	system.assertEquals(null, ctr.contactInfo.Id); //Should be cleared
        
			ctr.contactInfo.firstName = 'Jimi';
        	ctr.contactInfo.lastName = 'Hendrix';
        	ctr.contactInfo.email = 'Jimi.Hendrix@pgdev.org';
        	ctr.isPrimary = false;
        	ctr.saveContact();
            system.debug(logginglevel.WARN, '********* ctr.contactOptions: '+ctr.contactOptions);
        	system.assertEquals(4, ctr.contactOptions.size());//Ringo, Bob, Jimi plus "Add new Contact"
        	
        test.stopTest();

        //Assert related Case_Contacts size is correct
        List<Case_Contact__c> caseCons = new List<Case_Contact__c>([SELECT Id, Case__c, Contact__c, Contact__r.Name, Case_Primary_Contact__c FROM Case_Contact__c WHERE Case__C = :testCase.Id]);
        system.assertEquals(3, caseCons.size());//Ringo, Bob, Jimi
        
        //Assert primary Case Contact is the same as the Case.ContactId
        testCase = [SELECT Id, ContactId FROM Case WHERE Id = :testCase.Id];
        Case_Contact__c primCaseCon = [SELECT Id, Case__c, Contact__c, Case_Primary_Contact__c FROM Case_Contact__c WHERE Case__C = :testCase.Id AND Case_Primary_Contact__c = True LIMIT 1];
        system.assertEquals(testCase.ContactId, primCaseCon.Contact__c);//Bob
    }

        
	/****************************************************************
     * Covers:														*
     * Unchecking isPrimary on ContactInfo page						*
	****************************************************************/ 
	@isTest
    static void uncheckIsPrimaryTest(){
        Case testCase = [SELECT Id FROM Case WHERE ContactId != null LIMIT 1];
		PageReference pageRef = Page.sf_ContactInfo;
        Test.setCurrentPage(pageRef);

		ApexPages.StandardController sc = new ApexPages.StandardController (testCase);
        sf_ContactInfoController ctr = new sf_ContactInfoController (sc);
        
        test.startTest();
        
			ctr.isPrimary = false;
        	ctr.saveContact();
        
			List<ApexPages.Message> msgs = new List<ApexPages.Message>(ApexPages.getMessages());
			system.assertEquals(1, msgs.size());//TODO: Assert correct message is received

        test.stopTest();   
    }

	/****************************************************************
     * Covers:														*
     * Removing primary on ContactInfo page							*
     ****************************************************************/     
	/*
    Moved to removeContact_Test
    @isTest
    static void removePrimaryTest(){
        Case testCase = [SELECT Id FROM Case WHERE ContactId != null LIMIT 1];
		PageReference pageRef = Page.sf_ContactInfo;
        Test.setCurrentPage(pageRef);

		ApexPages.StandardController sc = new ApexPages.StandardController (testCase);
        sf_ContactInfoController ctr = new sf_ContactInfoController (sc);
        
        test.startTest();
        
			ctr.removeContact();
			List<ApexPages.Message> msgs = new List<ApexPages.Message>(ApexPages.getMessages());
			system.assertEquals(1, msgs.size());//TODO: Assert correct message is received

        test.stopTest();   
    }*/

	/****************************************************************
     * Covers:														*
     * Removing non-primary on ContactInfo page						*
     ****************************************************************/    
    /*
    Moved to removeContact_Test  
	@isTest
    static void removeNonPrimaryTest(){
        Case testCase = [SELECT Id FROM Case WHERE ContactId != null LIMIT 1];
		PageReference pageRef = Page.sf_ContactInfo;
        Test.setCurrentPage(pageRef);

		ApexPages.StandardController sc = new ApexPages.StandardController (testCase);
        sf_ContactInfoController ctr = new sf_ContactInfoController (sc);
        
        test.startTest();
			//Create and a save a new non-prim Contact
        	ctr.selectedConId = 'newCon';//Select add a new Contact
        	ctr.setContactId();
        	system.assertEquals(null, ctr.contactInfo.Id); //Should be cleared
        
			ctr.contactInfo.firstName = 'Jimi';
        	ctr.contactInfo.lastName = 'Hendrix';
        	ctr.contactInfo.email = 'Jimi.Hendrix@pgdev.org';
        	ctr.isPrimary = false;
        	ctr.saveContact();
        	system.assertEquals(3, ctr.contactOptions.size());//Ringo, Jimi plus "Add new Contact"
        
			ctr.removeContact();
			
        	Case_Contact__c removedCaseCon = [SELECT Id, Contact_Status__c, Case_Primary_Contact__c FROM Case_Contact__c WHERE Case__C = :testCase.Id AND Case_Primary_Contact__c = False LIMIT 1];
        	system.assertEquals('Cancelled',removedCaseCon.Contact_Status__c);
        
        test.stopTest();
    }*/

}