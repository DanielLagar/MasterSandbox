trigger ContactTrigger on Contact (before insert, before update, after update) {
    if(checkRecursive.triggerStatus('ContactTrigger__c')){
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                sf_ContactHelper.contactAddressValidation(Trigger.new); //WR120
                sf_ContactAddressTriggerHelper.processNewContacts(Trigger.new);
                sf_RepeaterHelper.syncNewContactFromAccount(trigger.new);
                
            } else if (Trigger.isUpdate) {
               sf_ContactHelper.contactAddressValidation(Trigger.new); //WR120
               sf_ContactAddressTriggerHelper.processExistingContacts (Trigger.oldMap, Trigger.newMap);
               sf_RepeaterHelper.syncExistingContactFromAccount(trigger.oldMap, trigger.newMap);
           }
        }
    
        if(Trigger.isAfter){
            if(Trigger.isUpdate){
                sf_ContactHelper.flagCasesForBouncedContactEmails(Trigger.oldMap, Trigger.newMap);
                sf_RepeaterHelper.syncContactToAccount(trigger.oldMap, trigger.newMap);
                //sf_ContactHelper.updateCaseField(Trigger.newMap); // deprecated
            }
        }        
    }
}