trigger sf_InternalActivityTrigger on Internal_Activity__c (before update, after update, before insert, after insert) {

	sf_InternalActivityTriggerHandler internalActivityTriggerHandler = new sf_InternalActivityTriggerHandler();
	
	if (trigger.isBefore && trigger.isUpdate) {	
		internalActivityTriggerHandler.onBeforeUpdate(trigger.new, trigger.old, trigger.newMap, trigger.oldMap);
	}

	if(trigger.isAfter && trigger.isInsert){
		internalActivityTriggerHandler.onAfterInsert(trigger.new);
	}
}