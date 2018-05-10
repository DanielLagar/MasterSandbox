trigger sf_encodeSiteId on PIISitespageSettings__c (after insert) {
 
  if (Trigger.isAfter && Trigger.isInsert) {
     sf_PIISitesPageSettingsTriggerHelper.encodeSiteId(trigger.new);
  }
}