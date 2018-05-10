//Test Class for TelephonyTrigger
//Sylvester Agyen (Appirio, Inc)

@isTest(SeeAllData=true)

private class TelephonyTrigger_Test{


 static testMethod void validateTelephony(){
  Test.startTest();
     
  Contact_Us_Brand__c brand = new Contact_Us_Brand__c(name='dfdfg',Brand__c='jibberish');
   insert brand;
  Call_Center_Inventory__c callCenter = new Call_Center_Inventory__c(Name='test', Call_Center_Location__c='test');
     insert callCenter;
  Telephony__c tel1 = new Telephony__c(telephony_name__c='testtel1', 
                                       Language__c='English-US', 
                                       Country__c='Andorra',
                                       GCR_Contact__c =Userinfo.getUserId(),
                                       ITFS_Number__c ='1111111111',
                                       LocalOperationalHours__c= 'test',
                                       ITFS_Status__c ='Active',
                                       Region__c = 'NA',
                                       localBrand__c ='test',
                                       Carrier__c = '1111111111',
                                       Call_Center__c = callCenter.id,
                                       Contact_Us_Brand__c=brand.id,
                                       Accept_Calls_from_Prepaid_Phone__c='Yes',
                                       Accept_Calls_from_Landline_Phone__c = 'Yes',
                                       Accept_Calls_from_Mobile__c = 'Yes',
                                       Country_Has_1_Phone_Number__c=false,
                                       Carrier_Contact_Information__c ='tst'
                                       );
              
  
  
  try{
    insert tel1;
  }catch(DMLException e){
      system.debug(e);
  }
  
  tel1.Country_Has_1_Phone_Number__c = true;
  tel1.Contact_Us_Brand__c = null;
  try{
    update tel1;
  }catch(DMLException e){
      system.debug(e);
  }
  sf_ContactUsHeaderComponentCtrl handr= new sf_ContactUsHeaderComponentCtrl();
  handr.setTelephony();
  Test.stopTest();
 }
}