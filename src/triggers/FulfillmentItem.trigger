trigger FulfillmentItem on Fulfillment_Item__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
	if(trigger.isBefore){
		if(trigger.isUpdate){
			sf_FulfillmentUtility.FulfillmentItemValidation(trigger.new);	
		} else if(trigger.isInsert){
			sf_FulfillmentUtility.FulfillmentItemValidation(trigger.new);	
		} else if(trigger.isDelete){
		}
	} else if( trigger.isAfter){
		if(trigger.isUpdate){
			
		} else if(trigger.isInsert){
			
		} else if(trigger.isDelete){
		}
	}
}