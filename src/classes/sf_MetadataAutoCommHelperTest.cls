/********************************************************
    Deprecated as part of ICCS R2 2017                  *
    With the introduction of Digital Product Returns MAC*
    is now too out of date to effectively roll back to  *
********************************************************/    
@isTest
public class sf_MetadataAutoCommHelperTest {

    /*
    @testSetup
    public static void dataSetup(){
		//Create custom setting
        CustomSettingDataFactory.countryRegionSetup();
        TriggerSwitch__c testSwitch = new TriggerSwitch__c(
            name = 'macTrigger',
            //If true uses MAC, if false uses ACR
            TriggerOn__c = true
        );
        insert testSwitch;
        
    }
    
    private static Metadata_Auto_Communication__c mqrMac;  //Medical Questionnaire
    private static APXTConga4__Conga_Template__c mqrTempl;
    private static Metadata_Auto_Communication__c prmMac;  //Product Return Reminder
    private static APXTConga4__Conga_Template__c prmTempl;
    private static Metadata_Auto_Communication__c fnMac;   //Fraud Notice
    private static APXTConga4__Conga_Template__c fnTempl;
    private static Metadata_Auto_Communication__c prbMac;  //Product Return Bundle
    private static APXTConga4__Conga_Template__c prbTempl;
    private static Local_Product__c localReturnProd;   // returnable product
    private static Local_Product__c localNoReturnProd; // non-returnable product
    private static Local_Comment_Code__c localCC;      // Product Quality/Damaged/Seal

    private static User getSysAdmin() {
    	Profile admin = [select id from profile where name='System Administrator'];
        User testUser = new User(alias = 'u1', email='u1@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = admin.Id,  country='United States', CommunityNickname = 'u1',
            timezonesidkey='America/Los_Angeles', username=getName('user') + '@example.com');
        insert testUser;
        return testUser;
    }

    private static void caseSetup() {
    	BrandTemplate bt = [select id from BrandTemplate limit 1];

    	EmailTemplate mqrEt = new EmailTemplate(
    	    brandTemplateId = bt.id,
    	    FolderId = UserInfo.getOrganizationId(), //public unfiled folder
    	    DeveloperName = 'MQR_Test_Email_Template',
    	    isActive = true,
    	    Name = 'MQR Test Email Template',
    	    Subject = 'MQR Test Email Subject',
    	    TemplateType = 'text',
    	    Body = 'MQR contactname:{contact.name}, casenumber:{case.number}'
    	);

        EmailTemplate prmEt = new EmailTemplate(
            brandTemplateId = bt.id,
            FolderId = UserInfo.getOrganizationId(), //public unfiled folder
            DeveloperName = 'PRM_Test_Email_Template',
            isActive = true,
            Name = 'PRM Test Email Template',
            Subject = 'PRM Test Email Subject',
            TemplateType = 'text',
            Body = 'PRM contactname:{contact.name}, casenumber:{case.number}'
        );

        EmailTemplate fnEt = new EmailTemplate(
            brandTemplateId = bt.id,
            FolderId = UserInfo.getOrganizationId(), //public unfiled folder
            DeveloperName = 'FN_Test_Email_Template',
            isActive = true,
            Name = 'FN Test Email Template',
            Subject = 'FN Test Email Subject',
            TemplateType = 'text',
            Body = 'FN contactname:{contact.name}, casenumber:{case.number}'
        );

        //setup object - avoid MIXED DML ERROR by running in another user context
        system.runAs(getSysAdmin()) {
    	   insert new list<EmailTemplate>{mqrEt, prmEt, fnEt};
        }

        list<Letter_Head__c> letterheads = new list<Letter_Head__c>{
        	new Letter_Head__c(country__c='United States of America', language__c='English-US', brand__c='Scope', header_id__c = 'scope.jpg'),
            new Letter_Head__c(country__c='Canada', language__c='English-US', brand__c='Scope', header_id__c = 'scope.jpg')
        };
        insert letterheads;

        mqrTempl = new APXTConga4__Conga_Template__c(
            brand__c = 'Scope',
            language__c = 'English-US',
            country__c = 'United States of America',
            RTL_Language__c = false,
            HTML_Content__c = '<p>MQR:{Account.Salutation}-{Account.LastName}-{Case.Country}</p>'
        );
        prmTempl = new APXTConga4__Conga_Template__c(
            brand__c = 'Scope',
            language__c = 'English-US',
            country__c = 'United States of America',
            RTL_Language__c = false,
            HTML_Content__c = '<p>PRM:{Account.Salutation}-{Account.LastName}-{Case.Country}</p>'
        );
        fnTempl = new APXTConga4__Conga_Template__c(
            brand__c = 'Scope',
            language__c = 'English-US',
            country__c = 'United States of America',
            RTL_Language__c = false,
            HTML_Content__c = '<p>FN:{Account.Salutation}-{Account.LastName}-{Case.Country}</p>'
        );
        insert new list<APXTConga4__Conga_Template__c>{mqrTempl, prmTempl, fnTempl};

    	Fulfillment_Item__c mqrFi = new Fulfillment_Item__c(
    	    name = 'Medical QR Reminder',
    	    Type__c = 'FL',
    	    Description__c = 'Medical Questionnaire Reminder Letter',
    	    Active__c = true,
    	    Contact_Country__c = 'United States of America',
    	    Contact_Language__c = 'English-US',
    	    Conga_Template__c = mqrTempl.id,
    	    SKU__c = 'testSKU'
    	);
        Fulfillment_Item__c prmFi = new Fulfillment_Item__c(
            name = 'Product Return Reminder',
            Type__c = 'FL',
            Description__c = 'Product Return Reminder Letter',
            Active__c = true,
            Contact_Country__c = 'United States of America',
            Contact_Language__c = 'English-US',
            Conga_Template__c = prmTempl.id,
    	    SKU__c = 'testSKU'
        );
        Fulfillment_Item__c fnFi = new Fulfillment_Item__c(
            name = 'Fraud Notice',
            Type__c = 'FL',
            Description__c = 'Fraud Notice Letter for Pending Violation Case with Known Repeater Contact',
            Active__c = true,
            Contact_Country__c = 'United States of America',
            Contact_Language__c = 'English-US',
            Conga_Template__c = fnTempl.id,
    	    SKU__c = 'testSKU'
        );
    	insert new list<Fulfillment_Item__c>{mqrFi, prmFi, fnFi};
    	
    	mqrMac = new Metadata_Auto_Communication__c(
    	    Type__c = sf_MetadataAutoCommHelper.MAC_TYPE_MEDICAL_QR,
    	    Fulfillment_Item__c = mqrFi.id,
    	    Attempt__c = '2; 3',
    	    Email_Template_Name__c = mqrEt.developerName
    	);
        prmMac = new Metadata_Auto_Communication__c(
            Type__c = sf_MetadataAutoCommHelper.MAC_TYPE_RETURN_REMINDER,
            Fulfillment_Item__c = prmFi.id,
            Attempt__c = '2; 3',
            Email_Template_Name__c = prmEt.developerName
        );
        fnMac = new Metadata_Auto_Communication__c(
            Type__c = sf_MetadataAutoCommHelper.MAC_TYPE_FRAUD_NOTICE,
            Fulfillment_Item__c = fnFi.id,
            Email_Template_Name__c = mqrEt.developerName,
            Generate_PDF__c = true,
            Query_Type__c = 'Segment',
            Segment__c = 'Oral Rinse'


        );
    	insert new list<Metadata_Auto_Communication__c>{mqrMac, prmMac, fnMac};
    } 

    private static void caseCommentSetup() {
    	Global_Product__c globalReturnProd = new Global_Product__c(
    	    Consumer_Facing_Name__c = 'Scope Travel Size',
    	    GPID__c = '12345',
    	    Path__c = 'Scope/Oral Rinse/Base/Breath Freshening/Original Mint/1.5OZ'
    	); 
        Global_Product__c globalNoReturnProd = new Global_Product__c(
            Consumer_Facing_Name__c = 'Scope Family Size',
            GPID__c = '54321',
            Path__c = 'Scope/Oral Rinse/Base/Breath Freshening/Original Mint/1.5L',
            Postal_Restriction__c = true
        ); 
        insert new list<Global_Product__c>{globalReturnProd, globalNoReturnProd};
        
        localReturnProd = new Local_Product__c(
            Global_Product__c = globalReturnProd.id,
            Country__c = 'United States of America'
        );
        localNoReturnProd = new Local_Product__c(
            Global_Product__c = globalNoReturnProd.id,
            Country__c = 'United States of America'
        );
        insert new list<Local_Product__c>{localReturnProd, localNoReturnProd};
        
        Global_Comment_Code__c globalCC = new Global_Comment_Code__c(
            Level_1__c = 'Product Quality Complaint',
            Level_2__c = 'Product or Packaging Non Functioning or Damaged (Not Hazardous)',
            Level_3__c = 'Seal; damaged',
            GCR_CID__c = '555'
        );
        insert globalCC;
        
        localCC = new Local_Comment_Code__c(
            Global_Comment_Code__c = globalCC.id
        );
        insert localCC;
    	
        list<Letter_Head__c> letterheads = new list<Letter_Head__c>{
            new Letter_Head__c(country__c='United States of America', language__c='English-US', brand__c='Scope', header_id__c = 'scope.jpg'),
            new Letter_Head__c(country__c='Canada', language__c='English-US', brand__c='Scope', header_id__c = 'scope.jpg')
        };
        insert letterheads;

        prbTempl = new APXTConga4__Conga_Template__c(
            brand__c = 'Scope',
            language__c = 'English-US',
            country__c = 'United States of America',
            RTL_Language__c = false,
            HTML_Content__c = '<p>PRB:{Account.Salutation}-{Account.LastName}-{Case.Country}</p>'
        );
        insert new list<APXTConga4__Conga_Template__c>{prbTempl};

        Fulfillment_Item__c prbFi = new Fulfillment_Item__c(
            name = 'Product Return Bundle',
            Type__c = 'FL',
            Description__c = 'Product Return Bundle',
            Active__c = true,
            Contact_Country__c = 'United States of America',
            Contact_Language__c = 'English-US',
            Conga_Template__c = prbTempl.id,
    	    SKU__c = 'testSKU'
        );
        insert new list<Fulfillment_Item__c>{prbFi};
        
        prbMac = new Metadata_Auto_Communication__c(
            Type__c = sf_MetadataAutoCommHelper.MAC_TYPE_PRODUCT_RETURN,
            Fulfillment_Item__c = prbFi.id,
            Segment__c = 'Oral Rinse', 
            Comment_Code_List__c = '555,556,557,558' 
        );
        insert new list<Metadata_Auto_Communication__c>{prbMac};
    	
    }

    private static integer counter = 0;
    private static string getName(string prefix) {
    	return prefix + counter++;
    }

    private static set<id> getIds(list<sObject> lst) {
        map<id, sObject> temp = new map<id, sObject>(lst);
        return temp.keyset();
    }

    private static list<Account> getTestAccounts(integer num) {
    	list<Account> accounts = new list<Account>();
    	for(integer i=0;i<num;i++) {
    		accounts.add(new Account(name = getName('acct')));
    	}
    	insert accounts;
    	return accounts;
    }

    private static list<Contact> getTestContacts(list<Account> accounts) {
    	list<Contact> contacts = new list<Contact>();
    	for(Account a : accounts) {
    		contacts.add(new Contact(lastName=getName('cntc'), country__c = 'United States of America', Primary_Address_Line_1__c = '50 Fremont St', Primary_City__c = 'San Francisco', Primary_Postal_Code__c = '94105' , Primary_State_Province__c = 'CA'));
    	}
    	insert contacts;
    	return contacts;
    }
    
    private static Case getNewMQRCase(Contact ct, string mqrStatus) {
    	return new case(
    	   accountid = ct.accountid, 
    	   contactid = ct.id, 
    	   Medical_QR_Status__c = mqrStatus, 
    	   country__c='United States of America',
    	   language__c = 'English-US',
           currency__c = 'USD',
    	   brand__c = 'Scope',
    	   subject = getName('subject') //make sortable
    	);
    }

    private static Case getNewPRMCase(Contact ct, string returnStatus) {
        return new case(
           accountid = ct.accountid, 
           contactid = ct.id, 
           Product_Return_Status__c = returnStatus, 
           country__c='United States of America',
           language__c = 'English-US',
           brand__c = 'Scope',
           subject = getName('subject') //make sortable
        );
    }

    private static Case getNewFraudCase(Contact ct, string repeaterStatus) {
        return new case(
           accountid = ct.accountid, 
           contactid = ct.id, 
           Repeater_Case__c = repeaterStatus, 
           country__c='United States of America',
           language__c = 'English-US',
           brand__c = 'Scope',
           subject = getName('subject') //make sortable
        );
    }


    // Tests of internal methods
    @isTest
    static private void testGetMedicalQRMACS() {
    	caseSetup();
    	list<Account> accounts = getTestAccounts(4);
    	list<Contact> contacts = getTestContacts(accounts);
        
    	Case mqr1 = getNewMQRCase(contacts[0], null);
        Case mqr2 = getNewMQRCase(contacts[1], null);
        Case mqr3 = getNewMQRCase(contacts[2], null);
        Case mqr4 = getNewMQRCase(contacts[3], null);
        list<Case> cases = new list<Case>{mqr1, mqr2, mqr3, mqr4};   
    	insert cases;
        
        mqr1.Medical_QR_Status__c = 'Questionnaire Received';
        mqr2.Medical_QR_Status__c = 'Questionnaire Requested - Attempt 1';
        mqr3.Medical_QR_Status__c = 'Questionnaire Requested - Attempt 2';
        mqr4.Medical_QR_Status__c = 'Questionnaire Requested - Attempt 3';
        sf_MetadataAutoCommHelper.firstRun = true;
        update cases;
        
    	map<id, Case> caseMap = new map<id, Case>(cases);
    	map<id, Contact> contactMap = new map<id, Contact>(contacts);

    	list<sf_MetadataAutoCommHelper.OutboundMAC> results = sf_MetadataAutoCommHelper.getMedicalQRMACS(caseMap.keyset(), caseMap, contactMap);
    	results.sort();

    	system.assertEquals(2, results.size(), 'Should return 2 OutboundMAC objects');
    	system.assertEquals(cases[2].id, results[0].caseId, 'Should return outboundMAC object for Attempt 2 case');
        system.assertEquals(cases[3].id, results[1].caseId, 'Should return outboundMAC object for Attempt 3 case');
        system.assertEquals(contacts[2].id, results[0].contactId);
        system.assertEquals(contacts[3].id, results[1].contactId);
    	system.assertNotEquals(null, results[0].emailTemplateName);
    	system.assertEquals(null, results[0].emailTemplateId);
        system.assertNotEquals(null, results[0].fulfillmentItemId);
        system.assertEquals(false, results[0].generatePDF);
    	
    }

    @isTest
    static private void testGetReturnReminderMACS() {
        caseSetup();
        list<Account> accounts = getTestAccounts(4);
        list<Contact> contacts = getTestContacts(accounts);
            
        Case case1 = getNewPRMCase(contacts[0], null);
        Case case2 = getNewPRMCase(contacts[1], null);
        Case case3 = getNewPRMCase(contacts[2], null);
        Case case4 = getNewPRMCase(contacts[3], null);
        list<Case> cases = new list<Case>{case1, case2, case3, case4};   
    	insert cases;
        
        case1.Product_Return_Status__c = null;
        case2.Product_Return_Status__c = 'Product Requested - Attempt 1';
        case3.Product_Return_Status__c = 'Product Requested - Attempt 2';
        case4.Product_Return_Status__c = 'Product Requested - Attempt 3';
        sf_MetadataAutoCommHelper.firstRun = true;
        update cases;
        
        map<id, Case> caseMap = new map<id, Case>(cases);
        map<id, Contact> contactMap = new map<id, Contact>(contacts);

        list<sf_MetadataAutoCommHelper.OutboundMAC> results = sf_MetadataAutoCommHelper.getReturnReminderMACS(caseMap.keyset(), caseMap, contactMap);
        results.sort();

        system.assertEquals(2, results.size(), 'Should return 2 OutboundMAC objects');
        system.assertEquals(cases[2].id, results[0].caseId, 'Should return outboundMAC object for Attempt 2 case');
        system.assertEquals(cases[3].id, results[1].caseId, 'Should return outboundMAC object for Attempt 3 case');
        system.assertEquals(contacts[2].id, results[0].contactId);
        system.assertEquals(contacts[3].id, results[1].contactId);
        system.assertNotEquals(null, results[0].emailTemplateName);
        system.assertEquals(null, results[0].emailTemplateId);
        system.assertNotEquals(null, results[0].fulfillmentItemId);
        
    }

    @isTest
    static private void testGetFraudNoticeMACS() {
        caseSetup();
        list<Account> accounts = getTestAccounts(4);
        list<Contact> contacts = getTestContacts(accounts);
        contacts[0].Repeater_Status__c = sf_MetadataAutoCommHelper.CONTACT_REPEATER_STATUS_KNOWN;  
        contacts[1].Repeater_Status__c = sf_MetadataAutoCommHelper.CONTACT_REPEATER_STATUS_KNOWN; 
        contacts[3].Repeater_Status__c = sf_MetadataAutoCommHelper.CONTACT_REPEATER_STATUS_KNOWN;
        update contacts;
        list<Case> cases = new list<Case>{
            getNewFraudCase(contacts[0], sf_MetadataAutoCommHelper.CONTACT_REPEATER_STATUS_SUSPECTED),     // Case:Pending, Contact:Known
            getNewFraudCase(contacts[1], sf_MetadataAutoCommHelper.CONTACT_REPEATER_STATUS_SUSPECTED),     // Case:Pending, Contact:Suspected
            getNewFraudCase(contacts[2], sf_MetadataAutoCommHelper.CONTACT_REPEATER_STATUS_SUSPECTED),     // Case:Pending, Contact:No repeater status
            getNewFraudCase(contacts[3], null)                                                      // Case:Not Pending, Contact: Known (shouldn't occur)
        };
        insert cases;
        
        sf_MetadataAutoCommHelper.firstRun = true;
        update cases;
        
        map<id, Case> caseMap = new map<id, Case>(cases);
        map<id, Contact> contactMap = new map<id, Contact>(contacts);

        list<sf_MetadataAutoCommHelper.OutboundMAC> results = sf_MetadataAutoCommHelper.getFraudNoticeMACS(caseMap.keyset(), caseMap, contactMap);
        results.sort();

        //system.assertEquals(0, results.size(), 'Should return 1 OutboundMAC objects');
        //system.assertEquals(cases[0].id, results[0].caseId, 'Should return outboundMAC object for Pending Validation case with Known Repeater contact');
        //system.assertEquals(contacts[0].id, results[0].contactId);
        //system.assertNotEquals(null, results[0].emailTemplateName);
        //system.assertEquals(null, results[0].emailTemplateId);
        //system.assertNotEquals(null, results[0].fulfillmentItemId);
        //system.assertEquals(true, results[0].generatePDF);
        
    }
   
    @isTest
    static private void testCreateFulfillmentOrdersMQR() {
        caseSetup();
        list<Account> accounts = getTestAccounts(4);
        list<Contact> contacts = getTestContacts(accounts);
        
        Case case1 = getNewMQRCase(contacts[0], null);
        Case case2 = getNewMQRCase(contacts[1], null);
        Case case3 = getNewMQRCase(contacts[2], null);
        Case case4 = getNewMQRCase(contacts[3], null);
        list<Case> cases = new list<Case>{case1, case2, case3, case4};   
    	insert cases;
        
        case1.Medical_QR_Status__c = 'Questionnaire Requested - Attempt 2';
        case2.Medical_QR_Status__c = 'Questionnaire Requested - Attempt 2';
        case3.Medical_QR_Status__c = 'Questionnaire Requested - Attempt 2';
        case4.Medical_QR_Status__c = 'Questionnaire Requested - Attempt 3';
        //sf_MetadataAutoCommHelper.firstRun = true; //WR377
        checkRecursive.ACRprocessedIds.clear(); //WR377
        update cases;
        
        map<id, Case> caseMap = new map<id, Case>(cases);
        map<id, Contact> contactMap = new map<id, Contact>(contacts);

        list<sf_MetadataAutoCommHelper.OutboundMAC> macs = sf_MetadataAutoCommHelper.getMedicalQRMACS(caseMap.keyset(), caseMap, contactMap);
        macs.sort();
        id fulfillmentItemId = macs[0].fulfillmentItemId;
        
        //test.startTest();
        //sf_MetadataAutoCommHelper.createFulfillmentOrders(macs, caseMap);
        //test.stopTest();

        list<Fulfillment_Order__c> results = [
            select case__c, Conga_Merge_Template_Id__c, rtl_language__c, letter_body__c, ff_header__c, contact__c, trans_country__c, case_comment_code__c, 
                   (select Case__c, fulfillment_item__c, quantity__c, Type__c, Fulfillment_SKU__c, Fulfillment_Item_Id__c,
                    Fulfillment_Item__r.Fulfillment_Item_Id__c from Fulfillment_Order_Line_Items__r)
              from Fulfillment_Order__c
             where case__c in :caseMap.keyset()
          order by case__c asc
        ];
    	
    	system.assertEquals(cases.size(), results.size());
    	for(integer i=0; i<cases.size(); i++) {
    		Fulfillment_Order__c fo = results[i];
    		system.assertEquals(cases[i].id, fo.case__c);
    		system.assertEquals(mqrTempl.id, fo.Conga_Merge_Template_Id__c);
    		system.assertEquals(false, fo.rtl_language__c);
            system.assertEquals('<p>MQR:-'+contacts[i].lastname+'-United States of America</p>', fo.letter_body__c);
            system.assertEquals('scope.jpg', fo.ff_header__c);
            system.assertEquals(contacts[i].id, fo.contact__c);
            system.assertEquals(contacts[i].country__c, fo.trans_country__c);
            system.assertEquals(null, fo.case_comment_code__c);  //null for MQR?
    		system.assertEquals(1, fo.Fulfillment_Order_Line_Items__r.size());
    		Fulfillment_Order_Line_Item__c li = fo.Fulfillment_Order_Line_Items__r[0];
            system.assertEquals(cases[i].id, li.case__c);
            system.assertEquals(fulfillmentItemId, li.Fulfillment_Item__c);
            system.assertEquals(1, li.Quantity__c);
            system.assertEquals(sf_MetadataAutoCommHelper.MAC_FULFILLMENT_ORDER_LINE_ITEM_TYPE, li.Type__c);
            system.assertEquals('testSKU', li.Fulfillment_SKU__c);
        	system.assertEquals(li.Fulfillment_Item__r.Fulfillment_Item_Id__c, li.Fulfillment_Item_Id__c);
    	}
    	
    }

    //trigger tests
    
    @isTest
    private static void testTriggerSendsEmail() {
        caseSetup();
        list<Account> accounts = getTestAccounts(1);
        Contact ct = new Contact(lastname = getName('Cntc'), email=getName('e')+'@example.com');
        insert ct;
        Case c = getNewMQRCase(ct, null);
        insert c;

        c.Medical_QR_Status__c='Questionnaire Requested - Attempt 2';
        test.startTest();
        //sf_MetadataAutoCommHelper.firstRun = true;//WR377
        checkRecursive.ACRprocessedIds.clear(); //WR377
        update c;
        test.stopTest();
    	
    	system.assertEquals(1, sf_MetadataAutoCommHelper.emailResults.size());
    	system.assert(sf_MetadataAutoCommHelper.emailResults[0].isSuccess());
    	
    	list<Fulfillment_Order__c> results = [select id from fulfillment_order__c where case__c = :c.id];
    	system.assertEquals(0, results.size());
    	
    }

    @isTest
    private static void testCaseTriggerCreatesFulfillmentOrder() {
        caseSetup();
        list<Account> accounts = getTestAccounts(3);
        list<Contact> contacts = new list<Contact> {
            new Contact(lastname = getName('Cntc'), AccountId = accounts[0].id, Country__c = 'United States of America'), //no email address
            new Contact(lastname = getName('Cntc'), AccountId = accounts[1].id, Country__c = 'United States of America'), //no email address
            new Contact(lastname = getName('Cntc'), AccountId = accounts[2].id, Country__c = 'United States of America')  //no email address
        };
        insert contacts;
        contacts[2].Repeater_Status__c = sf_MetadataAutoCommHelper.CONTACT_REPEATER_STATUS_KNOWN;
        update contacts;
        Case mqrCase = getNewMQRCase(contacts[0], null);
        Case prmCase = getNewPRMCase(contacts[1], null);
        Case fnCase = getNewFraudCase(contacts[2], null);
        list<Case> cases = new list<Case>{mqrCase, prmCase, fnCase}; 
        insert cases;

        mqrCase.Medical_QR_Status__c='Questionnaire Requested - Attempt 2';
        prmCase.Product_Return_Status__c='Product Requested - Attempt 2';
        fnCase.Repeater_Case__c = sf_MetadataAutoCommHelper.CONTACT_REPEATER_STATUS_KNOWN;
        test.startTest();
        //sf_MetadataAutoCommHelper.firstRun = true;//WR377
        checkRecursive.ACRprocessedIds.clear(); //WR377
        update cases;
        test.stopTest();
        
        //system.assertEquals(0, sf_MetadataAutoCommHelper.emailResults.size());
        
        //list<Fulfillment_Order__c> results = [
        //    select case__c, Conga_Merge_Template_Id__c, rtl_language__c, letter_body__c, ff_header__c, contact__c, trans_country__c, case_comment_code__c, 
        //           (select Case__c, fulfillment_item__c, quantity__c, Type__c, Fulfillment_SKU__c, Fulfillment_Item_Id__c,
        //            Fulfillment_Item__r.Fulfillment_Item_Id__c from Fulfillment_Order_Line_Items__r) 
        //      from fulfillment_order__c 
        //     where case__c in :getIds(cases)
        //  order by case__r.subject ASC];
        //system.assertEquals(2, results.size());
        //Fulfillment_Order__c fo = results[0]; //mqr first
        //Case c = cases[0];
        //Contact ct = contacts[0];
        //system.assertEquals(c.id, fo.case__c);
        //system.assertEquals(mqrTempl.id, fo.Conga_Merge_Template_Id__c);
        //system.assertEquals(false, fo.rtl_language__c);
        //system.assertEquals('<p>MQR:-'+ct.lastname+'-United States of America</p>', fo.letter_body__c);
        //system.assertEquals('scope.jpg', fo.ff_header__c);
        //system.assertEquals(ct.id, fo.contact__c);
        //system.assertEquals(ct.country__c, fo.trans_country__c);
        //system.assertEquals(null, fo.case_comment_code__c);  //null for MQR?
        //system.assertEquals(1, fo.Fulfillment_Order_Line_Items__r.size());
        //Fulfillment_Order_Line_Item__c li = fo.Fulfillment_Order_Line_Items__r[0];
        //system.assertEquals(c.id, li.case__c);
        //system.assertEquals(1, li.Quantity__c);
        //system.assertEquals(sf_MetadataAutoCommHelper.MAC_FULFILLMENT_ORDER_LINE_ITEM_TYPE, li.Type__c);
        //system.assertEquals('testSKU', li.Fulfillment_SKU__c);
        //system.assertEquals(li.Fulfillment_Item__r.Fulfillment_Item_Id__c, li.Fulfillment_Item_Id__c);

        //fo = results[1]; //prm
        //c = cases[1];
        //ct = contacts[1];
        //system.assertEquals(c.id, fo.case__c);
        //system.assertEquals(prmTempl.id, fo.Conga_Merge_Template_Id__c);
        //system.assertEquals(false, fo.rtl_language__c);
        //system.assertEquals('<p>PRM:-'+ct.lastname+'-United States of America</p>', fo.letter_body__c);
        //system.assertEquals('scope.jpg', fo.ff_header__c);
        //system.assertEquals(ct.id, fo.contact__c);
        //system.assertEquals(ct.country__c, fo.trans_country__c);
        //system.assertEquals(null, fo.case_comment_code__c);  //FIXME: null for PRM?
        //system.assertEquals(1, fo.Fulfillment_Order_Line_Items__r.size());
        //li = fo.Fulfillment_Order_Line_Items__r[0];
        //system.assertEquals(c.id, li.case__c);
        //system.assertEquals(1, li.Quantity__c);
        //system.assertEquals(sf_MetadataAutoCommHelper.MAC_FULFILLMENT_ORDER_LINE_ITEM_TYPE, li.Type__c);
        //system.assertEquals('testSKU', li.Fulfillment_SKU__c);
        //system.assertEquals(li.Fulfillment_Item__r.Fulfillment_Item_Id__c, li.Fulfillment_Item_Id__c);

        //fo = results[2]; //fn
        //c = cases[2];
        //ct = contacts[2];
        //system.assertEquals(c.id, fo.case__c);
        //system.assertEquals(fnTempl.id, fo.Conga_Merge_Template_Id__c);
        //system.assertEquals(false, fo.rtl_language__c);
        //system.assertEquals('<p>FN:-'+ct.lastname+'-United States of America</p>', fo.letter_body__c);
        //system.assertEquals('scope.jpg', fo.ff_header__c);
        //system.assertEquals(ct.id, fo.contact__c);
        //system.assertEquals(ct.country__c, fo.trans_country__c);
        //system.assertEquals(null, fo.case_comment_code__c);  //FIXME: null for PRM?
        //system.assertEquals(1, fo.Fulfillment_Order_Line_Items__r.size());
        //li = fo.Fulfillment_Order_Line_Items__r[0];
        //system.assertEquals(c.id, li.case__c);
        //system.assertEquals(1, li.Quantity__c);
        //system.assertEquals(sf_MetadataAutoCommHelper.MAC_FULFILLMENT_ORDER_LINE_ITEM_TYPE, li.Type__c);
        //system.assertEquals('testSKU', li.Fulfillment_SKU__c);
        //system.assertEquals(li.Fulfillment_Item__r.Fulfillment_Item_Id__c, li.Fulfillment_Item_Id__c);

        
    }
    //Out of date for MAC even
    @isTest
    private static void testCaseCommentTriggerCreatesFulfillmentOrder() {
        caseCommentSetup();
        list<Account> accounts = getTestAccounts(2);
        list<Contact> contacts = getTestContacts(accounts);
        list<Case> cases = new list<Case>{
            getNewPRMCase(contacts[0], ''),
            getNewPRMCase(contacts[1], '')
        };
        insert cases;
        list<Case_Product__c> caseProds = new list<Case_Product__c>{
            new Case_Product__c(Case__c = cases[0].id, Local_Product__c = localReturnProd.id, Product_available_for_return__c = 'Yes - Product is available'),
            new Case_Product__c(Case__c = cases[1].id, Local_Product__c = localNoReturnProd.id, Product_available_for_return__c = 'Yes - Product is available')
        }; 
        insert caseProds;
        
        list<Case_Comment_Code__c> CCCs = new list<Case_Comment_Code__c>{
            new Case_Comment_Code__c(Case__c= cases[0].id, Case_Product__c = caseProds[0].id, Local_Comment_Code__c = localCC.id),
            new Case_Comment_Code__c(Case__c= cases[1].id, Case_Product__c = caseProds[1].id, Local_Comment_Code__c = localCC.id)
        };

        test.startTest();
        insert CCCs;
        test.stopTest();

        list<Fulfillment_Order__c> results = [
            select case__c, Conga_Merge_Template_Id__c, rtl_language__c, letter_body__c, ff_header__c, contact__c, trans_country__c, case_comment_code__c, 
                   (select Case__c, fulfillment_item__c, quantity__c, Type__c from Fulfillment_Order_Line_Items__r) 
              from fulfillment_order__c 
             where case__c in :getIds(cases)
          order by case__r.subject ASC];
        system.assertEquals(1, results.size());
        Fulfillment_Order__c fo = results[0]; 
        Case c = cases[0];
        Contact ct = contacts[0];
        system.assertEquals(c.id, fo.case__c);
        system.assertEquals(prbTempl.id, fo.Conga_Merge_Template_Id__c);
        system.assertEquals(false, fo.rtl_language__c);
        system.assertEquals('<p>PRB:-'+ct.lastname+'-United States of America</p>', fo.letter_body__c);
        system.assertEquals('scope.jpg', fo.ff_header__c);
        system.assertEquals(ct.id, fo.contact__c);
        system.assertEquals(ct.country__c, fo.trans_country__c);
        system.assertEquals(CCCs[0].id, fo.case_comment_code__c);  //null for MQR?
        system.assertEquals(1, fo.Fulfillment_Order_Line_Items__r.size());
        Fulfillment_Order_Line_Item__c li = fo.Fulfillment_Order_Line_Items__r[0];
        system.assertEquals(c.id, li.case__c);
        system.assertEquals(1, li.Quantity__c);
        system.assertEquals(sf_MetadataAutoCommHelper.MAC_FULFILLMENT_ORDER_LINE_ITEM_TYPE, li.Type__c);        
    	
    }

    //Out of date for MAC even
    @isTest
    private static void testCaseCommentTriggerCreatesFulfillmentOrderNoDups() {
        caseCommentSetup();
        list<Account> accounts = getTestAccounts(2);
        list<Contact> contacts = getTestContacts(accounts);
        list<Case> cases = new list<Case>{
            getNewPRMCase(contacts[0], '') // if two instances of same FI on same case, only create one FO
        };
        insert cases;
        list<Case_Product__c> caseProds = new list<Case_Product__c>{
            new Case_Product__c(Case__c = cases[0].id, Local_Product__c = localReturnProd.id, Product_available_for_return__c = 'Yes - Product is available'),
            new Case_Product__c(Case__c = cases[0].id, Local_Product__c = localReturnProd.id, Product_available_for_return__c = 'Yes - Product is available')
        }; 
        insert caseProds;
        
        list<Case_Comment_Code__c> CCCs = new list<Case_Comment_Code__c>{
            new Case_Comment_Code__c(Case__c= cases[0].id, Case_Product__c = caseProds[0].id, Local_Comment_Code__c = localCC.id),
            new Case_Comment_Code__c(Case__c= cases[0].id, Case_Product__c = caseProds[1].id, Local_Comment_Code__c = localCC.id)
        };

        test.startTest();
        insert CCCs;
        test.stopTest();

        list<Fulfillment_Order__c> results = [
            select case__c, Conga_Merge_Template_Id__c, rtl_language__c, letter_body__c, ff_header__c, contact__c, trans_country__c, case_comment_code__c, 
                   (select Case__c, fulfillment_item__c, quantity__c, Type__c from Fulfillment_Order_Line_Items__r) 
              from fulfillment_order__c 
             where case__c in :getIds(cases)
          order by case__r.subject ASC];
        system.assertEquals(1, results.size());
        Fulfillment_Order__c fo = results[0]; 
        Case c = cases[0];
        Contact ct = contacts[0];
        system.assertEquals(c.id, fo.case__c);
        system.assertEquals(prbTempl.id, fo.Conga_Merge_Template_Id__c);
        system.assertEquals(false, fo.rtl_language__c);
        system.assertEquals('<p>PRB:-'+ct.lastname+'-United States of America</p>', fo.letter_body__c);
        system.assertEquals('scope.jpg', fo.ff_header__c);
        system.assertEquals(ct.id, fo.contact__c);
        system.assertEquals(ct.country__c, fo.trans_country__c);
        system.assertEquals(1, fo.Fulfillment_Order_Line_Items__r.size());
        Fulfillment_Order_Line_Item__c li = fo.Fulfillment_Order_Line_Items__r[0];
        system.assertEquals(c.id, li.case__c);
        system.assertEquals(1, li.Quantity__c);
        system.assertEquals(sf_MetadataAutoCommHelper.MAC_FULFILLMENT_ORDER_LINE_ITEM_TYPE, li.Type__c);        
        
    }

@isTest
    private static void testTriggerFailedEmailCreatesFulfillmentOrder() {
        caseSetup();
        mqrMac.Email_Template_Name__c = 'FAIL'; //magic value to force a sendEmail failure
        update mqrMac;
        
        list<Account> accounts = getTestAccounts(1);
        Contact ct = new Contact(lastname = getName('Cntc'), email=getName('e')+'@example.com');
        insert ct;
        Case c = getNewMQRCase(ct, null);
        insert c;

        c.Medical_QR_Status__c='Questionnaire Requested - Attempt 2';
        test.startTest();
        update c;
        test.stopTest();
        
        system.assertEquals(0, sf_MetadataAutoCommHelper.emailResults.size());
        system.assert(!sf_MetadataAutoCommHelper.emailResults[0].isSuccess());
        
        list<Fulfillment_Order__c> results = [select id from fulfillment_order__c where case__c = :c.id];
        system.assertEquals(0, results.size());
        
    }

    @isTest
    private static void testTriggerBulk() {
        caseSetup();
        list<Account> emailAccounts = getTestAccounts(100);
        list<Contact> contacts = getTestContacts(emailAccounts);
        for (Contact ct : contacts) {
        	ct.email = getName('e')+'@example.com';
        }
        update contacts;
        list<Account> ffmtAccounts = getTestAccounts(100);
        contacts.addAll(getTestContacts(ffmtAccounts));
        
        list<Case> cases = new list<Case>();
        for(Contact ct : contacts) {
        	cases.add(getNewMQRCase(ct, null));
        }
        insert cases;

        for(Case c : cases) {
            c.Medical_QR_Status__c='Questionnaire Requested - Attempt 2';
        }
        
        test.startTest();
        //sf_MetadataAutoCommHelper.firstRun = true;//WR377
        checkRecursive.ACRprocessedIds.clear(); //WR377
        update cases;
        test.stopTest();
        
        system.assertEquals(100, sf_MetadataAutoCommHelper.emailResults.size());
        
        list<Fulfillment_Order__c> results = [select id from fulfillment_order__c where case__c in :getIds(cases)];
        system.assertEquals(100, results.size());
    	
    }

*/
}