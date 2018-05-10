/*
* @author:       Accenture
* @date:         13/10/2016
* @description:  CR392 - Proactive Chat: Test Class for proactive api class
* CHANGE LOG
* DATE          NAME                CHANGE DESCRIPTION
* 13/10/2016    Accenture           Initial Draft
*/
@isTest(SeeAllData = false)
public class gcr_proChatApiTest {
    
    /*
     * @author: 		Accenture
	 * @date: 		 	13/10/2016
	 * @description:  	TEST DATA SETUP METHOD
     */
    @testSetup
    static void setupTestData() {
        gcr_TestUtility.createCustomSettings();
        String brandConLangId = gcr_TestUtility.createContactUsObjectData();
    }

    /*
     * @author: 		Accenture
	 * @date: 		 	13/10/2016
	 * @description:  	TEST METHOD TO TEST PROACTIVE CHAT API IF CARE HUB EXISTS FOR SELECTED BRAND COUNTRY LANGUAGE
     */
    static testmethod void chatApiCareHubTest() {
        // CREATE CARE HUB DATA
        List<sObject> lBrandConLang = [ SELECT Id FROM Contact_Us_Brand_Language__c
                                  		WHERE Contact_Us_Brand__r.Name = :gcr_TestUtility.DEFAULT_BRAND 
                                 			AND Contact_Us_Language__r.Country__c = :gcr_TestUtility.DEFAULT_COUNTRY 
                                 			AND Contact_Us_Language__r.Language__c = :gcr_TestUtility.DEFAULT_LANGUAGE ];
        sObject careHub = gcr_TestUtility.getCareHubData(lBrandConLang.get(0).Id);
        Database.insert(careHub, true);
        List<sObject> lCareHubChannels = gcr_TestUtility.getCareHubChannels(careHub.Id);
        Database.insert(lCareHubChannels, true);
        
        // SET LIVE AGENT MOCK API 
        Test.setMock(HttpCalloutMock.class, new gcr_mockApiClass.gcr_liveAgentButton());
        
        Test.startTest();
        // INSTANTIATE REQUEST
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestUri = '/services/apexrest/chatAvailabilityDetail/v1';
        RestContext.request.httpMethod = 'GET';

        // SET REQUEST PARAMETERS
        RestContext.request.params.put('brand', gcr_TestUtility.DEFAULT_BRAND);
        RestContext.request.params.put('country', gcr_TestUtility.DEFAULT_COUNTRY_ISO);
        RestContext.request.params.put('language', gcr_TestUtility.DEFAULT_LANGUAGE_ISO);
        
        gcr_proChatResponse.gcr_availabilityDetail results 
            = (gcr_proChatResponse.gcr_availabilityDetail) gcr_proChatApi.isAgentAvailable();
        Test.stopTest();
        // VALIDATE RESPONSE
        SYSTEM.assertEquals(true, results.withinBusinessHours);
        SYSTEM.assertEquals(true, results.isAgentActive);
        SYSTEM.assertEquals(true, results.isSuccess);
        SYSTEM.assertEquals('http://chatimageurl.com', results.chatImage);
        SYSTEM.assertEquals(ContactUsURL__c.getInstance().CareHubUrl__c
                          + '/gcr_proChatRedirect?brand=' + gcr_TestUtility.DEFAULT_BRAND
                          + '&country=' + gcr_TestUtility.DEFAULT_COUNTRY_ISO
                          + '&language=' + gcr_TestUtility.DEFAULT_LANGUAGE_ISO
                          , results.chatUrl);
    }
    
    /*
     * @author: 		Accenture
	 * @date: 		 	13/10/2016
	 * @description:  	TEST METHOD TO TEST PROACTIVE CHAT API IF V3 CONFIG EXISTS FOR SELECTED BRAND COUNTRY LANGUAGE
     */
    static testmethod void chatApiV3Test() {
        // SET LIVE AGENT MOCK API 
        Test.setMock(HttpCalloutMock.class, new gcr_mockApiClass.gcr_liveAgentButton());
        
        Test.startTest();
        // INSTANTIATE REQUEST
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestUri = 'https://pgconsumersupport.secure.force.com/carehub/services/apexrest/chatAvailabilityDetail/v1';
        RestContext.request.httpMethod = 'GET';

        // SET REQUEST PARAMETERS
        RestContext.request.params.put('brand', gcr_TestUtility.DEFAULT_BRAND);
        RestContext.request.params.put('country', gcr_TestUtility.DEFAULT_COUNTRY_ISO);
        RestContext.request.params.put('language', gcr_TestUtility.DEFAULT_LANGUAGE_ISO);
        // CALL API
        gcr_proChatResponse.gcr_proResponseInterface proChatResp = gcr_proChatApi.isAgentAvailable();
        Test.stopTest();
        // VALIDATE RESPONSE OBJECT TYPE
        SYSTEM.assert(proChatResp instanceof gcr_proChatResponse.gcr_availabilityDetail);
        gcr_proChatResponse.gcr_availabilityDetail results = (gcr_proChatResponse.gcr_availabilityDetail) proChatResp;
        // VALIDATE RESPONSE
        SYSTEM.assertEquals(true, results.withinBusinessHours);
        SYSTEM.assertEquals(true, results.isAgentActive);
        SYSTEM.assertEquals(true, results.isSuccess);
        SYSTEM.assertEquals('http://chatimageurl.com', results.chatImage);
        SYSTEM.assertEquals(ContactUsURL__c.getInstance().URL__c
                          + '/gcr_proChatRedirect?brand=' + gcr_TestUtility.DEFAULT_BRAND
                          + '&country=' + gcr_TestUtility.DEFAULT_COUNTRY_ISO
                          + '&language=' + gcr_TestUtility.DEFAULT_LANGUAGE_ISO
                          , results.chatUrl);
    }
    
    /*
     * @author: 		Accenture
	 * @date: 		 	17/10/2016
	 * @description:  	TEST METHOD TO TEST PROACTIVE CHAT API IF NO PARAMETERS PASSED TO API
     */
    static testmethod void chatApiInvalidParamsTest() {
        // CREATE CARE HUB DATA
        List<sObject> lBrandConLang = [ SELECT Id FROM Contact_Us_Brand_Language__c
                                  		WHERE Contact_Us_Brand__r.Name = :gcr_TestUtility.DEFAULT_BRAND 
                                 			AND Contact_Us_Language__r.Country__c = :gcr_TestUtility.DEFAULT_COUNTRY 
                                 			AND Contact_Us_Language__r.Language__c = :gcr_TestUtility.DEFAULT_LANGUAGE ];
        sObject careHub = gcr_TestUtility.getCareHubData(lBrandConLang.get(0).Id);
        Database.insert(careHub, true);
        List<sObject> lCareHubChannels = gcr_TestUtility.getCareHubChannels(careHub.Id);
        Database.insert(lCareHubChannels, true);
        
        // SET LIVE AGENT MOCK API 
        Test.setMock(HttpCalloutMock.class, new gcr_mockApiClass.gcr_liveAgentButton());
        
        Test.startTest();
        // INSTANTIATE REQUEST
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestUri = '/services/apexrest/chatAvailabilityDetail/v1';
        RestContext.request.httpMethod = 'GET';
		// CALL API
        gcr_proChatResponse.gcr_proResponseInterface proChatResp = gcr_proChatApi.isAgentAvailable();
        Test.stopTest();
        // VALIDATE RESPONSE OBJECT TYPE
		SYSTEM.assert(proChatResp instanceof gcr_proChatResponse.gcr_errorResponse);
        gcr_proChatResponse.gcr_errorResponse results = (gcr_proChatResponse.gcr_errorResponse) proChatResp;
        // VALIDATE RESPONSE
        SYSTEM.assertEquals('INVALID_PARAMETERS', results.errorCode);
        SYSTEM.assertEquals(Label.errMsgNoExpParams, results.errorMessage);
    }
    
    /*
     * @author: 		Accenture
	 * @date: 		 	17/10/2016
	 * @description:  	TEST METHOD TO TEST PROACTIVE CHAT API IF NO CARE HUB OR V3 FOUND
     */
    static testmethod void chatApiNoWebConfigTest() {
        // CREATE CARE HUB DATA
        List<sObject> lBrandConLang = [ SELECT Id FROM Contact_Us_Brand_Language__c
                                  		WHERE Contact_Us_Brand__r.Name = :gcr_TestUtility.DEFAULT_BRAND 
                                 			AND Contact_Us_Language__r.Country__c = :gcr_TestUtility.DEFAULT_COUNTRY 
                                 			AND Contact_Us_Language__r.Language__c = :gcr_TestUtility.DEFAULT_LANGUAGE ];
        sObject careHub = gcr_TestUtility.getCareHubData(lBrandConLang.get(0).Id);
        Database.insert(careHub, true);
        List<sObject> lCareHubChannels = gcr_TestUtility.getCareHubChannels(careHub.Id);
        Database.insert(lCareHubChannels, true);
        
        // SET LIVE AGENT MOCK API 
        Test.setMock(HttpCalloutMock.class, new gcr_mockApiClass.gcr_liveAgentButton());
        
        Test.startTest();
        // INSTANTIATE REQUEST
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestUri = '/services/apexrest/chatAvailabilityDetail/v1';
        RestContext.request.httpMethod = 'GET';

        // SET INVALID REQUEST PARAMETERS
        RestContext.request.params.put('brand', 'brand');
        RestContext.request.params.put('country', 'country');
        RestContext.request.params.put('language', 'language');
		// CALL API
        gcr_proChatResponse.gcr_proResponseInterface proChatResp = gcr_proChatApi.isAgentAvailable();
        Test.stopTest();
        // VALIDATE RESPONSE OBJECT TYPE
		SYSTEM.assert(proChatResp instanceof gcr_proChatResponse.gcr_errorResponse);
        gcr_proChatResponse.gcr_errorResponse results = (gcr_proChatResponse.gcr_errorResponse) proChatResp;
        // VALIDATE RESPONSE
        SYSTEM.assertEquals('CONFIG_NOT_SETUP', results.errorCode);
        SYSTEM.assertEquals(Label.errMsgNoWebConfig, results.errorMessage);
    }
    
    /*
     * @author: 		Accenture
	 * @date: 		 	17/10/2016
	 * @description:  	TEST METHOD TO TEST PROACTIVE CHAT API IF NO CHAT CONFIG FOUND
     */
    static testmethod void chatApiNoChatConfigTest() {
        // CREATE CARE HUB DATA
        List<sObject> lBrandConLang = [ SELECT Id FROM Contact_Us_Brand_Language__c
                                  		WHERE Contact_Us_Brand__r.Name = :gcr_TestUtility.DEFAULT_BRAND 
                                 			AND Contact_Us_Language__r.Country__c = :gcr_TestUtility.DEFAULT_COUNTRY 
                                 			AND Contact_Us_Language__r.Language__c = :gcr_TestUtility.DEFAULT_LANGUAGE ];
        Contact_Us_Brand_Language__c tempVar = (Contact_Us_Brand_Language__c) lBrandConLang.get(0);
        tempVar.Live_Agent_Button_Id__c = null;
        tempVar.Live_Agent_Deployment_Id__c = null;
        Database.update(lBrandConLang, false);
        
        // SET LIVE AGENT MOCK API 
        Test.setMock(HttpCalloutMock.class, new gcr_mockApiClass.gcr_liveAgentButton());
        
        Test.startTest();
        // INSTANTIATE REQUEST
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestUri = '/services/apexrest/chatAvailabilityDetail/v1';
        RestContext.request.httpMethod = 'GET';

        // SET REQUEST PARAMETERS
        RestContext.request.params.put('brand', gcr_TestUtility.DEFAULT_BRAND);
        RestContext.request.params.put('country', gcr_TestUtility.DEFAULT_COUNTRY_ISO);
        RestContext.request.params.put('language', gcr_TestUtility.DEFAULT_LANGUAGE_ISO);
		// CALL API
        gcr_proChatResponse.gcr_proResponseInterface proChatResp = gcr_proChatApi.isAgentAvailable();
        Test.stopTest();
        // VALIDATE RESPONSE OBJECT TYPE
		SYSTEM.assert(proChatResp instanceof gcr_proChatResponse.gcr_errorResponse);
        gcr_proChatResponse.gcr_errorResponse results = (gcr_proChatResponse.gcr_errorResponse) proChatResp;
        // VALIDATE RESPONSE
        SYSTEM.assertEquals('CHAT_NOT_SETUP', results.errorCode);
        SYSTEM.assertEquals(Label.errMsgNoChatConfig, results.errorMessage);
    }
}