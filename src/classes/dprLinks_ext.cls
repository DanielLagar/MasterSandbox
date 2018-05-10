public class dprLinks_ext {
    private Set <String> validCaseOrigins = new Set<String>{'Chat','Social Media'};
	public case currentCase {get;set;}//The Current Case
    public list<Case_Product__c> cps {
        get{
            if(cps==null){
                cps = new List<Case_Product__c>();
                cps = [SELECT Id, ACR_Info__c, ACR_Return_Type__c, 	Digital_Return_Id__c, Digital_Returns_Link__c, Case__r.Product_Return_Status__c, Local_Product__r.Consumer_Facing_Name__c
                       	FROM Case_Product__c
                      	WHERE Case__c = :currentCase.Id AND Digital_Return_Id__c != null AND Case__r.Origin IN :validCaseOrigins];
                        //WHERE Case__c = :currentCase.Id AND Digital_Return_Id__c != null AND Case__r.Origin != 'Phone'];
            }
            return cps;
        }
		set;
	}

    public dprLinks_ext(ApexPages.StandardController stdctr){
        currentCase = (case)stdctr.getRecord(); 
        currentCase = [SELECT Id, Origin, CaseNumber FROM Case WHERE Id = :currentCase.Id];
    }
}