/*
* @author: Lauren OMeara
* @date: 07/31/2014

* @description:
* US668 - re-architect contact us page
*/

public class sf_ContactUsLanguageController {

    public static final String AGE_CAPTURE_MMYYYY = 'MM/YYYY';
    public static final String AGE_CAPTURE_RANGES = 'Age Range';
    public static String DEFAULT_LANGUAGE_NAME = 'Default';

    public static sf_ContactUsLanguageController instance {
        get {
            instance = new sf_ContactUsLanguageController();
            return instance;
        }
        set;
    }
    
    /*Below used to control if featured and/or Article 
    *summary is displayed as part of featured articles work
    *christopher.macduff@accenture.com
    */

    public static list<String> artNums{get;set;}
    public static String selectedLang{get;set;}
    public Boolean bl_display_featured {get;set;}
    public Boolean bl_display_summary {get;set;}

    public String languageCode {get; set;}
    public Boolean bl_show_facebook_link { get {return brand_language_config!=null && !string.isblank(brand_language_config.Link_URL_Facebook__c); } }
    public Boolean bl_show_twitter_link { get {return brand_language_config!=null && !string.isblank(brand_language_config.Link_URL_Twitter__c); } }
    public Boolean bl_show_pinterest_link { get {return brand_language_config!=null && !string.isblank(brand_language_config.Link_URL_Pinterest__c); } }
    public Boolean bl_show_Weibo_link { get {return brand_language_config!=null && !string.isblank(brand_language_config.Link_URL_Weibo__c); } }  //CDOY Added
    public Boolean bl_show_Wechat_link { get {return brand_language_config!=null && !string.isblank(brand_language_config.Link_URL_Wechat__c); } } //CDOY Added
    public Boolean bl_show_community_tab { get {return brand_language_config!=null && !string.isBlank(brand_language_config.Link_URL_Community_Site__c); } }
    public Boolean bl_show_live_chat_tab {get; set;}
    public Boolean bl_show_age_mmyyyy {get; set;}
    public Boolean bl_show_age_ranges {get; set;}
    public Boolean bl_show_ask_gender {get; set;}
    public Boolean isLastNameFirst {get; set;} //CDOY WR172
    public string displayWidget {get; set;} // CDOY WR285
    
    public Integer bl_case_minimum_age {get; set;} 

    public String currentLanguage {get; set;}
    public String currentCountry {get; set;}
    
    public Contact_Us_Language__c language_config {get; set;}
    public Contact_Us_Brand_Language__c brand_language_config {get; set;}
    
    public sf_ContactUsLanguageController(ApexPages.StandardController c) {
        this();
    }

    public sf_ContactUsLanguageController(sf_ContactUsTemplateController c) {
        this();
    }

    public sf_ContactUsLanguageController(sf_ContactUsHeaderComponentCtrl c) {
        this();
    }

    public sf_ContactUsLanguageController() {
        this(sf_ContactUsHelperCtrl.getLanguage(), sf_ContactUsHelperCtrl.getCountry(), sf_ContactUsHelperCtrl.getBrand());
    }

    public sf_ContactUsLanguageController(String language, String country, String brand) {
        
        language_config = null;

        String languageWhereClause = '(Country__c = :country and Language__c = :language) ';
        
        Map <String, String> subqueryWhereClauses = new Map <String, String> {
            'Contact_Us_Brands_Languages__r' => 'Contact_Us_Brand__r.name = :brand'
        };
        
        String languageQueryString = sf_ContactUsHelperCtrl.createSelectAllQueryString('Contact_Us_Language__c', languageWhereClause, (String)null, subqueryWhereClauses); //object, where, limit, subqueries
        //christopher.macduff@accenture.com
        system.debug('>>> lang query: '+languageQueryString);
        system.debug('>>> country: '+country);
        system.debug('>>> language: '+language);
        system.debug('>>> brand: '+brand);
        //
        
        List <Contact_Us_Language__c> languageRecords = (List <Contact_Us_Language__c>)Database.query(languageQueryString); 
        

        //try combination from page parameters
        if (languageRecords != null && !languageRecords.isEmpty()) {
            language_config = languageRecords[0];
        } else {
            System.debug('No Language Record found: country=' + country + ', language=' + language);
        }
        
        system.debug('>>> language_config: '+language_config);


        //no combination found need to try DEFAULT_LANGUAGE_NAME
        if (language_config == null) {

            languageWhereClause = ' name = :DEFAULT_LANGUAGE_NAME ';
            languageQueryString = sf_ContactUsHelperCtrl.createSelectAllQueryString('Contact_Us_Language__c', languageWhereClause, (String)null, subqueryWhereClauses); //object, where, limit, subqueries
            languageRecords = (List <Contact_Us_Language__c>)Database.query(languageQueryString); 

            if (languageRecords != null && !languageRecords.isEmpty()) {
                language_config = languageRecords[0];
            } else {
                 System.debug('No DEFAULT_LANGUAGE_NAME Language Record found...');
            }
        }

        if(language_config!=null) {
            currentLanguage = language_config.Language__c;
            currentCountry = language_config.Country__c;
            languageCode = language_config.Language_Locale_Key__c;
            isLastNameFirst = language_config.isLastNameFirst__c; //CDOY WR172

            
            if(language_config.Contact_Us_Brands_Languages__r.size()>0) {
                brand_language_config = language_config.Contact_Us_Brands_Languages__r[0];
            }
        }
        if(brand_language_config != null) {
            bl_show_live_chat_tab = brand_language_config.show_live_chat_tab__c;
            bl_show_ask_gender = brand_language_config.Case_Submit_Ask_Gender__c;
            bl_case_minimum_age = (Integer)brand_language_config.Case_Submit_Minimum_Age__c;
            bl_show_age_mmyyyy = bl_case_minimum_age!=null && brand_language_config.Age_Capture_Style__c == AGE_CAPTURE_MMYYYY;
            bl_show_age_ranges = brand_language_config.Age_Capture_Style__c == AGE_CAPTURE_RANGES;
            displayWidget = brand_language_config.Widget__c;
            
            /*Generating list of article numbers to pass to pkbCon to generate article data
            for pkb_3ct_featured to display christopher.macduff@accenture.com*/
            artNums = new List<String>();
            Set<String> dedupeArtNums = new Set<String>();
            
            bl_display_featured = false;
            bl_display_summary = brand_language_config.Display_Summary__c;
            if(!String.isBlank(brand_language_config.Featured_Article_1__c)){
                dedupeArtNums.add(brand_language_config.Featured_Article_1__c);
            }
            if(!String.isBlank(brand_language_config.Featured_Article_2__c)){
                dedupeArtNums.add(brand_language_config.Featured_Article_2__c);
            }
            if(!String.isBlank(brand_language_config.Featured_Article_3__c)){
                dedupeArtNums.add(brand_language_config.Featured_Article_3__c);
            }
            if(!String.isBlank(brand_language_config.Featured_Article_4__c)){
                dedupeArtNums.add(brand_language_config.Featured_Article_4__c);
            }
            if(!String.isBlank(brand_language_config.Featured_Article_5__c)){
                dedupeArtNums.add(brand_language_config.Featured_Article_5__c);
            }
            if(!dedupeArtNums.isEmpty()){
                bl_display_featured = true;
                artNums.addAll(dedupeArtNums);
            }
            selectedLang = languageCode;
            bl_display_summary = brand_language_config.Display_Summary__c;
        }
        else {
            //brand-language defaults
            bl_display_featured = false;
            bl_display_summary = false;
            bl_show_live_chat_tab = false;
            bl_show_ask_gender = false;
            bl_show_age_mmyyyy = false;
            bl_show_age_ranges = false;
            
        }
    }

    // convenience handle for passing to components
    public sf_ContactUsLanguageController getLangCon() { return this; }

}