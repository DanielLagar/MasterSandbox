/*
* @author: Oleg Rikkers
* @date: 06/02/2014

* @description: 
* DE412
* Name:Removing the Comment Code association does not disassociate the product

* Description:
	Create a case
	Add a product and comment code which triggers an SAS
	Add another of the same product and same comment code
	Click Associate on the popup
	See that the product is associated on the Required Info page
	Now go back and remove the Comment Code from one of the products
	Notice 2 products are still associated on the Required Info page
 	
 	Cas: Spoke with P&G, they would like to prevent the deletion of products/comment codes associated to the a survey with the error message, "The Comment Code has linked surveys and cannot be deleted."

	Chris:
	Also prevent delete of Case Comment Codes when there are associated Fulfillment Orders
*/ 


public with sharing class sf_CaseCommentCodeTriggerHelper {
	/**
	* @description prevents the delete of comment codes if they are related to a Survey or Fulfillment Order.
	*/
	public static void checkCommentCodesBeforeDelete (Map <Id, Case_Comment_Code__c> triggerOldMap) {
		
		//Map <Id, List <Id>> cpToCccMap = new Map <Id, List <Id>> ();

		//for (Case_Comment_Code__c ccc: triggerOldMap.values()) {
		//	if (cpToCccMap.get(ccc.Case_Product__c) == null) {
		//		cpToCccMap.put (ccc.Case_Product__c, new List <Id> {ccc.Id});
		//	} else {
		//		cpToCccMap.get(ccc.Case_Product__c).add (ccc.Id);
		//	}
		//}

		Set <Id> cccSet = new Set <Id> ();

		for (Survey_Comment_Product__c scp: [SELECT Id, Case_Product__c, Case_Comment_Code__c 
											FROM Survey_Comment_Product__c 
											WHERE Case_Comment_Code__c IN :triggerOldMap.keySet()]) {
			//if (cpToCccMap.get(scp.Case_Product__c) != null) {
			//	for (Id cccId: cpToCccMap.get(scp.Case_Product__c)) {
			//		triggerOldMap.get(cccId).addError(Label.CommentCodeCannotBeDeleted);
			//	}
			//}


			//orikkers 10-13-14 only disallow deletion of comment codes associated to scp
			if (triggerOldMap.get(scp.Case_Comment_Code__c) != null)
				triggerOldMap.get(scp.Case_Comment_Code__c).addError(Label.CommentCodeCannotBeDeleted);
		}
		
		//Prevent delete of Case Comment Codes when there are associated Fulfillment Orders
		for(Fulfillment_Order__c ffo : [SELECT Id, Case_Comment_Code__c FROM Fulfillment_Order__c WHERE Case_Comment_Code__c IN :triggerOldMap.keySet()]){
			triggerOldMap.get(ffo.Case_Comment_Code__c).addError(Label.CommentCodeCannotBeDeletedFulfillmentOrders);
		}
	}
	
   /**
	* @author: Chris Southworth
	* @date: 09/23/2014
	* @param: oldMap: Map of Case Comment Codes before delete
	* @description: prevent all users from deleting Case Comment Codes after the case has been submitted and the
	*	comment code is of type AE or PQC.
	*	Users can use the Product/Comment tab in the console to 'soft' delete the case comment codes.
	*/
	public static void preventDeleteSubmittedCaseComments(Map<Id, Case_Comment_Code__c> oldMap){
		Set<Id> caseIds = new Set<Id>();
		for(Case_Comment_Code__c ccc : oldMap.values()){
			if(ccc.Is_Deletable__c == false){
				caseIds.add(ccc.Case__c);
			}
		}
		if(caseIds.size() > 0){
			Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Id FROM Case WHERE Id IN :caseIds AND CCM_Initial_Pull__c != null]);
			for(Case_Comment_Code__c ccc : oldMap.values()){
				if(caseMap.containsKey(ccc.Case__c)){
					oldMap.get(ccc.Id).addError(Label.CaseCommentCode_PreventDeleteForAEorPQC);
				}
			}
		}
	}
}