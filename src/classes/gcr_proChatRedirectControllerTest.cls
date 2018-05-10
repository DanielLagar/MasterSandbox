/*
* @author:       Accenture
* @date:         12/10/2016
* @description:  CR392 - Proactive Chat: Test Class for proactive chat redirect controller
* CHANGE LOG
* DATE          NAME                CHANGE DESCRIPTION
* 12/10/2016    Accenture           Initial Draft
*/
@isTest(SeeAllData = false)
public class gcr_proChatRedirectControllerTest {

    /*
     * @author:         Accenture
     * @date:           12/10/2016
     * @description:    TEST DATA SETUP METHOD
     */
    @testSetup
    static void setupTestData() {
        gcr_TestUtility.createCustomSettings();
        String brandConLangId = gcr_TestUtility.createContactUsObjectData();
        gcr_TestUtility.createContactUsData();
    }
    
    /*
     * @author:         Accenture
     * @date:           12/10/2016
     * @description:    TEST METHOD TO TEST PROACTIVE CHAT REDIRECT URL IF CARE HUB EXISTS
     *                  FOR BRAND COUNTRY LANGUAGE
     */
    static testmethod void chatPageCareHubTest() {
        // CREATE CARE HUB DATA
        List<sObject> lBrandConLang = [ SELECT Id FROM Contact_Us_Brand_Language__c
                                        WHERE Contact_Us_Brand__r.Name = :gcr_TestUtility.DEFAULT_BRAND 
                                            AND Contact_Us_Language__r.Country__c = :gcr_TestUtility.DEFAULT_COUNTRY 
                                            AND Contact_Us_Language__r.Language__c = :gcr_TestUtility.DEFAULT_LANGUAGE ];
        sObject careHub = gcr_TestUtility.getCareHubData(lBrandConLang.get(0).Id);
        Database.insert(careHub, true);
        List<sObject> lCareHubChannels = gcr_TestUtility.getCareHubChannels(careHub.Id);
        Database.insert(lCareHubChannels, true);
        
        // SET PAGE PARAMETERS
        ApexPages.currentPage().getParameters().put('brand', gcr_TestUtility.DEFAULT_BRAND);
        ApexPages.currentPage().getParameters().put('country', gcr_TestUtility.DEFAULT_COUNTRY_ISO);
        ApexPages.currentPage().getParameters().put('language', gcr_TestUtility.DEFAULT_LANGUAGE_ISO);
        
        // INSTANTIATE CONTROLLER'S CONSTRUCTOR
        Test.startTest();
        gcr_proChatRedirectController controller = new gcr_proChatRedirectController();
        Test.stopTest();
        // GET CHAT CHANNEL DATA FOR CARE HUB
        List<GCRChannelContent__c> lCareChannels = [ SELECT Id
                                                          , LADeploymentId__c
                                                          , LAButtonId__c
                                                     FROM GCRChannelContent__c
                                                     WHERE CareHub__r.Brand__c = :gcr_TestUtility.DEFAULT_BRAND
                                                        AND CareHub__r.CountryIsoCode__c = :gcr_TestUtility.DEFAULT_COUNTRY_ISO
                                                        AND CareHub__r.LanguageIsoCode__c = :gcr_TestUtility.DEFAULT_LANGUAGE_ISO
                                                        AND RecordType.Name = 'chat' LIMIT 1 ];
        
        // DATA VALIDATION
        SYSTEM.assertEquals('/apex/' + ChatPage__c.getInstance().ProactiveChat__c
                            // GCRGenericProperties__c.getInstance('CHAT_PAGE').value__c 
                            + '?brand=' + gcr_TestUtility.DEFAULT_BRAND 
                            + '&country='+ gcr_TestUtility.DEFAULT_COUNTRY
                            + '&language=' + gcr_TestUtility.DEFAULT_LANGUAGE
                            + '#deployment_id=' + lCareChannels.get(0).LADeploymentId__c
                            + '&button_id=' + lCareChannels.get(0).LAButtonId__c
                            + '&org_id=' + UserInfo.getOrganizationId().substring(0, 15)
                            + '&session_id='
                          , controller.endpoint);
        SYSTEM.assertEquals(lCareChannels.get(0).LAButtonId__c, controller.buttonId);
        SYSTEM.assertEquals(lCareChannels.get(0).LADeploymentId__c, controller.deploymentId);
    }
    
    /*
     * @author:         Accenture
     * @date:           13/10/2016
     * @description:    TEST METHOD TO TEST PROACTIVE CHAT REDIRECT URL IF NO CARE HUB EXISTS BUT
     *                  A V3 CONFIG EXISTS FOR BRAND COUNTRY LANGUAGE
     */
    static testmethod void chatPageV3Test() {
        // SET PAGE PARAMETERS
        ApexPages.currentPage().getParameters().put('brand', gcr_TestUtility.DEFAULT_BRAND);
        ApexPages.currentPage().getParameters().put('country', gcr_TestUtility.DEFAULT_COUNTRY_ISO);
        ApexPages.currentPage().getParameters().put('language', gcr_TestUtility.DEFAULT_LANGUAGE_ISO);
        
        // INSTANTIATE CONTROLLER'S CONSTRUCTOR
        Test.startTest();
        gcr_proChatRedirectController controller = new gcr_proChatRedirectController();
        Test.stopTest();
        
        // GET CHAT CHANNEL DATA FROM V3 OBJECTS
        List<Contact_Us_Brand_Language__c> lV3BrandLang = [ SELECT Id
                                                                 , Live_Agent_Button_Id__c
                                                                 , Live_Agent_Deployment_Id__c
                                                            FROM Contact_Us_Brand_Language__c
                                                            WHERE Brand_Name__c = :gcr_TestUtility.DEFAULT_BRAND
                                                                AND Contact_Us_Language__r.GCRCountryIsoCode__c = :gcr_TestUtility.DEFAULT_COUNTRY_ISO
                                                                AND Contact_Us_Language__r.GCRLanguageIsoCode__c = :gcr_TestUtility.DEFAULT_LANGUAGE_ISO LIMIT 1 ];
        // DATA VALIDATION
        SYSTEM.assertEquals('/apex/' + ChatPage__c.getInstance().ProactiveChat__c
                            // GCRGenericProperties__c.getInstance('CHAT_PAGE').value__c 
                            + '?brand=' + gcr_TestUtility.DEFAULT_BRAND 
                            + '&country='+ gcr_TestUtility.DEFAULT_COUNTRY
                            + '&language=' + gcr_TestUtility.DEFAULT_LANGUAGE
                            + '#deployment_id=' + lV3BrandLang.get(0).Live_Agent_Deployment_Id__c
                            + '&button_id=' + lV3BrandLang.get(0).Live_Agent_Button_Id__c
                            + '&org_id=' + UserInfo.getOrganizationId().substring(0, 15)
                            + '&session_id='
                          , controller.endpoint);
        SYSTEM.assertEquals(lV3BrandLang.get(0).Live_Agent_Button_Id__c, controller.buttonId);
        SYSTEM.assertEquals(lV3BrandLang.get(0).Live_Agent_Deployment_Id__c, controller.deploymentId);
    }
    
    /*
     * @author:         Accenture
     * @date:           13/10/2016
     * @description:    TEST METHOD TO TEST PROACTIVE CHAT REDIRECT URL IF NO LIVE AGENT CONFIGURATION
     *                  AVAILABLE IN CONFIG
     */
    static testmethod void chatPageNoChatConfigTest() {
        // GET AND CLEAR LIVE AGENT CONFIG DATA
        List<sObject> lBrandConLang = [ SELECT Id FROM Contact_Us_Brand_Language__c
                                        WHERE Contact_Us_Brand__r.Name = :gcr_TestUtility.DEFAULT_BRAND 
                                            AND Contact_Us_Language__r.Country__c = :gcr_TestUtility.DEFAULT_COUNTRY 
                                            AND Contact_Us_Language__r.Language__c = :gcr_TestUtility.DEFAULT_LANGUAGE ];
        Contact_Us_Brand_Language__c tempVar = (Contact_Us_Brand_Language__c) lBrandConLang.get(0);
        tempVar.Live_Agent_Button_Id__c = null;
        tempVar.Live_Agent_Deployment_Id__c = null;
        Database.update(lBrandConLang, false);
        // SET PAGE PARAMETERS
        ApexPages.currentPage().getParameters().put('brand', gcr_TestUtility.DEFAULT_BRAND);
        ApexPages.currentPage().getParameters().put('country', gcr_TestUtility.DEFAULT_COUNTRY_ISO);
        ApexPages.currentPage().getParameters().put('language', gcr_TestUtility.DEFAULT_LANGUAGE_ISO);
        
        // INSTANTIATE CONTROLLER'S CONSTRUCTOR
        Test.startTest();
        gcr_proChatRedirectController controller = new gcr_proChatRedirectController();
        Test.stopTest();

        // DATA VALIDATION
        SYSTEM.assert(gcr_TestUtility.pageMessageCheck(ApexPages.getMessages(), ApexPages.Severity.FATAL
                                                     , Label.errMsgNoChatConfig, Label.errMsgNoChatConfig));
    }
    
    /*
     * @author:         Accenture
     * @date:           13/10/2016
     * @description:    TEST METHOD TO TEST IF NO WEB CONFIG AVAILABLE FOR SELECTED BRAND COUNTRY
     *                  LANGUAGE
     */
    static testmethod void chatPageNoWebConfigTest() {
        // GET AND CLEAR LIVE AGENT CONFIG DATA
        List<sObject> lBrandConLang = [ SELECT Id FROM Contact_Us_Brand_Language__c
                                        WHERE Contact_Us_Brand__r.Name = :gcr_TestUtility.DEFAULT_BRAND 
                                            AND Contact_Us_Language__r.Country__c = :gcr_TestUtility.DEFAULT_COUNTRY 
                                            AND Contact_Us_Language__r.Language__c = :gcr_TestUtility.DEFAULT_LANGUAGE ];
        Database.delete(lBrandConLang, false);
        // SET PAGE PARAMETERS
        ApexPages.currentPage().getParameters().put('brand', gcr_TestUtility.DEFAULT_BRAND);
        ApexPages.currentPage().getParameters().put('country', gcr_TestUtility.DEFAULT_COUNTRY_ISO);
        ApexPages.currentPage().getParameters().put('language', gcr_TestUtility.DEFAULT_LANGUAGE_ISO);
        
        // INSTANTIATE CONTROLLER'S CONSTRUCTOR
        Test.startTest();
        gcr_proChatRedirectController controller = new gcr_proChatRedirectController();
        Test.stopTest();

        // DATA VALIDATION
        SYSTEM.assert(gcr_TestUtility.pageMessageCheck(ApexPages.getMessages(), ApexPages.Severity.FATAL
                                                     , Label.errMsgNoWebConfig, Label.errMsgNoWebConfig));
    }
    
    /*
     * @author:         Accenture
     * @date:           13/10/2016
     * @description:    TEST METHOD TO TEST IF NO WEB CONFIG AVAILABLE FOR SELECTED BRAND COUNTRY
     *                  LANGUAGE
     */
    static testmethod void chatPageNoParamsTest() {
        // GET AND CLEAR LIVE AGENT CONFIG DATA
        List<sObject> lBrandConLang = [ SELECT Id FROM Contact_Us_Brand_Language__c
                                        WHERE Contact_Us_Brand__r.Name = :gcr_TestUtility.DEFAULT_BRAND 
                                            AND Contact_Us_Language__r.Country__c = :gcr_TestUtility.DEFAULT_COUNTRY 
                                            AND Contact_Us_Language__r.Language__c = :gcr_TestUtility.DEFAULT_LANGUAGE ];
        
        // INSTANTIATE CONTROLLER'S CONSTRUCTOR
        Test.startTest();
        gcr_proChatRedirectController controller = new gcr_proChatRedirectController();
        Test.stopTest();

        // DATA VALIDATION
        SYSTEM.assert(gcr_TestUtility.pageMessageCheck(ApexPages.getMessages(), ApexPages.Severity.FATAL
                                                     , Label.errMsgNoExpParams, Label.errMsgNoExpParams));
    }
    
    /*
     * @author:         Accenture
     * @date:           09/10/2017
     * @description:    TEST METHOD TO TEST PROACTIVE CHAT REDIRECT URL IF CARE HUB EXISTS
     *                  FOR BRAND COUNTRY LANGUAGE WHEH THE SOURCE IS CHATBOT
     */
    static testmethod void chatPageCareHubChatBotTest() {
        // CREATE CARE HUB DATA
        List<sObject> lBrandConLang = [ SELECT Id FROM Contact_Us_Brand_Language__c
                                        WHERE Contact_Us_Brand__r.Name = :gcr_TestUtility.DEFAULT_BRAND 
                                            AND Contact_Us_Language__r.Country__c = :gcr_TestUtility.DEFAULT_COUNTRY 
                                            AND Contact_Us_Language__r.Language__c = :gcr_TestUtility.DEFAULT_LANGUAGE ];
        sObject careHub = gcr_TestUtility.getCareHubData(lBrandConLang.get(0).Id);
        Database.insert(careHub, true);
        List<sObject> lCareHubChannels = gcr_TestUtility.getCareHubChannels(careHub.Id);
        Database.insert(lCareHubChannels, true);
        
        case c = new case();
        c.Country__c = 'United States of America';
        c.language__c = 'English-US';
        insert c;
        
        // SET PAGE PARAMETERS
        ApexPages.currentPage().getParameters().put('brand', gcr_TestUtility.DEFAULT_BRAND);
        ApexPages.currentPage().getParameters().put('country', gcr_TestUtility.DEFAULT_COUNTRY_ISO);
        ApexPages.currentPage().getParameters().put('language', gcr_TestUtility.DEFAULT_LANGUAGE_ISO);
        ApexPages.currentPage().getParameters().put('source', 'Chatbot');
        ApexPages.currentPage().getParameters().put('chatbotCase', c.Id);
        
        // INSTANTIATE CONTROLLER'S CONSTRUCTOR
        Test.startTest();
        gcr_proChatRedirectController controller = new gcr_proChatRedirectController();
        Test.stopTest();
        // GET CHAT CHANNEL DATA FOR CARE HUB
        List<GCRChannelContent__c> lCareChannels = [ SELECT Id
                                                          , LADeploymentId__c
                                                          , LAButtonId__c
                                                     FROM GCRChannelContent__c
                                                     WHERE CareHub__r.Brand__c = :gcr_TestUtility.DEFAULT_BRAND
                                                        AND CareHub__r.CountryIsoCode__c = :gcr_TestUtility.DEFAULT_COUNTRY_ISO
                                                        AND CareHub__r.LanguageIsoCode__c = :gcr_TestUtility.DEFAULT_LANGUAGE_ISO
                                                        AND RecordType.Name = 'chat' LIMIT 1 ];
        
        // DATA VALIDATION
        SYSTEM.assertEquals('/apex/' + ChatPage__c.getInstance().ProactiveChat__c
                            // GCRGenericProperties__c.getInstance('CHAT_PAGE').value__c 
                            + '?brand=' + gcr_TestUtility.DEFAULT_BRAND 
                            + '&country='+ gcr_TestUtility.DEFAULT_COUNTRY
                            + '&language=' + gcr_TestUtility.DEFAULT_LANGUAGE
                            + '&chatbotCase='+c.Id
                            + '&Source=Chatbot'
                            + '#deployment_id=' + lCareChannels.get(0).LADeploymentId__c
                            + '&button_id=' + lCareChannels.get(0).LAButtonId__c
                            + '&org_id=' + UserInfo.getOrganizationId().substring(0, 15)
                            + '&session_id='
                          , controller.endpoint);
        SYSTEM.assertEquals(lCareChannels.get(0).LAButtonId__c, controller.buttonId);
        SYSTEM.assertEquals(lCareChannels.get(0).LADeploymentId__c, controller.deploymentId);
    }
}