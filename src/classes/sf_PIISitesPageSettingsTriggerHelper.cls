public with sharing class sf_PIISitesPageSettingsTriggerHelper {

public static void encodeSiteId(List<PIISitesPageSettings__c> piiSettings) {
   Blob blobRecId;
   string encodedRecId;
   List<PIISitespageSettings__c> objs = [select Id, Name from PIISitespageSettings__c where Id in: piiSettings];
   For(PIISitespageSettings__c obj : objs){
      blobRecId = Blob.valueOf(obj.Id);   
      encodedRecId = EncodingUtil.base64Encode(blobRecId);
      obj.Site_Id__c = encodedRecId;
   }
   update objs;
}
}