public Class checkRecursive{
	/************************************************************************************************************
	* This set is used with trg_AutoComRuleHelper to prevent the same Case record being processed twice in the	*
	* same transaction. Using a static boolean is less reliable if used with time-based workflow:				*
	* https://help.salesforce.com/apex/HTViewHelpDoc?id=workflow_time_action_considerations.htm&language=en		*
	************************************************************************************************************/

	@testVisible //Need this so test class can reset it - test.start does not reset these
    public static set<Id> ACRprocessedIds = new Set<Id>();
    
    //Is it a Case Insert transaction?
    @testVisible 
    public static Boolean newCase = false;
    
    //CaseCommentTrigger has already fired?
    public static Boolean cccTriggerRunMe = true;

    //Allow bypass of multiple primary Case Contacts on insert - allows primary changing
    //sf_ContactInfoController will then update the records correctly
    //True = validate 
    public static Boolean doNotByPass = True;
    
	/************************************************************************
    * Allows other methods to deactivate ACR for the current transaction	*
    * E.g. Prevent ACR on historical Case update in ContactInfoController	*
    ************************************************************************/  
    
	@testVisible 
    public static Boolean ACREnabled = true;
    
    /********************************************************************
    * Utility method used to return if trigger is enabled or disabled	*
    * If no custom setting record found will default to true			*
    ********************************************************************/
    public static Boolean triggerStatus(String triggerName){
		Boolean triggerStatus = true; //default to true, doesn't break existing code/test methods
		TriggerToggle__c t = TriggerToggle__c.getInstance();
		if (t.get(triggerName) != null) {
			triggerStatus = (boolean)t.get(triggerName);
		}
		return triggerStatus;
	}
  
	/********************************************************************
    * Finds all checkbox fields and toggles according to passed			*
    * Boolean value														*
    * NOTE: Currently turns all on/off regardless of previous value		*
    ********************************************************************/
    @TestVisible
    public static void toggleAllTriggers(Boolean toggle){
        TriggerToggle__c triggerToggle = TriggerToggle__c.getInstance();		
        List<Schema.SObjectType> objects = new List<Schema.SObjectType>{TriggerToggle__c.SObjectType};
        for(Schema.SObjectType objType: objects){
            for(Schema.SObjectField fld: objType.getDescribe().fields.getMap().values()){
                if(fld.getDescribe().getType() == Schema.DisplayType.BOOLEAN && fld.getDescribe().getName().right(3) == '__c'){
                    triggerToggle.put(fld.getDescribe().getName(),toggle);
                }
            }
        }	
        upsert triggerToggle;   
    }
}