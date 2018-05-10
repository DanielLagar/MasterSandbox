/*
* @author: 		 Accenture
* @date: 		 25/05/2016
* @description:  Handshake class for GCR widget
* DATE					NAME					CHANGE DESCRIPTION
* 25/05/2016			Accenture				Initial Draft
* 21/11/2016			Accenture				Add referrer property and capture referrer detail
*/
public class gcr_WidgetHandshake {
    public class CustomException extends Exception{}

    public List<SelectOption> lCountry { get; set; }
    public List<GCRCareHub__c> lCareHub { get; set; }
    
    public String gcrFunctionality { get; set; }
    public Map<String, String> mGcrContentId { get; set; }
    public Boolean isChatVisited { get; set; }
    public Boolean isRightToLeft { get; set; }

    // PRODUCT SEARCH RELATED VARIABLES
    public List<gcr_emailUsPrbController.CaseProductWrapper> lCaseProduct { get; set; }
    public Case newCase { get; set; }
    public Contact newContact { get; set; }
    public Map<String, Boolean> mValidationMap { get; set; }
    public Boolean isProductSearch { get; set; }
    public Boolean isZipMandatory { get; set; }
    public Boolean isStateMandatory { get; set; }
    
    public String strKaUrlName { get; set; }
    // VARIBALE TO CAPTURE REFERRER DETAIL ON PAGE INTIALIZATION
    public String referer { get; set; }
    
    public gcr_WidgetHandshake() {
        this.mGcrContentId = new Map<String, String>();
        this.strKaUrlName = '';
        this.isChatVisited = false;
        // INTIALIZE REFERRER FROM HTTP REFERRER HEADER
        this.referer = ApexPages.currentPage().getHeaders().get('Referer');
    }
    
    public gcr_WidgetHandshake(List<gcr_emailUsPrbController.CaseProductWrapper> lCaseProduct, Case newCase, Contact newContact) {
        this.lCaseProduct = lCaseProduct;
        this.newCase = newCase;
        this.newContact = newContact;
    }
}