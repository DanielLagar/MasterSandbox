trigger AccountTrigger on Account (after update) {
    if(checkRecursive.triggerStatus('AccountTrigger__c')){
        if(Trigger.isAfter){
            if(Trigger.isUpdate){
                sf_RepeaterHelper.syncAccountToContacts(trigger.oldMap, trigger.newMap);
            }
        }       
    }
}