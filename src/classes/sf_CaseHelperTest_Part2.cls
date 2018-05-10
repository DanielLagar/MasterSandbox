@isTest
private class sf_CaseHelperTest_Part2 {
    Static Final String COUNTRY = 'New Zealand';
    
    @testSetup static void setupData(){
        //Create User to avoid mixed DML
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User adminTestUser = new User(
            Lastname = 'Admin',
            Alias = 'UTAdmin',
            Email = 'UTAdmin@pgTEST.com',
            Username = String.valueOF(math.random())+'@pgTEST.com',
            CommunityNickname = 'atu',
            ProfileId=p.Id,
            TimeZoneSidKey='America/New_York',
            LocaleSidKey='en_US',
            EmailEncodingKey='ISO-8859-1',
            LanguageLocaleKey='en_US',
            USD_Monetary_Threshold__c = 50,
            GBP_Monetary_Threshold__c = 50,
            EUR_Monetary_Threshold__c = 50,
            IsActive = True
        );
        Insert adminTestUser;
        
        system.runAs(adminTestUser){
            //Get Case RTs
            List<RecordType> caseRTs = [SELECT Id FROM RecordType WHERE SObjectType = 'Case'];
    
            //Create Group
            List<Group> groupsToInsert = new List<Group>();
            Group qGroup1 = new Group();
            qGroup1.Name = 'HasCountryValue';
            qGroup1.Type = 'Queue';
            groupsToInsert.add(qGroup1);
            
            Group qGroup2 = new Group();
            qGroup2.Name = 'CountryValueIsAll';
            qGroup2.Type = 'Queue';
            groupsToInsert.add(qGroup2);            

            Insert groupsToInsert;
            
            //Create Queue
            List<QueueSObject> qs = new List<QueueSObject>();
            QueueSObject q1 = New QueueSobject(
                sObjectType = 'Case',
                QueueId = qGroup1.Id
            );
            qs.add(q1);
            
			QueueSObject q2 = New QueueSobject(
                sObjectType = 'Case',
                QueueId = qGroup2.Id
            );
            qs.add(q2);
            
            insert qs;
            
            //Create QueueRecordType__c
            List<QueueRecordType__c> qrts = new List<QueueRecordType__c>();
            QueueRecordType__c qrt = new QueueRecordType__c(
                Name = qGroup1.Id,
                Country__c = COUNTRY,
                Case_Record_Type_Id__c = caseRTs[0].Id
            );
            qrts.add(qrt);
            
			QueueRecordType__c qrtAll = new QueueRecordType__c(
                Name = qGroup2.Id,
                Country__c = 'All',
                Case_Record_Type_Id__c = caseRTs[3].Id
            );
            qrts.add(qrtAll);

            insert qrts;
            
            Case testCase = new Case(
                Status = 'Open',
                Country__c = 'United States of America',
                RecordTypeId = caseRTs[1].Id
        	);
        	insert testCase;
        }
    }
    
    @isTest static void setCaseRecordTypeTest(){

        Case testCase = [SELECT Country__c, RecordTypeId FROM Case ORDER BY CaseNumber DESC LIMIT 1];

        system.assertNotEquals(COUNTRY, testCase.Country__c);
        
        Id oldRecordTypeId = [SELECT RecordTypeId FROM Case WHERE Id = :testCase.Id].RecordTypeId;
        
        Id assignToAllQueueId = [SELECT QueueId FROM QueueSObject WHERE queue.Name = 'CountryValueIsAll' LIMIT 1].QueueId;
        Id assignToCountryQueueId = [SELECT QueueId FROM QueueSObject WHERE queue.Name = 'HasCountryValue' LIMIT 1].QueueId;

        test.startTest();
        //Country = 'All' test. Country and Language should not be updated
        testCase.OwnerId = assignToAllQueueId;
        update testCase;
        
        testCase = [SELECT Country__c, RecordTypeId FROM Case WHERE Id = :testCase.Id];
        
       	system.assertNotEquals(testCase.RecordTypeId, oldRecordTypeId);//RecordTypeId should have been changed
        system.assertEquals(null, testCase.Country__c);//Country value should have been cleared
        
        
        //Country has specific value, Country should be updated
        testCase.OwnerId = assignToCountryQueueId;
        update testCase;
        
        testCase = [SELECT Country__c, RecordTypeId FROM Case WHERE Id = :testCase.Id];
        
        system.assertNotEquals(testCase.RecordTypeId, oldRecordTypeId);//RecordTypeId should have been changed
        system.assertEquals(COUNTRY, testCase.Country__c);//Country should be set to match the QueueRecordType__c
        
        test.stopTest();
    }
    
    @isTest static void updateCPBasedonCaseTest(){
        //Setup data
		Case c = [SELECT Id FROM Case LIMIT 1];
    
		Global_Product__c gp = new Global_Product__c();
		insert gp;
		
        Local_Product__c lp = new Local_Product__c();
		lp.Name = 'Test Product';
		lp.Country__c = 'United States of America';
		lp.Translated_Path__c = 'Test Path';
		lp.Global_Product__c = gp.Id;
		insert lp;
    
		Global_Comment_Code__c gcc = new Global_Comment_Code__c ();
		gcc.Level_1__c = 'Adverse Event';
		insert gcc;
    
		Local_Comment_Code__c lcc = new Local_Comment_Code__c ();
		lcc.Global_Comment_Code__c = gcc.Id;
		insert lcc;
    
		Case_Product__c cp = new Case_Product__c();
		cp.Local_Product__c = lp.Id;
		cp.Case__c = c.Id;
        cp.Status__c = 'Product Requested - Attempt 1';
		insert cp;
    
		Case_Comment_Code__c ccc = new Case_Comment_Code__c();
		ccc.Local_Comment_Code__c = lcc.Id;
		ccc.Case__c = c.Id;
		ccc.Case_Product__c = cp.Id;
		insert ccc;
        
        //Confirm both fields are setup as expected
        cp = [SELECT Id, Status__c, Case__r.Product_Return_Status__c FROM Case_Product__c WHERE Id = :cp.Id];
        system.assertEquals('Product Requested - Attempt 1', cp.Case__r.Product_Return_Status__c);
        system.assertEquals('Product Requested - Attempt 1', cp.Status__c);
        
        test.startTest();
        	//Change case status to a non cp update value
        	c.Product_Return_Status__c = 'Product Requested - Attempt 2';
        	update c;
        
			cp = [SELECT Id, Status__c, Case__r.Product_Return_Status__c FROM Case_Product__c WHERE Id = :cp.Id];
        	system.assertEquals('Product Requested - Attempt 2', cp.Case__r.Product_Return_Status__c);
       	 	system.assertEquals('Product Requested - Attempt 1', cp.Status__c); //CP is not updated
        
        	//Change case status to a cp update value
            c.Product_Return_Status__c = 'Product Received';
        	update c;
        
        	cp = [SELECT Id, Status__c, Case__r.Product_Return_Status__c FROM Case_Product__c WHERE Id = :cp.Id];
        	system.assertEquals('Product Received', cp.Case__r.Product_Return_Status__c);
       	 	system.assertEquals('Product Received', cp.Status__c); //CP is updated

        test.stopTest();
    }

}