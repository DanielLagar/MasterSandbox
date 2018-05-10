trigger SafetyAssessmentSurvey on Safety_Assessment_Survey__c (after insert, after update) {
	if(checkRecursive.triggerStatus('SafetyAssessmentSurvey__c')){
        //After insert
        if(Trigger.isAfter && Trigger.isInsert){
            SafetyAssessmentSurveyHelper.UpdateCaseToMatchSAS(Trigger.newMap);
        }
    
        //After update
        if(Trigger.isAfter && Trigger.isUpdate){
            SafetyAssessmentSurveyHelper.UpdateCaseToMatchSAS(Trigger.newMap);
        }        
    }
}