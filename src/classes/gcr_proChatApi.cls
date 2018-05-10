/*
* @author:       	Accenture
* @date:         	10/10/2016
* @description:  	CR392 - Proactive Chat: Rest resource class for proactive chat which is used by Brand.com to 
*					identify contact center and agent availability for selected Brand, Country and Language
* DATE				NAME				CHANGE DESCRIPTION
* 10/10/2016		Accenture			Initial Draft
*/
@RestResource(urlMapping='/chatAvailabilityDetail/v1/*')
global class gcr_proChatApi {

    /*
     * @author:         Accenture
     * @date:           10/10/2016
     * @description:    Rest API (GET) to provide agent availability details for selected Brand, Country and Language
     * @param:			String, String, String
     * @return:			Object
     */
	@HttpGet
    global static gcr_proChatResponse.gcr_proResponseInterface isAgentAvailable() {
        // GET PARAMETERS FROM REQUEST
        String brand = RestContext.request.params.get('brand');
        String country = RestContext.request.params.get('country');
        String language = RestContext.request.params.get('language');

        // IF BRAND, COUNTRY AND LANGUAGE PARAMETERS RECEIVED
        if (String.isNotEmpty(brand) && String.isNotEmpty(country) && String.isNotEmpty(language)) {
            // GET WEB CONFIG FOR BRAND COUNTRY AND LANGUAGE
			sObject webConfig = gcr_apiHelper.getWebConfiguration(brand, country, language);
            if (webConfig != null) {
                gcr_proChatResponse.gcr_chatConfigData chatConfig 
                    = (gcr_proChatResponse.gcr_chatConfigData) gcr_apiHelper.getChatConfiguration(webConfig, true);
                if (chatConfig != null 
                && String.isNotEmpty(chatConfig.buttonId) 
                && String.isNotEmpty(chatConfig.deploymentId)) {
                    // PREPARE SUCCESS RESPONSE DATA
                    return (gcr_proChatResponse.gcr_proResponseInterface)
                            gcr_apiHelper.prepareResponse(chatConfig.businessHourId, chatConfig.deploymentId
										  				, chatConfig.buttonId, chatConfig.appSite
                                          				, chatConfig.chatImageUrl, brand, country, language);
                } else {
					// PREPARE ERROR RESPONSE DATA IF LIVE AGENT DEPLOYMENT OR BUTTON ID NOT SETUP
                    return (gcr_proChatResponse.gcr_errorResponse)
						gcr_apiHelper.prepareResponse('CHAT_NOT_SETUP', Label.errMsgNoChatConfig);
                }
			} else {
				// IF VERSION 3 AND CARE HUB CONFIG DO NOT EXIST, PREPARE AND SEND ERROR RESPONSE DATA
				return (gcr_proChatResponse.gcr_errorResponse)
                    gcr_apiHelper.prepareResponse('CONFIG_NOT_SETUP', Label.errMsgNoWebConfig);
			}
        } else {
            // IF ANY OF BRAND, COUNTRY AND LANGUAGE PARAMETERS NOT RECEIVED
            return (gcr_proChatResponse.gcr_errorResponse)
                gcr_apiHelper.prepareResponse('INVALID_PARAMETERS', Label.errMsgNoExpParams);
        }
    }
}