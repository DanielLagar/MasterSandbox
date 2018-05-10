public with sharing class sf_CaseProductHelper {
    
    /**
    * @author: Chris Southworth
    * @date: 05/08/2014
    * @param: oldProductMap: Map of Case_Products__c before update or delete
    * @param: newProductMap: Map of updated Case_Products after update, NULL if part of delete trigger
    * @description: Prevent all users except System Admin from modifying/deleting Case_Products__c once 
    *   the Status__c has been changed to 'Received'
    */
	public static void preventModifyAndDeleteCaseProduct(Map<Id, Case_Product__c> oldProductMap, Map<Id, Case_Product__c> newProductMap){
	/* Note the below can be called by the Automated Process user via MAC/ACR, which has no profile
	 * This is why the boolean/try-catch is used */
		boolean canEdit = true;
		try{
			String profileName = [SELECT Id, Name FROM Profile WHERE Id =:UserInfo.getProfileId()].Name;
			if(profileName != 'System Administor'){
				canEdit = false;
			}            
		}
		catch(queryException e){
			system.debug('>>> error on querying current user profile: '+e);
		}
        
        if(!canEdit){
            String error = Label.CaseProduct_PreventModifyOrDelete;
            for(Case_Product__c cp : oldProductMap.values()){
                if(cp.Status__c == 'Received'){
                    if(newProductMap != NULL){
                        newProductMap.get(cp.Id).addError(error);
                    }
                    else{
                        cp.addError(error);
                    }                   
                }
            }
        }
	}
    
   /**
    * @author: Chris Southworth
    * @date: 09/23/2014
    * @param: cpMap: Map of updated Case_Products before delete
    * @description: prevent all users from deleting Case Products after the case has been submitted when the
    *   case comment code is of type AE or PQC.
    *   Users can use the Product/Comment tab in the console to 'soft' delete the case products.
    */
    public static void preventDeleteSubmittedCaseProducts(Map<Id, Case_Product__c> cpMap){
        Set<Id> submittedCpSet = new Set<Id>();
        Set<Id> caseIds = new Set<Id>();
        for(Case_Product__c cp : cpMap.values()){
            caseIds.add(cp.Case__c);
        }
        
        Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Id, CCM_Initial_Pull__c FROM Case WHERE Id IN :caseIds AND CCM_Initial_Pull__c != null]);
        if(caseMap.size() > 0){
            for(Case_Product__c cp : cpMap.values()){
                if(caseMap.containsKey(cp.Case__c)){
                    submittedCpSet.add(cp.Id);
                }
            }
            //System.debug('**Case Product Ids: ' + submittedCpSet);
            if(submittedCpSet.size() > 0){
                List<Case_Comment_Code__c> cccList = [SELECT Id, Case_Product__c, Is_Deletable__c FROM Case_Comment_Code__c 
                                                    WHERE Case_Product__c IN :submittedCpSet AND Is_Deletable__c = false];
                                                    
                if(cccList.size() > 0){
                    Set<Id> cpIds = new Set<Id>();
                    for(Case_Comment_Code__c ccc : cccList){
                        cpIds.add(ccc.Case_Product__c);
                    }
                    if(cpIds.size() > 0){
                        for(Case_Product__c cp : cpMap.values()){
                            if(cpIds.contains(cp.Id)){
                                 cpMap.get(cp.Id).addError(Label.CaseProduct_PreventDeleteForCCCAEorPQC);
                            }
                        }
                    }
                }
            }
        }
    }
}