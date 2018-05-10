trigger caseContactTrigger on Case_Contact__c (after insert, after update) {
        
    if(checkRecursive.triggerStatus('CaseContactTrigger__c')){
        if(Trigger.isBefore && Trigger.isInsert){

        }
        if(Trigger.isBefore && Trigger.isUpdate){

        }
        if(Trigger.isAfter && Trigger.isInsert){
            if(checkRecursive.doNotByPass){
                caseContactHelper.singlePrimaryCheck(trigger.new);  
            }             
        }
        if(Trigger.isAfter && Trigger.isUpdate){
            caseContactHelper.singlePrimaryCheck(trigger.new);
        }            
	}
}