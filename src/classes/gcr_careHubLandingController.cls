/*
* @author:       Accenture
* @date:         18/07/2016
* @description:  Controller class of Landing page of GCR care hub widget
* DATE					NAME					CHANGE DESCRIPTION
* 18/07/2016			Accenture				Initial Draft
* 22/02/2017			Accenture				WR467 - Added additional property to identify if there is a defult channel exists for care hub
*/
public class gcr_careHubLandingController {
    // HANDSHAKE VARIABLE INSTANCE TO PASS DATA IN GCR COMPONENTS
	public gcr_WidgetHandshake handshakeInstance { public get; public set; }
    // WR467 - ADDED NEW PROPERTY TO IDENDTIFY DEFAULT CHANNEL
    public Boolean isDefault { private set; public get; }
    public string strPageUrl { private set; public get; } //CDOY Added WR367
   /*
    * @date:		18/07/2016
    * @param:		none 
    * @return:		na
    * @description:	Constructor of Controller class
    */
    public gcr_careHubLandingController() {
        Set<String> sRtlLanguage = new Set<String>();
        handshakeInstance = new gcr_WidgetHandshake();
        String language = ApexPages.currentPage().getParameters().get('language');
        handshakeInstance.strKaUrlName = ApexPages.currentPage().getParameters().get('articleId');
        //CDOY ADDDED WR367
        // GET URL FROM PAGE PARAMETERS
        strPageUrl = ApexPages.currentPage().getParameters().get('pageUrl');

        if(GCRGenericProperties__c.getInstance('RTL_LANGUAGES') != null
        && String.isNotEmpty(GCRGenericProperties__c.getInstance('RTL_LANGUAGES').value__c)) {
            sRtlLanguage.addAll(GCRGenericProperties__c.getInstance('RTL_LANGUAGES').value__c.split(','));
        }
        if (sRtlLanguage.contains(language)) {
            handshakeInstance.isRightToLeft = true;
        } else {
            handshakeInstance.isRightToLeft = false;
        }
        // QUERY ALL FIELDS OF 'GCRCareHub' AND CHILD 'GCRChannelContent__c' OBEJCT FOR PASSED CONTRY, BRAND AND LANGUAGE RECORD
		String strQuery = gcr_helperClass.createQueryString('SELECT',
            gcr_helperClass.getAllFieldsForQuery('GCRCareHub__c') + ',(SELECT Id, RecordTypeId, Default__c FROM GCRChannelContent__r)'
			, 'GCRCareHub__c')
            + ' WHERE Brand__c = \'' + ApexPages.currentPage().getParameters().get('brand') + '\' AND'
            	+ ' CountryIsoCode__c = \''+ ApexPages.currentPage().getParameters().get('country') + '\'AND'
            	+ ' LanguageIsoCode__c = \'' + language + '\'';
        // ASSIGN QUERY RECORDS TO HANDSHAKE INSTANCE
        try {
        	handshakeInstance.lCareHub = Database.query(strQuery);
            // GET RECORDTYPE INFOS FOR CHANNEL CONTENT OBJECT AND MAP CHANNEL CONTENT MAP WITH APPROPRIATE CHANNEL OBJECT
            Map<Id, Schema.RecordTypeInfo> mRecordTypeInfo 
                = Schema.getGlobalDescribe().get('GCRChannelContent__c').getDescribe().getRecordTypeInfosById();
            if (handshakeInstance.lCareHub != null && !handshakeInstance.lCareHub.isEmpty()) {
                for (GCRChannelContent__c eachChannelContent :handshakeInstance.lCareHub.get(0).GCRChannelContent__r) {
                    handshakeInstance.mGcrContentId.put(mRecordTypeInfo.get(eachChannelContent.RecordTypeId).getName(), eachChannelContent.Id);
                    // WR467 - CHECK IF A DEFAULT CHANNEL AVAILABLE
                    if (eachChannelContent.Default__c) {
                        isDefault = eachChannelContent.Default__c;
                    }
                }
            } else {
                throw new gcr_WidgetHandshake.CustomException(GCRGenericProperties__c.getInstance('GCR_FATAL_ERRMSG').value__c);
            }
        } catch (Exception caughtException) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, GCRGenericProperties__c.getInstance('GCR_FATAL_ERRMSG').value__c));
        }
	}
}