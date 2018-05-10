/*
* @author: Chris MacDuff
* @date: 6th Dec 2016

* @description:
* Test methods for Fulfillment Order Extension
* Rewritten version, original commented out below.
*/
@isTest
public class sf_FulfillmentOrderCtrlTest {
    
    public Static Final String USA = 'United States of America';

    @testSetup
    static void setupData(){
        CustomSettingDataFactory.countryRegionSetup(); //Country/Region custom setting records
        List<Case> casesToInsert = new List<Case>();
        Map<String, Id> rtMap = sf_GlobalUtilityClass.recordTypeMap;
        Profile p = [SELECT Id FROM Profile WHERE Name='NA User'];
        
        User naUser = new User(
            Alias = 'Test',
            Email='test+' + System.Math.random() + '@PGUnitTest.com', 
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            Contact_Center__c='NA',
            TimeZoneSidKey='America/Los_Angeles',
            USD_Monetary_Threshold__c = 50,
            UserName='naUSer@PGUnitTest.com'
        );
        insert naUser;
        
        //Run as naUser so it ha access to records in tests
        system.runAs(naUser){
            Account exAccount = new Account(
                RecordTypeId = rtMap.get('Household'),
                Address_Line_1__c = '1 Procter & Gamble Plaza',
                Address_Line_2__c = '',
                City__c = 'Cincinnati',
                State_Province__c = 'OH',
                Postal_Code__c = '45202',
                Country__c = USA,
                name = 'Test existing Consumer Account'
            );
            insert exAccount;
            
            List<Contact> consToInsert = new List<Contact>();
            Contact primCon = new Contact(
                RecordTypeId = rtMap.get('Consumer'),
                AccountId = exAccount.Id,
                Salutation ='Mr.',
                FirstName = 'Ringo',
                LastName = 'Starr',
                Email = math.random()+'@pgdev.org',
                Primary_Address_Line_1__c = '1 Procter & Gamble Plaza',
                Primary_Address_Line_2__c = '',
                Primary_City__c = 'Cincinnati',
                Primary_State_Province__c = 'OH',
                Primary_Postal_Code__c = '45202',            
                Primary_Country__c = USA
            );
            consToInsert.add(primCon);
            
            Contact secCon = new Contact(
                RecordTypeId = rtMap.get('Consumer'),
                AccountId = exAccount.Id,
                Salutation ='Mr.',
                FirstName = 'George',
                LastName = 'Harrison',
                Email = math.random()+'@pgdev.org',
                Primary_Address_Line_1__c = '2 Procter & Gamble Plaza',
                Primary_Address_Line_2__c = '',
                Primary_City__c = 'Cincinnati',
                Primary_State_Province__c = 'OH',
                Primary_Postal_Code__c = '45202',            
                Primary_Country__c = USA
            );
            consToInsert.add(secCon);
            insert consToInsert;
            
            Case testCase1 = new Case(
                RecordTypeId = rtMap.get('NA'),
                Language__c = 'English-US',
                contactId = primCon.Id,
                accountId = exAccount.Id,
                Subject = 'FO Unit Test Case',
                Summary__c = 'FO Unit Test Case',
                Priority = '3',
                Origin = 'Email',
                Brand__c = 'Brand',
                Segment__c = 'Segment'
                
            );
            insert testCase1;
            //Primary Case Contact should be handled via Trigger
            
            Case_Contact__c secCC = new Case_Contact__c (
                Case__c = testCase1.Id,
                Contact__c = secCon.Id,
                Case_Primary_Contact__c = false,
                Contact_Status__c = 'Active'
            );
            insert secCC;
            
            Global_Product__c gp = new Global_Product__c(
                Path__c = 'TestBrand/TestSegment'
            );
            insert gp;
    
            Local_Product__c lp = new Local_Product__c(
                Name = 'Test Path',
                Country__c = USA,
                Translated_Path__c = 'Test Path/Test/Path',
                Global_Product__c = gp.Id
            );
            insert lp;
          
            Case_Product__c cp = new Case_Product__c(
                Case__c = testCase1.Id,
                Local_Product__c = lp.Id
            );
            insert cp;
    
            Global_Comment_Code__c gcc = new Global_Comment_Code__c (
                GCR_CID__c='1234'
            );
            insert gcc;
    
            Local_Comment_Code__c cc = new Local_Comment_Code__c(
                Level_1__c = 'TestLevel1',
                Level_2__c = 'TestLevel2',
                Level_3__c = 'Test Classify',
                Global_Comment_Code__c = gcc.Id,
                Translated_Language__c = USA,
                Inactive__c = false
            );
            insert cc;
          
            Product_Comment_Code__c pcc = new Product_Comment_Code__c(
                Global_Comment_Code__c = gcc.Id,
                Global_Product__c = gp.Id,
                Global_Product_Brand__c = 'TestBrand',
                Global_Product_Segment__c = 'TestSegment'
            );
            insert pcc;
            
            Case_Comment_Code__c ccc = new Case_Comment_Code__c(
                Case__c = testCase1.Id,
                Local_Comment_Code__c = cc.Id,
                Case_Product__c = cp.Id
            );
            insert ccc;
            
            APXTConga4__Conga_Template__c congaTemplate = new APXTConga4__Conga_Template__c(
                APXTConga4__Name__c='Test Name',
                country__c=USA,
                contact_center__c='NA',
                language__c='English-US',
                brand__C='TestBrand',
                segment__c='TestSegment',
                HTML_Content__c='Test HTML Content {Case.Brand}',
                RTL_Language__c=false,
                Default_Template_Active__c=true
            );
            insert congaTemplate;
            
            Letter_Head__c lhObj=new Letter_Head__c(
                country__c=USA,
                Language__c='English-US',
                Brand__c='TestBrand',
                Header_ID__c='TestId'
            );
            insert lhObj;
            
            Metadata_Item_Type_Selection__c mitObj=new Metadata_Item_Type_Selection__c(
                Contact_Center__c='NA',
                Item_Type__c='BD; CH; CO; CP; CR; DC; FL; PA; PI; PP; PR; RC; SA'
            );
            insert mitObj;
            
            List<Metadata_FF_Order_Line_Item_Record_Type__c> ffoliRTsToInsert = new List<Metadata_FF_Order_Line_Item_Record_Type__c>();
            Metadata_FF_Order_Line_Item_Record_Type__c BDflirtObj=new Metadata_FF_Order_Line_Item_Record_Type__c(
                Item_Type__c='BD',
                FF_Order_Line_Item_Record_Type_Id__c=rtMap.get('PGRecordType')
            );
            ffoliRTsToInsert.add(BDflirtObj);
            
            Metadata_FF_Order_Line_Item_Record_Type__c ETflirtObj=new Metadata_FF_Order_Line_Item_Record_Type__c(
                Item_Type__c='ET',
                FF_Order_Line_Item_Record_Type_Id__c=rtMap.get('PGRecordType')
            );
            ffoliRTsToInsert.add(ETflirtObj);
            insert ffoliRTsToInsert;
            
            List<Fulfillment_Item__c> fisToInsert = new List<Fulfillment_Item__c>();
            Fulfillment_Item__c bdFI =new Fulfillment_Item__c(
                Active__c=true,
                Promo_Flag__c=false,
                Contact_Country__c=USA,
                Contact_Language__c='English-US',
                Crisis__c = false,
                Promo_Limit__c=10,
                Brand__c='ALL',
                Promo_Segment__c='ALL',
                Segment__c='ALL',
                Contact_Center__c='NA',   
                Type__c='BD',
                Description__c='Test',
                Name='BD PGB SF to NYC WCIB No Prod',
                Auto_Fulfillment_GCR_CID__c='1234',
                Promo_Template_Id__c=[select Id from APXTConga4__Conga_Template__c limit 1].Id
            );
            fisToInsert.add(bdFI);
            
            Fulfillment_Item__c etFI =new Fulfillment_Item__c(
                Active__c=true,
                Promo_Flag__c=false,
                Contact_Country__c=USA,
                Contact_Language__c='English-US',
                Crisis__c = false,
                Promo_Limit__c=10,
                Brand__c='ALL',
                Promo_Segment__c='ALL',
                Segment__c='ALL',
                Contact_Center__c='NA',   
                Type__c='ET',
                Description__c='Test',
                Name='BD PGB SF to NYC WCIB No Prod',
                Auto_Fulfillment_GCR_CID__c='1234',
                Promo_Template_Id__c=[select Id from APXTConga4__Conga_Template__c limit 1].Id
            );
            fisToInsert.add(etFI);
            
            Fulfillment_Item__c promoFI =new Fulfillment_Item__c(
                Active__c=true,
                Promo_Flag__c=true,
                Contact_Country__c=USA,
                Contact_Language__c='English-US',
                Crisis__c = false,
                Promo_Limit__c=10,
                Brand__c='ALL',
                Promo_Segment__c='ALL',
                Segment__c='ALL',
                Contact_Center__c='NA',   
                Type__c='ET',
                Description__c='Test',
                Name='BD PGB SF to NYC WCIB No Prod',
                Auto_Fulfillment_GCR_CID__c='1234',
                Promo_Template_Id__c=[select Id from APXTConga4__Conga_Template__c limit 1].Id
            );
            fisToInsert.add(promoFI);
            
            Fulfillment_Item__c mpFI =new Fulfillment_Item__c(
                Active__c=true,
                Promo_Flag__c=false,
                Contact_Country__c=USA,
                Contact_Language__c='English-US',
                Crisis__c = false,
                Promo_Limit__c=10,
                Brand__c='ALL',
                Promo_Segment__c='ALL',
                Segment__c='ALL',
                Contact_Center__c='NA',   
                Type__c='MP',
                Description__c='Test',
                Name='BD PGB SF to NYC WCIB No Prod',
                Auto_Fulfillment_GCR_CID__c='1234',
                Promo_Template_Id__c=[select Id from APXTConga4__Conga_Template__c limit 1].Id
            );
            fisToInsert.add(mpFI);
            insert fisToInsert;
        }//RunAs end
    }//data setup end

    @isTest
    static void addFItests(){
        Case testCase = [SELECT Id, ContactId FROM Case LIMIT 1];
        User naUser = [SELECT Id FROM User WHERE Username = 'naUSer@PGUnitTest.com'];
        
        PageReference pageRef = Page.sf_SelectFulfillmentItems;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testCase.Id);
        ApexPages.currentPage().getParameters().put('comment', [SELECT Id FROM Case_Comment_Code__c limit 1].Id);
        ApexPages.currentPage().getParameters().put('fromPage', 'sf_SelectFulfillmentItems');

        system.runAs(naUser){
            test.startTest();

                ApexPages.StandardSetController sc = new ApexPages.StandardSetController([SELECT Name FROM Fulfillment_Order__c LIMIT 1]);
                sf_FulfillmentOrderCtrl ctr = new sf_FulfillmentOrderCtrl(sc);
            
                List<SelectOption> conOptions = ctr.contactOptions;
                system.assertEquals(2, conOptions.size());
            
                List<Case_Comment_Code__c> caseComments = new List<Case_Comment_Code__c>(ctr.getComments());
                system.assertEquals(1, caseComments.size());

                List<selectOption> itemTypes = new List<selectOption>(ctr.getItemTypes());
                system.assert(itemTypes.size() > 1);
            
                List<selectOption> itemTypesNew = new List<selectOption>(ctr.getItemTypesNew());
                system.assertEquals(14, itemTypesNew.size());
            
                ctr.save();

                //Select Primary, search, add FI
                ctr.selectedConId = testCase.ContactId;
            
                List<String> selectTypes = new List<String>{'CO'};
                ctr.setItemTypeList2(selectTypes);
            
                //Will return no results initially
                List<sf_FulfillmentOrderCtrl.ffFulfillmentItem> ffItemList = new List<sf_FulfillmentOrderCtrl.ffFulfillmentItem>(ctr.ffItemsList);
                ctr.searchFulfillmentItems();
                ffItemList = new List<sf_FulfillmentOrderCtrl.ffFulfillmentItem>(ctr.getfulfillmentItems());
                system.assertEquals(0, ffItemList.size());
                List<ApexPages.Message> msgs = new List<ApexPages.Message>(ApexPages.getMessages());
                system.assertEquals(1, msgs.size()); 
                system.assertEquals(System.Label.Fulfillment_NoResultsReturned, msgs[0].getDetail());
            
                //Will now return 1 FI
                selectTypes.add('BD');
                ctr.setItemTypeList2(selectTypes);
                ctr.searchFulfillmentItems();
                ffItemList = new List<sf_FulfillmentOrderCtrl.ffFulfillmentItem>(ctr.getfulfillmentItems());
                system.assertEquals(1, ffItemList.size());

                //Don't select FI but try to process:
                ctr.addNewLineItems(); //Add line items
                msgs = new List<ApexPages.Message>(ApexPages.getMessages());
                system.assertEquals(System.Label.Fulfillment_atLeastOne, msgs[1].getDetail());
            
                ctr.saveAndNew(); // Save and new
                msgs = new List<ApexPages.Message>(ApexPages.getMessages());
                system.assertEquals(System.Label.Fulfillment_atLeastOne, msgs[1].getDetail());
                //Note: Can't clear ApexPages and the same value can only appear once:
                //https://success.salesforce.com/ideaView?id=08730000000ZLADAA4
            
                //Now select FI and process
                for(sf_FulfillmentOrderCtrl.ffFulfillmentItem ffItem : ffItemList){
                   ffItem.quantity=2;
                }
                ctr.addNewLineItems(); //Add line items
                ctr.goToSaveAndNew();

                //Select non Primary, search, add FI
            test.stopTest();           
        }
    }
    
    @isTest
    static void etTestsPart1(){
        Case testCase = [SELECT Id, ContactId FROM Case LIMIT 1];
        User naUser = [SELECT Id FROM User WHERE Username = 'naUSer@PGUnitTest.com'];
        
        PageReference pageRef = Page.sf_SelectFulfillmentItems;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testCase.Id);
        ApexPages.currentPage().getParameters().put('comment', [SELECT Id FROM Case_Comment_Code__c limit 1].Id);
        ApexPages.currentPage().getParameters().put('fromPage', 'sf_SelectFulfillmentItems');

        system.runAs(naUser){
            Apexpages.currentPage().getParameters().put('invId', UserInfo.getUserId());
            test.startTest();
                ApexPages.StandardSetController sc = new ApexPages.StandardSetController([SELECT Name FROM Fulfillment_Order__c LIMIT 1]);
                sf_FulfillmentOrderCtrl ctr = new sf_FulfillmentOrderCtrl(sc);
            
                system.assertEquals(naUser.Id, ctr.invId);
            
                ctr.selectedConId = testCase.ContactId;

                List<String> selectTypes = new List<String>{'ET'};
                ctr.setItemTypeList2(selectTypes);
                ctr.searchFulfillmentItems();
                List<sf_FulfillmentOrderCtrl.ffFulfillmentItem> ffItemList = new List<sf_FulfillmentOrderCtrl.ffFulfillmentItem>(ctr.ffItemsList);
                system.assertEquals(1, ffItemList.size());
            
                //Now select FI and try to process with a quantity over 1
                for(sf_FulfillmentOrderCtrl.ffFulfillmentItem ffItem : ffItemList){
                   ffItem.quantity=2;
                }
            
                ctr.addNewLineItems(); //Add line items
                List<ApexPages.Message> msgs = new List<ApexPages.Message>(ApexPages.getMessages());
                system.assertEquals('If Fulfillment Type = \'ET\', \'PP\', or \'CH\' then Quantity must not be more than 1', msgs[0].getDetail());//Validation rule
            
                ctr.goToSaveAndNew();
            
                //Now select FI and try to process with a quantity of 1 but no amount
                for(sf_FulfillmentOrderCtrl.ffFulfillmentItem ffItem : ffItemList){
                    ffItem.quantity=1;
                    ffItem.amount=0;
                }
                ctr.addNewLineItems(); //Add line items
                msgs = new List<ApexPages.Message>(ApexPages.getMessages());
                system.debug(logginglevel.WARN, '!!!!!! In FO CTRL Test msgs: '+msgs);
                //WR343
                Set<String> msgSet = new Set<String>();
                for(ApexPages.Message msg : msgs){
                    msgSet.add(msg.getDetail());
                }
                system.assert(msgSet.contains(System.Label.Fulfillment_AmountMandatory));
            
                ctr.goToSaveAndNew();
            
                //Now complete correctly
                for(sf_FulfillmentOrderCtrl.ffFulfillmentItem ffItem : ffItemList){
                    ffItem.quantity=1;
                    ffItem.amount=10.00;
                }
                ctr.addNewLineItems();
                //This will throw more than one record error:
                ctr.goToSaveAndNew();
                msgs = new List<ApexPages.Message>(ApexPages.getMessages());
                //WR343
                msgSet.clear();
                for(ApexPages.Message msg : msgs){
                    msgSet.add(msg.getDetail());
                }
                system.assert(msgSet.contains(System.Label.Fulfillment_oneCHorET));

            test.stopTest();
        }
    }
    
    @isTest
    static void etTestsPart2(){
        Case testCase = [SELECT Id, ContactId FROM Case LIMIT 1];
        User naUser = [SELECT Id FROM User WHERE Username = 'naUser@PGUnitTest.com'];
        
        PageReference pageRef = Page.sf_SelectFulfillmentItems;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testCase.Id);
        ApexPages.currentPage().getParameters().put('comment', [SELECT Id FROM Case_Comment_Code__c limit 1].Id);
        ApexPages.currentPage().getParameters().put('fromPage', 'sf_SelectFulfillmentItems');

        system.runAs(naUser){
            Apexpages.currentPage().getParameters().put('invId', UserInfo.getUserId());
            test.startTest();
                ApexPages.StandardSetController sc = new ApexPages.StandardSetController([SELECT Name FROM Fulfillment_Order__c LIMIT 1]);
                sf_FulfillmentOrderCtrl ctr = new sf_FulfillmentOrderCtrl(sc);
            
                ctr.selectedConId = testCase.ContactId;
            
                List<String> selectTypes = new List<String>{'ET'};
                ctr.setItemTypeList2(selectTypes);
                ctr.searchFulfillmentItems();

                for(sf_FulfillmentOrderCtrl.ffFulfillmentItem ffItem : ctr.getfulfillmentItems()){
                    ffItem.quantity=1;
                    ffItem.amount=10.00;
                }
                ctr.goToSaveAndNew();
                List<Fulfillment_Order__c> caseFOs = new List<Fulfillment_Order__c>([SELECT Id FROM Fulfillment_Order__c WHERE Case__c = :testCase.Id]);
                system.assertEquals(1, caseFOs.Size());
            
                List<Fulfillment_Order_Line_Item__c> caseFOLIs = new List<Fulfillment_Order_Line_Item__c>([SELECT Id FROM Fulfillment_Order_Line_Item__c WHERE Case__c = :testCase.Id]);
                system.assertEquals(1, caseFOs.Size());
            
            test.stopTest();
        }
    }
    
    @isTest
    static void etTestsPart3(){
        Case testCase = [SELECT Id, ContactId FROM Case LIMIT 1];
        User naUser = [SELECT Id FROM User WHERE Username = 'naUSer@PGUnitTest.com'];
        
        PageReference pageRef = Page.sf_SelectFulfillmentItems;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testCase.Id);
        ApexPages.currentPage().getParameters().put('comment', [SELECT Id FROM Case_Comment_Code__c limit 1].Id);
        ApexPages.currentPage().getParameters().put('fromPage', 'sf_SelectFulfillmentItems');

        system.runAs(naUser){
            test.startTest();
                ApexPages.StandardSetController sc = new ApexPages.StandardSetController([SELECT Name FROM Fulfillment_Order__c LIMIT 1]);
                sf_FulfillmentOrderCtrl ctr = new sf_FulfillmentOrderCtrl(sc);
            
                ctr.selectedConId = testCase.ContactId;
            
                List<String> selectTypes = new List<String>{'ET'};
                ctr.setItemTypeList2(selectTypes);
                ctr.searchFulfillmentItems();

                for(sf_FulfillmentOrderCtrl.ffFulfillmentItem ffItem : ctr.getfulfillmentItems()){
                    ffItem.quantity=1;
                    ffItem.amount=10.00;
                }
                ctr.goToSaveAndNew();
            
                List<Fulfillment_Order__c> caseFOs = new List<Fulfillment_Order__c>([SELECT Id FROM Fulfillment_Order__c WHERE Case__c = :testCase.Id]);
                system.assertEquals(1, caseFOs.Size());
            
                List<Fulfillment_Order_Line_Item__c> caseFOLIs = new List<Fulfillment_Order_Line_Item__c>([SELECT Id FROM Fulfillment_Order_Line_Item__c WHERE Case__c = :testCase.Id]);
                system.assertEquals(1, caseFOs.Size());
            
            test.stopTest();
        }
    }
    
    @isTest
    static void mpTest(){
        Case testCase = [SELECT Id, ContactId FROM Case LIMIT 1];
        User naUser = [SELECT Id FROM User WHERE Username = 'naUser@PGUnitTest.com'];
        
        PageReference pageRef = Page.sf_SelectFulfillmentItems;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testCase.Id);
        ApexPages.currentPage().getParameters().put('comment', [SELECT Id FROM Case_Comment_Code__c limit 1].Id);
        ApexPages.currentPage().getParameters().put('fromPage', 'sf_SelectFulfillmentItems');

        system.runAs(naUser){
            Apexpages.currentPage().getParameters().put('invId', UserInfo.getUserId());
            test.startTest();
                ApexPages.StandardSetController sc = new ApexPages.StandardSetController([SELECT Name FROM Fulfillment_Order__c LIMIT 1]);
                sf_FulfillmentOrderCtrl ctr = new sf_FulfillmentOrderCtrl(sc);
            
                ctr.selectedConId = testCase.ContactId;
            
                List<String> selectTypes = new List<String>{'MP'};
                ctr.setItemTypeList2(selectTypes);
                ctr.searchFulfillmentItems();
                List<ApexPages.Message> msgs = new List<ApexPages.Message>(ApexPages.getMessages());
                String msg = msgs[0].getDetail();
                //system.assertEquals(System.Label.Fulfillment_mpEmailCheck, msg);
                system.assert(msg.contains(System.Label.Fulfillment_mpEmailCheck));

            test.stopTest();
        }
    }
    
    @isTest
    static void generalCoverage(){
        PageReference pageRef = Page.sf_SelectFulfillmentItems;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('fromPage', 'Additems');
        
        test.startTest();
            ApexPages.StandardSetController sc = new ApexPages.StandardSetController([SELECT Name FROM Fulfillment_Order__c LIMIT 1]);
            sf_FulfillmentOrderCtrl ctr = new sf_FulfillmentOrderCtrl(sc);
            //Get Error when there is no case comment
            List<Case_Comment_Code__c> caseComments = new List<Case_Comment_Code__c>(ctr.getComments());
            List<ApexPages.Message> msgs = new List<ApexPages.Message>(ApexPages.getMessages());
            system.assertEquals(1, msgs.size()); 
            
            //ctr.setSearchMsg('test');
            //ctr.getSearchMsg();
            ctr.setcNum('Test');
            ctr.getcNum();
            ctr.setfiType('Test');
            ctr.getfiType();
            ctr.setAmount(10);
            ctr.getAmount();
            ctr.setSelection('Test');
            ctr.getSelection();
            ctr.setAction('Test');
            ctr.getAction();
            //ctr.setSelectTopic('Test');
            //ctr.getSelectTopic();
            //ctr.setFfSearch('Test');
            //ctr.getFfSearch();
            ctr.setCountry('Test');
            ctr.getCountry();
            ctr.setBrand('Test');
            ctr.getBrand();
            ctr.setSegment('Test');
            ctr.getSegment();
            ctr.setDesc1('Test');
            ctr.getDesc1();
            ctr.setDescription('Test');
            ctr.getDescription();
            ctr.setAgentLanguage('Test');
            ctr.getAgentLanguage();
            ctr.setDisplay('Test');
            ctr.getDisplay();
            ctr.setLocalproductPath('Test');
            ctr.getLocalproductPath();
            ctr.setLocalcommentPath('Test');
            ctr.getLocalcommentPath();
            ctr.setItemType('Test');
            ctr.getItemType();
            ctr.setShowResults(True);
            ctr.getShowResults();
            ctr.setShowButton(True);
            ctr.getShowButton();
            ctr.getShowError();
            ctr.getShowError(True);
            ctr.getShowValidationError(true);
            ctr.getShowValidationError();
            ctr.setItemTypeList2(new List<String> { 'one', 'two' });
            ctr.getItemTypeList2();
            String utString = ctr.redirectUrl;
            ctr.redirectUrl = 'urlhere';
            ctr.redirect();
            ctr.changeProductComment();
            ctr.search();
            ctr.GetGlobalProductSegment();
            ctr.GetParentGlobalProduct();
            ctr.GetSegmentName();

        test.stopTest(); 
    }

/********************************************
 * Data Setup methods used elsewhere        *
*******************************************/
    public static Profile createProfile(){
        //Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; //Chris - Doesn't have access to custom record types...
        Profile p = [SELECT Id FROM Profile WHERE Name='NA User'];
        return p;
    }
    
    public static User createUserFFUserOne(Profile p){
        User userObj = new User(Alias = 'Test', Email='test+' + System.Math.random() + '@salesforce.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, Contact_Center__c='NA',
            TimeZoneSidKey='America/Los_Angeles', UserName='Under@threshold.com',
            USD_Monetary_Threshold__c = 100.00, BRL_Monetary_Threshold__c=999.00);
        insert userObj;        
        return userObj;
    }
    
    public static User createUserFFUserTwo(Profile p){
        User userObj = new User(Alias = 'Over', Email='test+' + System.Math.random() + '@salesforce.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, Contact_Center__c='NA',
            TimeZoneSidKey='America/Los_Angeles', UserName='test'+ System.Math.random() + '@salesforce.com',
            USD_Monetary_Threshold__c = 200.00, BRL_Monetary_Threshold__c=999.00);
        insert userObj;        
        return userObj;
    }
    
    public static Contact createContact(){
        Contact conObj = new Contact();
        conObj.FirstName='Test';
        conObj.LastName='Test';
        conObj.Country__c='United States of America';
        conObj.Salutation='Mr.';
        insert conObj;        
        return conObj;
    } 
    
    public static Case createCase(Contact conObj){
        Case c = new Case();
        c.Status = 'Open';
        c.country__c = 'United States of America';
        c.Language__c = 'English-US';
        c.Contact_Center__c = 'NA';
        c.ContactId = conObj.Id;
        c.Origin = 'Phone';
        c.Brand__c='TestBrand';
        c.Segment__c='TestSegment';
        insert c;        
        return c;
    }
    
    public static void createTestDataCommentsProducts(Case caseObj){
        Global_Product__c gp = new Global_Product__c();
        gp.Path__c = 'TestBrand/TestSegment';
        insert gp;

        Local_Product__c lp = new Local_Product__c ();
        lp.Name = 'Test Path';
        lp.Country__c = 'United States of America';
        lp.Translated_Path__c = 'Test Path/Test/Path';
        lp.Global_Product__c = gp.Id;
        insert lp;
      
        Case_Product__c cp = new Case_Product__c ();
        cp.Case__c = caseObj.Id;
        cp.Local_Product__c = lp.Id;
        insert cp;

        Global_Comment_Code__c gcc = new Global_Comment_Code__c ();
        gcc.GCR_CID__c='1234';
        insert gcc;

        Local_Comment_Code__c cc = new Local_Comment_Code__c ();
        cc.Level_1__c = 'TestLevel1';
        cc.Level_2__c = 'TestLevel2';
        cc.Level_3__c = 'Test Classify';
        cc.Global_Comment_Code__c = gcc.Id;
        cc.Translated_Language__c = 'United States of America';
        cc.Inactive__c = false;
        insert cc;
      
        Product_Comment_Code__c pcc = new Product_Comment_Code__c();
        pcc.Global_Comment_Code__c = gcc.Id;
        pcc.Global_Product__c = gp.Id;
        pcc.Global_Product_Brand__c = 'TestBrand';
        pcc.Global_Product_Segment__c = 'TestSegment';
        insert pcc;
        
        Case_Comment_Code__c ccc = new Case_Comment_Code__c();
        ccc.Case__c = caseObj.Id;
        ccc.Local_Comment_Code__c = cc.Id;
        ccc.Case_Product__c = cp.Id;
        insert ccc;
    }
    
    public static void createFulFillmentOrder(Case caseObj){
        Fulfillment_Order__c ffOrder = new Fulfillment_Order__c();
        ffOrder.case__c = caseObj.id;
         
        insert ffOrder;
        
        Fulfillment_Order_Line_Item__c ffOrderLineItem = new Fulfillment_Order_Line_Item__c();
        ffOrderLineItem.Fulfillment_Order__c = ffOrder.id;
        ffOrderLineItem.case__c = caseObj.id;
        ffOrderLineItem.Type__c = 'ET';
        ffOrderLineItem.Quantity__c = 1;
        ffOrderLineItem.Amount_Currency__c = 110.00;
        ffOrderLineItem.Keep_amount__c = TRUE;

        insert ffOrderLineItem;
    }
    


}//Class fin
/********************************************
 * Old version below, note the liberal use  *
 * of system asserts                        *
*******************************************/

/*
* @author: Laure OMeara
* @date: 06/26/2014

* @description: 
* US496:
* Test methods for Fulfillment Order Controller from the old org
* moved to test class
*/
/*
@isTest
public class sf_FulfillmentOrderCtrlTest {
    static testMethod void moreTestCodeCoverage(){
        Profile p = createProfile(); 
        User userObj = createUser(p);
        
        System.runAs(userObj){
            Contact conObj = createContact();
            Case caseObj = createCase(conObj);
            createCongaTemplate();
            createLetterHead();   
            createMetadataFulfillmentLineItemRecType();
            createAutoFulfillmentItems();
            
            test.startTest();
            
            PageReference pageRef = Page.sf_SelectFulfillmentItems;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', caseObj.Id);
            ApexPages.currentPage().getParameters().put('fromPage', 'sf_SelectFulfillmentItems');
            Apexpages.currentPage().getParameters().put('invId', UserInfo.getUserId());

            ApexPages.StandardSetController standController = new ApexPages.StandardSetController([SELECT Name FROM Fulfillment_Order__c limit 10]);
            sf_FulfillmentOrderCtrl controller = new sf_FulfillmentOrderCtrl(standController);
            Try{
                controller.getComments();
            }
            Catch(exception e){
                
            }
            Try{
                controller.getItemTypesNew();
            }
            Catch(exception e){
                
            }
            
            createMetadataItemTypeSelection();
            createTestDataCommentsProducts(caseObj);
            ApexPages.currentPage().getParameters().put('comment', [SELECT Id FROM Case_Comment_Code__c limit 1].Id);
            controller.getComments();
            controller.save();
            
            createFulfillmentItems();
            controller.GetSegmentName();
            controller.searchFulfillmentItems();
            controller.getfulfillmentItems();
            controller.processSelected();
            //Try intially with amount = 0
            for(sf_FulfillmentOrderCtrl.ffFulfillmentItem ffItem : controller.getfulfillmentItems()){
                   ffItem.quantity=2;
                   ffItem.bankName='UTBank';
                   ffItem.Description='UT Description';
                   ffItem.Amount = 0;
                   ffItem.f.Type__c = 'ET';
            }
            try{
                controller.processSelected();
            }
            catch(exception e){
                
            }

            try{
                controller.saveAndNew();
            }
            catch(exception e){
                
            }
            //Try again with different from page - Additems
            pageRef = Page.sf_SelectFulfillmentItems;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', caseObj.Id);
            ApexPages.currentPage().getParameters().put('fromPage', 'Additems');
            Apexpages.currentPage().getParameters().put('invId', UserInfo.getUserId());
            ApexPages.currentPage().getParameters().put('comment', [SELECT Id FROM Case_Comment_Code__c limit 1].Id);
            
            controller = new sf_FulfillmentOrderCtrl(standController);

            controller.searchFulfillmentItems();
            for(sf_FulfillmentOrderCtrl.ffFulfillmentItem ffItem : controller.getfulfillmentItems()){
                   ffItem.quantity=2;
            }
            controller.processSelected();

            test.stopTest();           
        }
        
    }
    static testMethod void testCodeCoverage()
    {
        Profile p = createProfile(); 
        User userObj = createUser(p);
        
        System.runAs(userObj) {
            Contact conObj = createContact();
            Case caseObj = createCase(conObj);
            createTestDataCommentsProducts(caseObj);
            createCongaTemplate();
            createLetterHead();
            createMetadataItemTypeSelection();    
            createMetadataFulfillmentLineItemRecType();
            createAutoFulfillmentItems();
            
            test.startTest();
            
            PageReference pageRef = Page.sf_SelectFulfillmentItems;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', caseObj.Id);
            ApexPages.currentPage().getParameters().put('comment', [SELECT Id FROM Case_Comment_Code__c limit 1].Id);
            ApexPages.currentPage().getParameters().put('fromPage', 'sf_SelectFulfillmentItems');
            Apexpages.currentPage().getParameters().put('invId', UserInfo.getUserId());
            
            ApexPages.StandardSetController standController = new ApexPages.StandardSetController([SELECT Name FROM Fulfillment_Order__c limit 10]);
            sf_FulfillmentOrderCtrl controller = new sf_FulfillmentOrderCtrl(standController);
            controller.getComments();
            controller.save();

            controller.getItemTypes();
            controller.getItemTypesNew();
            controller.searchFulfillmentItems();
            createFulfillmentItems();
            controller.searchFulfillmentItems();
            controller.getfulfillmentItems();
            controller.processSelected();
            for(sf_FulfillmentOrderCtrl.ffFulfillmentItem ffItem : controller.getfulfillmentItems()){
                   ffItem.quantity=2;
            }
            controller.processSelected();            
            controller.goToSaveAndNew();
            controller.saveAndNew();
            controller.GetGlobalProductSegment();
            controller.changeProductComment();
            controller.search();
            
            //code coverage for the variables in the code. Keep this code at the end.
            controller.setSearchMsg('test');
            controller.getSearchMsg();
            controller.setcNum('Test');
            controller.getcNum();
            controller.setfiType('Test');
            controller.getfiType();
            controller.setAmount(10);
            controller.getAmount();
            controller.setSelection('Test');
            controller.getSelection();
            controller.setAction('Test');
            controller.getAction();
            controller.setSelectTopic('Test');
            controller.getSelectTopic();
            controller.setFfSearch('Test');
            controller.getFfSearch();
            controller.setCountry('Test');
            controller.getCountry();
            controller.setBrand('Test');
            controller.getBrand();
            controller.setSegment('Test');
            controller.getSegment();
            controller.setDesc1('Test');
            controller.getDesc1();
            controller.setDescription('Test');
            controller.getDescription();
            controller.setAgentLanguage('Test');
            controller.getAgentLanguage();
            controller.setDisplay('Test');
            controller.getDisplay();
            controller.setLocalproductPath('Test');
            controller.getLocalproductPath();
            controller.setLocalcommentPath('Test');
            controller.getLocalcommentPath();
            controller.setItemType('Test');
            controller.getItemType();
            controller.setShowResults(True);
            controller.getShowResults();
            controller.setShowButton(True);
            controller.getShowButton();
            controller.getShowError();
            controller.getShowError(True);
            controller.getShowValidationError(true);
            controller.getShowValidationError();
            controller.setItemTypeList2(new List<String> { 'one', 'two' });
            controller.getItemTypeList2();
            String utString = controller.redirectUrl;
            
            test.stopTest();
        }
    }
    
    static testMethod void testCodeCoverage2()
    {
        Profile p = createProfile(); 
        User userObj = createUser(p);
        
        System.runAs(userObj) {
            Contact conObj = createContact();
            Case caseObj = createCase(conObj);
            createTestDataCommentsProducts(caseObj);
            createCongaTemplate();
            createLetterHead();
            createMetadataItemTypeSelection();    
            createMetadataFulfillmentLineItemRecType();
            createAutoFulfillmentItems();
            
            PageReference pageRef = Page.sf_SelectFulfillmentItems;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', caseObj.Id);
            ApexPages.currentPage().getParameters().put('comment', [SELECT Id FROM Case_Comment_Code__c limit 1].Id);
            ApexPages.currentPage().getParameters().put('fromPage', 'Additems');
            ApexPages.currentPage().getParameters().put('pro', 'true');
            
            ApexPages.StandardSetController standController = new ApexPages.StandardSetController([SELECT Name FROM Fulfillment_Order__c limit 10]);
            sf_FulfillmentOrderCtrl controller = new sf_FulfillmentOrderCtrl(standController);
        }
    }
    
    public static Profile createProfile(){
        //Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; //Chris - Doesn't have access to custom record types...
        Profile p = [SELECT Id FROM Profile WHERE Name='NA User'];
        return p;
    }
    
    public static User createUser(Profile p){
        User userObj = new User(Alias = 'Test', Email='test+' + System.Math.random() + '@salesforce.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, Contact_Center__c='NA',
            TimeZoneSidKey='America/Los_Angeles', UserName='test'+ System.Math.random() + '@salesforce.com');
        insert userObj;        
        return userObj;
    }
    
    public static Case createCase(Contact conObj){
        Case c = new Case();
        c.Status = 'Open';
        c.country__c = 'United States of America';
        c.Language__c = 'English-US';
        c.Contact_Center__c = 'NA';
        c.ContactId = conObj.Id;
        c.Origin = 'Phone';
        c.Brand__c='TestBrand';
        c.Segment__c='TestSegment';
        insert c;        
        return c;
    }
    
    public static Contact createContact(){
        Contact conObj = new Contact();
        conObj.FirstName='Test';
        conObj.LastName='Test';
        conObj.Country__c='United States of America';
        conObj.Salutation='Mr.';
        insert conObj;        
        return conObj;
    }
    
    public static void createTestDataCommentsProducts(Case caseObj){
        Global_Product__c gp = new Global_Product__c();
        gp.Path__c = 'TestBrand/TestSegment';
        insert gp;

        Local_Product__c lp = new Local_Product__c ();
        lp.Name = 'Test Path';
        lp.Country__c = 'United States of America';
        lp.Translated_Path__c = 'Test Path/Test/Path';
        lp.Global_Product__c = gp.Id;
        insert lp;
      
        Case_Product__c cp = new Case_Product__c ();
        cp.Case__c = caseObj.Id;
        cp.Local_Product__c = lp.Id;
        insert cp;

        Global_Comment_Code__c gcc = new Global_Comment_Code__c ();
        gcc.GCR_CID__c='1234';
        insert gcc;

        Local_Comment_Code__c cc = new Local_Comment_Code__c ();
        cc.Level_1__c = 'TestLevel1';
        cc.Level_2__c = 'TestLevel2';
        cc.Level_3__c = 'Test Classify';
        cc.Global_Comment_Code__c = gcc.Id;
        cc.Translated_Language__c = 'United States of America';
        cc.Inactive__c = false;
        insert cc;
      
        Product_Comment_Code__c pcc = new Product_Comment_Code__c();
        pcc.Global_Comment_Code__c = gcc.Id;
        pcc.Global_Product__c = gp.Id;
        pcc.Global_Product_Brand__c = 'TestBrand';
        pcc.Global_Product_Segment__c = 'TestSegment';
        insert pcc;
        
        Case_Comment_Code__c ccc = new Case_Comment_Code__c();
        ccc.Case__c = caseObj.Id;
        ccc.Local_Comment_Code__c = cc.Id;
        ccc.Case_Product__c = cp.Id;
        insert ccc;
    }
    
    public static void createCongaTemplate(){
        APXTConga4__Conga_Template__c tempObj = new APXTConga4__Conga_Template__c();
        tempObj.APXTConga4__Name__c='Test Name';
        tempObj.country__c='United States of America';
        tempObj.contact_center__c='NA';
        tempObj.language__c='English-US';
        tempObj.brand__C='TestBrand';
        tempObj.segment__c='TestSegment';
        tempObj.HTML_Content__c='Test HTML Content {Case.Brand}';
        tempObj.RTL_Language__c=false;
        tempObj.Default_Template_Active__c=true;
        insert tempObj;
    }
    
    public static void createLetterHead(){
        Letter_Head__c lhObj=new Letter_Head__c();
        lhObj.country__c='United States of America';
        lhObj.Language__c='English-US';
        lhObj.Brand__c='TestBrand';
        lhObj.Header_ID__c='TestId';
        insert lhObj;
    }
    
    public static void createMetadataItemTypeSelection(){
        Metadata_Item_Type_Selection__c mitObj=new Metadata_Item_Type_Selection__c();
        mitObj.Contact_Center__c='NA';
        mitObj.Item_Type__c='BD; CH; CO; CP; CR; DC; FL; PA; PI; PP; PR; RC; SA';
        insert mitObj;
    }
    
    public static void createFulfillmentItems(){
        Fulfillment_Item__c fitObj=new Fulfillment_Item__c();
        fitObj.Type__c='BD';
        fitObj.Description__c='Test';
        fitObj.Contact_Language__c='English-US';
        fitObj.Name='BD PGB SF to NYC WCIB No Prod';
        fitObj.Active__c=true;
        fitObj.Contact_Country__c='United States of America';
        fitObj.Brand__c='ALL';
        fitObj.Contact_Center__c='NA';
        fitObj.Segment__c='ALL';
        insert fitObj;
    }
    
    public static void createAutoFulfillmentItems(){
        Fulfillment_Item__c fitObj=new Fulfillment_Item__c();
        fitObj.Active__c=true;
        fitObj.Promo_Flag__c=true;
        fitObj.Contact_Country__c='United States of America';
        fitObj.Contact_Language__c='English-US';
        fitObj.Promo_Limit__c=10;
        fitObj.Brand__c='ALL';
        fitObj.Promo_Segment__c='ALL';
        fitObj.Segment__c='ALL';
        fitObj.Contact_Center__c='NA';       
        fitObj.Type__c='BD';
        fitObj.Description__c='Test';        
        fitObj.Name='BD PGB SF to NYC WCIB No Prod'; 
        fitObj.Auto_Fulfillment_GCR_CID__c='1234';
        fitObj.Promo_Template_Id__c=[select Id from APXTConga4__Conga_Template__c limit 1].Id;
        insert fitObj;
    }
    
    public static void createMetadataFulfillmentLineItemRecType(){
        Metadata_FF_Order_Line_Item_Record_Type__c mflirtObj=new Metadata_FF_Order_Line_Item_Record_Type__c();
        mflirtObj.Item_Type__c='BD';
        //mflirtObj.FF_Order_Line_Item_Record_Type_Id__c='012Q000000096ot'; //Chris - is this the wrong ID? Come over from legacy?
        mflirtObj.FF_Order_Line_Item_Record_Type_Id__c='01280000000M41v'; //Chris - hard corded ID :(
        insert mflirtObj;
    }
    
    public static void createFulFillmentOrder(Case caseObj){
        Fulfillment_Order__c ffOrder = new Fulfillment_Order__c();
        ffOrder.case__c = caseObj.id;
         
        insert ffOrder;
        
        Fulfillment_Order_Line_Item__c ffOrderLineItem = new Fulfillment_Order_Line_Item__c();
        ffOrderLineItem.Fulfillment_Order__c = ffOrder.id;
        ffOrderLineItem.case__c = caseObj.id;
        ffOrderLineItem.Type__c = 'ET';
        ffOrderLineItem.Quantity__c = 1;
        ffOrderLineItem.Amount_Currency__c = 110.00;
        ffOrderLineItem.Keep_amount__c = TRUE;

        insert ffOrderLineItem;
    }

    public static User createUserFFUserOne(Profile p){
        User userObj = new User(Alias = 'Test', Email='test+' + System.Math.random() + '@salesforce.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, Contact_Center__c='NA',
            TimeZoneSidKey='America/Los_Angeles', UserName='Under@threshold.com',
            USD_Monetary_Threshold__c = 100.00, BRL_Monetary_Threshold__c=999.00);
        insert userObj;        
        return userObj;
    }
    
    public static User createUserFFUserTwo(Profile p){
        User userObj = new User(Alias = 'Over', Email='test+' + System.Math.random() + '@salesforce.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, Contact_Center__c='NA',
            TimeZoneSidKey='America/Los_Angeles', UserName='test'+ System.Math.random() + '@salesforce.com',
            USD_Monetary_Threshold__c = 200.00, BRL_Monetary_Threshold__c=999.00);
        insert userObj;        
        return userObj;
    }
}*/