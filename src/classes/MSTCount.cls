//Use this to run in Execute Anonymous -> Id BatchJobMSTCount = Database.executeBatch(new MSTCount(), 1);
/*
* @author: Accenture - CD
* @date: 22/06/2017
* @description:  Batch job to update the MST Count figures per record. Batch size of 1 Only.
*/
global class MSTCount implements Database.Batchable<sObject>{

    private static final Integer LIMIT_QUERY_ROW = Limits.getLimitQueryRows();
    private static final Date TODAY_MINUS_30 = date.Today()-30;
    private static final Date TODAY_MINUS_60 = date.Today()-60;
    private integer thirtyDayCount = 0;
    private integer sixtyDayCount = 0;

    //START
    global Database.QueryLocator start(Database.BatchableContext BC){
        //String str ='SELECT Id FROM Metadata_Survey_Trigger__c WHERE createdDate = LAST_MONTH';
        String str ='SELECT Id, Last_90_Day_Count__c FROM Metadata_Survey_Trigger__c WHERE lastModifiedDate = LAST_N_DAYS:90';
        return Database.getQueryLocator(str);
    }
    
    //Execute Small Queries
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Metadata_Survey_Trigger__c> mstList = (List<Metadata_Survey_Trigger__c>)scope;
        
        //instanciate set of ids
        set <Id> mstIds = new set <id>();

        //in For loop add mst.id to your set of ids
        for (Metadata_Survey_Trigger__c mst : mstList){
            
            mstIds.add(mst.Id);
        }
        system.debug('***CDOY*** Size'+ mstIds.size());
 
        List<MST_Action_Count__c> MAC = [SELECT id, Date_Triggered__c FROM MST_Action_Count__c WHERE Date_Triggered__c = LAST_N_DAYS:90 AND Metadata_Survey_Trigger__c IN :mstIds LIMIT :LIMIT_QUERY_ROW]; 
        
        for(MST_Action_Count__c m : MAC){

            if(m.Date_Triggered__c >= TODAY_MINUS_30){
                thirtyDayCount++;
                sixtyDayCount++;
            }

            else if (m.Date_Triggered__c >= TODAY_MINUS_60){
                sixtyDayCount++;
            }
        }

        mstList[0].Last_90_Day_Count__c = MAC.size();
        mstList[0].Last_60_Day_Count__c = sixtyDayCount;
        mstList[0].Last_30_Day_Count__c = thirtyDayCount;
        mstList[0].Trigger_Count_Last_Updated__c = DateTime.now();

        if(mstList[0].Last_90_Day_Count__c != null){
         Database.SaveResult[] results = Database.Update(mstList, false); //update last modified date
        }
        
    } 

    //Finish
	global void finish(Database.BatchableContext BC){
   	}

}