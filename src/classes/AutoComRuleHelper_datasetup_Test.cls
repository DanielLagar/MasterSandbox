@isTest
public class AutoComRuleHelper_datasetup_Test {
    private static final String COUNTRY = 'United States of America';
    private static final String LANGUAGE = 'English-US';
    private static final String ATTEMPT1 = 'Product Requested - Attempt 1';
    private static final String ATTEMPT2 = 'Product Requested - Attempt 2';
    private static final String ATTEMPT3 = 'Product Requested - Attempt 3';
    private static final String NOTRECEIVED = 'Not Received after 3 Attempts';
    public static String kavNumber = '';
    
	//@testSetup
    public static void dataSetup(){

        List<EmailTemplate> emTemplates = new List <EmailTemplate>();
        List<Letter_Head__c> letterHeads = new List<Letter_Head__c>();
		List<Global_Comment_Code__c> globalComs = new List<Global_Comment_Code__c>();
        List<Local_Comment_Code__c> localComs = new List<Local_Comment_Code__c>();
        List<Global_Product__c> globalProds = new List<Global_Product__c>();
        List<Local_Product__c> localProds = new List<Local_Product__c>();
        List<APXTConga4__Conga_Template__c> cts = new List<APXTConga4__Conga_Template__c>();
        List<Fulfillment_Item__c> ffItems = new List<Fulfillment_Item__c>();
        List<Auto_Communication_Rule__c> acrs = new List<Auto_Communication_Rule__c>();
        List<Account> accs = new List<Account>();
        List<Contact> cons = new List<Contact>();
        List<Case> cases = new List<Case>();
        
        CustomSettingDataFactory.countryRegionSetup();
        
        //To prevent mixed DML
        Profile admin = [select id from profile where name='System Administrator'];
        User testUser = new User(
            alias = 'u1',
            email ='u1@testorg.com',
            emailencodingkey = 'UTF-8',
            lastname ='Testing',
            languagelocalekey =' en_US',
            localesidkey = 'en_US',
            profileid = admin.Id, 
            country = 'United States',
            CommunityNickname = 'u1',
            timezonesidkey = 'America/Los_Angeles',
            username = math.random()+'@testorg.com',
            UserPermissionsKnowledgeUser = true//Needs to be able to insert/publish a KAV
        );
        insert testUser;
		
        system.runAs(testUser){
            
		/************************************
         * Create Contact_Us_Language__c	*
         ***********************************/
		Contact_Us_Language__c engLang = new Contact_Us_Language__c(
            Language__c = 'English-US',
            Country__c = 'United States of America',
            Language_Locale_Key__c = 'en_US',
			GCRCountryIsoCode__c = 'us'
        );
        insert engLang;
            
		/****************************
         * Create Return KAV		*
         ***************************/
		List<Return_Instructions__kav> kavsToInsert = new List<Return_Instructions__kav>();
		Return_Instructions__kav kav1 = new Return_Instructions__kav(
			Title = 'Return Instructions test Article 1',
            UrlName = 'Return-Instructions-test-Article-1',
            Summary = 'This is the summary for Return Instructions test Article 1',
			Digital_Return_Instructions__c = 'Some content here for the instuctions',
            No_of_Photos_Required__c = '3',
			IsVisibleInPkb = true,
            Language = 'en_US'
        );
		kavsToInsert.add(kav1);
		insert kavsToInsert;
            
		List<Return_Instructions__DataCategorySelection> dcsToInsert = new List<Return_Instructions__DataCategorySelection>();
        //DCs for first FAQ__kav
        Return_Instructions__DataCategorySelection dc1 = new Return_Instructions__DataCategorySelection(
            ParentId = kav1.Id,
            DataCategoryGroupName = 'Brand',
            DataCategoryName = 'All'
        );
        dcsToInsert.add(dc1);
        Return_Instructions__DataCategorySelection dc2 = new Return_Instructions__DataCategorySelection(
            ParentId = kav1.Id,
            DataCategoryGroupName = 'Region',
            DataCategoryName = 'North_America'
        );
		dcsToInsert.add(dc2);
		insert dcsToInsert;
        
		//Now publish and get
		List<Id> kavIds = new List<Id>{kav1.Id};
		for(KnowledgeArticleVersion kav : [SELECT Id, ArticleNumber,KnowledgeArticleId FROM KnowledgeArticleVersion WHERE Id IN :kavIds]){
            kavNumber = kav.ArticleNumber;
			KbManagement.PublishingService.publishArticle(kav.KnowledgeArticleId, true);
		}
            
		/****************************
         * Create email template	*
         ***************************/        
		BrandTemplate bt = [select id from BrandTemplate limit 1];

    	EmailTemplate utEmailTemplate1 = new EmailTemplate(
    	    brandTemplateId = bt.id,
    	    FolderId = UserInfo.getOrganizationId(), //public unfiled folder
    	    DeveloperName = 'ACR_UnitTest_EmailTemplate',
    	    isActive = true,
    	    Name = 'ACR UnitTest EmailTemplate',
    	    Subject = 'ACR UnitTest EmailTemplate',
    	    TemplateType = 'text',
    	    Body = 'Unit Test email template body'
    	);
        emTemplates.add(utEmailTemplate1);
        insert emTemplates;

		/****************************
         * Create letter head		*
         ***************************/ 
         Letter_Head__c lh1 = new Letter_Head__c(
			Brand__c = 'Ariel',
			Country__c = COUNTRY,
			Language__c = LANGUAGE,
            Header_ID__c = 'randomImage.jpg'
         );
         letterHeads.add(lh1);
            
         insert letterHeads;
        
        /****************************
         * Create custom setting	*
         ***************************/
        TriggerSwitch__c testSwitch = new TriggerSwitch__c(
            name = 'macTrigger',
            //If true uses MAC, if false uses ACR
            TriggerOn__c = false
        );
        insert testSwitch;

		/********************************
         * Create global comment codes	*
         *******************************/
        Global_Comment_Code__c gcc1 = new Global_Comment_Code__c(
            Criticality__c = 'Critical',
            Level_1__c = 'Product Quality Complaint',
            Level_2__c = 'Contamination',
            Level_3__c = 'Contamination'
        
        );
        globalComs.add(gcc1);
            
		Global_Comment_Code__c gcc2 = new Global_Comment_Code__c(
            Criticality__c = 'Critical',
            Level_1__c = 'Product Quality Complaint',
            Level_2__c = 'Foreign Material',
            Level_3__c = 'Alleged Foreign Material'
        
        );
        globalComs.add(gcc2);
            
		Global_Comment_Code__c gcc3 = new Global_Comment_Code__c(
            Criticality__c = 'Critical',
            Level_1__c = 'AE',
            Level_2__c = 'AE',
            Level_3__c = 'AE'
        
        );
        globalComs.add(gcc3);
        
		insert globalComs;
        
		/********************************
         * Create local comment codes	*
         *******************************/
        Local_Comment_Code__c lcc1 = new Local_Comment_Code__c(
            Global_Comment_Code__c = gcc1.Id,
            Criticality__c = 'Critical',
            Translated_Language__c = 'English-US',
			Level_1__c = 'Product Quality Complaint',
            Level_2__c = 'Contamination',
            Level_3__c = 'Contamination',
			Translated_Path__c = 'Product Quality Complaint/Contamination/Contamination'
        );
        localComs.add(lcc1);
            
 		Local_Comment_Code__c lcc2 = new Local_Comment_Code__c(
            Global_Comment_Code__c = gcc2.Id,
            Criticality__c = 'Critical',
            Translated_Language__c = 'English-US',
			Level_1__c = 'Product Quality Complaint',
            Level_2__c = 'Foreign Material',
            Level_3__c = 'Alleged Foreign Material',
			Translated_Path__c = 'Product Quality Complaint/Foreign Material/Alleged Foreign Material'
        );
        localComs.add(lcc2);
            
		Local_Comment_Code__c lcc3 = new Local_Comment_Code__c(
            Global_Comment_Code__c = gcc3.Id,
            Criticality__c = 'Critical',
            Translated_Language__c = 'English-US',
			Level_1__c = 'AE',
            Level_2__c = 'AE',
            Level_3__c = 'AE',
			Translated_Path__c = 'AE/AE/AE'
        );
        localComs.add(lcc3);
        
		insert localComs;
        
        /********************************
         * Create global product codes	*
         *******************************/
		Global_Product__c gp1 = new Global_Product__c(
            Path__c = 'Ariel/Laundry Detergent/Powder/High Suds/Regular/Regular/Compact/63OZ/Bag',
			Product_Level_Number__c = 12,
            GCR_Product_ID__c = '100952973',//May not be required
            GPID__c = '1107468877'//May not be required
        );
        globalProds.add(gp1);
        
        insert globalProds;
        
		/********************************
         * Create local product codes	*
         *******************************/
		Local_Product__c lp1 = new Local_Product__c(
            Name = 'Bag',
            Global_Product__c = gp1.Id,
            GCR_LPID__c = '472468', //May not be required
            Brand__c = 'Ariel',
            Translated_Path__c = 'Ariel/Laundry Detergent/Powder/-/-/Original/Compact/63oz/Bag',
            Country__c = COUNTRY,
            Consumer_Facing_Brand__c = 'Ariel'
		);
		localProds.add(lp1);

        insert localProds;
        
		/********************************
         * Create Conga Templates		*
         *******************************/
        APXTConga4__Conga_Template__c ct1 = new APXTConga4__Conga_Template__c(
            APXTConga4__Name__c = 'NA All Brands Critical Product available for return',
            APXTConga4__Description__c = 'NA All Brands Critical Product available for return',
            Template_Active__c = True,
            Country__c = COUNTRY,
            Language__c = '',
            Contact_Method__c = '',
            Contact_Center__c = '',
            HTML_Content__c = 'We need some content here otherwise the Letterhead is empty and we cannocover it',
            APXTConga4__Master_Field_to_Set_1__c = 'PDF_Page_Count__c=PDF_Page_Count'
        );
        cts.add(ct1);
        insert cts;

		/********************************
         * Create FF Items				*
         *******************************/
        //1st Attempt
        Fulfillment_Item__c ffItem1 = new Fulfillment_Item__c(
			Name = 'BD FHC Return - Jmbo Box',
            Type__c = 'BD',
			Active__c = True,
            Contact_Center__c = 'All',
			Contact_Language__c = LANGUAGE,
			Contact_Country__c = COUNTRY,
			Brand__c = 'ALL',
            Segment__c = 'Laundry Detergent',
			SKU__c = '1stAttempt',
            Conga_Template__c = ct1.Id
        );
        ffItems.add(ffItem1);
        
        //2nd and 3rd Attempt
        Fulfillment_Item__c ffItem2 = new Fulfillment_Item__c(
			Name = 'FL Letter Only 2nd 3rd Attempt',
            Type__c = 'FL',
			Active__c = True,
            Contact_Center__c = 'All',
			Contact_Language__c = 'English-US',
			Contact_Country__c = COUNTRY,
			Brand__c = 'ALL',
            Segment__c = 'ALL',
			SKU__c = '2ndAttempt',
            Conga_Template__c = ct1.Id
        );
        ffItems.add(ffItem2);        
        
        insert ffItems;
        
		/********************************
         * Create ACRs					*
         *******************************/
        Auto_Communication_Rule__c acr1 = new Auto_Communication_Rule__c(
            Type__c = 'Product Return',
			Global_Product_Path__c = 'Laundry Detergent',
			Supported_Return_Type__c = 'Physical',//CR16
            Global_Comment_Code__c = gcc1.Id,
            Product_Search_Key__c = '', //Should be set by WFR
			X1st_Attempt_Fulfillment_Item__c = ffItem1.Id,
			X2nd_Attempt_Fulfillment_Item__c = ffItem2.Id,
			X3rd_Attempt_Fulfillment_Item__c = ffItem2.Id,
			Generate_PDF_for_Attempt__c = '2;3',
			Template_Unique_Name__c =  'ACR_UnitTest_EmailTemplate'
        );
        acrs.add(acr1);
            
		Auto_Communication_Rule__c digiACR = new Auto_Communication_Rule__c (
            Type__c = 'Product Return',
			Global_Product_Path__c = 'Laundry Detergent', 
			Supported_Return_Type__c = 'Digital',//CR16
            Global_Comment_Code__c = gcc2.Id,
            Product_Search_Key__c = '', //Should be set by WFR
			X1st_Attempt_Fulfillment_Item__c = ffItem1.Id,
			X2nd_Attempt_Fulfillment_Item__c = ffItem2.Id,
			X3rd_Attempt_Fulfillment_Item__c = ffItem2.Id,
			Generate_PDF_for_Attempt__c = '2;3',
			Template_Unique_Name__c =  'ACR_UnitTest_EmailTemplate',
            Digital_Attempt_1st_Template__c = 'ACR_UnitTest_EmailTemplate',
            Digital_Attempt_2nd_Template__c = 'ACR_UnitTest_EmailTemplate',
            Digital_Attempt_3rd_Template__c = 'ACR_UnitTest_EmailTemplate',
            Digital_Thankyou_Email__c = 'ACR_UnitTest_EmailTemplate',
            Digital_Instructions__c = kavNumber
        );
        acrs.add(digiACR);
            
		Auto_Communication_Rule__c acr2 = new Auto_Communication_Rule__c(
            Type__c = 'Medical Questionnaire',
			X1st_Attempt_Fulfillment_Item__c = ffItem1.Id,
			X2nd_Attempt_Fulfillment_Item__c = ffItem2.Id,
			X3rd_Attempt_Fulfillment_Item__c = ffItem2.Id,
			Generate_PDF_for_Attempt__c = '2;3',
			Template_Unique_Name__c =  'ACR_UnitTest_EmailTemplate'
            
        );
        acrs.add(acr2);
            
		Auto_Communication_Rule__c acr3 = new Auto_Communication_Rule__c(
            Type__c = 'Fraud Notice',
			X1st_Attempt_Fulfillment_Item__c = ffItem1.Id,
			X2nd_Attempt_Fulfillment_Item__c = ffItem2.Id,
			X3rd_Attempt_Fulfillment_Item__c = ffItem2.Id,
			Generate_PDF_for_Attempt__c = '1;2;3',
			Template_Unique_Name__c =  ''
            
        );
        acrs.add(acr3);
        
        insert acrs;
            
		/********************************
         * Create Account/Contact/Case	*
         *******************************/        
        Account acc1 = new Account(
            Name = String.valueOf(date.today())
        );
        accs.add(acc1);
        
        insert accs;
        
        Contact con1 = new Contact(
            FirstName = String.valueOf(date.today()),
            LastName = 'TestContact',
            Email = 'testContact@UnitTest.com',
            AccountId = acc1.Id,
            Primary_Address_Line_1__c = '1 P&G Plaza',
			Primary_City__c = 'Cincinnati',
			Primary_State_Province__c = 'OH',
            Primary_Postal_Code__c = '45202',
			Primary_Country__c = COUNTRY,
			Other_Country__c = COUNTRY
        );
        cons.add(con1);
        
        insert cons;
            
        Case noACRCase = new Case(
            RecordTypeId = sf_GlobalUtilityClass.recordTypeMap.get('NA'),
            Country__c = COUNTRY,
            Language__c = LANGUAGE,
            subject = 'NoACR',
            Status = 'Open'    
        );
		cases.add(noACRCase);
            
		Case case1 = new Case(
            RecordTypeId = sf_GlobalUtilityClass.recordTypeMap.get('NA'),
            Country__c = COUNTRY,
            Language__c = LANGUAGE,
            ContactId = con1.id,
            subject = 'CaseOnly',
            Status = 'Open'
            
        );
        cases.add(case1);
            
		Case digiCase = new Case(
            RecordTypeId = sf_GlobalUtilityClass.recordTypeMap.get('NA'),
            Country__c = COUNTRY,
            Language__c = LANGUAGE,
            ContactId = con1.id,
            Origin = 'Social Media',
            subject = 'digital',
            Selected_Return_Type__c = system.label.digital,
            Status = 'Open'
        );
        cases.add(digiCase);

        insert cases;
            
		/********************************
         * Setup up digital Case with	*
         * CP, CC and matching ACR		*
         *******************************/ 
        String digiACRName = [SELECT Name FROM Auto_Communication_Rule__c WHERE Id = :digiACR.Id].Name;
        List<Case_Product__c> cpsToInsert = new List<Case_Product__c>();
            
		Case_Product__c noACR = new Case_Product__c(
            Case__c = noACRCase.Id,
            Local_Product__c = lp1.Id,
            Production_Code__c = 'randomvaluehere',
			ACR_Info__c = '',
            ACR_Return_Type__c = 'Digital',
            Product_available_for_return__c = 'Yes - Product is available'     
    	);
        cpsToInsert.add(noACR);
            
		Case_Product__c testCP = new Case_Product__c(
            Case__c = digiCase.Id,
            Local_Product__c = lp1.Id,
            Production_Code__c = 'randomvaluehere',
			ACR_Info__c = digiACRName,
            ACR_Return_Type__c = 'Digital',
            Product_available_for_return__c = 'Yes - Product is available'     
    	);
        
        cpsToInsert.add(testCP);
        insert cpsToInsert;
            
		//Have to do as an update as we need the id
        testCP.Digital_Return_Id__c = getProductReturnACR.setDigitalReturnId(testCP.Id);
        update testCP;
            
		Case_Comment_Code__c testCCC = new Case_Comment_Code__c(
            Case__c = digiCase.Id,
            Local_Comment_Code__c = lcc2.Id,
            Case_Product__c = testCP.Id
        );
            
		system.debug(logginglevel.WARN,'^^^ About to insert Case Comment');//CMD TO REMOVE
        insert testCCC;

		}//run as end
    }//Method end
}//Class end