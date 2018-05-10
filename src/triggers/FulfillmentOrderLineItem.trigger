trigger FulfillmentOrderLineItem on Fulfillment_Order_Line_Item__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    if(checkRecursive.triggerStatus('FulfillmentOrderLineItem__c')){
        if(trigger.isBefore){
            if(trigger.isUpdate){
                
            } else if(trigger.isInsert){
                            
            } else if(trigger.isDelete){
                //sf_FulfillmentUtility.CheckFulfillmentOrderLock(trigger.oldMap, NULL);
            }
        } else if( trigger.isAfter){
            if(trigger.isUpdate){
                
            } else if(trigger.isInsert){
                
            } else if(trigger.isDelete){
            }
        }        
    }
}