/*
* @author:       Accenture
* @date:         09/08/2016
* @description:  Trigger for care hub channel validations
*/
trigger ChannelContentTrigger on GCRChannelContent__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
			ChannelContentTriggerHelper.validateChannel(Trigger.new, Trigger.newMap);
        } else if (Trigger.isUpdate) {
			ChannelContentTriggerHelper.validateChannel(Trigger.new, Trigger.newMap);
        }
    }
}