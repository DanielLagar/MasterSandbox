/*
* @author:       Accenture
* @date:         11/08/2016
* @description:  CR392 - Proactive Chat Controller class of redirecting to chat pages in salesforce.
* DATE              NAME                CHANGE DESCRIPTION
* 11/08/2016        Accenture           Initial Draft
* 10/01/2017        Accenture           WR440 - Changs to support no prechat chat for standalone and proactive chat
*/
public class gcr_proChatRedirectController {
    public String endpoint { private set; public get; } 
    public String buttonId { private set; public get; }
    public String deploymentId { private set; public get; }
    public String preChatPage { private set; public get; }
    public String brand { private set; public get; }
    public String handover { public set; public get; }
    public String chatbotCase { public set; public get; }
    public String sourceFromUrl { public set; public get; }
    public boolean isChatbot { public set; public get; }
    public String country { private set; public get; }
    public String language { private set; public get; }
    // WR440 - ADDED NEW CLASS PROPERTIES FOR NO PRECHAT SUPPORT
    public Boolean isPrechat { private set; public get; }
    public String chatType { private set; public get; }
    // WR508 - Chat Redsign - SHOW ERROR ON STANDALONE CHAT WHEN OUT OF BUSINESS HOURS OR AGENT NOT AVAILABLE
    public Boolean isBusinessHrsActive { private set; public get; }
    public Boolean isAgentAvailable { private set; public get; }
    public String errorMsg { private set; public get; }
    
    public gcr_proChatRedirectController() {
        // WR440 - DETERMINE IF REQUEST IS STANDALONE OR PROACTIVE
        String paramName = GCRGenericProperties__c.getInstance('PROCHAT_PARAM').value__c;
        chatType = String.isNotEmpty(ApexPages.currentPage().getParameters().get(paramName))
            	 ? ApexPages.currentPage().getParameters().get(paramName) : 'standalone';

        // GET PARAMETERS FROM REQUEST
        brand = ApexPages.currentPage().getParameters().get('brand');
        country = ApexPages.currentPage().getParameters().get('country');
        language = ApexPages.currentPage().getParameters().get('language');
        handover = ApexPages.currentPage().getParameters().get('handover');
        chatbotCase = ApexPages.currentPage().getParameters().get('chatbotCase');
        sourceFromUrl = ApexPages.currentPage().getParameters().get('Source');

        if (sourceFromUrl!=NULL && sourceFromUrl.containsIgnoreCase('Chatbot')){
            isChatbot = TRUE;
        }
        // preChatPage = GCRGenericProperties__c.getInstance('PRECHAT_PAGE').value__c;
        // WR440 - SELECT PRE CHAT PAGE BASED PROACTIVE AND STANDALONE IDENTIFIER
        preChatPage = String.isNotEmpty(chatType) 
            ? ChatPage__c.getInstance().ProactivePrechat__c 
            : ChatPage__c.getInstance().StandalonePreChat__c;

        if (String.isNotEmpty(brand) && String.isNotEmpty(country) && String.isNotEmpty(language)) {
            // GET WEB CONFIG FOR BRAND COUNTRY AND LANGUAGE
            sObject webConfig = gcr_apiHelper.getWebConfiguration(brand, country, language);
            if (webConfig != null) {
                // IF WEB CONFIG EXISTS THEN FETCH CHAT CONFIG FROM THE 
                gcr_proChatResponse.gcr_chatConfigData chatConfig 
                    = (gcr_proChatResponse.gcr_chatConfigData) 
                    	gcr_apiHelper.getChatConfiguration(webConfig
                                                         , chatType.equalsIgnoreCase('standalone') ? false : true);

                if (chatConfig != null && String.isNotEmpty(chatConfig.buttonId) && String.isNotEmpty(chatConfig.deploymentId)) {
                    buttonId = chatConfig.buttonId;
                    deploymentId = chatConfig.deploymentId;
                    isPrechat = chatConfig.prechatReq;
                    if(chatType.containsIgnoreCase('Chatbot') || chatType.equalsIgnoreCase('Handoff')){
                    	isPrechat = false;
                    }
                    
                    // WR508 - Chat Redsign - SHOW ERROR ON STANDALONE CHAT WHEN OUT OF BUSINESS HOURS OR AGENT NOT AVAILABLE
                    isBusinessHrsActive = gcr_helperClass.isBusinessHoursActive(chatConfig.businessHourId);
                    isAgentAvailable = gcr_helperClass.ischatBtnAvailable(chatConfig.deploymentId, chatConfig.buttonId);
                    if (!isBusinessHrsActive) errorMsg = chatConfig.outsideBusinessHrsMsg;
					else if (!isAgentAvailable) errorMsg = chatConfig.agentNotAvailableMsg;
                    
                    if (System.Site.getBaseUrl().toLowerCase().contains('carehub')
                     || System.Site.getBaseUrl().toLowerCase().contains('ContactUs')) {
                        endpoint = System.Site.getBaseUrl() + '/';
                    } else {
                        endpoint = System.Site.getBaseUrl() + '/apex/';
                    }
                    // WR440 - SELECT CHAT PAGE BASED PROACTIVE AND STANDALONE IDENTIFIER
                    endpoint += String.isNotEmpty(chatType) 
                        ? ChatPage__c.getInstance().ProactiveChat__c : ChatPage__c.getInstance().StandaloneChat__c;
                    endpoint += '?brand=' + chatConfig.brand + '&country=' + chatConfig.country + '&language=' + chatConfig.language;
                    if (string.isNotEmpty(chatbotCase)){
                        endpoint += '&chatbotCase='+chatbotCase;
                        setChatType(chatbotCase);
                    }
                    if (string.isNotEmpty(handover)){
                        endpoint += '&handover=true';
                    } 
                    
                    
                    if (ApexPages.currentPage().getParameters().get('Source') !=NULL ){
                        endpoint += '&Source='+ ApexPages.currentPage().getParameters().get('Source');
                    }  

                    endpoint += '#deployment_id=' + deploymentId + '&button_id=' + buttonId;
                    

                    endpoint += '&org_id=' + UserInfo.getOrganizationId().substring(0, 15) + '&session_id=';
                    brand = chatConfig.brand;
                    country = chatConfig.country;
                    language = chatConfig.language;



                } else {
                    // SHOW PAGE ERROR IF CHAT CONFIG NOT FOUND
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, Label.errMsgNoChatConfig));
                }
            } else {
                // SHOW PAGE ERROR IF CONFIG NOT FOUND FOR SELECTED BRAND COUNTRY LANGUAGE
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, Label.errMsgNoWebConfig));
            }
        } else {
            // SHOW PAGE ERROR IF EXPECTED PARAMETERS NOT RECEIVED
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, Label.errMsgNoExpParams));
        }
    }

    /*
     * @author:         Accenture
     * @date:           28/09/2017
     * @description:    Method to set the append the chat type to the actual provider name EX - "Chatbot - Coversible" + Handoff
     * @input:          String ID
     * @return:         VOID
     */
    private void setChatType(String chatbotCase){
        List<Case> caseObj = [SELECT ID,ChatType__c FROM Case WHERE ID = : chatbotCase LIMIT 1];
        if(!caseObj.isEmpty()){
            chatType =  caseObj.get(0).ChatType__c + '-' + chatType;
        }
    }
}