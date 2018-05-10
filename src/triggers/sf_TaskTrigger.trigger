trigger sf_TaskTrigger on Task (after delete, after insert, after undelete, 
                                    after update, before delete, before insert, before update) {
	if(checkRecursive.triggerStatus('sf_TaskTrigger__c')){
        if (Trigger.isAfter && Trigger.isInsert) {
            sf_TaskHelper.updateCaseFields(Trigger.new, null);
        }    
        
        //ALM220
        //10-17-2014 - orikkers
        if (Trigger.isAfter && Trigger.isUpdate) {
            sf_TaskHelper.updateCaseFields(Trigger.new, Trigger.oldMap);
        } 
        
        if (Trigger.isBefore && Trigger.isDelete) {
            sf_TaskHelper.checkTaskBeforeDelete (trigger.old);
        }                                            
	}
}