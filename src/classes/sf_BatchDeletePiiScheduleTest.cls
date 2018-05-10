/*
* @author: John Casimiro
* @date: 02/13/2015
* @description:  Test class for sf_BatchDeletePiiSchedule.cls
*/

@isTest
private class sf_BatchDeletePiiScheduleTest {
	
	static testMethod void test_Schedule() {
        Test.startTest();
        
	        String cronExp = '0 0 0 3 9 ? 2022'; //midnight Sept. 3rd. 2022  
	        
	        Set<Id> jobIds = new Set<Id> {
	        	System.schedule('testBatchDeletePiiSchedule', cronExp, new sf_BatchDeletePiiSchedule()) 
	        };
	        
	        List<CronTrigger> cts = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id in :jobIds]; 
	        
	        System.assertEquals(cronExp, cts[0].CronExpression);
	        System.assertEquals(0, cts[0].TimesTriggered);
	        System.assertEquals('2022-09-03 00:00:00', String.valueOf(cts[0].NextFireTime));
        
        Test.stopTest();
    }
	
}