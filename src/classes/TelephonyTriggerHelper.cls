public  class TelephonyTriggerHelper {

    
   
    //handle when multiple telephonies exist and new one gets created with same country and
    //Country has 1 phone number set to true.
    //Results -- Block new entry
    public static void validateExistingRecords(List<Telephony__c> newTelephony,Map<Id,Telephony__c> oldMap){ 
        List<Telephony__c> results = [select id, Country_Has_1_Phone_Number__c ,Country__c, ITFS_Status__c from Telephony__c where ITFS_Status__c = 'Active' limit 50000];
        
        system.debug('@@@results: ' + results);
        
        Map<String, Telephony__c> countryDup = new Map<String, Telephony__c>(); 
        Map<String, Telephony__c> countryHasTrue = new Map<String, Telephony__c>(); 
      
        if(results.size() > 0){
            for(Telephony__c tel : results){
               countryDup.put(tel.Country__c,tel);
                if(tel.Country_Has_1_Phone_Number__c == true){
                    countryHasTrue.put(tel.Country__c,tel);
                }
            }
        }
        
        //inserting
        if(oldMap == null){
            for(Telephony__c tel : newTelephony){
                //check old records that have Country_Has_1_Phone_Number__c =true
                //check this one has Country_Has_1_Phone_Number__c = true and other records use same country
                
                system.debug('@@@countryDup.containsKey(tel.Country__c): ' + countryDup.containsKey(tel.Country__c));
                system.debug('@@@countryHasTrue.containsKey(tel.Country__c)): ' + countryHasTrue.containsKey(tel.Country__c));
                system.debug('@@@tel.Country_Has_1_Phone_Number__c: ' + tel.Country_Has_1_Phone_Number__c);
                system.debug('@@@countryDup.containsKey(tel.Country__c): ' + countryDup.containsKey(tel.Country__c));
                
                if(((countryDup.containsKey(tel.Country__c) && countryHasTrue.containsKey(tel.Country__c)) && tel.ITFS_Status__c == 'Active') || ((tel.Country_Has_1_Phone_Number__c == true && countryDup.containsKey(tel.Country__c) ) && tel.ITFS_Status__c == 'Active') ){ 
                    newTelephony[0].addError('Error: Country, '+newTelephony[0].Country__c + ' has been marked to have 1 telephony for all brands. Duplicate active records are not allowed.');
                }
            }
        }
        else if(oldMap != null){
           for(Telephony__c tel : newTelephony){
              if(countryDup.size() > 0 && newTelephony[0].Country_Has_1_Phone_Number__c == true && oldMap.get(newTelephony[0].id).Country_Has_1_Phone_Number__c == false && countryDup.get(tel.Country__c).id != newTelephony[0].id && tel.ITFS_Status__c == 'Active'){ 
                newTelephony[0].addError('Error: Country, '+newTelephony[0].Country__c + ' has been marked to have 1 telephony for all brands. Duplicates active records not allowed.');
              }
           }
        }
              
    }


}