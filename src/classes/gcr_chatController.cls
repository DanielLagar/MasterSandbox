/*
* @author:       Accenture
* @date:         02/06/2016
* @description:  Controller class for chat component of GCR widget
* DATE              NAME                CHANGE DESCRIPTION
* 02/06/2016        Accenture           Initial Draft
* 09/01/2017        Accenture           Added "retrieveChatPageUrl()" method call in tempBoolean getter method which 
*										retrieves chat url for no prechat form. Added additional condition to 
*										"retrieveChatPageUrl()"" method for no prechat form 
*/
global class gcr_chatController {
    // INCOMING DATA COMING TO CONTROLLER
    public String chlContentId { get; set; }
    public Boolean isButtonAvailable { get; set; }
    public Boolean isRightToLeft { get; set; }
    
    // COMPONENT PUBLIC VARIABLES
	public GCRChannelContent__c chatChannelContent { get; set; }
    public Boolean isBusinessHrsActive { get; set; }
    public Boolean isTNCAgreed { get; set; }
    public String strFirstName { get; set; }
    public String strLastName { get; set; }
    public String strEmail { get; set; }
    public String chatPageUrl { get; set; }
    public Boolean isSubmitDisable { get; private set; }

    public String privacyPolicyFull {get;set;}
    public String privacyPolicy2 {get;set;}

    /*
     * @author:         Accenture
     * @date:           25/08/2016
     * @description:    constructor method for chat controller
     * @input:			None
     */
    public gcr_chatController() {
        isSubmitDisable = true;

    }
    
    /*
     * @author:         Accenture
     * @date:           25/08/2016
     * @description:    getter method for temporary variable to get channel content, this variable is created 
     * 					to overcome salesforce component limitation of execution sequence.
     * @input:			None
     */
    // VARIABLE TO OVERCOME SALESFORCE COMPONENT LIMITATION
    public Boolean tempBoolean { get {
        if (chatChannelContent == null) {
			String queryString = gcr_helperClass.createQueryString('SELECT'
				, gcr_helperClass.getAllFieldsForQuery('GCRChannelContent__c')
                	+ ',CareHub__r.isLastNameFirst__c,CareHub__r.Country__c,CareHub__r.PrivacyPolicyLabel__c,CareHub__r.Privacy_Policy_Label_2__c'
					+ ',RecordType.Name,CareHub__r.LanguageLocaleKey__c,CareHub__r.PrivacyPolicyLink__c'
					+ ',CareHub__r.CountryIsoCode__c,CareHub__r.BackgroundImgLanding__c,CareHub__r.Language__c'
					+ ',CareHub__r.LanguageIsoCode__c,CareHub__r.Brand__c,CareHub__r.ValidationErrorMessage__c'
                , 'GCRChannelContent__c') + ' WHERE Id = \'' + chlContentId + '\'' ;
			chatChannelContent = (GCRChannelContent__c) Database.query(queryString).get(0);
            // ADDED TO CAPTURE CHAT URL FOR NO PRE CHAT FORM
            if (chatChannelContent.noPrechat__c) {
                retrieveChatPageUrl();
            }

        privacyPolicy2 = chatChannelContent.CareHub__r.Privacy_Policy_Label_2__c == null ? ' ' : chatChannelContent.CareHub__r.Privacy_Policy_Label_2__c; //CDOYs

        privacyPolicyFull = chatChannelContent.CareHub__r.PrivacyPolicyLabel__c + ' '+ privacyPolicy2; //CDOY
		}

        if(tempBoolean == null || tempBoolean) init(); return false;
    } private set; }
    
	/*
     * @author:         Accenture
     * @date:           25/08/2016
     * @description:    init method for chat controller
     * @input:			none
     * @output:			void
     */
    private void init() {
        isBusinessHrsActive = gcr_helperClass.isBusinessHoursActive(chatChannelContent.LiveAgentBusinessHour__c);
    }

	/*
     * @author:         Accenture
     * @date:           25/08/2016
     * @description:    method to retrieve chat page url which also sens chat page name in the url
     * @input:			none
     * @output:			void
     */
    public void retrieveChatPageUrl() {
        //WR552 Added to map Loyalty ID to the case 
        String strLoyaltyID = ApexPages.currentPage().getParameters().get('loyaltyID')!=NULL ? ApexPages.currentPage().getParameters().get('loyaltyID'):'';
		
		if (System.Site.getBaseUrl().contains('carehub')) {
            chatPageUrl = System.Site.getBaseUrl() + '/gcr_chatRedirectPage?';
        } else {
            chatPageUrl = System.Site.getBaseUrl() + '/apex/gcr_chatRedirectPage?';
        }
        if (!chatChannelContent.noPrechat__c) {
            if (String.isNotEmpty(strFirstName)) {
                chatPageUrl += 'fname=' + EncodingUtil.urlEncode(strFirstName, 'UTF-8');
            }
            if (String.isNotEmpty(strLastName)) {
                chatPageUrl += '&lname=' + EncodingUtil.urlEncode(strLastName, 'UTF-8');
            }
            if (String.isNotEmpty(strEmail)) {
                chatPageUrl += '&email=' + EncodingUtil.urlEncode(strEmail, 'UTF-8') + '&';
            }
        }
        //chatPageUrl += '&channel=' + chatChannelContent.Id;
        chatPageUrl += 'brand=' + chatChannelContent.CareHub__r.Brand__c;
        chatPageUrl += '&country=' + chatChannelContent.CareHub__r.CountryIsoCode__c;
        chatPageUrl += '&language=' + chatChannelContent.CareHub__r.LanguageIsoCode__c;
        chatPageUrl += '&type=Carehub';
        
        //WR552 Added to map Loyalty ID to the case 
        if (String.isNotEmpty(strLoyaltyID)) {
            chatPageUrl += '&loyaltyID=' + EncodingUtil.urlEncode(strLoyaltyID, 'UTF-8');
        }
        //End WR552
        isSubmitDisable = false;
    }
    
	/*
     * @author:         Accenture
     * @date:           25/08/2016
     * @description:    method to set disable submit chat button
     * @input:			none
     * @output:			void
     */
    public void disableSubmit() {
        isSubmitDisable = true;
    }
    
	/*
     * @author:         Accenture
     * @date:           25/08/2016
     * @description:    rempte action to validate email via strike iron api
     * @input:			String
     * @output:			Boolean
     */
    @RemoteAction
    global static Boolean validateEmail(String strEmailAddress) {
        return gcr_helperClass.isEmailAddressValid(strEmailAddress);
	}
}