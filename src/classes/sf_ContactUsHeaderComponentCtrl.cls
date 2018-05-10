/*
* @author: Lauren OMeara
* @date: 07/31/2014

* @description:
* US668 - re-architect contact us page
*/
public with sharing class sf_ContactUsHeaderComponentCtrl {

    // header brand config
    public String headerImageURL {get; set;}
    public List<Telephony__c> telephonyList {get; set;}
    public List<Telephony__c> frenchTelephonyList {get; set;}//Used to display French numbers
    public Telephony__c telephony {get; set;}
    public String telephonyString {get; set;}
    public String operationalHours {get; set;}
    //variables for header picklists
    public Contact_Us_Language__c langconfig {get; set;}
    public Contact_Us_Brand__c brandconfig {get; set;}
    public String selectedBrand {get; set;}
    public String selectedLanguage {get; set;}
    public String selectedCountry {get; set;}
    public sf_ContactUsHeaderComponentCtrl headerCon {get; set;}
    public Boolean isDuringBusinessHours {get; set;}

    //language controller
    public sf_ContactUsLanguageController langCon {get; set;}

    public sf_ContactUsHeaderComponentCtrl() {

        selectedBrand = sf_ContactUsHelperCtrl.getBrand();

        if (String.isEmpty(selectedBrand))
          selectedBrand = sf_ContactUsHelperCtrl.DEFAULT_BRAND;

        String brandWhereClause = ' brand__c = :selectedBrand ';
        
        String brandQueryString = sf_ContactUsHelperCtrl.createSelectAllQueryString ('Contact_Us_Brand__c', brandWhereClause, ' 1 '); //object, where, limit
        
        List <Contact_Us_Brand__c> brandConfigList = (List <Contact_Us_Brand__c>) Database.query(brandQueryString);

        System.debug('**sf_ContactUsHeaderComponentCtrl*** brandConfigList '+ brandConfigList);
        // brand config not found, fall back to default
        
        if (brandConfigList == null) { //get default brand
            brandConfigList = (List <Contact_Us_Brand__c>) Database.query(sf_ContactUsHelperCtrl.createSelectAllQueryString ('Contact_Us_Brand__c', 'brand__c = \'' + sf_ContactUsHelperCtrl.DEFAULT_BRAND +  '\'' , ' 1 '));
        }
        
        System.debug('***sf_ContactUsHeaderComponentCtrl** brandConfigList ' + brandConfigList);

        if (!brandconfigList.isEmpty()) {
            //at this point if no default brand found it crashes anyways. There HAS to be at least one brand record
            brandconfig =  brandConfigList[0];
            headerImageURL = brandConfigList [0].URL_Header_Image__c;
        }

        langCon = new sf_ContactUsLanguageController ();
        selectedLanguage = langCon.currentLanguage;
        selectedCountry = langCon.currentCountry;
        
        telephonyString = '';

        setTelephony();

        //7/21/2015 - sfdc
        //determine if page is loaded during business hours (live agent)
        List <BusinessHours> defaultBhList = new List <BusinessHours> ([SELECT Id FROM BusinessHours WHERE IsDefault=true]);

        Id bhId = langCon.brand_language_config.Business_Hours__c;
        bhId = (bhId == null && !defaultBhList.isEmpty()) ? bhId = defaultBhList[0].Id : bhId; 

        isDuringBusinessHours = bhId != null ? BusinessHours.isWithin(bhId, System.now()) : false;
    }

    //Sylvester Agyen (Appirio, Inc) 
    //Used for displaying Telephony fields on ContactUsHeader
    public void setTelephony(){
        
        //Query for records that match current page's country, language and brand
        telephonyList = [select id,Contact_Us_Brand__c, Contact_Us_Brand__r.Name, Country__c,Language__c,ITFS_Number__c,ITFS_Status__c,
                                                   Visible_to_contact_us_pages__c,LocalOperationalHours__c,localBrand__c,Country_Has_1_Phone_Number__c,
                                                   Telephony_for_Multiple_Brands__c,Phone_Charge_Type__c, Phone_Colour__c
                                            from Telephony__c 
                                            where Country__c=:langCon.currentCountry AND Visible_to_contact_us_pages__c=true AND ITFS_Status__c='Active' ];

        if(telephonyList.size() >0){
            List<Telephony__c> results = new List<Telephony__c>(); //hold telephonies to display 
            frenchTelephonyList = new List<Telephony__c>(); //French numbers to display
            
            //check for criteria. //country uses 1 phone # for all brands
            for(Telephony__c tel : telephonyList){
                if((tel.ITFS_Number__c != null && tel.ITFS_Number__c != '') && tel.Country_Has_1_Phone_Number__c == true ){ 
                    results.add(tel);
                    break;
                }
            }
            
            // match specific telephony
            for(Telephony__c tel : telephonyList){
                if((tel.ITFS_Number__c != null && tel.ITFS_Number__c != '') && tel.Language__c ==langCon.currentLanguage && tel.Contact_Us_Brand__r.Name == selectedBrand ){ 
                    results.add(tel);
                    frenchTelephonyList.add(tel);
                }
            }
            
           
            //Build telephony String
            if(results.size() > 0){
                for(Telephony__c tel: results){
                    telephonyString = telephonyString + ('  ' +tel.localBrand__c + ' ☎ '+ tel.ITFS_Number__c +'   //');
                }
                
                operationalHours = results[0].LocalOperationalHours__c;
            }
            
            if(telephonyString != '' && telephonyString != null ){
				telephonyString = telephonyString.substring(0, telephonyString.length()-2);
            }
            
            system.debug('@@@telephonyString: ' + telephonyString);
        }      
    } //end telephony

    public boolean isDefaultBrand {
        get {
            return selectedBrand == sf_ContactUsHelperCtrl.DEFAULT_BRAND;
        }
    }

    //Christopher.macduff@accenture.com - modify this
    //Not redirecting correctly post search
    public PageReference goPKB() {
        return redirectTo( Page.pkb_Home );
    }

    public PageReference goEmailUs() {
        return redirectTo( Page.EmailUs );
    }

    public List <SelectOption> getCountryList () {
        List <Contact_Us_Language__c> contactUsLanguages = new List <Contact_Us_Language__c> ();

        if (selectedBrand != sf_ContactUsHelperCtrl.DEFAULT_BRAND) {

            //need to not swow options that don't exist
            List <Contact_Us_Brand_Language__c> cblList = 
            new List <Contact_Us_Brand_Language__c> ([SELECT Id
                                                            ,Contact_Us_Brand__r.Brand__c
                                                            ,Contact_Us_Language__c 
                                                    FROM Contact_Us_Brand_Language__c
                                                    WHERE Contact_Us_Brand__r.Brand__c = :selectedBrand
                                                    ORDER BY Contact_Us_Language__r.Country__c
                                                    LIMIT 1000
                                                    ]);

            Set <Id> conLangSet = new Set <Id> ();

            for (Contact_Us_Brand_Language__c cbl: cblList) {
                conLangSet.add (cbl.Contact_Us_Language__c);
            }

            contactUsLanguages = [SELECT Id
                                        ,Country_Picklist_Label__c
                                        ,Country__c
                                        ,Language__c
                                FROM Contact_Us_Language__c
                                WHERE Id IN :conLangSet
                                ORDER BY Country_Picklist_Label__c
                                LIMIT 1000];
        } else {
            contactUsLanguages = [SELECT Id
                                        ,Country_Picklist_Label__c
                                        ,Country__c
                                        ,Language__c
                                FROM Contact_Us_Language__c
                                ORDER BY Country_Picklist_Label__c
                                LIMIT 1000];
        }
        



        List <SelectOption> countryOptions = new List <SelectOption> ();

        //if (langCon.language_config.Country_Please_Select__c != null)
            //countryOptions.add (new SelectOption ('', langCon.language_config.Country_Please_Select__c));

        Map <String, String> countryMap = new Map <String, String> ();
        for (Contact_Us_Language__c cul: contactUsLanguages) {
            countryMap.put (cul.Country__c, cul.Country_Picklist_Label__c);
        }

        List <String> sortedCountry = new List <String> ();
        sortedCountry.addAll(countryMap.keySet());
        sortedCountry.sort();

        for (String s: sortedCountry) {
            if (s != null && countryMap.get(s) != null)
                countryOptions.add (new SelectOption (s, countryMap.get(s)));
        }

        return countryOptions;

    }

    public List <SelectOption> getLanguageList () {
        List <SelectOption> langOptions = new List <SelectOption> ();
        List <Contact_Us_Language__c> contactUsLanguages = new List <Contact_Us_Language__c> ();

        
        contactUsLanguages = [SELECT Id
                                    ,Language_Picklist_Label__c
                                    ,Language__c
                            FROM Contact_Us_Language__c
                            WHERE Country__c = :selectedCountry
                            ORDER BY Language_Picklist_Label__c
                            LIMIT 1000];


        //if (langCon.language_config.Language_Please_Select__c != null)
        //  langOptions.add(new SelectOption ('', langCon.language_config.Language_Please_Select__c));
        
        Map <String, String> langMap = new Map <String, String> ();

        for (Contact_Us_Language__c cul: contactUsLanguages) {
            langMap.put(cul.Language__c, cul.Language_Picklist_Label__c);
        }

        List <String> sortedLang = new List <String> ();
        sortedLang.addAll(langMap.keySet());
        sortedLang.sort();

        for (String s: sortedLang) {
            if (s != null && langMap.get(s) != null)
                langOptions.add (new SelectOption (s, langMap.get(s)));
        }
		//Chris: Causes bug prevents redirect if the country selected has multiple language and En-US is not supported
        //if (langOptions.size()==1) selectedLanguage = langOptions[0].getValue();
        if (langOptions.size()==1){
			selectedLanguage = langOptions[0].getValue();
        }
        else{
            if(!langMap.containsKey(selectedLanguage)){
				selectedLanguage = langOptions[0].getValue();
            }
        }
        return langOptions;
    }


    //populate brands 
    public List <SelectOption> getBrandSelectList() {
        //return sf_BrandHelper.getBrandSelectList();
        //ALM 626
        //pulling brands from configs. no config no brand in the menu

        List <SelectOption> brandOptions = new List <SelectOption>();
        String selectLabel = sf_ContactUsLanguageController.instance.language_config.Brand_Please_Select__c;
        if (selectLabel==null) selectLabel = ''; 
        brandOptions.add(new SelectOption(sf_ContactUsHelperCtrl.DEFAULT_BRAND, selectLabel));


        List <Contact_Us_Brand_Language__c> cblList = 
                            new List <Contact_Us_Brand_Language__c> ([SELECT Id
                                                                            ,Contact_Us_Brand__r.Brand__c
                                                                    FROM Contact_Us_Brand_Language__c
                                                                    WHERE Contact_Us_Language__r.Country__c = :selectedCountry
                                                                    AND Contact_Us_Language__r.Language__c = :selectedLanguage
                                                                    ORDER BY Contact_Us_Brand__r.Brand__c
                                                                    LIMIT 1000
                                                                    ]);

        Set <String> brandSet = new Set <String> ();

        for (Contact_Us_Brand_Language__c cbl: cblList) {
            brandSet.add (cbl.Contact_Us_Brand__r.Brand__c);
        }
 
        List <String> brands = new List <String> ();
        brands.addAll(brandSet);
        brands.sort();

        for (String s: brands) {
            if (s != sf_ContactUsHelperCtrl.DEFAULT_BRAND) //we already used default brand in the beginning
                brandOptions.add(new SelectOption (s,s));
        }

       // if (brandOptions.size()==1) selectedBrand = brandOptions[0].getValue();
                                                                    
        return brandOptions;
    }

    
 
    public PageReference processCountrySelect () {

        PageReference pref = ApexPages.currentPage();
        pref.getParameters().put ('country', selectedCountry);
        pref.getParameters().put('brand',selectedBrand);
        
        if (getLanguageList().size()>=1) {
            pref.getParameters().put ('language', selectedLanguage);
        } 

        //langCon = new sf_ContactUsLanguageController();
        pref.setRedirect(false);
        return pref;    
    }

    public PageReference processLanguageSelect () {
        PageReference pref = ApexPages.currentPage();
        pref.getParameters().put('country',selectedCountry);
        pref.getParameters().put ('language', selectedLanguage);
        pref.getParameters().put('brand',selectedBrand);

        //langCon = new sf_ContactUsLanguageController();
        pref.setRedirect(false);
        return pref;
    }

    public PageReference processBrandSelect () {
        PageReference pref = ApexPages.currentPage();
        pref.getParameters().put('country',selectedCountry);
        pref.getParameters().put('language',selectedLanguage);
        pref.getParameters().put('brand',selectedBrand);
        //langCon = new sf_ContactUsLanguageController();
        pref.setRedirect(true);
        return pref;
    }

    private PageReference redirectTo(PageReference pageRef) {
        System.debug('redirecting (' + pageRef +') with ' + selectedLanguage
            + ' and ' + selectedCountry + ' and ' + selectedBrand);
		//Make sure q param is cleared
        //christopher.macduff@accenture.com
        pageRef.getParameters().clear();
        pageRef.getParameters().put('country',selectedCountry);
        pageRef.getParameters().put('language',selectedLanguage);
        pageRef.getParameters().put('brand',selectedBrand);

        pageRef.setRedirect(false);

        return pageRef;
    }


    public String getChatStartUrl () {

        ContactUsURL__c contactUsURl = ContactUsURL__c.getInstance();

        //get chat session id and affinity token
        Http h = new Http();
        HttpRequest req = new HttpRequest ();
        req.setMethod('GET');
        req.setEndpoint(contactUsURl.Live_Agent_Endpoint__c + '/chat/rest/System/SessionId');
        req.setHeader('X-LIVEAGENT-API-VERSION', '32');
        //req.setHeader('X-LIVEAGENT-AFFINITY', null); //this needs to be explicitly null if you need affinityId back...
        HttpResponse resp;
        if (!Test.isRunningTest())
            resp = h.send(req);

        else {
            resp = new HttpResponse ();
            resp.setStatus('OK');
            resp.setStatusCode(200);
            resp.setBody('{"clientPollTimeout": 40,"key": "1f905a4c-8b3e-4a93-a1fd-90e8ebb37eaa!32980c4c-06da-487b-8767-029c0a58a38f","id": "1f905a4c-8b3e-4a93-a1fd-90e8ebb37eaa"}');  
        }
        System.debug(resp);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());

        PageReference chatPage = Page.sf_PreChatForm;

        String params = '';
        params += 'language=' +  EncodingUtil.urlEncode(selectedLanguage == null ? 'en' : selectedLanguage, 'UTF-8');
        params += '&brand=' + EncodingUtil.urlEncode(selectedBrand == null ? 'P&G' : selectedBrand, 'UTF-8');
        params += '&country=' + EncodingUtil.urlEncode(selectedCountry == null ? 'United States of America' : selectedCountry, 'UTF-8');

        //create endpoint parameter


        String endpoint = System.Site.getBaseUrl() + '/sf_ContactUsChat?';
        endpoint += 'language=' + EncodingUtil.urlEncode(selectedLanguage == null ? 'en' : selectedLanguage, 'UTF-8');
        endpoint += '&brand=' +  EncodingUtil.urlEncode(selectedBrand == null ? 'P&G' : selectedBrand, 'UTF-8'); //double encode the damn & sign
        endpoint += '&country=' +  EncodingUtil.urlEncode(selectedCountry == null ? 'United States of America' : selectedCountry , 'UTF-8');
        endpoint += '#deployment_id=' + langCon.brand_language_config.Live_Agent_Deployment_Id__c;
        endpoint += '&org_id=' + UserInfo.getOrganizationId().substring(0, 15);
        endpoint += '&button_id=' + langCon.brand_language_config.Live_Agent_Button_Id__c;
        endpoint += '&session_id=' + String.valueOf(m.get('id'));
        

        //chatPage.getParameters().put('endpoint', System.Site.getBaseUrl() + '/sf_ContactUsChat');
        //chatPage.getParameters().put('deployment_id', '572Q000000000Cs');
        //chatPage.getParameters().put('org_id', '00DQ000000GJmnJ');
        //chatPage.getParameters().put('button_id', '573Q000000000Dl');
        //chatPage.getParameters().put('session_id', String.valueOf(m.get('id')));
        //chatPage.getParameters().put('country',selectedCountry);
       // chatPage.getParameters().put('language',selectedLanguage);
       // chatPage.getParameters().put('brand',selectedBrand);

       chatPage.getParameters().put('endpoint', endpoint);
        System.debug(chatPage.getParameters());

        

        return contactUsURl.URL__c + '/sf_PreChatForm?'+ params +'&endpoint=' + EncodingUtil.urlEncode(endpoint, 'UTF-8');
    }
}