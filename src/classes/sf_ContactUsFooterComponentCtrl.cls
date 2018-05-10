/*
* @author: Lauren OMeara
* @date: 07/31/2014

* @description: 
* US668 - re-architect contact us page
*/
public with sharing class sf_ContactUsFooterComponentCtrl {
	// footer language config values
	public String termsAndConditions {get; set;}
	public String privacy {get; set;}	
	public String termsAndConditionsURL {get; set;}
	public String privacyURL {get; set;}
    //WR225 CRM banner
    public Contact_Us_Brand_Language__c brand_lang_config {get;set;}
    public boolean showBanner {get;set;}
		
	public sf_ContactUsFooterComponentCtrl() {
		string language = sf_ContactUsHelperCtrl.getLanguage();
		string country = sf_ContactUsHelperCtrl.getCountry();
        string brand = sf_ContactUsHelperCtrl.getBrand(); //WR225
        showBanner = String.isBlank(ApexPages.currentPage().getParameters().get('surveyid')); //WR225 do not display if on CSAT page

		/* get language config for footer */
		List<Contact_Us_Language__c> language_config = [SELECT 
			Terms_and_Conditions__c, Privacy__c, URL_Terms_and_Conditions__c, URL_Privacy_Policy__c 
			FROM Contact_Us_Language__c 
			WHERE Country__c=:country AND Language__c=:language ];
			
		system.debug('***** language config '+language_config);
		// country & language config not found, fall back to default
		if (language_config.size() == 0) {
			language_config = [SELECT 
				Terms_and_Conditions__c, Privacy__c, URL_Terms_and_Conditions__c, URL_Privacy_Policy__c 
				FROM Contact_Us_Language__c 
				WHERE Country__c='United States of America' AND Language__c='English-US' ];
		}
		system.debug('***** language config '+language_config);
		
		termsAndConditions = language_config[0].Terms_and_Conditions__c;
		privacy = language_config[0].Privacy__c;
		termsAndConditionsURL = language_config[0].URL_Terms_and_Conditions__c;
		privacyURL = language_config[0].URL_Privacy_Policy__c;
        
        //WR225 Start
        //Language/Brand/Country should be a unique combination
        List<Contact_Us_Brand_Language__c> blcList = new List<Contact_Us_Brand_Language__c>([SELECT Id, Signup_Blurb__c, Signup_Button_Label__c, Signup_Image__c, signup_URL__c
                             FROM Contact_Us_Brand_Language__c
                             WHERE Contact_Us_Language__r.Language__c = :language
                             AND Contact_Us_Language__r.Country__c = :country
                             AND Contact_Us_Brand__r.Brand__c = :brand
                            ]);
        //If none found find the "default" record
        if(blcList.size()==0){
            brand_lang_config = [SELECT Id, Signup_Blurb__c, Signup_Button_Label__c, Signup_Image__c, signup_URL__c
                                 FROM Contact_Us_Brand_Language__c
                                 WHERE Contact_Us_Language__r.Name = 'Default'
                                 AND Contact_Us_Brand__r.Name = 'P&G'
                                 LIMIT 1 //Just in case...
                                ];
        }
        else{
            brand_lang_config = blcList[0];
        }
        system.debug('>>> brand_lang_config: '+brand_lang_config);
        if(String.isBlank(brand_lang_config.Signup_Image__c)){
            showBanner = false;
        }
        //WR225 Fin

	}
    
}