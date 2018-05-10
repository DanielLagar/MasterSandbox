trigger FulfillmentOrder on Fulfillment_Order__c ( after update, before delete, before update, before insert) {
    if(checkRecursive.triggerStatus('FulfillmentOrder__c')){
        if(trigger.isBefore){
            if(trigger.isUpdate){
                sf_FulfillmentUtility.PopulateMidnightLocalTime(NULL, trigger.newMap);
                sf_fulfillmentUtility.SetCorrectMonetaryThreshold(trigger.new); //CDOY WR266
            } else if(trigger.isDelete){
                //FIXME - turns out this wasn't needed. This trigger may not be needed
                //sf_FulfillmentUtility.checkLockBeforeDelete(trigger.oldMap, NULL);    
                sf_FulfillmentUtility.PopulateMidnightLocalTime(trigger.oldMap, NULL);  
            }
 
        }
        if(trigger.isAfter && trigger.isUpdate) {
            sf_RepeaterHelper.clearCasesFromClearedOrders(trigger.oldMap, trigger.newMap);
        }        
    }
}