/*
* @author:       Accenture
* @date:         09/08/2016
* @description:  Trigger helper for care hub channels validations
*/
public class ChannelContentTriggerHelper {
    public static void validateChannel(List<GCRChannelContent__c> lTriggerNew, Map<Id, GCRChannelContent__c> mTriggerNew) {
        Set<String> sRecordTypeId = null;
        Set<String> sDisplayOrder = null;
        Map<String, Set<String>> mExistingRecTypeByCareHub = new Map<String, Set<String>>();
        Map<String, Set<String>> mExistingOrderByCareHub = new Map<String, Set<String>>();
        Map<String, Boolean> mIsDefaultByCareHub = new Map<String, Boolean>();
    
        for (GCRChannelContent__c eachChannelContent :lTriggerNew) {
            mExistingRecTypeByCareHub.put(eachChannelContent.CareHub__c, null);
        }
        for (GCRCareHub__c eachCareHub :[ SELECT Id
                                               , (SELECT Id
                                                  	   , RecordTypeId
                                                  	   , DisplayOrder__c
                                                  	   , Default__c
                                                  	   , isActive__c
                                                  FROM GCRChannelContent__r)
                                          FROM GCRCareHub__c
                                          WHERE Id IN :mExistingRecTypeByCareHub.keySet() ]) {
			sRecordTypeId = new Set<String>();
            sDisplayOrder = new Set<String>();
            for(GCRChannelContent__c eachChannelContent :eachCareHub.GCRChannelContent__r) {
                if (mTriggerNew != null && !mTriggerNew.isEmpty()) {
                    // RECORD UPDATE
                    if (!mTriggerNew.keySet().contains(eachChannelContent.Id)) {
                        sRecordTypeId.add(eachChannelContent.RecordTypeId);
                        if (eachChannelContent.isActive__c) {
                            sDisplayOrder.add(String.valueOf(eachChannelContent.DisplayOrder__c));
                            if(eachChannelContent.Default__c) {
                                mIsDefaultByCareHub.put(eachCareHub.Id, eachChannelContent.Default__c);
                            }
                        }
                    }
                } else {
                    // RECORD INSERT
                    sRecordTypeId.add(eachChannelContent.RecordTypeId);
                    if (eachChannelContent.isActive__c) {
                        sDisplayOrder.add(String.valueOf(eachChannelContent.DisplayOrder__c));
                        if(eachChannelContent.Default__c) {
                            mIsDefaultByCareHub.put(eachCareHub.Id, eachChannelContent.Default__c);
                        }
                    }
                }
            }
            mExistingRecTypeByCareHub.put(eachCareHub.Id, sRecordTypeId);
            mExistingOrderByCareHub.put(eachCareHub.Id, sDisplayOrder);
			if (mIsDefaultByCareHub.get(eachCareHub.Id) == null) {
				mIsDefaultByCareHub.put(eachCareHub.Id, false);
			}
        }
        SYSTEM.DEBUG('mExistingRecTypeByCareHub : ' + mExistingRecTypeByCareHub);
        SYSTEM.DEBUG('mExistingOrderByCareHub : ' + mExistingRecTypeByCareHub);
        SYSTEM.DEBUG('mIsDefaultByCareHub : ' + mExistingRecTypeByCareHub);
        for (GCRChannelContent__c eachChannelContent :lTriggerNew) {
            if(mExistingRecTypeByCareHub != null 
            && !mExistingRecTypeByCareHub.isEmpty() 
            && mExistingRecTypeByCareHub.get(eachChannelContent.CareHub__c) != null) {
                if(mExistingRecTypeByCareHub.get(eachChannelContent.CareHub__c).contains(eachChannelContent.recordTypeId)) {
                    eachChannelContent.addError(SYSTEM.LABEL.errMsgChannelExists);
                }
            }
            if(mExistingOrderByCareHub != null 
            && !mExistingOrderByCareHub.isEmpty() 
            && mExistingOrderByCareHub.get(eachChannelContent.CareHub__c) != null) {
                if(mExistingOrderByCareHub.get(eachChannelContent.CareHub__c).contains(String.valueOf(eachChannelContent.DisplayOrder__c))) {
                    eachChannelContent.addError(SYSTEM.LABEL.errMsgDisplayOrderExists);
                }
            }
            if(mIsDefaultByCareHub != null 
            && !mIsDefaultByCareHub.isEmpty() 
            && mIsDefaultByCareHub.get(eachChannelContent.CareHub__c) != null) {
                if(mIsDefaultByCareHub.get(eachChannelContent.CareHub__c) && eachChannelContent.Default__c) {
                    eachChannelContent.addError(SYSTEM.LABEL.errMsgSingleDefaultChannel);
                }
            }
        }
    }
}