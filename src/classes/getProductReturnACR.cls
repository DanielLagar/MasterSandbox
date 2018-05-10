/*
 * Want to set ACR.Id and ACR.ReturnType on CaseProduct
*/
public class getProductReturnACR {
    public static final String NO_MATCH = 'No Match';
    
    public static void getCCCACRs(map<id, Case_Comment_Code__c>cccMap){
        Set<Id> cccsToQuery = new Set<Id>();//CaseCommentCode Ids to process
        List<Case_Comment_Code__c> cccProcessList = new List<Case_Comment_Code__c>();
        Map<Id, Case_Product__c> cpMap = new Map<Id, Case_Product__c>(); //Want ACR info on the CP - issue with using Set is CCs can hit different ACRs so won't appear identical. 
        List<Case_Product__c> cpsToUpdate = new List<Case_Product__c>();
        
		//Only process thoughs without an ACR already
        for(Case_Comment_Code__c ccc : cccMap.values()){
            if(String.isBlank(ccc.ACR_Info__c)){
                cccsToQuery.add(ccc.Id);
            }
        }  
        
        if(!cccsToQuery.isEmpty()){
            //Will have to query to get Case and Case Product info to use
            cccProcessList = [SELECT Id, ACR_Info__c, Contact_Has_Address__c, Case_Product__r.Product_available_for_return__c, Case_Product__r.Status__c, Case_Product__r.ACR_Info__c,
                                Status__c, GCR_CID__c, Case_Contact_Id__c, Case__c, Case_Product__c, Global_Product_Segment__c, Product_Postal_Restriction__c,
                                Global_Comment_Path__c, Global_Product_Path__c, Product_Brand__c, Local_Comment_Code__r.Global_Comment_Code__r.Full_Comment_Path__c,
                                Case__r.Country__c, Case__r.Language__c, Name
                                FROM Case_Comment_Code__c
                                WHERE Id In :cccsToQuery];
            
			//Create Search Keys
            Set<String> caseSearchKeys = new Set<String>(); //Stores Case search Keys
            for(Case_Comment_Code__c ccc :cccProcessList){
                String caseSearchPathKey = ccc.Case__r.Country__c+':'+ccc.Case__r.Language__c+':'+ccc.Global_Product_Path__c+':'+ccc.Local_Comment_Code__r.Global_Comment_Code__r.Full_Comment_Path__c;
                String caseSearchSegmentKey = ccc.Case__r.Country__c+':'+ccc.Case__r.Language__c+':'+ccc.Global_Product_Segment__c+':'+ccc.Local_Comment_Code__r.Global_Comment_Code__r.Full_Comment_Path__c;
                caseSearchKeys.add(caseSearchPathKey);
                caseSearchKeys.add(caseSearchSegmentKey);
            }

			//Now find ACR
            Map<String, Auto_Communication_Rule__c> ACRMap = new Map<String, Auto_Communication_Rule__c>();
            if(caseSearchKeys.size() > 0 ){
                system.debug(logginglevel.WARN,'>>> Finding ACRs');
                
                //Don't need all the ACR fields here
                for(Auto_Communication_Rule__c acr :  [SELECT Id, Name, Product_Search_Key__c, Supported_Return_Type__c
                                                        FROM Auto_Communication_Rule__c
                                                        WHERE Product_Search_Key__c IN :caseSearchKeys
                                                        AND Type__c = :trg_AutoComRuleHelper.ACR_TYPE_PRODUCT_RETURN]){
                        
                    ACRMap.put(acr.Product_Search_Key__c, acr);
                } 
            }
			    
            //Now match up and updated CC/CP if required
            for(Case_Comment_Code__c ccc :cccProcessList){
                system.debug(logginglevel.WARN,'>>> Matching found ACRs to CCC');
                String caseSearchPathKey = ccc.Case__r.Country__c+':'+ccc.Case__r.Language__c+':'+ccc.Global_Product_Path__c+':'+ccc.Local_Comment_Code__r.Global_Comment_Code__r.Full_Comment_Path__c; //Country+':'+Language+':'+Global_Product_Path__c+':'+Local_Comment_Code__r.Global_Comment_Code__r.Full_Comment_Path__c
                String caseSearchSegmentKey = ccc.Case__r.Country__c+':'+ccc.Case__r.Language__c+':'+ccc.Global_Product_Segment__c+':'+ccc.Local_Comment_Code__r.Global_Comment_Code__r.Full_Comment_Path__c;//Country+':'+Language+':'+Global_Product_Segment__c+':'+Local_Comment_Code__r.Global_Comment_Code__r.Full_Comment_Path__c
                
                Auto_Communication_Rule__c matchedACR = new Auto_Communication_Rule__c();
                
                //Look for segment match first
                if(ACRMap.containsKey(caseSearchSegmentKey)){
					System.debug(logginglevel.WARN,'>>> Match found on Product Segment');
                    matchedACR = ACRMap.get(caseSearchSegmentKey);
                    ccc.ACR_Info__c = matchedACR.Name;
                    
                }
                else if(ACRMap.containsKey(caseSearchPathKey)){
					System.debug(logginglevel.WARN,'>>> Match found on Product Path');
                    matchedACR = ACRMap.get(caseSearchPathKey);
                    ccc.ACR_Info__c = matchedACR.Name;
                }
                //If no match set ACR_Info__c to no match to prevent searching for a match again in the future. Prevent an old case hitting a new acr
                else{
                    ccc.ACR_Info__c = NO_MATCH;
                }

                //Now check to see if parent CP needs updating
                if(String.isBlank(ccc.Case_Product__r.ACR_Info__c) || ccc.Case_Product__r.ACR_Info__c == NO_MATCH){
                    
                    Case_Product__c cp = new Case_Product__c(id = ccc.Case_Product__c);
					//If Supported_Return_Type__c is null assume physical:
					cp.ACR_Info__c = matchedACR.Name;
					cp.ACR_Return_Type__c = String.isBlank(matchedACR.Supported_Return_Type__c) ? 'Physical' : matchedACR.Supported_Return_Type__c;
                    cp.Digital_Return_Id__c = setDigitalReturnId(cp.Id);
					//Note: Last element added to a map with the same key overrides the previous value. We want to keep the first.
                    if(cpMap.get(cp.Id)==null){
						cpMap.put(cp.Id, cp);
                    }
                    system.debug(logginglevel.WARN,'!!!!!!!!!!!!!!!! Updating CaseProduct: '+cp);
                }
                try{
                    update cccProcessList;
                    cpsToUpdate = new List<Case_Product__c>(cpMap.values());
                    update cpsToUpdate;
                }
                catch(exception e){
                    System.enqueueJob(new exceptionHelperQueable(e,'Error updating CCCs: '+String.ValueOf(cccProcessList)));
                }
            }
        }//isemtpy end
        
    }//method end
    
     /********************************************
     * Sets unique hashed Id that will be used  *
     * In the form url sent to consumer         *
     *******************************************/
    
    public static String setDigitalReturnId(Id cpId) {
        String hashedCPID = '';
        Blob b = Crypto.generateDigest('SHA-256', Blob.valueOf(cpId));
        hashedCPID = EncodingUtil.convertToHex(b);
        return hashedCPID;
    }
}//class end