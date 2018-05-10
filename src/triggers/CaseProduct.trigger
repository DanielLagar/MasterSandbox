trigger CaseProduct on Case_Product__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	if(trigger.isBefore){
		if(trigger.isUpdate){
			sf_CaseProductHelper.preventModifyAndDeleteCaseProduct(trigger.oldMap, trigger.newMap);
		} else if(trigger.isInsert){
			
		} else if(trigger.isDelete){
			sf_CaseProductHelper.preventModifyAndDeleteCaseProduct(trigger.oldMap, NULL);
			sf_CaseProductHelper.preventDeleteSubmittedCaseProducts(trigger.oldMap);			
		}
	} else if( trigger.isAfter){
		if(trigger.isUpdate){
			
		} else if(trigger.isInsert){
			
		} else if(trigger.isDelete){
		}
	}
}