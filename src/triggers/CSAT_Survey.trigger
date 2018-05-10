/**
* @author: salesforce.com, inc.
* @date: 02/05/2015
*
* @description: trigger for CSAT survey
* 
*/

trigger CSAT_Survey on CSAT_Survey__c (before insert, before update, after update) {

    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)) {
        sf_CSATSurveyHelper.updateCSATId(trigger.new);
    }
    
    if(trigger.isAfter && trigger.isUpdate) {
        sf_CSATSurveyHelper.updateCaseCSATFields(trigger.oldMap, trigger.new);
    }
}