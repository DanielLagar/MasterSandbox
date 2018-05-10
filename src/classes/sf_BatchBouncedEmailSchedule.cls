/*
* @author: Chris Southworth
* @date: 06/02/2014
* @description:  Schedule class for sf_BatchBouncedEmail.cls
*/

global class sf_BatchBouncedEmailSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {

		sf_BatchBouncedEmail batch = new sf_BatchBouncedEmail();
		Database.executeBatch(batch);

	}
}