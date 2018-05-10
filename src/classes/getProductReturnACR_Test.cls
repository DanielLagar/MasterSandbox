@isTest
public class getProductReturnACR_Test {
	
    @testSetup
    static void setupData(){
        checkrecursive.toggleAllTriggers(false);
        AutoComRuleHelper_datasetup_Test.dataSetup();
        checkrecursive.toggleAllTriggers(true);
    }
	/****************************************************
     * Covers:											*
     * No Match found									*
	****************************************************/
    @isTest
    static void noACRMatchFoundTest(){
        //Get Case and CP and LC to use
        Case noACRCase = [SELECT Id FROM Case WHERE Subject = 'NoACR' LIMIT 1];
        Case_Product__c noACRCP = [SELECT id, ACR_Info__C FROM Case_Product__c WHERE Case__c = :noACRCase.Id LIMIT 1];
        system.assertEquals(null, noACRCP.ACR_Info__c);
        
        test.startTest();
            Local_Comment_Code__c lcc = [SELECT Id FROM Local_Comment_Code__c WHERE Translated_Path__c = 'AE/AE/AE' LIMIT 1];
            Case_Comment_Code__c testCCC = new Case_Comment_Code__c(
                Case__c = noACRCase.Id,
                Local_Comment_Code__c = lcc.Id,
                Case_Product__c = noACRCP.Id
            );
            insert testCCC;
            
            testCCC = [SELECT Id, ACR_Info__c FROM Case_Comment_Code__c WHERE Id = :testCCC.Id];
            system.assertEquals(getProductReturnACR.NO_MATCH, testCCC.ACR_Info__c);        
        test.stopTest();
    }
    
    /****************************************************
     * Covers:											*
     * Finding a matching ACR on CaseCommentCode insert	*
     * based on a product segment match					*
	****************************************************/
    @isTest
    static void cccTriggerSegmentTest(){
        //Query records we need
        Case testCase = [SELECT Id, ContactId FROM Case LIMIT 1];
        Local_Product__c testLP = [SELECT Id FROM Local_Product__c WHERE Name = 'Bag' LIMIT 1];
        Local_Comment_Code__c testLC = [SELECT Id FROM Local_Comment_Code__c WHERE Level_2__c = 'Foreign Material' LIMIT 1];

        //Create Case Product
        Case_Product__c testCP = new Case_Product__c(
            Case__c = testCase.Id,
            Local_Product__c = testLP.Id,
            Production_Code__c = 'randomvaluehere',
            Product_available_for_return__c = 'Yes - Product is available'     
        );
        system.debug(logginglevel.WARN,'!!! insert Case Product');
        insert testCP;
          
        //ChrisM Aug 2016 boolean deprecated
        checkRecursive.ACRprocessedIds.clear();
        
        Case_Comment_Code__c testCCC = new Case_Comment_Code__c(
            Case__c = testCase.Id,
            Local_Comment_Code__c = testLC.Id,
            Case_Product__c = testCP.Id
        );
        
        test.startTest();
            system.debug(logginglevel.WARN,'!!! insert Case Comment Code');
            insert testCCC;
        
            //Requery new CCC
            Auto_Communication_Rule__c ACR = [SELECT Id, Name FROM Auto_Communication_Rule__c WHERE Type__c = 'Product Return' AND Supported_Return_Type__c = 'Digital' LIMIT 1];
            testCP = [SELECT ACR_Info__c, Digital_Return_Id__c, ACR_Return_Type__c, Status__c FROM Case_Product__c WHERE Id = :testCP.Id];
            system.assertEquals(ACR.Name, testCP.ACR_Info__c);
        	system.assertNotEquals(null, testCP.Digital_Return_Id__c);
        	system.assertEquals('Digital', testCP.ACR_Return_Type__c);
        test.stopTest();
    }
    
    /****************************************************
     * Covers:											*
     * Finding a matching ACR on CaseCommentCode insert	*
     * based on an exact product segment match	        *
	****************************************************/    
	@isTest
    static void cccTriggerPathTest(){
        String productPath = 'Ariel/Laundry segment/Powder/-/-/Original/Compact/63oz/Bag/digi';//manually updated path to get an exact match > segment 
		Fulfillment_Item__c ffItem1 = [SELECT Id FROM Fulfillment_Item__c WHERE Type__c = 'BD' LIMIT 1];
        Global_Comment_Code__c gcc2 = [SELECT Id FROM Global_Comment_Code__c WHERE Level_2__c = 'Foreign Material' LIMIT 1];
        String kavNumber = [SELECT Id, ArticleNumber FROM Return_Instructions__kav
                            WHERE PublishStatus = 'Online' AND Language = 'en_US' AND UrlName = 'Return-Instructions-test-Article-1' LIMIT 1].ArticleNumber;
        
        //Create path ACR
		Auto_Communication_Rule__c pathDigiACR = new Auto_Communication_Rule__c (
            Type__c = 'Product Return',
			Global_Product_Path__c = productPath,
			Supported_Return_Type__c = 'Digital',//CR16
            Global_Comment_Code__c = gcc2.Id,
            Product_Search_Key__c = '', //Should be set by WFR
			X1st_Attempt_Fulfillment_Item__c = ffItem1.Id,
			X2nd_Attempt_Fulfillment_Item__c = ffItem1.Id,
			X3rd_Attempt_Fulfillment_Item__c = ffItem1.Id,
			Generate_PDF_for_Attempt__c = '2;3',
			Template_Unique_Name__c =  'ACR_UnitTest_EmailTemplate',
            Digital_Attempt_1st_Template__c = 'ACR_UnitTest_EmailTemplate',
            Digital_Attempt_2nd_Template__c = 'ACR_UnitTest_EmailTemplate',
            Digital_Attempt_3rd_Template__c = 'ACR_UnitTest_EmailTemplate',
            Digital_Thankyou_Email__c = 'ACR_UnitTest_EmailTemplate',
            Digital_Instructions__c = kavNumber
        );
        insert pathDigiACR;
        
		//Query records we need
		pathDigiACR = [SELECT Id, Name FROM Auto_Communication_Rule__c WHERE Id = :pathDigiACR.Id];
        Case testCase = [SELECT Id, ContactId FROM Case LIMIT 1];
        Local_Product__c testLP = [SELECT Id, Global_Product__c FROM Local_Product__c WHERE Name = 'Bag' LIMIT 1];
        Global_Product__c testGP = [SELECT Id FROM Global_Product__c WHERE Id = :testLP.Global_Product__c LIMIT 1];
        Local_Comment_Code__c testCC = [SELECT Id FROM Local_Comment_Code__c WHERE Level_2__c = 'Foreign Material' LIMIT 1];
        
        testGP.Path__c = productPath;
        update testGP;

        //Create Case Product
        Case_Product__c testCP = new Case_Product__c(
            Case__c = testCase.Id,
            Local_Product__c = testLP.Id,
            Production_Code__c = 'randomvaluehere',
            Product_available_for_return__c = 'Yes - Product is available'     
        );
        system.debug(logginglevel.WARN,'!!! insert Case Product');
        insert testCP;
          
        //ChrisM Aug 2016 boolean deprecated
        checkRecursive.ACRprocessedIds.clear();
        
        Case_Comment_Code__c testCCC = new Case_Comment_Code__c(
            Case__c = testCase.Id,
            Local_Comment_Code__c = testCC.Id,
            Case_Product__c = testCP.Id
        );
        
        test.startTest();
            system.debug(logginglevel.WARN,'!!! insert Case Comment Code');
            insert testCCC;
        
            //Requery new CCC
            testCP = [SELECT ACR_Info__c, Digital_Return_Id__c, ACR_Return_Type__c, Status__c FROM Case_Product__c WHERE Id = :testCP.Id];
            system.assertEquals(pathDigiACR.Name, testCP.ACR_Info__c);
        	system.assertNotEquals(null, testCP.Digital_Return_Id__c);
        	system.assertEquals('Digital', testCP.ACR_Return_Type__c);
        test.stopTest(); 
    }

}