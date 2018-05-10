/*
* @author: Accenture CD
* @date: 22/06/2017
* @description:  Schedule class for MSTCount.cls
*/

global class MSTCountSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
       

        MSTCount batch = new MSTCount();
        Database.executeBatch(batch,1);

    }
}