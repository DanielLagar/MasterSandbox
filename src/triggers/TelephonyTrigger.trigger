//Validates Telephony entries to avoid duplicates
//Sylvester Agyen (Appirio, Inc)


trigger TelephonyTrigger on Telephony__c (before insert, before update) {
    if(Trigger.isBefore && Trigger.isInsert){
       TelephonyTriggerHelper.validateExistingRecords(Trigger.New,null);
    }
  
    if(Trigger.isBefore && Trigger.isUpdate){
        TelephonyTriggerHelper.validateExistingRecords(Trigger.New,Trigger.oldMap);
    
    }
   
}