/*
* @author: 		 Accenture
* @date: 		 05/19/2016
* @description:  Controller class for siderbar component of GCR widget
* DATE			NAME				CHANGE DESCRIPTION
* 05/19/2016	Accenture			INITIAL DRAFT
* 20/10/2016	Accenture			Additional processing for default chat channel added in method
									preparePageRecords(), where button availability required to be known before
									chat component render when chat is default channel.
*/
public class gcr_sidebarController {
    // ALL PUBLIC GETTER SETTER VARIABLES
    public gcr_WidgetHandshake iHandshake { public get; public set; }
    
    // ALL PUBLIC GETTER VARIABLES
    public List<GCRChannelProperties__c> lResourceData { public get; private set; }
    public Map<String, String> mDisplayName { public get; private set; }
    public Boolean controlConstructor { public get {
        if (controlConstructor == null) init();
        return false;
    } private set; }
    public String selectedChannel { get; set; }
    
    // PRIVATE VARIABLES
    private Integer totalRecords { private get; private set; }
    private Integer recordOffset { private get; private set; }

   /*
    * @date:		18/07/2016
    * @param:		none 
    * @return:		void
    * @description:	INIT METHOD OF CONTROLLER CUNSTRUCTOR
    */
    public void init() {
        this.recordOffset = 0;
        mDisplayName = new Map<String, String>();
        try {
            this.totalRecords = [ SELECT COUNT() FROM GCRChannelContent__c
                                  WHERE CareHub__r.Id = :iHandshake.lCareHub.get(0).Id AND isActive__c = true
                                  LIMIT :Limits.getLimitDMLRows() - Limits.getDMLRows() ];
            // GET ALL CHANNELS REQUIRED TO BE DISPLAYED ON PAGE
            // DEFAULT CHANNELS TO SHOW IS SET TO 5 IF NOT SET IN CUSTOM SETTINGS
            lResourceData = this.preparePageRecords(GCRGenericProperties__c.getInstance('gcr_ChannelCount') != null ?
                                                    Integer.valueOf(GCRGenericProperties__c.getInstance('gcr_ChannelCount').value__c) : 5
                                                  , this.recordOffset);
        } catch (Exception caughtException) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, GCRGenericProperties__c.getInstance('GCR_FATAL_ERRMSG').value__c));
            ApexPages.addMessages(caughtException);
        }
    }
    
   /*
    * @date:		18/07/2016
    * @param:		none 
    * @return:		void
    * @description:	ACTION METHOD FOR CHANNEL SELECTION, THIS METHOD EXECUTED WHEN USER CLICKS ON ANY CHANNEL ON THE PAGE
    */
    public void process() {
        iHandshake.gcrFunctionality = selectedChannel;
        if (selectedChannel.equalsIgnoreCase('chat')) {
            iHandshake.isChatVisited = gcr_helperClass.ischatBtnAvailable(iHandshake.mGcrContentId.get('chat'));
        }
    }
    
   /*
    * @date:		18/07/2016
    * @param:		none 
    * @return:		void
    * @description:	PAGINATION METHOD FOR CHANNELS TO GET NEXT SET OF CHANNELS
    */    
    public void next() {
        // GET TOTAL CHANNELS TO BE DISPLAYED ON THE SIDEBAR
        Integer pageSize = Integer.valueOf(GCRGenericProperties__c.getInstance('gcr_ChannelCount').value__c);
        recordOffset += this.totalRecords > pageSize ? (recordOffset < 1 ? pageSize - 1 : pageSize - 2) : pageSize;
        lResourceData = preparePageRecords(GCRGenericProperties__c.getInstance('gcr_ChannelCount') != null ?
                                                Integer.valueOf(GCRGenericProperties__c.getInstance('gcr_ChannelCount').value__c) : 5
                                           , this.recordOffset);
    }
    
   /*
    * @date:		18/07/2016
    * @param:		none 
    * @return:		void
    * @description:	PAGINATION METHOD FOR CHANNELS TO GET PREVIOUS SET OF CHANNELS
    */   
    public void previous() {
        Integer pageSize = Integer.valueOf(GCRGenericProperties__c.getInstance('gcr_ChannelCount').value__c);
        recordOffset -= recordOffset > pageSize - 1 ? pageSize - 2 : pageSize - 1;
        lResourceData = preparePageRecords(Integer.valueOf(GCRGenericProperties__c.getInstance('gcr_ChannelCount').value__c) != null ?
                                                Integer.valueOf(GCRGenericProperties__c.getInstance('gcr_ChannelCount').value__c) : 5
                                         , this.recordOffset);
    }
    
   /*
    * @date:		18/07/2016
    * @param:		Integer, Integer 
    * @return:		List<sObject>
    * @description:	METHOD TO PREPARE CHANNELD TO BE DISPLAYED ON THE PAGE
    */ 
    private List<GCRChannelProperties__c> preparePageRecords(Integer pageSize, Integer recordOffset) {
        List<GCRChannelProperties__c> retVal = new List<GCRChannelProperties__c>();
        Integer intQueryLimit = this.totalRecords > pageSize ? (recordOffset < 1 ? pageSize - 1 : pageSize - 2) : pageSize;
        if (recordOffset > 0) retVal.add(navigationIconData(false));
        for (GCRChannelContent__c eachContryLang :[ SELECT RecordType.Name, Name, DisplayName__c, Default__c FROM GCRChannelContent__c 
                         WHERE CareHub__r.Id = :iHandshake.lCareHub.get(0).Id AND isActive__c = true
						 ORDER BY DisplayOrder__c LIMIT :intQueryLimit OFFSET :recordOffset ]) {
			retVal.add(GCRChannelProperties__c.getInstance(eachContryLang.RecordType.Name));
			mDisplayName.put(eachContryLang.RecordType.Name, eachContryLang.DisplayName__c);
			// IF CHAT CHANNEL IS DEFAULT SET FUCNTIONALITY TO DEFAULTED CHANNEL
			if (eachContryLang.Default__c) {
				iHandshake.gcrFunctionality = eachContryLang.RecordType.Name;
                // IF CHAT CHANNEL IS DEFAULT GET CHAT BUTTON AVAILABILITY
                if (iHandshake.gcrFunctionality.equalsIgnoreCase('chat')) {
                    iHandshake.isChatVisited = gcr_helperClass.ischatBtnAvailable(iHandshake.mGcrContentId.get('chat'));
                }
            }
        }
        // IF ARTICLE DATA IS PASSED DEFAULT TO FAQ
		if (String.isNotEmpty(iHandshake.strKaUrlName)) {
			iHandshake.gcrFunctionality = 'faq';
		}
        if (recordOffset + pageSize < this.totalRecords) retVal.add(navigationIconData(true));
        controlConstructor = true;
        return retVal;
    }
    
   /*
    * @date:		18/07/2016
    * @param:		Boolean
    * @return:		sObject
    * @description:	METHOD TO PREPARE GET PAGINATION DATA (PREVIOUS OR NEXT) BASED ON PASSED PARAMETER
    */
    private GCRChannelProperties__c navigationIconData(Boolean isNext) {
        if(isNext) {
            mDisplayName.put('next', iHandshake.lCareHub.get(0).GCRLabelNext__c);
            return GCRChannelProperties__c.getInstance('next');
		} else {
			mDisplayName.put('previous', iHandshake.lCareHub.get(0).GCRLabelPrevious__c);
            return GCRChannelProperties__c.getInstance('previous');
		}
    }
}