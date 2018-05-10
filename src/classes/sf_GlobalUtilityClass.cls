public class sf_GlobalUtilityClass {
	public static List<String> getSystemEmailAddress()
    {
        List<String> toAddresses=new List<String>();
        List<System_Email_Address__c> mcs = System_Email_Address__c.getall().values();
        for(System_Email_Address__c s:mcs)
        toAddresses.add(s.Name);
        
        return toAddresses;
    }
    
    public static final Schema.Describesobjectresult taskSObjectResult = Task.SObjectType.getDescribe();
     /**
    * RECORD TYPE ID 
    */
    
   public static final  Id TASK_INTERNAL_ACTIVITY_RT_ID = ( taskSObjectResult != null 
   		&& taskSObjectResult.getRecordTypeInfosByName() != null 
   		&& taskSObjectResult.getRecordTypeInfosByName().get('Internal Activity') != null)?
   		taskSObjectResult.getRecordTypeInfosByName().get('Internal Activity').getRecordTypeId():null;
    
   public static final  Id TASK_CONSUMER_ACTIVITY_RT_ID = ( taskSObjectResult != null 
   		&& taskSObjectResult.getRecordTypeInfosByName() != null 
   		&& taskSObjectResult.getRecordTypeInfosByName().get('Consumer Activity') != null)?
   		taskSObjectResult.getRecordTypeInfosByName().get('Consumer Activity').getRecordTypeId():null;
    
    /*
     * @author: Christopher.macduff@accenture.com
     * @Date: 9th Mar 2016
     * @WR: 158
     * @Description: Creates/Caches Map of Org Wide Email Addresses
     */   
    public static map<String,OrgWideEmailAddress> orgEmailMap{
        get{
            if(orgEmailMap == null){
				orgEmailMap = new Map<String, OrgWideEmailAddress>();
                List<OrgWideEmailAddress> oweList = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress];
                For(OrgWideEmailAddress o : oweList){
					orgEmailMap.put(o.Address, o);               
                }
            }
            return orgEmailMap;      
        }
        set;
    }
    
	/*
     * @author: Christopher.macduff@accenture.com
     * @Date: 9th Mar 2016
     * @Description: Creates/Caches Map of RecordTypes
     * SOQL based
     */
    public static map<String, Id> recordTypeMap{
        get{
            if(recordTypeMap == null){
				recordTypeMap = new Map<String, Id>();
                List<RecordType> rtList = [SELECT Id, DeveloperName FROM RecordType];
                For(RecordType rt : rtList){
					recordTypeMap.put(rt.DeveloperName, rt.Id);               
                }
            }
            return recordTypeMap;      
        }
        set;
    }    
    
}