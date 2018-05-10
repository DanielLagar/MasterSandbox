trigger CaseCommentCodeTrigger on Case_Comment_Code__c (before delete, after insert, after update) {

    if(checkRecursive.triggerStatus('CaseCommentCodeTrigger__c')){
        //BEFORE
        if(Trigger.isBefore){
            if(Trigger.isDelete){
                sf_CaseCommentCodeTriggerHelper.checkCommentCodesBeforeDelete (Trigger.oldMap);
                sf_CaseCommentCodeTriggerHelper.preventDeleteSubmittedCaseComments(Trigger.oldMap);            
            }
        }

        if(Trigger.isAfter){
            if(Trigger.isInsert){
				if(checkRecursive.cccTriggerRunMe){
                    checkRecursive.cccTriggerRunMe = false;
                    getProductReturnACR.getCCCACRs(Trigger.newMap);
                }
            }
        }
    }
}