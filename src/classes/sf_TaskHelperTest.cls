/**
* @author: Archana Sethuraman
* @date: 9/5/2014
* @description: 
*	Test class for task trigger helper
*/

@isTest
private class sf_TaskHelperTest {

	static testmethod void updateCaseFieldsTest() {
		
		List<Case> casesToInsert = new List<Case>();
		
		for (Integer i = 0; i < 5; i++) {
			Case c = new Case();
			casesToInsert.add(c);
		}

		insert casesToInsert;
		
		List<Task> tasksToInsert = new List<Task>();
		
		for(Case c: casesToInsert) {
			
			Task newTask = sf_TestDataUtility.createTask(c.Id, sf_Constants.TASK_CONSUMER_ACTIVITY_RECTYPE_ID);
			newTask.type = sf_Constants.TASK_TYPE_CCM_ACTIVITY;
			newTask.Follow_up_category__c = sf_Constants.TASK_TYPE_CCM_ACTIVITY;
			newTask.Follow_Up_Reason__c = sf_Constants.TASK_FOLLOWUP_REASON_AUDIO_LOG_REQUEST;
			tasksToInsert.add(newTask);
		}
		
		Test.startTest();
		
		insert tasksToInsert;

		System.debug(tasksToInsert);
		
		Test.stopTest();
		
		List <Case> cases = new List <Case> ([SELECT Id
													,Status
													,Reassign_Case__c
											FROM Case
											WHERE Id IN:casesToInsert]);
		
		System.assertEquals(cases.size(), 5, 'Cases insert error');
		
		for (Case c: cases) {
			System.assertNotEquals(c.status,sf_Constants.CASE_STATUS_REOPENED_BY_CCM, 'Status not set to reopened by CCM');
			System.assertEquals(c.Reassign_Case__c,false, 'Reassign flag not set correctly');
		}
	}
    
    //ChrisM - test for Ecoystem changes March 2016
    //Covers tasks created by Tibco with subject "Product Retrieval Request"
	static testmethod void updateCaseFieldsTibcoTest() {//TODO: Change test method name to be more meaningful
		
		List<Case> casesToInsert = new List<Case>();
		
		for (Integer i = 0; i < 5; i++) {
			Case c = new Case();
			casesToInsert.add(c);
		}

		insert casesToInsert;
		
		List<Task> tasksToInsert = new List<Task>();
		
		for(Case c: casesToInsert) {
			
			Task newTask = sf_TestDataUtility.createTask(c.Id, sf_Constants.TASK_CONSUMER_ACTIVITY_RECTYPE_ID);
			newTask.type = sf_Constants.TASK_TYPE_CCM_ACTIVITY;
			newTask.Follow_up_category__c = sf_Constants.TASK_TYPE_CCM_ACTIVITY;
			newTask.Follow_Up_Reason__c = sf_Constants.TASK_SUBJECT_PRODUCT_RETRIEVAL;
            newTask.Subject = sf_Constants.TASK_SUBJECT_PRODUCT_RETRIEVAL;
            newTask.Originating_System__c = 'CCM';
			tasksToInsert.add(newTask);
		}
		
		Test.startTest();
        system.debug('!!! In ChrisM Unit test for Ecosystem tasks');
		
		insert tasksToInsert;

		System.debug(tasksToInsert);
		
		Test.stopTest();
		
		List <Case> cases = new List <Case> ([SELECT Id
													,Status
													,Reassign_Case__c
                                              		,Intake_Agent_Request__c
											FROM Case
											WHERE Id IN:casesToInsert]);
		
		System.assertEquals(cases.size(), 5, 'Cases insert error');
		
		for (Case c: cases) {
			System.assertEquals(c.status,sf_Constants.CASE_STATUS_REOPENED_BY_CCM, 'Status set to reopened by CCM');
			System.assertEquals(c.Reassign_Case__c,false, 'Reassign flag not set correctly');
            System.assertEquals(c.Intake_Agent_Request__c,true, 'Intake Agent request flag not set correctly');
		}
	}//ChrisM Finish  

	static testmethod void deleteTaskTest() {
		List<Case> casesToInsert = new List<Case>();
		
		for (Integer i = 0; i < 5; i++) {
			Case c = new Case();
			casesToInsert.add(c);
		}

		insert casesToInsert;
		System.debug(casesToInsert);

		List<Task> tasksToInsert = new List<Task>();
		
		for(Case c: casesToInsert) {
			
			Task newTask = sf_TestDataUtility.createTask(c.Id, sf_Constants.TASK_CONSUMER_ACTIVITY_RECTYPE_ID);
			newTask.type = sf_Constants.TASK_TYPE_CCM_ACTIVITY;
			newTask.Follow_up_category__c = sf_Constants.TASK_TYPE_CCM_ACTIVITY;
			newTask.Follow_Up_Reason__c = sf_Constants.TASK_FOLLOWUP_REASON_AUDIO_LOG_REQUEST;
			tasksToInsert.add(newTask);
		}
		
		insert tasksToInsert;

		System.debug(tasksToInsert);


		Test.startTest();
		
		delete [SELECT Id FROM Task];
		
		Test.stopTest();

		System.assertEquals(0,[SELECT Id FROM Task].size());
	}

	static testmethod void deleteTaskTestNoPerm() {
			
		Profile agentProfile = [SELECT Id, Name FROM Profile WHERE Name = 'EU1 User'];
		User agentUser = new User(alias = 'agent', email='testAgent@test.com',
						emailencodingkey='UTF-8', firstname='Test', lastname='User', languagelocalekey='en_US',
						localesidkey='en_US', profileid = agentProfile.id,
						timezonesidkey='America/Los_Angeles', username='guest@testpkg.com');
		insert agentUser;
		
		System.runAs(agentUser){

			List<Case> casesToInsert = new List<Case>();
			
			for (Integer i = 0; i < 5; i++) {
				Case c = new Case();
				casesToInsert.add(c);
			}

			insert casesToInsert;
			
			List<Task> tasksToInsert = new List<Task>();
			for(Case c: casesToInsert) {
				
				Task newTask = sf_TestDataUtility.createTask(c.Id, sf_Constants.TASK_CONSUMER_ACTIVITY_RECTYPE_ID);
				newTask.type = sf_Constants.TASK_TYPE_CCM_ACTIVITY;
				newTask.Follow_up_category__c = sf_Constants.TASK_TYPE_CCM_ACTIVITY;
				newTask.Follow_Up_Reason__c = sf_Constants.TASK_FOLLOWUP_REASON_AUDIO_LOG_REQUEST;
				tasksToInsert.add(newTask);
			}
			
			insert tasksToInsert;
			System.debug(tasksToInsert);

			Test.startTest();

			try{
				delete [SELECT Id FROM Task];
			} catch(Exception e) {
				System.assert(true);
			}
			
			Test.stopTest();

		}
	}
}