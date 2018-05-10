/*
* @author:              Accenture
* @date:                11/10/2016
* @description:         Helper class for api related methods
* DATE                  NAME                CHANGE DESCRIPTION
* 11/10/2016            Accenture           Initial Draft
* 10/01/2017            Accenture           WR-440 - 1. Added additional field in queries to determine if prechat
*											form is required for proactive chat
*											2. Assigned fetched value prechat form required to chat setup data in 
*											"getChatConfiguration()" method.
*/
public class gcr_apiHelper {
    
    /*
     * @author:         Accenture
     * @date:           11/10/2016
     * @description:    method for find web configuration for chat. Tires to find config in care hub first
     *                  if not found then search in v3 objects
     * @input:          String, String, String
     * @return:         sObject
     */
    public static sObject getWebConfiguration(String brand, String country, String language) {
        // QUERY CARE HUB FOR RECEIVED BRAND COUNTRY LANGUAGE
        List<sObject> lWebConfig = [ SELECT Id
                                    	  , Brand__c
                                    	  , Country__c
                                    	  , BrandCountryLanguage__r.Contact_Us_Language__r.Language__c
                                          , BrandCountryLanguage__r.Contact_Us_Language__r.GCRCountryIsoCode__c //CDOY 25/7/2017
                                          , BrandCountryLanguage__r.Contact_Us_Language__r.GCRLanguageIsoCode__c //CDOY 25/7/2017
                                    	  , (SELECT Id
                                                  , LiveAgentBusinessHour__c
                                                  , LAButtonId__c
                                                  , LADeploymentId__c
                                                  , ChatImageUrl__c
                                             	  // WR508 - Chat Redsign - SHOW ERROR ON STANDALONE CHAT WHEN OUT OF BUSINESS HOURS OR AGENT NOT AVAILABLE
                                             	  , OutsideBusinessHoursMsg__c
                                             	  , AgentBusyMsg__c
                                             	  // WR-440 - ADDED ADDITIONAL FIELDS TO DETERMINE PRECHAT FORM REQUIREMENT
                                             	  , noPrechatProactive__c
                                             	  , noPrechatStandalone__c
                                             FROM GCRChannelContent__r
                                             WHERE RecordType.Name = 'chat'
                                             	AND isActive__c = true LIMIT 1)
                                     FROM GCRCareHub__c
                                     WHERE Brand__c = :brand
                                        AND CountryIsoCode__c = :country
                                        AND LanguageIsoCode__c = :language LIMIT 1 ];

        //CDOY Added
        system.debug('***list WebConfig*** : '+lWebConfig);

        // IF CARE HUB FOUND THEN RETURN CARE HUB
        if (lWebConfig != null && !lWebConfig.isEmpty() 
         && ((GCRCareHub__c) lWebConfig.get(0)).GCRChannelContent__r != null
         && !((GCRCareHub__c) lWebConfig.get(0)).GCRChannelContent__r.isEmpty()) {
            return lWebConfig.get(0);
        } else {
            // IF CARE HUB NOT FOUND QUERY V3 CONFIG FOR RECEIVED BRAND COUNTRY LANGUAGE
            lWebConfig = [ SELECT Id
                                , Business_Hours__c
                                , Live_Agent_Button_Id__c
                                , Live_Agent_Deployment_Id__c
                                , ChatImageUrl__c
                            		, Contact_Us_Language__r.Language__c
                            		, Contact_Us_Language__r.Country__c
                            		, Contact_Us_Brand__r.Name
                            		// WR508 - Chat Redsign - SHOW ERROR ON STANDALONE CHAT WHEN OUT OF BUSINESS HOURS OR AGENT NOT AVAILABLE
                            		, Contact_Us_Language__r.Tab_Title_Outside_of_Business_Hours__c
                            		, Contact_Us_Language__r.Tab_Title_Chat_Offline__c
                            		// WR-440 - ADDED ADDITIONAL FIELDS TO DETERMINE PRECHAT FORM REQUIREMENT
                                , noPrechatProactive__c
                            		, noPrechatStandalone__c
                           FROM Contact_Us_Brand_Language__c
                           WHERE Brand_Name__c = :brand
                            AND Contact_Us_Language__r.GCRCountryIsoCode__c = :country
                            AND Contact_Us_Language__r.GCRLanguageIsoCode__c = :language LIMIT 1 ];
            // IF V3 CONFIG FOUND THEN RETURN V3 CONFIG ELSE NULL
            if (lWebConfig != null && !lWebConfig.isEmpty()) {
                return lWebConfig.get(0);
            } else {
                return null;
            }
        }
    }
    
    /*
     * @author:         Accenture
     * @date:           11/10/2016
     * @description:    retrieve chat configuration from incoming sObject based on type of sObject
     * @input:          sObject, Boolean
     * @return:         Object
     */
    public static Object getChatConfiguration(sObject configData, Boolean isProactive) {
        // INITIALIZE CHAT CONFIG OBJECT
        gcr_proChatResponse.gcr_chatConfigData retVal;
        
        if (configData != null) {
            // INSTANTIATE CHAT CONFIG OBJECT
            retVal = new gcr_proChatResponse.gcr_chatConfigData();
            // CHECK IF INCOMING OBJECT IS CAREHUB OR VERSION 3
            if (configData instanceof GCRCareHub__c) {
                // TYPECAST GENERIC OBJECT TO CARE HUB
                GCRCareHub__c careHub = (GCRCareHub__c) configData;
                if (careHub.GCRChannelContent__r != null
                && !careHub.GCRChannelContent__r.isEmpty()) {
                    // PREPARE CHAT CONFIG RETURN OBJECT FROM CARE HUB OBJECTS
                    retVal.buttonId = careHub.GCRChannelContent__r.get(0).LAButtonId__c;
                    retVal.deploymentId = careHub.GCRChannelContent__r.get(0).LADeploymentId__c;
                    retVal.businessHourId = careHub.GCRChannelContent__r.get(0).LiveAgentBusinessHour__c;
                    retVal.chatImageUrl = careHub.GCRChannelContent__r.get(0).ChatImageUrl__c;
                    retVal.appSite = 'careHub';
                    retVal.brand = careHub.Brand__c;

                    //CDOY 25/07/2017
                    //retVal.country = careHub.Country__c; //Old
                    //retVal.language = careHub.BrandCountryLanguage__r.Contact_Us_Language__r.Language__c; //Old
                    //retVal.country = careHub.BrandCountryLanguage__r.Contact_Us_Language__r.GCRCountryIsoCode__c; //New
                    //retVal.language = careHub.BrandCountryLanguage__r.Contact_Us_Language__r.GCRLanguageIsoCode__c; //New

                    // WR-440 - ASSIGN PRECHAT FORM REQUIRED VALUE TO RETURN OBJECT
                    retVal.prechatReq = isProactive ? !careHub.GCRChannelContent__r.get(0).noPrechatProactive__c 
                        							: !careHub.GCRChannelContent__r.get(0).noPrechatStandalone__c;

                    
                    String preChatPage = isProactive ? ChatPage__c.getInstance().ProactivePrechat__c:ChatPage__c.getInstance().StandalonePreChat__c;
                    //CDOY 28/07/2017
                    system.debug('***About to check prechatReq');
                    //KUMAR MURUGAN 04/10/2017  - SWAPPED THE CONDITION SINCE WE NEED TO PASS THE ISO CODES ONLY IN CASE OF PRECHATS
                    
                    if(retVal.prechatReq 
                    	&& (preChatPage.containsIgnoreCase('gcr'))){
                        system.debug('***prechatreq = False');
                        retVal.country = careHub.BrandCountryLanguage__r.Contact_Us_Language__r.GCRCountryIsoCode__c;
                        retVal.language = careHub.BrandCountryLanguage__r.Contact_Us_Language__r.GCRLanguageIsoCode__c;
                    }
                    else {
                    	system.debug('***prechatreq = True');
                        retVal.country = careHub.Country__c;
                        retVal.language = careHub.BrandCountryLanguage__r.Contact_Us_Language__r.Language__c;
                        
                    }

                    // WR508 - Chat Redsign - SHOW ERROR ON STANDALONE CHAT WHEN OUT OF BUSINESS HOURS OR AGENT NOT AVAILABLE
                    retVal.outsideBusinessHrsMsg = careHub.GCRChannelContent__r.get(0).OutsideBusinessHoursMsg__c;
                    retVal.agentNotAvailableMsg = careHub.GCRChannelContent__r.get(0).AgentBusyMsg__c;
                }
            } else if (configData instanceof Contact_Us_Brand_Language__c) {
                // TYPECAST GENERIC OBJECT TO CONTACT US BRAND LANGUAGE
                Contact_Us_Brand_Language__c contactUsV3 = (Contact_Us_Brand_Language__c) configData;
                // PREPARE CHAT CONFIG RETURN OBJECT FROM VERSION 3 OBJECTS
                retVal.buttonId = contactUsV3.Live_Agent_Button_Id__c;
                retVal.deploymentId = contactUsV3.Live_Agent_Deployment_Id__c;
                retVal.businessHourId = contactUsV3.Business_Hours__c;
                retVal.chatImageUrl = contactUsV3.ChatImageUrl__c;
                retVal.appSite = 'ContactUs';
				        retVal.brand = contactUsV3.Contact_Us_Brand__r.Name;
                retVal.country = contactUsV3.Contact_Us_Language__r.Country__c;
                retVal.language = contactUsV3.Contact_Us_Language__r.Language__c;
                // WR-440 - ASSIGN PRECHAT FORM REQUIRED VALUE TO RETURN OBJECT
                retVal.prechatReq = isProactive ? !contactUsV3.noPrechatProactive__c : !contactUsV3.noPrechatStandalone__c;
                // WR508 - Chat Redsign - SHOW ERROR ON STANDALONE CHAT WHEN OUT OF BUSINESS HOURS OR AGENT NOT AVAILABLE
                retVal.outsideBusinessHrsMsg = contactUsV3.Contact_Us_Language__r.Tab_Title_Outside_of_Business_Hours__c;
                retVal.agentNotAvailableMsg = contactUsV3.Contact_Us_Language__r.Tab_Title_Chat_Offline__c;
            } else {
                retVal = null;
            }
        }
        
        return retVal;
    }
    
    /*
     * @author:         Accenture
     * @date:           10/10/2016
     * @description:    method to return success response based on provided data
     * @input:          String, String, String, String, String, String, String
     * @return:         Object
     */
    public static Object prepareResponse(String businessHrId, String deploymentId, String buttonId, String appSite
                                        , String chatImage, String brand, String country, String language) {
        // INITILIZE RESPONSE
        gcr_proChatResponse.gcr_proResponseInterface retVal;
        // INITIALIZE SUCCESS RESPONSE
        gcr_proChatResponse.gcr_availabilityDetail response = new gcr_proChatResponse.gcr_availabilityDetail();
        
        try {
            // GET BUSINESS HOUR DETAILS
            response.withinBusinessHours = gcr_helperClass.isBusinessHoursActive(businessHrId);
            // IF WITHIN BUSINESS HOURS 
            if (response.withinBusinessHours) {
                // API CALL TO CHECK IF ANY AGENT IS ONLINE AND HAVE CAPACITY TO CHAT
                response.isAgentActive = gcr_helperClass.ischatBtnAvailable(deploymentId, buttonId);
                if (response.isAgentActive) {
                    // IF AGENT IS ACTIVE SET CHAT IMAGE URL IN RESPONSE
                    response.chatImage = chatImage;
                    // IF AGENT IS ACTIVE PREPARE PRE-CHAT REDIRECT PAGE URL BASED ON APPLICATION
                    // TODO: CHECK IF CUSTOM SETTINGS DEPENDENCY CAN BE REMOVED
                    if (appSite.equalsIgnoreCase('contactus')) {
                        response.chatUrl = ContactUsURL__c.getInstance().URL__c
                            + '/gcr_proChatRedirect?brand=' + brand + '&country=' + country + '&language=' + language;
                    } else if (appSite.equalsIgnoreCase('carehub')) {
                        response.chatUrl = response.chatUrl = ContactUsURL__c.getInstance().CareHubUrl__c
                            + '/gcr_proChatRedirect?brand=' + brand + '&country=' + country + '&language=' + language;
                    }
                }
            }
        } catch (Exception caughtException) {
            throw new ApiCalloutException(Label.errMsgGeneric);
        }
        // SET DATA IN RESPONSE INTERFACE AND SUCCESS ATTRIBUTE AS TRUE
        retVal = response;
        retVal.isSuccess = true;

        return retVal;
    }
    
    /*
     * @author:         Accenture
     * @date:           10/10/2016
     * @description:    method to return error response
     * @input:          String, String
     * @return:         Object
     */
    public static Object prepareResponse(String errorCode, String errorMessage) {
        // INITILIZE RESPONSE
        gcr_proChatResponse.gcr_proResponseInterface retVal;
        // INITIALIZE ERROR RESPONSE
        gcr_proChatResponse.gcr_errorResponse response = new gcr_proChatResponse.gcr_errorResponse();
        // SET ERROR CODE AND MESSAGE
        response.errorCode = errorCode;
        response.errorMessage = errorMessage;
        // SET DATA IN RESPONSE INTERFACE AND SUCCESS ATTRIBUTE AS TRUE
        retVal = response;
        retVal.isSuccess = false;

        return response;
    }

    private class ApiCalloutException extends Exception {}
}