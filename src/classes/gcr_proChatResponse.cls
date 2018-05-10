/*
* @author:          Accenture
* @date:            10/10/2016
* @description:     CR392 - Proactive Chat: Response class for proactive chat API which will have all responses sent 
*                   back from the api for selected Brand, Country and Language
* DATE              NAME                CHANGE DESCRIPTION
* 10/10/2016        Accenture           Initial Draft
* 13/12/2016        Accenture           Defect fix to map version 3 brand country language
*										Added 3 (brand, country, language) properties in gcr_chatConfigData class
* 11/01/2017        Accenture           WR-440 - Added another proeprty "prechatReq" in class "gcr_chatConfigData" 
*										which determins if prechat form is required for proactive chat
*/
global class gcr_proChatResponse {

    /*
     * @author:         Accenture
     * @date:           10/10/2016
     * @description:    Availability details class to have hold chat related details which is used
     *                  to return success data to the proactive chat api
     */
    public class gcr_availabilityDetail extends gcr_proResponseInterface {
        public Boolean withinBusinessHours;
        public Boolean isAgentActive;
        public String chatImage;
        public String chatUrl;
        
        public gcr_availabilityDetail() {
            this.withinBusinessHours = false;
            this.isAgentActive = false;
            this.chatImage = 'NA';
            this.chatUrl = 'NA';
        }
    }
    
    /*
     * @author:         Accenture
     * @date:           10/10/2016
     * @description:    Availability details class to have hold error details which is used to return 
     *                  error data to the proactive chat api
     */
    public class gcr_errorResponse extends gcr_proResponseInterface {
        public String errorCode;
        public String errorMessage;
    }
    
    /*
     * @author:         Accenture
     * @date:           10/10/2016
     * @description:    Availability details class to have hold error details which is used to capture
     *                  success data to the proactive chat api
     */
    public class gcr_chatConfigData {
        public String chatImageUrl;
        public String buttonId;
        public String deploymentId;
        public String businessHourId;
        public String appSite;
        // ADDED BRAND COUNTRY LANGUAGE
        public String brand;
        public String country;
        public String language;
        // ADDED A BOOLEAN TO IDENTIFY IF PRECHAT FORM IS REQUIRED
        public Boolean prechatReq;
        // WR508 - Chat Redsign - ADDED FOLLOWING PARAMS TO SUPPORT/PASS ERROR MESSAGES
        public String outsideBusinessHrsMsg;
        public String agentNotAvailableMsg;
    }
    
    /*
     * @author:         Accenture
     * @date:           10/10/2016
     * @description:    Interface to have success and error response
     */
    global virtual class gcr_proResponseInterface {
        public Boolean isSuccess;
    }
}