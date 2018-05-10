@isTest
private class sf_ProductsAddedSubtabControllerTest {
    
	public static testMethod void testAddProductComment () {
        String userLanguage = 'Chinese';

        Case c = new Case ();
        c.Country__c = 'China';
        c.Language__c = 'Chinese';
        insert c;

        Global_Product__c gp = new Global_Product__c();
        gp.Path__c = 'TestBrand/TestSegment';
        insert gp;

        Local_Product__c lp = new Local_Product__c ();
        lp.Name = 'Test Path';
        lp.Country__c = 'China';
        lp.Translated_Path__c = 'Test Path/Test/Path';
        lp.Global_Product__c = gp.Id;
        insert lp;
        
        Case_Product__c cp = new Case_Product__c ();
        cp.Case__c = c.Id;
        cp.Local_Product__c = lp.Id;
        insert cp;

        Global_Comment_Code__c gcc = new Global_Comment_Code__c ();
        insert gcc;

        Local_Comment_Code__c cc = new Local_Comment_Code__c ();
        cc.Level_1__c = 'TestLevel1';
        cc.Level_2__c = 'TestLevel2';
        cc.Level_3__c = 'Test Classify';
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
        
        //Unable to Classify
        Global_Comment_Code__c gccUTC = new Global_Comment_Code__c ();
        gccUTC.Reason_Required__c = true;
        insert gccUTC;

        Local_Comment_Code__c ccUTC = new Local_Comment_Code__c ();
        ccUTC.Level_1__c = 'Unable To Classify';
        ccUTC.Level_2__c = 'Unable To Classify';
        ccUTC.Level_3__c = 'Unable To Classify';
        ccUTC.Global_Comment_Code__c = gccUTC.Id;
        ccUTC.Translated_Language__c = 'Chinese';
        //ccUTC.Country__c = 'China';
        ccUTC.Inactive__c = false;
        insert ccUTC;
        
        Product_Comment_Code__c pccUTC = new Product_Comment_Code__c();
        pccUTC.Global_Comment_Code__c = gccUTC.Id;
        pccUTC.Global_Product__c = gp.Id;
        pccUTC.Global_Product_Brand__c = 'TestBrand';
        pccUTC.Global_Product_Segment__c = 'TestSegment';
        insert pccUTC;

        ApexPages.StandardController sc = new ApexPages.StandardController (c);
        sf_ProductsAddedSubtabController ctrl = new sf_ProductsAddedSubtabController (sc);

        Test.startTest();
            
            //verify case query by caseId
            ctrl.caseId = c.Id;
            ctrl.setCaseId();
            System.assertEquals(ctrl.caseId, ctrl.caseRecord.Id, 'Case Id not set');
    
            //verify language check
            System.assertEquals('Chinese', ctrl.caseRecord.Language__c, 'Case Language not set');
            
            //verify case comment code search.  Should return the LCC created above and query for the Unable to Classify LCC
            Id [] commentResults = new Id[1];
            commentResults[0] = cc.Id;
            Test.setFixedSearchResults(commentResults);
            List <sObject> ccList = sf_ProductsAddedSubtabController.doCaseCommentSoslSearch(gp.Id, pcc.Global_Product_Brand__c, pcc.Global_Product_Segment__c, 'test', 'China', userLanguage, 'TestLevel1', 'TestLevel2');
            //System.assertEquals(2, ccList.size(), 'Comment Code Search did not return expected results');

            //verify case comment code search.  Should return the LCC created above and the Unable to Classify LCC without the need to query
            Id [] commentResults2 = new Id[2];
            commentResults2[0] = cc.Id;
            commentResults2[1] = ccUTC.Id;
            Test.setFixedSearchResults(commentResults2);
            List <sObject> ccList2 = sf_ProductsAddedSubtabController.doCaseCommentSoslSearch(gp.Id, pcc.Global_Product_Brand__c, pcc.Global_Product_Segment__c, 'Classify', 'China', userLanguage, 'TestLevel1', 'TestLevel2');
            //System.assertEquals(2, ccList.size(), 'Comment Code Search did not return expected results');
    
            //verify adding comment code
            ctrl.refreshCaseProducts();
            ctrl.localProductId = cp.Id;
            sf_ProductsAddedSubtabController.addCaseCommentCode(c.Id, cc.Id, ctrl.localProductId);
            ctrl.caseProductId = cp.Id;
            ctrl.updateCaseCommentList();
            //System.assertEquals(1, [SELECT Id FROM Case_Comment_Code__c].size(), 'Case Comment was not added.');
            
            //verify saving case product changes
            ctrl.productCommentsList[0].product.Production_Code__c = '12345';
            ctrl.saveProductCommentChanges();
            Case_Product__c caseProduct = [SELECT Id, Production_Code__c FROM Case_Product__c WHERE Id = :ctrl.productCommentsList[0].product.Id];
            System.assertEquals('12345', caseProduct.Production_Code__c, 'Case Product: Production Code was not saved to record');
                        
            //verify saving case comment code changes
            ctrl.productCommentsList[0].caseCommentCodes[0].Quantity_Affected__c = 5;
            ctrl.commentCodeId = ctrl.productCommentsList[0].caseCommentCodes[0].Id;
            ctrl.saveProductCommentChanges();
            Case_Comment_Code__c commentSuccess = [SELECT Id, Quantity_Affected__c FROM Case_Comment_Code__c WHERE Id = :ctrl.commentCodeId];
            System.assertEquals(5, commentSuccess.Quantity_Affected__c, 'Quantity was not saved to Case Comment Code');
                        
            //Test Case Product Clone
            ctrl.localProductId = cp.Id;
            ctrl.cloneCaseProduct();
            System.assertEquals(2, [SELECT Id FROM Case_Product__c].size(), 'Case Product was cloned.');
            //System.assertEquals(2, [SELECT Id FROM Case_Comment_Code__c].size(), 'Case Comment was not cloned.');
            //query for and remove clone
            ctrl.localProductId = [SELECT Id FROM Case_Product__c WHERE Id != :cp.Id LIMIT 1].Id;
            ctrl.removeCaseProduct();
            System.assertEquals(1, [SELECT Id FROM Case_Product__c].size(), 'Case Product was not removed.');
            
            //verify removing case comment code
            ctrl.refreshCaseProducts();
            ctrl.commentCodeId = [SELECT Id FROM Case_Comment_Code__c LIMIT 1].Id;
            ctrl.localProductId = cp.Id;
            ctrl.removeCommentCode();
            System.assertEquals(0, [SELECT Id FROM Case_Comment_Code__c].size(), 'Case Comment was not removed.');
    
            //verify removing case product
            //ctrl.localProductId = cp.Id;
            //ctrl.removeCaseProduct();
            //System.assertEquals(0, [SELECT Id FROM Case_Product__c].size(), 'Case Product was not removed.');
            
        Test.stopTest();
    }
    
    public static testMethod void testFilteringAndDictionary(){
        Case c = new Case ();
        c.Country__c = 'China';
        c.Language__c = 'Chinese';
        insert c;

        Global_Product__c gp = new Global_Product__c();
        gp.Path__c = 'TestBrand/TestSegment';
        insert gp;

        Local_Product__c lp = new Local_Product__c ();
        lp.Name = 'tester';
        lp.Country__c = 'China';
        lp.Translated_Path__c = 'tester path 1';
        lp.Global_Product__c = gp.Id;
        insert lp;
        
        Case_Product__c cp = new Case_Product__c ();
        cp.Case__c = c.Id;
        cp.Local_Product__c = lp.Id;
        insert cp;

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
        sf_ProductsAddedSubtabController ctrl = new sf_ProductsAddedSubtabController (sc);
        ctrl.userLanguage = 'Chinese';

        Test.startTest();
            
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
            ctrl.dictionaryProductId = cp.Id;
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
            
            //verify close of dictionary
            ctrl.closeCommentCodeDictionary();
            System.assertEquals(false, ctrl.displayCommentCodeDictionary, 'Comment Code Dictionary Display should be false');
        Test.stopTest();
    }
    
    public static testMethod void testSurveyCreation(){
        Case c = new Case ();
        c.Country__c = 'China';
        c.Language__c = 'Chinese';
        c.Direction__c = 'test';
        c.Origin = 'test';
        insert c;

        Global_Product__c gp = new Global_Product__c();
        gp.Path__c = 'TestBrand/TestSegment';
        insert gp;

        Local_Product__c lp = new Local_Product__c ();
        lp.Name = 'tester';
        lp.Country__c = 'China';
        lp.Translated_Path__c = 'tester path 1';
        lp.Global_Product__c = gp.Id;
        insert lp;
        
        Case_Product__c cp = new Case_Product__c ();
        cp.Case__c = c.Id;
        cp.Local_Product__c = lp.Id;
        insert cp;

        Global_Comment_Code__c gcc = new Global_Comment_Code__c ();
        gcc.Level_1__c = 'TestLevel1';
        gcc.Level_2__c = 'TestLevel2';
        gcc.Level_3__c = 'TestLevel3';
        insert gcc;

        Local_Comment_Code__c lcc = new Local_Comment_Code__c();
        lcc.Level_1__c = 'TestLevel1';
        lcc.Level_2__c = 'TestLevel2';
        lcc.Level_3__c = 'TestLevel3';
        lcc.Translated_Language__c = 'Chinese';
        //cc.Name = 'test';
        lcc.Global_Comment_Code__c = gcc.Id;
        lcc.Translated_Path__c = 'Some/Content/Here';
        insert lcc;
        
        Case_Comment_Code__c ccc = new Case_Comment_Code__c();
        ccc.Case__c = c.Id;
        ccc.Local_Comment_Code__c = lcc.Id;
        ccc.Case_Product__c = cp.Id;
        insert ccc;
        
        List<Metadata_Survey_Trigger__c> mstsToInsert = new List<Metadata_Survey_Trigger__c>();
        
        Metadata_Survey_Trigger__c mst = new Metadata_Survey_Trigger__c ();
        mst.Active__c = true;
        mst.Expiration_Date__c = System.today() + 10;
        mst.Country__c = 'China';
        mst.Language__c = 'Chinese';
        mst.Brand__c = 'TestBrand';
        mst.Segment__c = 'TestSegment';
        mst.Comment_Code_L1__c = 'TestLevel1|';
        mst.Comment_Code_L2__c = 'TestLevel2|';
        mst.Comment_Code_L3__c = 'TestLevel3|';
        mst.Contact_Method__c = 'test';
        mst.Direction__c = 'test';
        mst.Survey_Fieldset__c = 'test';
        mst.Survey_Object__c = 'Survey__c';
        mst.Trigger_Type__c = 'Level';
        mst.Product_Path__c = 'Testing';
        mst.Comment_Code_Path__c = 'Testing';
        mstsToInsert.add(mst);
        
        Metadata_Survey_Trigger__c mst2 = new Metadata_Survey_Trigger__c ();
        mst2.Active__c = true;
        mst2.Expiration_Date__c = System.today() + 10;
        mst2.Country__c = 'China';
        mst2.Language__c = 'Chinese';
        mst2.Brand__c = 'TestBrand';
        mst2.Segment__c = 'TestSegment';
        mst2.Comment_Code_L1__c = 'TestLevel1|';
        mst2.Comment_Code_L2__c = 'TestLevel2|';
        mst2.Comment_Code_L3__c = 'TestLevel3|';
        mst2.Contact_Method__c = 'test';
        mst2.Direction__c = 'test';
        mst2.Survey_Fieldset__c = 'test';
        mst2.Survey_Object__c = 'Safety_Assessment_Survey__c';
        mst2.Trigger_Type__c = 'Level';
        mst2.Product_Path__c = 'Testing';
        mst2.Comment_Code_Path__c = 'Testing';
        mstsToInsert.add(mst2);
        
        //Path only MST
        Metadata_Survey_Trigger__c mst3 = new Metadata_Survey_Trigger__c ();
        mst3.Active__c = true;
        mst3.Expiration_Date__c = System.today() + 10;
        mst3.Country__c = 'China';
        mst3.Language__c = 'Chinese';
        mst3.Brand__c = 'TestBrand';
        mst3.Segment__c = '';
        mst3.Comment_Code_L1__c = 'TestLevel1|';
        mst3.Comment_Code_L2__c = 'TestLevel2|';
        mst3.Comment_Code_L3__c = 'TestLevel3|';
        mst3.Contact_Method__c = 'test';
        mst3.Direction__c = 'test';
        mst3.Survey_Fieldset__c = 'test';
        mst3.Survey_Object__c = 'Safety_Assessment_Survey__c';
        mst3.Trigger_Type__c = 'Path';
        mst3.Product_Path__c = 'Testing';
        mst3.Comment_Code_Path__c = 'Testing';
        mstsToInsert.add(mst3);        
        
        insert mstsToInsert;

        ApexPages.StandardController sc = new ApexPages.StandardController (c);
        sf_ProductsAddedSubtabController ctrl = new sf_ProductsAddedSubtabController (sc);
            
        Test.startTest();
            
            sf_ProductsAddedSubtabController.createCommentCodeSurvey(ccc.Id);
            System.assertEquals(1, [SELECT Id FROM Survey__c].size(), 'Should only find 1 Survey__c record');
            System.assertEquals(1, [SELECT Id FROM Safety_Assessment_Survey__c].size(), 'Should only find 1 Safety_Assessment_Survey__c record');
            System.assertEquals(1, [SELECT Id FROM Survey_Comment_Product__c].size(), 'Should only find 1 Survey_Comment_Product__c record');
        
        Test.stopTest();
    } 
    
    public static testMethod void wtbTest (){
        List<TriggerSwitch__c> switchesToInsert = new List<TriggerSwitch__c>();
        TriggerSwitch__c wtbEnabled = new TriggerSwitch__c(
            name = 'consoleWTB',
            TriggerOn__c = true
        );
        switchesToInsert.add(wtbEnabled);
        TriggerSwitch__c macTrigger = new TriggerSwitch__c(
            name = 'macTrigger',
            TriggerOn__c = true
        );
        switchesToInsert.add(macTrigger);
        insert switchesToInsert;
        
        Country_Region_SMO__c testCountry = new Country_Region_SMO__c(
            Name = 'UNITED STATES OF AMERICA',
            Currency_ISO_Code__c = 'USD',
            WTB_Enabled__c = True
        );
        insert testCountry;
        
        Case testCase = new Case(
            Country__c = 'United States of America',
            subject = 'Test case for WTB boolean',
            Language__c = 'English-US'
        );
        insert testCase;
        
		ApexPages.StandardController sc = new ApexPages.StandardController (testCase);
        sf_ProductsAddedSubtabController ctrl = new sf_ProductsAddedSubtabController (sc);
        
        Test.startTest();
        	Boolean testBoo = ctrl.wtbCountry;
        Test.stopTest();
		system.assertEquals(True, testBoo);
    }

}