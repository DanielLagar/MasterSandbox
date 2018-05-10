@isTest
public class gcr_chatRedirectController_Test {
    
    @testSetup
    static void setupTestData(){
        gcr_TestUtility.createCustomSettings();
        String brandConLangId = gcr_TestUtility.createContactUsObjectData();
        sObject careHub = gcr_TestUtility.getCareHubData(brandConLangId);
        Database.insert(careHub, true);
        List<sObject> lCareHubChannels = gcr_TestUtility.getCareHubChannels(careHub.Id);
        Database.insert(lCareHubChannels, true);
    }

    @isTest
    static void changeCountryTest(){
        test.startTest();
        	Country_Status__c result = gcr_chatRedirectController.changeCountry('United States of America');
        test.stopTest();
    }

    @isTest
    static void sendTrascriptNoChannel(){
        String emailAddress = '';
        String emailContent = '';
        String channelId = '';
        
        test.startTest();
            try{
                gcr_chatRedirectController.sendTrascript(emailAddress, emailContent, channelId,'');
            }
            catch(exception e){
                system.assertEquals('Channel content not found', e.getMessage());
            }
        test.stopTest();
        Exception__c ex = [SELECT Id, Further_Details__C FROM Exception__c WHERE CreatedDate = TODAY LIMIT 1];
        String errorMsg = ex.Further_Details__c;
        system.debug(logginglevel.WARN, 'The error: '+errorMsg);
        system.assert(errorMsg.startsWith('gcr_chatRedirectController.sendTrascript : Channel content not found.'));
    }
    
	@isTest
    static void sendTrascriptNoOrgWideEmail(){
        //Test utility does not create a org wide email by default
        String emailAddress = 'email@pg.com';
        String emailContent = 'Some random email content';
        String channelId = [SELECT Id FROM GCRChannelContent__c LIMIT 1].Id;
        test.startTest();
            try{
                gcr_chatRedirectController.sendTrascript(emailAddress, emailContent, channelId,'');
            }
            catch(exception e){
                system.assertEquals('Organization wide address not found', e.getMessage());
            }
        test.stopTest();
    }
    
	@isTest
    static void sendTrascript(){
        //Test utility does not create a org wide email by default
		GCRChannelContent__c channel = [SELECT Id, CareHub__c FROM GCRChannelContent__c LIMIT 1];
        String emailAddress = 'email@pg.com';
        String emailContent = 'Some random email content';
		GCRCareHub__c carehub = [SELECT Id FROM GCRCareHub__c WHERE Id = :channel.CareHub__c];
        carehub.OrgWideEmail__c = 'consumercare.im@pg.com';
        update carehub;
        
        test.startTest();
        	gcr_chatRedirectController.sendTrascript(emailAddress, emailContent, channel.Id,'');
        	//Sends an email, nothing to assert
        test.stopTest();                    
    }
    //CDOY WR545 Added Start
    @isTest
    static void CreateChatbotCase(){

        test.startTest();
            gcr_chatRedirectController.createCaseForChatbot('ChatBot','United States of America','English-US','Vicks');
            case c = [SELECT id, chatType__c FROM case WHERE chatType__c = 'Chatbot'];
            update c;
            
        test.stopTest();                 
    }
    @isTest
    static void CloseChatbotCase(){
        //Test utility does not create a org wide email by default

        case c = new case();
        c.Country__c = 'United States of America';
        c.language__c = 'English-US';
        insert c;

        string chatbotcaseId = c.id;
        string fullChatDiv = 'Hello Is it me ';
        string agentTranscript = 'you\'re looking for';

        test.startTest();
            gcr_chatRedirectController.closeChatbotCase(chatbotcaseId, fullChatDiv,false, agentTranscript,'');

        test.stopTest();                    
    }
    //CDOY WR545 Added End 
    
    @isTest
    static void testUpdateCaseOnOOHHandOff(){
        //Test utility does not create a org wide email by default
        String str = '';

        case c = new case();
        c.Country__c = 'United States of America';
        c.language__c = 'English-US';
        insert c;
  
        string fullChatDiv = 'Hello Is it me ';
        string agentTranscript = 'you\'re looking for';

        test.startTest();
           str =  gcr_chatRedirectController.updateCaseOnOOHHandOff(c.Id, agentTranscript,'');
           system.assert(string.isNotBlank(str));

        test.stopTest();                    
    }
    //CDOY WR545 Added End 
    
	@isTest
    static void submitPiiDatMissingData(){
        test.startTest();
        	try{
                gcr_chatRedirectController.submitPiiData(null, null, null, null, null, null,null);
            }
            catch(exception e){
                system.assertEquals('gcr_chatRedirectController.chatException', e.getTypeName());
            }
            try{
                gcr_chatRedirectController.submitPiiData(null, null, null, null, null, 'IAMNOTANID',null);
            }
            catch(exception e){
                system.assertEquals('gcr_chatRedirectController.chatException', e.getTypeName());
            }
        test.stopTest();
    }
    
	@isTest
    static void submitPiiDataNoConId(){
		String strFName = 'First';
		String strLName = 'testCon';
		String strEmail = 'testCon@testCon.net';
		String strPhone = '71 74 71 74'; 
		String strAddress = 'A new road, in a new town, in a new place';
		
		Case testCase = new Case();
		Insert testCase;
		
		test.StartTest();
			gcr_chatRedirectController.submitPiiData(strFName, strLName, strEmail, strPhone, strAddress, testCase.Id,'');
			testCase = [SELECT Id, ContactId, Contact.LastName, Contact.Phone FROM Case WHERE Id = :testCase.Id];
        	Contact testCon = [SELECT Id, FirstName, LastName, Email, Phone FROM Contact WHERE Id = :testCase.ContactId];
        	system.debug(logginglevel.WARN, 'The inserted Contact: '+testCon);
       		// PHONE FIELD IS NOT MAPPED WHEN THERE IS A CONTACT INSRETED AS NEW
			//system.assertEquals(strPhone, testCase.contact.phone);
		test.StopTest();
	}
    
	@isTest
    static void submitPiiDataExistingCon(){
		String strFName = 'First';
		String strLName = 'testCon';
		String strEmail = 'testCon@testCon.net';
		String strPhone = '71 74 71 74'; 
		String strAddress = 'A new road, in a new town, in a new place';
        Contact testContact = new Contact(FirstName = strFName, LastName = strLName, email = strEmail);
        insert testContact;
		
		Case testCase = new Case();
		Insert testCase;
		
		test.StartTest();
			gcr_chatRedirectController.submitPiiData(strFName, strLName, strEmail, strPhone, strAddress, testCase.Id,'');
			testCase = [SELECT Id, ContactId, Contact.LastName, Contact.Phone FROM Case WHERE Id = :testCase.Id];
        	Contact testCon = [SELECT Id, FirstName, LastName, Email, Phone FROM Contact WHERE Id = :testCase.ContactId];
        	//system.debug(logginglevel.WARN, 'The inserted Contact: '+testCon);
			//system.assertEquals(strPhone, testCon.phone);
        	system.assertEquals(strPhone, testCase.contact.phone);
		test.StopTest();
	}
	
	@isTest
    static void submitPiiDataWithConId(){
		String strFName = 'First';
		String strLName = 'testCon';
		String strEmail = 'testCon@testCon.net';
		String strPhone = '71 74 71 74'; 
		String strAddress = 'A new road, in a new town, in a new place';
		
		Contact caseContact = new Contact(lastName = 'testCon', email='testCon@testCon.net');
		insert caseContact;
		
		Case testCase = new Case(contactId = caseContact.Id);
		Insert testCase;
		
		test.StartTest();
			gcr_chatRedirectController.submitPiiData(strFName, strLName, strEmail, strPhone, strAddress, testCase.Id,'');
			caseContact = [SELECT Id, Phone FROM Contact WHERE Id = :caseContact.Id];
			system.assertEquals(strPhone, caseContact.phone);
		test.StopTest();
	}
    
    @isTest
    static void validateAddress(){
        /*Pass 6 params - address line 3 is set to '' by  gcr_helperClass.mapAddressDetails:
			retVal.Primary_Address_Line_1__c = lAddress.get(0);
            retVal.Primary_Address_Line_2__c = lAddress.get(1);
			// STRIKE IRON LIMITATION
			retVal.Primary_Address_Line_3__c = '';
            retVal.Primary_City__c = lAddress.get(2);
            retVal.Primary_State_Province__c = lAddress.get(3);
            retVal.Primary_Country__c = lAddress.get(4);
            retVal.Primary_Postal_Code__c = lAddress.get(5);
		*/
        
		String strAddress = '1 Procter & Gamble Plaza; ;Cincinnati; OH; United States of America; 45202;';
        test.startTest();
        	Test.setMock(HttpCalloutMock.class, new sf_MockStrikeIronGblAddressImpl());
        	String result = gcr_chatRedirectController.validateAddress(strAddress);
        	system.assertEquals('1 STREET BERLIN;1 STREET;BERLIN; United States of America; 45202', result);
        test.stopTest();
    }
    
    @isTest
    static void redirectToChatV3Test() {
		GCRChannelContent__c channelContent = [ SELECT Id, CareHub__r.Brand__c , CareHub__r.CountryIsoCode__c, CareHub__r.LanguageIsoCode__c
												FROM GCRChannelContent__c
												WHERE RecordType.Name = 'chat' ];
        ApexPages.currentPage().getParameters().put('brand', channelContent.CareHub__r.Brand__c);
        ApexPages.currentPage().getParameters().put('country', channelContent.CareHub__r.CountryIsoCode__c);
        ApexPages.currentPage().getParameters().put('language', channelContent.CareHub__r.LanguageIsoCode__c);
        ApexPages.currentPage().getParameters().put('fname', 'fname');
        ApexPages.currentPage().getParameters().put('lname', 'lname');
        ApexPages.currentPage().getParameters().put('email', 'fname.lname@gmail.com');
		
        test.startTest();
            gcr_chatRedirectController chatRedirect = new gcr_chatRedirectController();
            system.assert(chatRedirect.getChatData());        
        test.stopTest();

    }
    
	@isTest
    static void redirectToChatV4Test() {
		GCRChannelContent__c channelContent = [ SELECT Id, CareHub__r.Brand__c , CareHub__r.CountryIsoCode__c, CareHub__r.LanguageIsoCode__c
												FROM GCRChannelContent__c
												WHERE RecordType.Name = 'chat' ];
        ApexPages.currentPage().getParameters().put('brand', channelContent.CareHub__r.Brand__c);
        ApexPages.currentPage().getParameters().put('country', channelContent.CareHub__r.CountryIsoCode__c);
        ApexPages.currentPage().getParameters().put('language', channelContent.CareHub__r.LanguageIsoCode__c);
        ApexPages.currentPage().getParameters().put('fname', 'fname');
        ApexPages.currentPage().getParameters().put('lname', 'lname');
        ApexPages.currentPage().getParameters().put('email', 'fname.lname@gmail.com');
        
        //Update custom setting to mock V4 request
        //ChatPage__c settings = ChatPage__c.getInstance();//bug returns null org owner id
        ChatPage__c settings = ChatPage__c.getOrgDefaults();
		settings.CareHubChat__c = 'cheese';
        update settings;
        
        test.startTest();
            gcr_chatRedirectController chatRedirect = new gcr_chatRedirectController();
            system.assert(chatRedirect.getChatData());        
        test.stopTest();

    }
}