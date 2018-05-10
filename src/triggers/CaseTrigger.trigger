trigger CaseTrigger on Case (after insert, before insert, before update, after update) {
    if(checkRecursive.triggerStatus('CaseTrigger__c')){
        //AFTER INSERT
        if (trigger.isAfter && trigger.isInsert) {
            //US721 Activity: Logging Followup Calls
            sf_CaseHelper.createInternalActivitiesForNewCases (trigger.newMap);
            //Prevent sf_taskHelper updating Case if new Case
            checkRecursive.newCase = True;
        }
    
        //BEFORE INSERT
        if(trigger.isBefore && trigger.isInsert) {
            sf_CaseHelper.updateRegionSMO(trigger.new, null);
            sf_CaseHelper.setCaseContactCenter(trigger.new, null);
            sf_FulfillmentUtility.getPrefixTitle(trigger.new, null, trigger.isInsert, trigger.isUpdate);
            sf_CaseHelper.UpdateChatbotTranscript(trigger.new, null); //CDOY Added as part of WR505 Chatbot
        }
    
        //BEFORE UPDATE
        if (trigger.isBefore && trigger.isUpdate) {
            sf_CaseClosedTriggerHelper.processCases (trigger.newMap, trigger.oldMap);
            //sf_CaseHelper.preventCloseForMissingContactAndAddress(Trigger.newMap, Trigger.oldMap); //WR120 defunct?
            sf_RepeaterHelper.checkCaseRepeaterStatus(trigger.oldMap, trigger.newMap);
    
            sf_CaseHelper.triggerCaseAssignmentRulesForReassignedCases(trigger.newMap); //1
            sf_CaseHelper.setCaseRecordType(trigger.new, trigger.oldMap); //2
            sf_CaseHelper.updateRegionSMO(trigger.new, trigger.oldMap);//3
            
            sf_CaseHelper.setCaseContactCenter(trigger.new, trigger.oldMap);
            sf_FulfillmentUtility.getPrefixTitle(trigger.new, trigger.oldMap, trigger.isInsert, trigger.isUpdate);
        }
        
        //AFTER UPDATE
        if(trigger.isAfter && trigger.isUpdate) {
            sf_RepeaterHelper.updateFulfillmentOrders(trigger.oldMap, trigger.newMap);

            //No more MAC \o/
            if(checkRecursive.ACREnabled){
                trg_AutoComRuleHelper.getACRs(trigger.oldMap, trigger.newMap);//Still dependent on time based workflow rules
            } 
    
            List <Case> casesClosed = new List <Case> ();
            for (Case c: trigger.new) {
                if (c.IsClosed != trigger.oldMap.get(c.Id).IsClosed && c.isClosed) {
                    casesClosed.add(c);
                }
            }
    
            sf_CSATSurveyHelper.createCSATForClosedCases (casesClosed);
            sf_CaseHelperWithoutSharing.CreateTransferActivityForCase(trigger.New, trigger.OldMap);
            sf_CaseHelper.UpdateSASBasedOnCase(trigger.newMap);
            sf_CaseHelper.updateCPBasedonCase(trigger.new, trigger.oldmap); //WR249
            caseContactHelper.setPrimaryCaseContact(trigger.oldMap, trigger.newMap);//CR47
        }       
    }
}