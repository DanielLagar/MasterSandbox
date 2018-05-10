@isTest
private class sf_DAMProcessImagesScheduleableTest {
	
	@isTest static void testSchedule() {
		Test.startTest();

      	String CRON_EXP = '0 0 0 3 9 ? 2022';
      	// Schedule the test job

      	String jobId = System.schedule('testBasicScheduledApex', CRON_EXP, new sf_DAMProcessImagesScheduleable());

      	// Get the information from the CronTrigger API object
      	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
         					FROM CronTrigger 
         					WHERE id = :jobId];

      	// Verify the expressions are the same
      	System.assertEquals(CRON_EXP, ct.CronExpression);

      	// Verify the job has not run
      	System.assertEquals(0, ct.TimesTriggered);

     	// Verify the next time the job will run
    	System.assertEquals('2022-09-03 00:00:00', 
    	String.valueOf(ct.NextFireTime));
      
   		Test.stopTest();
	}
}