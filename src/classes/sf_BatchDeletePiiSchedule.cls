/*
* @author: John Casimiro
* @date: 02/13/2015
* @description:  Schedule class for sf_BatchDeletePii.cls
*/

global class sf_BatchDeletePiiSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {

		sf_BatchDeletePii batch = new sf_BatchDeletePii();
		Database.executeBatch(batch);

	}
}