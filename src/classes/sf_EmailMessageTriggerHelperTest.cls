/**
* @author: Salesforce.com
* @date: 10/20/2014
*
* @description: Trigger test for EmailMessage
*/

@isTest
private class sf_EmailMessageTriggerHelperTest {
	
	@isTest static void testMessageInsert() {

		Account a = new Account ();
		a.Name = 'test';
		insert a;

		Contact con = new Contact();
		con.LastName = 'Tetst';
		con.AccountId = a.Id;
		con.Other_Address_Override_Reason__c = 'test';
		con.Primary_Address_Override_Reason__c = 'test';
		insert con;

		List<Case> casesToInsert = new List<Case>();
		
		for (Integer i = 0; i < 5; i++) {
			Case c = new Case();
			c.AccountId = a.Id;
			c.ContactId = con.Id;
			casesToInsert.add(c);
		}

		insert casesToInsert;
		
		List <Task> tasksToInsert = new List <Task>();
		

		for(Case c: casesToInsert) {
			
			Task newTask = sf_TestDataUtility.createTask(c.Id, sf_Constants.TASK_CONSUMER_ACTIVITY_RECTYPE_ID);
			newTask.type = sf_Constants.TASK_TYPE_CCM_ACTIVITY;
			newTask.Follow_up_category__c = sf_Constants.TASK_TYPE_CCM_ACTIVITY;
			newTask.Follow_Up_Reason__c = sf_Constants.TASK_FOLLOWUP_REASON_AUDIO_LOG_REQUEST;
			tasksToInsert.add(newTask);


		}

		insert tasksToInsert;

		List <EmailMessage> emList = new List <EmailMessage> ();

		for (Task t: [SELECT Id, WhatId FROM Task]) {
			EmailMessage em = new EmailMessage ();
			em.ParentId = t.WhatId;
			em.Incoming = true;
			em.HtmlBody = 'blah';
			em.ActivityId = t.Id;
			emList.add(em);
		}

		emList[0].Incoming = false;
		emList[0].TextBody = 'blah';
		emList[0].HtmlBody = '';
		
		Test.startTest();
		
		insert emList;

		Test.stopTest();
	}
	
	@isTest static void testMessageDelete() {
		Case c = new Case();
		insert c;

		EmailMessage em = new EmailMessage ();
		em.ParentId = c.Id;
		insert em;

		Test.startTest();
		
		delete [SELECT Id FROM EmailMessage];

		Test.stopTest();

		System.assertEquals(0,[SELECT Id FROM EmailMessage].size());

	}
	

	@isTest static void testMessageDeleteNoPerm() {

		Profile agentProfile = [SELECT Id, Name FROM Profile WHERE Name = 'EU1 User'];
		User agentUser = new User(alias = 'agent', email='testAgent@test.com',
						emailencodingkey='UTF-8', firstname='Test', lastname='User', languagelocalekey='en_US',
						localesidkey='en_US', profileid = agentProfile.id,
						timezonesidkey='America/Los_Angeles', username='guest@testpkg.com');
		insert agentUser;
		
		System.runAs(agentUser){
			Case c = new Case();
			insert c;

			EmailMessage em = new EmailMessage ();
			em.ParentId = c.Id;
			insert em;

			Test.startTest();
			
			try{
				delete [SELECT Id FROM EmailMessage];
			} catch(Exception e) {
				System.assert(true);
			}

			Test.stopTest();

			System.assertEquals(1,[SELECT Id FROM EmailMessage].size());
		}
		
	}
    /*Tests reply task functionality
     *Unit test limitations as SF does not automatically create the inbound task
	 *Nor does it close it on reply
	*/
    @isTest static void replyTaskTest(){
        Id customerActivity = Schema.SObjectType.Task.getRecordTypeInfosByName().get(sf_Constants.TASK_CUSTOMER_ACTIVITY_RECORDTYPENAME).getRecordTypeId();
        Id internalActivity = Schema.SObjectType.Task.getRecordTypeInfosByName().get(sf_Constants.TASK_INTERNAL_ACTIVITY_RECORDTYPENAME).getRecordTypeId();
        
        //Create Case
        Case c = new Case(
        	status = 'Open'
        );
        insert c;
        
        //WR361 - We have to manually reset this as all the records are created in the same context during test execution
        checkRecursive.newCase = false;

        //Create Inbound email task
        //Need to do this before the email message
        Task inboundTask = new Task(
            WhatId = c.Id,
            Subject = 'Inbound Email Task',
            Direction__c = 'Inbound',
            RecordTypeId = customerActivity
        );
        insert inboundTask;
        //Create Inbound Email
        EmailMessage inboundEmail = new EmailMessage(
            ActivityId = inboundTask.Id,
            ParentId = c.Id,
            incoming = True,
            Status = '0',
            subject = 'Consumer inbound',
            textBody = 'Body of email'
        );
        insert inboundEmail;
        
        //Asserts
        Integer TaskCount = [SELECT Count() FROM Task WHERE WhatId = :c.Id];
        Integer OpenTaskCount = [SELECT Count() FROM Task WHERE WhatId = :c.Id AND isClosed = FALSE];
        Integer InternalTaskCount = [SELECT Count() FROM Task WHERE WhatId = :c.Id AND RecordTypeId = :internalActivity];
            
        system.assertEquals(2, TaskCount); //Inital case creation and inbound email task
        system.assertEquals(1, OpenTaskCount);
        system.assertEquals(0,InternalTaskCount);
        
        test.startTest();
        
        
        
            //Create Outbound Email
            EmailMessage outboundEmail = new EmailMessage(
                ActivityId = inboundTask.Id,
                ParentId = c.Id,
                incoming = False,
                Status = '3',
                subject = 'Agent reply',
                textBody = 'Body of email'
            );
            insert outboundEmail;
            
            //Asserts
            TaskCount = [SELECT Count() FROM Task WHERE WhatId = :c.Id];
        	InternalTaskCount = [SELECT Count() FROM Task WHERE WhatId = :c.Id AND RecordTypeId = :internalActivity];
                
            system.assertEquals(2, TaskCount);
        	system.assertEquals(1, InternalTaskCount);
        
			EmailMessage outboundHTMlEmail = new EmailMessage(
                ActivityId = inboundTask.Id,
                ParentId = c.Id,
                incoming = False,
                Status = '3',
                subject = 'Agent reply',
                htmlBody = 'Body of email'
            );
            insert outboundHTMlEmail;
        test.stopTest();
    }	
    
        //This method tests what happens when the Subject field is longer than 255 characters and the Body is empty.
    @isTest static void TestEmailSubjectAndBodyOne(){
		test.startTest();

    	Case c = new Case(
        	status = 'Open'
        );
        insert c;

        EmailMessage newEmail = new EmailMessage(
            ParentId = c.Id,
	        subject  = 'This is some really long text that should go on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on but the subject should end here.The Body of the emailmessage should start here.',
	        textBody = ''
	    );

		insert newEmail;

		newEmail = [SELECT subject, textBody FROM emailMessage WHERE id=: newEmail.id];

		system.assertEquals(255, newEmail.subject.length());
        system.assertNotEquals(null, newEmail.textBody);

		test.stopTest();

    }

    //This method tests what happens when the Subject field is longer than 255 characters and the Body is empty.
    @isTest static void TestEmailSubjectAndBodyTwo(){
		test.startTest();

    	Case c = new Case(
        	status = 'Open'
        );
        insert c;

        EmailMessage newEmail = new EmailMessage(
            ParentId = c.Id,
	        subject  = 'This is some really long text that should go on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on but the subject should end here.The Body of the emailmessage should start here.',
	        textBody = '',
	        htmlBody = '<p>This is a paragraph</p>'
	    );
		insert newEmail;

		newEmail = [SELECT subject, textBody, htmlBody FROM emailMessage WHERE id=: newEmail.id];

		system.assertEquals(255, newEmail.subject.length());
        system.assertNotEquals(null, newEmail.textBody);
        system.assertNotEquals(null, newEmail.htmlBody);

		test.stopTest();
    }
}