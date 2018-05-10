/**
* @author: Laure OMeara
* @date: 07/31/2014
*
* @description: 
* US668 - re-architect contact us page
*
* @changes:
* 21-10-2015
* Removing meta site/auto response functionality
* as converting to standard auto response rules
* christopher.macduff@accenture.com
*/

public with sharing class sf_EmailUsExt {

    private static final String TOO_YOUNG_COOKIE = 'EmailUsTooYoung';
    private static final String COOKIE_PATH_ANY = '/';
    private static final Integer SESSION_COOKIE = -1;
    private static final Boolean COOKIE_NOT_SECURE_ONLY = false;
    public Boolean displayFirstAddressOption {get;set;} //CDOYWR363
    public Boolean displaySecondAddressOption {get;set;} //CDOYWR363
    public Boolean displayThirdAddressOption {get;set;} //CDOYWR363
    public Boolean displayFourthAddressOption {get;set;} //CDOYWR363

    //Language Configuration
    public Contact_Us_Language__c lang_config {get; private set;}
    
    //WR236 ChrisM - Salutation field
    //To be confirmed if required 27th April 2016
    public String salutation {get;set;}
    public list <SelectOption> salutations {
        
        get{
            if(salutations==null){
				Salutations = new List<SelectOption>();
				list <Metadata_Title_Prefix__c> salutationList = [SELECT  id, Prefix__c, Full_Title__c
                                                                  FROM Metadata_Title_Prefix__c
                                                                  WHERE Country__c =: template_country AND Language__c =: language
                                                                  ORDER BY Prefix__c ASC ];
                
				salutations.add(new SelectOption('', '--None--'));//Get default value from language record
				for(Metadata_Title_Prefix__c m: salutationList){
                    if(!String.IsBlank(m.Prefix__c)){
                    	Salutations.add(new SelectOption(m.Prefix__c, m.Prefix__c));   
                    }
				}
			}
            return salutations;
        }
		set;
    }

    /** form fields */
    public String lastName { get; set; }
    public String firstName { get; set; }
    public String email { get; set; }
    public String phone { get; set; }
    public String birthdate { get; set; }
    public String agerange { get; set; }
    public String comment { get; set; }    
    public String productsearch { get; set; }
    public String segment { get; set; }
    
    //Contact Address Fields
    public String primaryAddressZipPostalCode { get; set; }
    public String primaryAddressAddresLine1 { get; set; }
    public String primaryAddressTownCity { get; set; }
    public String primaryAddressAddresLine2 { get; set; }
    public String primaryAddressStateProvinceCounty { get; set; }
     public String primaryAddressAddresLine3 { get; set; } //CDOYWR363
    public String overridePrimaryAddress {get;set;}
	
	public String serviceSuggestedAddressLine1{get; set;}
	public String serviceSuggestedAddressLine2{get; set;}
	public String serviceSuggestedAddressLine3{get; set;} //CDOYWR363
    public String serviceSuggestedAddressCity{get; set;}
    public String serviceSuggestedAddressState{get; set;}
    public String serviceSuggestedAddressZip{get; set;}
  
   	public String formattedUserInputWithHTMLBreaksAndColors {get; set;}
   	public String formattedAddressWithHTMLBreaks  {get; set;}

    public List <AdditionalQuestion> additionalQuestions {get; set;}
    public String additionalQuestionsSectionClasses {get; set;}
    public String selectedReasonForWritingClass {get; set;}
    
    

	/** page variables */
    public String brand { get; set; }
    public String language { get; set; }
    public String template_country { get; set; }

    public Case newCase{get;set;}
    public Case caseForFilter{get;set;}
    public Contact newContact{get;set;}


    //added 2/1/2016 by Ian Barker to make zip and state fields dynamically required on Email Us page
    public Boolean isZipRequired {
        get {
            Country_Status__c cs = Country_Status__c.getInstance(newContact.Country__c);
            return (cs != null) ? cs.Uses_Postal_Codes__c : false;
        }
        set;
    }
    public Boolean isStateRequired {
        get{
            Country_Status__c cs = Country_Status__c.getInstance(newContact.Country__c);
            return (cs != null) ? cs.Uses_States__c : false;
        }
        set;
    }
    
    /** language helper */
    public sf_ContactUsLanguageController langCon {get; set;}   

    public String defaultProductImageUrl {
        get {
            if (defaultProductImageUrl == null) {
                String resourceName = 'sf_missingProductImage';
                List<StaticResource> resourceList= [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName];
                if (resourceList.size() == 1) {
                    // Getting namespace
                    String namespace = resourceList[0].NamespacePrefix;
                    // Resource URL
                    defaultProductImageUrl = '/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + resourceName;
                }
            }
            return defaultProductImageUrl;
        }
        private set;
    }
    
    public Integer prodImageWidth {
        get {
            if (prodImageWidth == null) prodImageWidth = 65;
            return prodImageWidth;
        } 
        private set;
    }
    
    public Integer prodImageHeight {
        get {
            if (prodImageHeight == null) prodImageHeight = 65;
            return prodImageHeight;
        } 
        private set;
    }
    /** end should this be pulled from brand config */
    
    public List <SelectOption> reasons {get; private set;}
    
    public sf_ContactUsTemplateController mainCtrl;
    
    public String emailAboutProducts {get; set;}

    //US764 adding search terms to capture for product search
    public String productSearchTermText {get; set;}

	//US760 adding selected GTIN to the case product
	public String selectedGTIN {get; set;}

    //US768 create a map of reasons
    private Map <String, String> reasonsMap;

    //primarily used to check if brand filter is needed on search
    public Contact_Us_Brand__c brand_config;

    //CONSTRUCTOR
    public sf_EmailUsExt (sf_ContactUsTemplateController mainCtrl) {
        this.mainCtrl = mainCtrl;
        init (mainCtrl);
    }

    public void init (sf_ContactUsTemplateController mainCtrl) {
        try {
            //this.mainCtrl = mainCtrl;
            langCon = new sf_ContactUsLanguageController ();
            brand_config = mainCtrl.brand_config;
        
            newCase = new Case();
            caseForFilter = new Case();
            newCase.Status = sf_Constants.EMAILUS_DEFAULT_STATUS;
            newCase.OwnerId = sf_ContactUsHelperCtrl.getSysAdmin().Id;
            newContact = new Contact();
           
            
            if (!String.isEmpty(ApexPages.currentPage().getParameters().get('debug'))) {
                firstName = 'Debug First Name';
                lastName = 'Debug Last Name';
                phone = '612682721'; 
                email = 'test123@tester.com';
                primaryAddressAddresLine1 = 'One Market Street';
                primaryAddressZipPostalCode = '99023';
                primaryAddressTownCity = 'San Francisco';
                primaryAddressStateProvinceCounty = 'CA';

                
                newCase.Summary__c = 'Bacon ipsum dolor sit amet occaecat anim voluptate, ';
                newCase.Summary__c += 'pork chop drumstick boudin irure tempor enim ut biltong short loin et.';
                newCase.Summary__c += 'Aliqua occaecat commodo meatloaf kevin short ribs shank, fugiat veniam t-bone sausage chuck tempor pork belly nulla. Brisket salami';
                
                newCase.reason = 'Ask a question';
            }

            language = sf_ContactUsHelperCtrl.getLanguage();
            template_country = sf_ContactUsHelperCtrl.getCountry();
            brand = sf_ContactUsHelperCtrl.getBrand();

            system.debug('***** language  '+language+ ' template_country '+ template_country);
            
            /** get language config for header */
            lang_config = null; //clear it for page reload
            lang_config = langCon.language_config;
            System.debug(LoggingLevel.INFO, '***** assigning lang_config \n '+lang_config);

            newCase.Country__c = template_country;
            newContact.Country__c = template_country;
            caseForFilter.Country__c = template_country;
            
            // prepare reason drop down 
            reasons= new List <SelectOption> ();
            reasons.add(new SelectOption('', lang_config.Reason_Please_Select__c));
            reasons.add(new SelectOption(lang_config.Reason_1__c, lang_config.Reason_1__c));
            reasons.add(new SelectOption(lang_config.Reason_2__c, lang_config.Reason_2__c));
            reasons.add(new SelectOption(lang_config.Reason_3__c, lang_config.Reason_3__c));
            reasons.add(new SelectOption(lang_config.Reason_4__c, lang_config.Reason_4__c));
            reasons.add(new SelectOption(lang_config.Reason_5__c, lang_config.Reason_5__c));
            reasons.add(new SelectOption(lang_config.Reason_6__c, lang_config.Reason_6__c));

            reasonsMap = new Map <String, String> ();
            reasonsMap.put ('', '0'); //just in case :)
            reasonsMap.put (lang_config.Reason_1__c, '1');
            reasonsMap.put (lang_config.Reason_2__c, '2');
            reasonsMap.put (lang_config.Reason_3__c, '3');
            reasonsMap.put (lang_config.Reason_4__c, '4');
            reasonsMap.put (lang_config.Reason_5__c, '5');
            reasonsMap.put (lang_config.Reason_6__c, '6');
                    
            // prepare sitespageurl for case
            String path = ApexPages.currentPage().getUrl();
            sitespageURL = Site.getBaseUrl() +  path.replace('/apex/', '');     
            System.debug(LoggingLevel.INFO, 'sitespageURL = ' + sitespageURL);

            additionalQuestions = new list<AdditionalQuestion>();
            Set <String> sectionClasses = new Set <String>(); 
            for(integer i=1;i<=10;i++) {
                AdditionalQuestion q = new AdditionalQuestion(i, langCon.brand_language_config);
                if(q.inUse) {
                    sectionClasses.addAll( q.reasonsForWritingClasses.split(' ', 0) );
                    additionalQuestions.add(q);
                }
            }
            List <String> sectionClassList = new List <String>();
            sectionClassList.addAll(sectionClasses);
            additionalQuestionsSectionClasses = String.join(sectionClassList, ' ');
            
            
            //CDOYWR363 Change Display different address options based on country START
            system.debug('***CDOY*** '+ newContact.Country__c);
            
            displaySecondAddressOption = False;
            displayThirdAddressOption = False;
            displayFourthAddressOption = False;
            displayFirstAddressOption = False;
            
            if(newContact.Country__c == 'Argentina' || newContact.Country__c == 'Germany'){
                displaySecondAddressOption = True;    
            }
           
            else if(newContact.Country__c == 'China'){
                displayThirdAddressOption = True;    
            }
            
            else if(newContact.Country__c == 'Japan'){
                displayFourthAddressOption = True;    
            }
            
            else{
                displayFirstAddressOption = True;    
            }
            //CDOYWR363 Change Display different address options based on country END

            
        } catch (Exception e) {
            System.debug('Error occurred while loading emailUs page. \n ' + e + '- ' + e.getStackTraceString());
            ApexPages.addMessages (e);  
        }
    }
    
    /** form handling */
    private string oriURL {
        get{
            if(String.isEmpty(oriURL)) oriURL = 'all';
            return oriURL;
        }
        set;
    }

    public string sitespageURL{
        get{
            if(sitespageURL.length()>255) sitespageURL = sitespageURL.subString(0,254);
            return sitespageURL;
        }
        set;
    }
    
    /**  
    *   @Date: 08/25/2014
    *   @Author: orikkers@salesforce.com 
    *   @Description: US402. Retrieve Notification_Templates__c custom settings to get template to be used for autoresponse when case is created.
    */
    private Notification_Templates__c getNotificationTemplate(String strBrand, String strLanguage){
        Notification_Templates__c notificationTemplate;
        System.debug(LoggingLevel.INFO, '############# strbrand: '+ strbrand);
        System.debug(LoggingLevel.INFO, '############# strlanguage: '+ strlanguage);
        List<Notification_Templates__c> templates = Notification_Templates__c.getall().values();
        for(Notification_Templates__c nt : templates){
            if(nt.brand__c == strbrand && nt.Language__c == strlanguage){
                notificationTemplate = nt;
                break;
            }
        }

        //if notificationTemplate is null, then search the custom setting with just only by language.
        if(notificationTemplate == null){
            for(Notification_Templates__c nt : templates){
                if(String.isBlank(nt.brand__c) && nt.Language__c == strlanguage){
                notificationTemplate = nt;
                break;
                }
            }
        }

        return notificationTemplate;
    }
    
    
    /**  
    *   @Date: 08/25/2014
    *   @Author: orikkers@salesforce.com 
    *   @Description: US402. Retrieve Metadata_Site_Rule__c custom object to determine necessary actions 
    */
    //Christopher.macduff@accenture.com to be replaced with oob SF auto response rules
    /*private Metadata_Site_Rule__c getSiteRule(String country 
                                                ,String brand
                                                ,String priority
                                                ,String lang
                                                ,String summary
                                                ,String reasonForWriting){
        Metadata_Site_Rule__c matchedSiteRule;
        
        System.debug(LoggingLevel.INFO, 'Getting Metadata_Site_Rule__c for country: '+country+' brand: '+brand+' priority: '+priority+' lang: '+lang+' reasonForWriting: '+reasonForWriting);
        
        List<Metadata_Site_Rule__c> msrList = new List<Metadata_Site_Rule__c>([SELECT Keywords__c
                                                                                        ,Action__c
                                                                                        ,Third_Party_Email_Address__c
                                                                                        ,Third_Party_Email_Subject__c
                                                                                        ,AutoResponse_FromName__c
                                                                                        ,Email_Address__c
                                                                                        ,AutoResponse_Template_Name__c
                                                                                FROM Metadata_Site_Rule__c
                                                                                WHERE Country__c includes (:country) 
                                                                                AND Brand__c includes (:brand) 
                                                                                AND Language__c = :lang 
                                                                                AND Priority__c includes (:priority) 
                                                                                AND  Reason_for_Writing__c includes (:reasonForWriting)
                                                                                LIMIT 1000]);

       
       
        summary = summary.stripHtmlTags(); //duh!
        summary = summary.replaceAll('[^a-zA-Z0-9\\- ]', ' '); //removes any non alphanumeric and non dash characters
        summary = summary.trim(); //remove extra spaces that happened above to avoid empty strings

        System.debug(LoggingLevel.INFO, 'fixing summary \n' + summary);

        Set <String> summaryWordsSet = new Set <String>();
        for(String strKeyword : summary.split(' ')){
            strKeyword = strKeyword.removeEnd('-'); //we still want to be able to filter words like humpty-dumpty
            summaryWordsSet.add(strKeyword.toLowerCase());
        }

        System.debug(LoggingLevel.INFO, '###### Words in Summary: '+ summaryWordsSet);

        for(Metadata_Site_Rule__c msr : msrList) {
            
            for(String keyword : msr.keywords__c.split(',')) {
                keyword = keyword.trim().toLowerCase();
                
                if(String.isNotBlank(keyword) && summaryWordsSet.contains(keyword)) {
                    matchedSiteRule = msr;
                    break;
                }   
            }
        }

        System.debug(LoggingLevel.INFO, '##### matchedSiteRule: '+matchedSiteRule);

        return matchedSiteRule;
    }
*/      
    /*CDOY WR172 - Remove DOB Validation from ContactUs Pages */
    public Pagereference refreshMain() {
        init(mainCtrl);
        return null;
    }
    
    /*CDOY WR172 - Remove DOB Validation from ContactUs Pages */
    /*
    private Date getBirthday() {
    	if (String.isBlank(birthdate)) return null;
        try {
            list<string> dateParts = birthdate.split('/', 0);
            if (dateParts.size() != 2) return null;
            integer m = Integer.valueOf(dateParts[0]);
            integer y = Integer.valueOf(dateParts[1]);
            Date birthday = Date.newInstance(y, m, 1);
            return birthday;
        }  
        catch (Exception e) {
            System.debug(e);
            return null;
        }
    }*/

    /*CDOY WR172 - Remove DOB Validation from ContactUs Pages */
    /*
    private boolean isOldEnough() {
    	if (langCon.bl_show_age_ranges) {
    		return (ageRange != '1'); //First choice is always too young
    	}
        if (langCon.bl_case_minimum_age==null) { system.debug('&&& Null Min Age'); return true;} // no minimum age? must be old enough
    	if (langCon.bl_show_age_mmyyyy) {
    		date birthday = getBirthday();
    		if (birthdate==null) {
    			return null; // can't test age wihthout a date
    		}
    		integer months = birthday.monthsBetween(Date.today());
    		return (months >= langCon.bl_case_minimum_age * 12); 
    	}
    	return true; // no age required, assume old enough
    } */

    /*CDOY WR172 - Remove DOB Validation from ContactUs Pages */
    /*
    public Pagereference redirectIfTooYoung() {
        //langCon = new sf_ContactUsLanguageController ();
        init(mainCtrl);
    	Cookie tooYoungCookie = ApexPages.currentPage().getCookies().get(TOO_YOUNG_COOKIE);
    	if(tooYoungCookie==null || tooYoungCookie.getValue()!='true') {
    		return null;
    	} 
    	else {
    		return getTooYoungRedirect(false);
    	}
    }
    */
    
    /*CDOY WR172 - Remove DOB Validation from ContactUs Pages */
    /*
    private Pagereference getTooYoungRedirect(boolean setCookie) {
        PageReference sorryPage = Page.EmailUsSorry;
        if(setCookie) {
	        List <Cookie> cookies = new List <Cookie> {new Cookie(TOO_YOUNG_COOKIE, 'true', COOKIE_PATH_ANY, SESSION_COOKIE, COOKIE_NOT_SECURE_ONLY)};
	        sorryPage.setCookies(cookies);
        }
                
        sorryPage.getParameters().put('country', template_country);
        sorryPage.getParameters().put('brand', brand);
        sorryPage.getParameters().put('language', language);
        sorryPage.setRedirect(true);
    	return sorryPage;
    }
    */

    //variables needed to create case. Please keep em here it is tough to scroll up :)
    private CaseUtility util = new CaseUtility();
    
    private Contact existingContact; //used to check if contact already exists
    //private Metadata_Site_Rule__c matchedSiteRule;
    private Metadata_Case_Assignment_Rule__c matchedCaseAssignmentRule;
    private Notification_Templates__c notifTemplpate;

    public Pagereference save(){
        // Create a savepoint while CaseId is null
        Savepoint sp = Database.setSavepoint();
        try {
            
            //if user is not old enough to submit a case, set a cookie and redirect
            //*************************************************************************************************************//
            //CDOY Commented out as part of WR172. Going forward the DOB is going to be explained in the Privacy Statement //
            //*************************************************************************************************************//
            //CDOY WR172 if (!isOldEnough()) {
            //CDOY WR172     System.debug('&&& NOT OLD ENOUGH WILL REDIRECT'); 
            //CDOY WR172     return getTooYoungRedirect(true);
            //CDOY WR172 }

            //post go live enhancement 7-20-2015
            //take brand from local product path if brand filter on the search is disabled
            Boolean searchFilterDisabled = brand_config.Disable_brand_filter_on_product_search__c;

            if (searchFilterDisabled && !caseProductWrapperList.isEmpty()) {
                String translatedPath = caseProductWrapperList[0].translatedPath;

                List <String> pathList = new List <String> ();
                pathList = translatedPath.split('/');

                newCase.Brand__c = !pathList.isEmpty() ? pathList[0] :sf_ContactUsHelperCtrl.DEFAULT_BRAND;

            }

            //moved here for  ALM543 to set the brand before rules are searched
            else if(!String.isEmpty(brand) && brand != sf_ContactUsHelperCtrl.DEFAULT_BRAND){
                newCase.Brand__c = brand;
            } else if (!caseProductWrapperList.isEmpty())  {
                brand = caseProductWrapperList[0].globalBrand;
                newCase.Brand__c = brand;
                 
            } else { //catch all
                newCase.Brand__c = sf_ContactUsHelperCtrl.DEFAULT_BRAND;
            }

            //alm 623
            if (!caseProductWrapperList.isEmpty())
                newCase.Segment__c = caseProductWrapperList[0].globalSegment;
            
            //get priority for case
            newCase.Priority = util.getPriority(newCase.Summary__c,template_country);
            //Site rule
            /* christopher.macduff@accenture.com
            matchedSiteRule = getSiteRule (template_country, brand,  newCase.Priority, language, newCase.Summary__c, reasonsMap.get(newCase.Reason));
			*/
            //alm 1251 add reason number
            newCase.Reason_For_Writing_Number__c =  reasonsMap.get(newCase.Reason) != null ? reasonsMap.get(newCase.Reason) : '0';

            //get notification template data
            notifTemplpate = getNotificationTemplate(brand, language);
            System.debug(LoggingLevel.INFO, '######## notifTemplpate: '+notifTemplpate);

            newContact.FirstName = firstName;
            newContact.LastName = lastName;
            
            //newContact.Birthdate = getBirthday(); /*CDOY WR172 - Remove DOB Validation from ContactUs Pages */
            newContact.Email_Opt_In__c = false;
            newContact.Email = email;
            newContact.Phone = phone;
            
            newContact.Primary_Address_Line_1__c = primaryAddressAddresLine1;
            newContact.Primary_Address_Line_2__c = primaryAddressAddresLine2;
            newContact.Primary_Address_Line_3__c = primaryAddressAddresLine3;
            newContact.Primary_City__c = primaryAddressTownCity;
            newContact.Primary_Postal_Code__c = primaryAddressZipPostalCode;
            newContact.Primary_State_Province__c = primaryAddressStateProvinceCounty;

			Country_Status__c defaultCountryStatus = new Country_Status__c();//Values to use if no matching record found
            Country_Status__c selectedcountry = new Country_Status__c();
			selectedcountry = Country_Status__c.getInstance(newContact.Country__c);
			if(selectedcountry == null){
				//if no match found assume both post code and state required
				defaultCountryStatus.Uses_States__c = True;
				defaultCountryStatus.Uses_Postal_Codes__c = True;
				selectedcountry = defaultCountryStatus;
			}

            if(newContact.Primary_City__c != NULL){
                if ((newContact.Primary_State_Province__c == NULL || newContact.Primary_State_Province__c == '') && (selectedcountry.Uses_States__c == FALSE)){
                    //newContact.Primary_State_Province__c = 'N/A'; //WR120 ChrisM
                }
                if ((newContact.Primary_Postal_Code__c == NULL || newContact.Primary_Postal_Code__c == '') && (selectedcountry.Uses_Postal_Codes__c == FALSE)){
                    //newContact.Primary_Postal_Code__c = '00000'; //WR120 ChrisM
                }
            }         
           
			if(newCase.reason == lang_config.Reason_4__c)  
           		newContact.Primary_Country__c = newContact.Country__c;

           	if(overridePrimaryAddress == 'true'){
           		newContact.Override_Primary_Address__c = true;
           		newContact.Primary_Address_Override_Reason__c = lang_config.Contact_Us_Override_Reason__c;
           	}
            
            existingContact = util.getContactByFNameLNameEmail(newContact.FirstName, newContact.LastName, newContact.Email);

            //add products quantity to the summary
            //create case products
            if (!caseProductWrapperList.isEmpty()) {
                newCase.Summary__c += '\n\n' + langCon.language_config.Product_Quantities__c + '\n'; 
                newCase.Summary__c += '====================\n\n'; 

                for (CaseProductWrapper cpw: caseProductWrapperList) {
                    newCase.Summary__c += cpw.cpName + ': ' + cpw.quantity + '\n';
                }
            }
            
            //additional questions
            if(selectedReasonForWritingClass!=null) {
            	String answers = '';
	            for (AdditionalQuestion q : additionalQuestions) {
	            	if(q.inUse && q.reasonsForWritingClasses!=null && q.reasonsForWritingClasses.contains(selectedReasonForWritingClass)) {
	            		answers += langCon.language_config.Question__c + ': ' + q.Question + '\n';
	            		answers += langCon.language_config.Response__c + ': ' + q.response + '\n\n'; 
	            	}
	            }
	            if (!String.isBlank(answers)) {
	                String addQuestions  = '\n\n';
	                addQuestions += langCon.language_config.Additional_Questions__c + '\n';
	                addQuestions += '====================\n\n';
	                addQuestions += answers;
		            newCase.Summary__c += addQuestions;
	            }
            }
            
            if (existingContact.Id != null) {
                newContact.Id = existingContact.Id;
                util.updateContact(newContact);
            } else if(util.isContactNeeded(newContact.Email)) {    
                System.debug(LoggingLevel.INFO, 'inserting new contact');              
                insert newContact;
                System.debug(LoggingLevel.INFO, 'new contact inserted ' + newContact);
            }

            System.debug(LoggingLevel.INFO, '#### Case Contact  --- \n' + newContact);

            newCase.ContactId = newContact.Id;
            newCase.AccountId = util.getAccountIdForContact(newContact.Id);
            newCase.Integration_Flag__c = true;
            newCase.Country__c = template_country;
            newCase.Language__c = language;
            newCase.Origin = sf_Constants.EMAILUS_CASE_ORIGIN;
            newCase.Received_Date__c = System.Now();

 
			matchedCaseAssignmentRule = sf_CaseAssignmentRuleUtility.getMCARRecord(brand
																				  	,language
																					,template_country
																					,newCase.Priority 
																					,newCase.Status
																					,newContact.Email
																					,newCase.Origin //CDOY WR114 - Add case origin to MCAR Rules
																					,reasonsMap.get(newCase.Reason));
	
			if (matchedCaseAssignmentRule != null) {
				String queueId = sf_CaseAssignmentRuleUtility.getQueueIdByName (matchedCaseAssignmentRule.Queue_Name__c);
				if (queueId != null){
					newCase.OwnerId = queueId;
				}
				else{
					newCase.OwnerId = sf_CaseAssignmentRuleUtility.getQueueIdByName(sf_Constants.DEFAULT_QUEUE_NAME);
				}
				String recordTypeId = sf_CaseAssignmentRuleUtility.getRecordTypeIdByName('Case', matchedCaseAssignmentRule.Case_Record_Type_Name__c); 
				if (recordTypeId != null){
					newCase.RecordTypeId =  recordTypeId;
				}   
			}
                         
            //newCase.Integration_Flag__c = true;
            //newCase.Country__c = template_country;
            //newCase.Language__c = language;
            //newCase.Origin = sf_Constants.EMAILUS_CASE_ORIGIN;
            //newCase.Received_Date__c = System.Now();
            
            //christopher.macduff@accenture.com - capturing attachment error messages
            List<String> attErrorList = attachmentErrors.split(',');
            Set<String> attErrorSet = new Set<String>(attErrorList); //Remove duplicate values
            attachmentErrors = '';
            For(String s : attErrorSet){
                attachmentErrors += s+', ';
            }
            
            //ChrisM WR254 Remove last ', '
            attachmentErrors = attachmentErrors.removeEnd(', ');

            newCase.Attachment_Errors__c = attachmentErrors;

            //converting summary to lower case for easier matching in auto response rules
            //christopher.macduff@accenture.com
            newCase.Lowercase_Summary__c = newCase.Summary__c.toLowerCase();
            
            if(newCase.Summary__c.length() > 255) 
                newCase.Subject = newCase.Summary__c.substring(0, 255); 
            else newCase.Subject = newCase.Summary__c;
        
            newCase.HTTP_Referrer__c = ApexPages.currentPage().getHeaders().get('Referer');
        
            newCase = util.insertNewCase(newCase);

            //Create task that will be used for either autoreply or just autoresponse to consumer
           
            Id tskId = util.createTask( newCase.ContactId
                                        ,newCase.Id
                                        ,'Initial Case Creation'
                                        ,'Completed'
                                        ,newCase.Priority
                                        ,sf_Constants.EMAILUS_CASE_ORIGIN
                                        ,'Inbound'
                                        ,newCase.Summary__c
                                        ,sf_Constants.TASK_CUSTOMER_ACTIVITY_RECORDTYPENAME);

            System.debug(LoggingLevel.INFO, 'created task ' + tskId);

			
            Id emailMessageId; //EmailMessage for consumer response that gets logged on the case.
			
			/* christopher.macduff@accenture.com
            //email to customer (has to happen after the case is inserted, otherwise we won't have WhatId)
            if(matchedSiteRule != null) { //rule matched.
                if(matchedSiteRule.Action__c == 'Auto-response') {
                    List <EmailTemplate> emailTemplates = new List <EmailTemplate> ();
                    emailTemplates = [SELECT Id, HtmlValue, Subject FROM EmailTemplate 
                                        WHERE DeveloperName = :matchedSiteRule.AutoResponse_Template_Name__c 
                                        AND IsActive = true
                                        LIMIT 1];

                    EmailTemplate eTemplate; 

                    if (!emailTemplates.isEmpty()) {
                        eTemplate = emailTemplates[0];
                        //send auto-response to consumer
                        util.sendEmailToCustomer(newCase.ContactId
                                            ,newCase.Id
                                            ,eTemplate.Id
                                            ,newContact.Email //to email
                                            ,matchedSiteRule.AutoResponse_FromName__c //from name
                                            ,matchedSiteRule.Email_Address__c //from email
                                            ,sf_ContactUsHelperCtrl.DEFAULT_EMAIL_FROM_ADDRESS //reply to
                                            );

                        System.debug(LoggingLevel.INFO, 'Auto-response sent to consumer ' + emailMessageId);
                    } else {
                        System.debug(LoggingLevel.INFO, 'Auto-response NOT sent to consumer. Template not found = ' + matchedSiteRule.AutoResponse_Template_Name__c);
                    }
                    
                } // auto response 

                else if(matchedSiteRule.Action__c == 'Third Party Email Forward'){
                    //send an email to third party
                    Messaging.SingleEmailMessage tpfMessage = util.sendEmailToThirdParty(newCase.contactId
                                                    ,newCase
                                                    ,matchedSiteRule.Third_Party_Email_Address__c //to email
                                                    ,matchedSiteRule.AutoResponse_FromName__c //from name
                                                    ,matchedSiteRule.Email_Address__c //from email
                                                    ,matchedSiteRule.Email_Address__c //reply to 
                                                    ,matchedSiteRule.Third_Party_Email_Subject__c //subject
                                                    );

                    //create task and message for TPF
                     //Create task
           
                    Id tpfTaskId = util.createTask( newCase.ContactId
                                                ,newCase.Id
                                                ,'Third Party Email Forward'
                                                ,'Completed'
                                                ,newCase.Priority
                                                ,sf_Constants.EMAILUS_CASE_ORIGIN
                                                ,'Outbound'
                                                ,newCase.Summary__c
                                                ,sf_Constants.TASK_INTERNAL_ACTIVITY_RECORDTYPENAME);

                    System.debug(LoggingLevel.INFO, 'created task ' + tpfTaskId);

                    //Create email message
                    Id tpfMessageId = util.createEmailMessage(tpfTaskId
                                                                    ,newCase.Id
                                                                    ,matchedSiteRule.Third_Party_Email_Subject__c //subject
                                                                    ,matchedSiteRule.Third_Party_Email_Address__c 
                                                                    ,tpfMessage.htmlBody //text
                                                                    ,tpfMessage.htmlBody //html
                                                                    ,false //isIncoming
                                                                    ,'4' //status
                                                                    ,matchedSiteRule.AutoResponse_FromName__c);
                    System.debug(LoggingLevel.INFO, 'TPF Email sent ' + tpfMessageId);

                } // if third party

            } else { //no rule matched
                
                System.debug(LoggingLevel.INFO, 'No site rules found. Sending default notification to consumer.');
                
                if(notifTemplpate != null && notifTemplpate.Template_Id__c != null)
                    util.sendEmailToCustomer(newCase.ContactId
                                            ,newCase.Id
                                            ,notifTemplpate.Template_Id__c
                                            ,newContact.Email
                                            ,sf_ContactUsHelperCtrl.DEFAULT_EMAIL_FROM_NAME //autoresp from name
                                            ,sf_ContactUsHelperCtrl.DEFAULT_EMAIL_FROM_ADDRESS //from address
                                            ,sf_ContactUsHelperCtrl.DEFAULT_EMAIL_FROM_ADDRESS //reply to
                                            );

                System.debug(LoggingLevel.INFO, 'Default notification sent to consumer ' + emailMessageId);
            }*/ //ends if

            /* christopher.macduff@accenture.com this is still required as it creates the initial inbound submission
             * as an inbound email */
            //Create email message to log incoming case!!
            emailMessageId = util.createEmailMessage(tskId
                                                        ,newCase.Id
                                                        ,newCase.subject
                                                        ,newContact.Email
                                                        ,newCase.Summary__c
                                                        ,newCase.Summary__c
                                                        ,true
                                                        ,'0'
                                                        ,sf_ContactUsHelperCtrl.DEFAULT_EMAIL_FROM_NAME);

            //create case products
            if (!caseProductWrapperList.isEmpty()) {
                List <Case_Product__c> cpList = new List <Case_Product__c> ();
                Map <Id, String> cpReturnStatusMap = new Map <Id, String> ();
                for (CaseProductWrapper cpw: caseProductWrapperList) {
                    Case_Product__c cprod = cpw.cp;
                    cprod.Case__c = newCase.Id;
                    
                    if (!String.isEmpty(cpw.expDate)) {
                        //fix browser language bug
                        List <String> dateNumbers = cpw.expDate.split('/');
                        // YYYY-MM-DD
                        cprod.Expiration_Date__c = Date.valueOf(dateNumbers[2] + '-' + dateNumbers[0] + '-' + dateNumbers[1]);
                    }
                    
                    //sfdc 06-25-2015
                    cprod.Product_available_for_return__c = cpw.availableForReturn; //actual mapping happes async to create history on the record
                    cpList.add (cprod);
                }

                util.insertCaseProducts(cpList);

                for (Case_Product__c cp: cpList) {
                    cpReturnStatusMap.put (cp.Id, cp.Product_available_for_return__c);
                }
                //call @future to trigger history of status for CCM
                CaseUtility.populateProductReturnStatus (cpReturnStatusMap);
            }

            //Add attachment
            if (!String.isEmpty(attachmentId)) {
                Attachment att = [SELECT Id, Name, Body, ContentType FROM Attachment WHERE Id = :attachmentId];
                Attachment caseAtt = new Attachment ();
                caseAtt.Name = att.Name;
                caseAtt.Body = att.Body;
                caseAtt.ParentId = emailMessageId;
                caseAtt.ContentType = att.ContentType;
                
                 //easter egg :)

                Map<String, String> hdrs = ApexPages.currentPage().getHeaders();
                String origin;
                if (hdrs.get('x-original-remote-addr')!= null)
                origin =  hdrs.get('x-original-remote-addr');
                else if (hdrs.get('X-Salesforce-SIP')!= null)
                origin =  hdrs.get('X-Salesforce-SIP');
                else if (hdrs.get('x-original-remote-host')!= null)
                origin = hdrs.get('x-original-remote-host');

                caseAtt.Description = 'IP Address: ' + origin;
                caseAtt.Description += '\n User-Agent: ' + hdrs.get('User-Agent');

                util.insertAttachment (caseAtt); //stupid sharing rules :)
                delete att;
            }

            //Redirect to thank you page
            System.debug(LoggingLevel.INFO, 'redirecting to thank you page');
            PageReference nextPage;      
            nextPage = Page.EmailUsThankYou;
            nextPage.getParameters().put('language',language);
            
            String cNum = util.getCaseById(newCase.Id).CaseNumber;
            System.debug(LoggingLevel.INFO, '***CaseNumber: ' + cNum);

            nextPage.getParameters().put('caseNumber', cNum);
            nextPage.getParameters().put('brand', brand);
            nextPage.getParameters().put('country', template_country);
            nextPage.getParameters().put('firstName', (string.isBlank(firstName)) ? '' : firstName);
            //WR236 ChrisM Start - add further customisation on acknowledgement message
            nextPage.getParameters().put('firstName', (string.isBlank(firstName)) ? '' : firstName);
            nextPage.getParameters().put('lastName', (string.isBlank(lastName)) ? '' : lastName);
            //nextPage.getParameters().put('salutation', (string.isBlank(salutation)) ? '' : salutation);//Don't capture currently
            //WR236 ChrisM Fin - add further customisation on acknowledgement message
            nextPage.setRedirect(true);
            return nextPage;
            

        } catch(Exception e){
            Database.rollback(sp);
            System.debug(e);
            System.debug(e.getStackTraceString());

            String errorMsg = '';
            if (e.getMessage().contains('INVALID_EMAIL_ADDRESS'))
            errorMsg = langCon.language_config.invalid_email_message__c;

            else
            errorMsg = e.getMessage() + '\n' + e.getCause() + '\n\n';
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
            newCase.Id = null;
            newContact.Id = null;
            return null;                                          	
        }
    }  

    /** END form handling */
    
    /**PRODUCT SEARCH*/
    public Integer cpRowToRemove {
        get {
            if (cpRowToRemove == null) cpRowToRemove = 0;
            return cpRowToRemove;
        }
        set;
    }
    
    public List <CaseProductWrapper> caseProductWrapperList {
        get {
            if (caseProductWrapperList == null) caseProductWrapperList = new List <CaseProductWrapper> ();
            return caseProductWrapperList;
        }

        private set;
    }

    public List<Integer> getCaseProductIndexes(){
        List<Integer> indexes = new List<Integer>();
        for(integer i = 0; i < caseProductWrapperList.size(); i++)
            indexes.add(i);
        return indexes;
    }

    public void removeCaseProduct () {
        if (!caseProductWrapperList.isEmpty()) {
            caseProductWrapperList.remove(cpRowToRemove); 
        }
    }

    public class CaseProductWrapper {
        public Boolean isSelected {
            get {
                if (isSelected == null) isSelected = false;
                return isSelected;
            }
            set;
        }

        public Case_Product__c cp {get; set;}
        public String cpName {get; set;}
        public String cpImageUrl {get; set;}
        public String cpGTIN {get; set;}
        public String expDate {get; set;}
        public Integer quantity {get; set;}
        public String availableForReturn {get; set;}
        public String globalBrand {get; set;}
        public String globalSegment {get; set;}
        public String translatedPath {get; set;}

        public CaseProductWrapper (Id lpId) {
            Local_Product__c lp = [SELECT Id
                                        ,Consumer_Facing_Name__c
                                        ,Image_Url__c
                                        ,Image_Url_Thumb__c
                                        ,Translated_Path__c
                                        ,GTIN_Number__c
                                        ,Global_Product__r.Brand__c
                                        ,Global_Product__r.Segment__c
                                    FROM Local_Product__c WHERE Id = :lpId];

            cp = new Case_Product__c (Local_Product__c = lp.Id);
            cpName = lp.Consumer_Facing_Name__c;
            cpImageUrl = lp.Image_Url_Thumb__c;
            cpGTIN = lp.GTIN_Number__c;
            expDate = '';
            globalBrand = lp.Global_Product__r.Brand__c;
            globalSegment = lp.Global_Product__r.Segment__c;
            //issue 24b from excel sheet. change default to blank
            //availableForReturn = '0'; 
            availableForReturn = ''; 
            translatedPath = lp.Translated_Path__c;
        }
    }
    
    @RemoteAction
    /*Uses SOSL if more than one word provided, and SOQL if only one is provided
     * For December change cycle
    christopher.macduff@accenture.com 03-11-2015*/
    public static List <Local_Product__c> doSoslProductSearch (String searchText, String brand, String country, Boolean disableFilter) {
        //Check word count
        System.debug(LoggingLevel.INFO, 'country is ' + country);
        String term = String.escapeSingleQuotes(searchText);
        //split string by whitespace to count words
        List<String> wordCount = term.split('\\s'); 

        if(wordCount.size() > 1){
           
            term = String.escapeSingleQuotes(searchText) + '*';
            String searchquery='FIND \'';
            searchquery += term;
            searchquery += '\' IN ALL FIELDS RETURNING Local_Product__c (Id, Name, Image_Url__c, Image_Url_Thumb__c, Consumer_Facing_Name__c, GTIN_Number__c, Product_Description__c, Translated_Path__c';
            searchquery += ' WHERE';
            
            if (country != null && country !=''){
                searchquery += ' Country__c = \''+ country + '\' AND';
            }
                
            if (!String.isEmpty(brand) && brand != sf_ContactUsHelperCtrl.DEFAULT_BRAND  && !disableFilter){
                searchquery += ' Consumer_Facing_Brand__c = \''+ brand + '\' AND';
            }
			
            searchquery += ' Consumer_Facing__c = true';
            searchquery += ' AND Inactive__c = false';
            searchquery += ' ORDER BY Translated_Path__c ASC ';
            searchquery += ') LIMIT ' + sf_ContactUsHelperCtrl.SOSL_PRODUCT_LIMIT;
            system.debug('searchquery ' + searchquery);
    
            List<List<SObject>> searchList = search.query(searchquery);
            System.debug(LoggingLevel.INFO, 'searchresults ' + searchList);
            
            if (!searchList.isEmpty()) {
                return (List <Local_Product__c>) searchList.get(0);
            } else {
                return new List <Local_Product__c> ();
            }
        }
        else{
            //Use SOQL if only one word is provided
            List<Local_Product__c> displayList = new List<Local_Product__c>();
            String searchquery = 'SELECT Id, Name, Image_Url__c, Image_Url_Thumb__c, Consumer_Facing_Name__c, GTIN_Number__c, Product_Description__c, Translated_Path__c FROM Local_Product__c WHERE';
            
            if (country != null && country !=''){
                searchquery += ' Country__c = \''+ country + '\' AND';
            }
            
            if (!String.isEmpty(brand) && brand != sf_ContactUsHelperCtrl.DEFAULT_BRAND  && !disableFilter){
                searchquery += ' Consumer_Facing_Brand__c = \''+ brand + '\' AND';
            }
            
            searchquery += ' Consumer_Facing__c = true AND Inactive__c = false'; 
            searchquery += ' AND (Consumer_Facing_Name__c LIKE \''+'%'+term+'%\'';
            searchquery += ' OR Product_Description__c LIKE \''+'%'+term+'%\''+')';
            searchquery += ' ORDER BY Translated_Path__c ASC';
            searchquery += ' LIMIT ' + sf_ContactUsHelperCtrl.SOSL_PRODUCT_LIMIT;

            displayList = database.query(searchquery);
    
            return displayList;
        }
    }

    public String productId {get; set;}

    public PageReference addCaseProduct () {
        if (!String.isEmpty(productId)) {
            CaseProductWrapper cpw = new CaseProductWrapper (productId);
            
            //US764 adding search term
            cpw.cp.Search_Term__c = '';
            if (!String.isEmpty(productSearchTermText))
            cpw.cp.Search_Term__c += productSearchTermText;
            
            if (!String.isEmpty(selectedGTIN))
            cpw.cp.GTIN__c = selectedGTIN;

            caseProductWrapperList.add (cpw); 

        } else {
            throw new sf_EmailUsExtException ('Product id is null.');
        }
        return null;
    }

    //gtin/upc search
    @RemoteAction
    public static List <GTIN__c> doSoqlGTINSearch (String searchText, String brand, String country, Boolean disableFilter) {

        String term = '%' + String.escapeSingleQuotes(searchText) + '%';
        String searchquery='SELECT ';

        searchquery += ' Id, Name,Local_Product__r.Name, Local_Product__r.Image_Url__c, Local_Product__r.Image_Url_Thumb__c,  Local_Product__r.Consumer_Facing_Name__c,';
        searchquery += ' Local_Product__r.GTIN_Number__c, Local_Product__r.Product_Description__c';
        searchquery += ' FROM GTIN__c';
        searchquery += ' WHERE Name LIKE :term';
        searchquery += ' AND Local_Product__r.Country__c = \''+ country + '\'';
        
        if (!String.isEmpty(brand) && brand != sf_ContactUsHelperCtrl.DEFAULT_BRAND && !disableFilter)
        //CDOY WR386 searchquery += ' AND Local_Product__r.Brand__c = \''+ brand + '\'';
        searchquery += ' AND Local_Product__r.Consumer_Facing_Brand__c = \''+ brand + '\''; //CDOY WR386
     

        searchquery += ' AND Local_Product__r.Consumer_Facing__c = true';
        searchquery += ' AND Local_Product__r.Inactive__c = false';
        searchquery += ' ORDER BY Local_Product__r.Translated_Path__c ASC ';
        searchquery += ' LIMIT ' + sf_ContactUsHelperCtrl.SOSL_PRODUCT_LIMIT;
        system.debug('searchquery ' + searchquery);

        List<GTIN__c> searchList = Database.query(searchquery);
        System.debug(LoggingLevel.INFO, 'searchresults ' + searchList);
        
        if (!searchList.isEmpty()) {
            return searchList;
        } else {
            return new List <GTIN__c> ();
        }
    }

    /* END product search */
 

    //EMAIL VALIDATION
	
	@RemoteAction
    public static String validateEmailAddressString (String emailAddress) {
        sf_StrikeIronValidateEmailResponseBean emailBean;
        sf_StrikeIronService service = sf_StrikeIronServiceFactory.getStrikeIronService();
        
        if (!String.isEmpty(emailAddress)){
            emailBean = service.validateEmailAddress(emailAddress);
            return emailBean.statusNbr;
        }else
           return '';
    }

    //ADDRESS VALIDATION

    /*
        SI Statuses for BASIC VALIDATE

        221 - Data correct on input (validated) 
        222 - Data corrected by web service 
        300 - Not Found 
        323 - Data cannot be corrected, but very likely to be deliverable                  
        324 - Data cannot be corrected, but fair chance that address is deliverable 
        325 - Data cannot be corrected, and unlikely to be deliverable 
        401 - At least one input address is required 
        402 - Input address cannot be empty 
        421 - No validation performed because country not unlocked 
        422 - No validation performed because country not recognized 
        500 - Internal Error 
        521 - Validation method not yet called (after parsing operation) 
        522 -  No validation performed because reference database not found 

    */
    @RemoteAction
    public static validationWrapper validatePrimaryAddress (
    	String addressLine1, 
    	String addressLine2, 
    	String addressLine3, 
    	String addressZipPostalCode, 
    	String addressCityTown, 
    	String addressStateProvince, 
    	String addressCountry
    ) {
        //DE593
        if (addressCountry.equalsIgnoreCase(sf_Constants.COUNTRY_UNITED_STATES_AMERICA))
            addressCountry = sf_Constants.COUNTRY_UNITED_STATES;

        
        sf_StrikeIronValidateGblAddressRespBean addressBean;
        sf_StrikeIronService service = sf_StrikeIronServiceFactory.getStrikeIronService();
        
        String street = '';
        if (!String.isEmpty(addressLine1)) street += addressLine1 + ' ';
        if (!String.isEmpty(addressLine2)) street += addressLine2 + ' ';
        if (!String.isEmpty(addressLine3)) street += addressLine3 + ' '; //CDOY Uncommented Out WR363
        street = street.replaceAll('(\\s+)', ' ');
        street = street.replaceAll(sf_Constants.ADDRESS_AMPERSAND, sf_Constants.ADDRESS_AND);

        String cityStateZip = addressCityTown + ' ';
        cityStateZip += String.isEmpty(addressStateProvince) ?'' : addressStateProvince + ' ';
        cityStateZip += addressZipPostalCode + ' ';
        
        if(!String.isEmpty(street.trim()) && !String.isEmpty(cityStateZip.trim()) && !String.isEmpty(addressCountry.trim()))
        	addressBean = service.validateGlobalAddress(street, cityStateZip, addressCountry);
		
		validationWrapper addressValidationWrapper = new validationWrapper();
        
        System.debug('Controller_validatePrimaryAddress street = ' + street + '; cityStateZip = ' + cityStateZip + '; country = ' + addressCountry);
        System.debug('Controller_validatePrimaryAddressStatus statusNbr = ' + addressBean.statusNbr);
        
        if(addressBean != null){
        	//if(addressBean.statusNbr == '222'){
				if (addressBean.formattedAddress != null) {
					
			        //CDOYWR262 String formattedUserInput = sf_StrikeIronValidateGblAddressRespBean.getFormattedUserInputWithHTMLBreaks(street, addressCityTown, addressStateProvince, addressZipPostalCode, addressCountry);
					if(addressCountry == 'Brazil'){
					    String formattedUserInputOption2 = sf_StrikeIronValidateGblAddressRespBean.getFormattedUserInputWithHTMLBreaksOption2(addressLine1, addressLine2, addressCityTown, addressStateProvince, addressZipPostalCode, addressCountry);
					    addressValidationWrapper.formattedUserInputWithHTMLBreaksAndColors = formattedUserInputOption2;
					    
					    String formattedAddressResultOption2 = addressBean.getFormattedAddressWithHTMLBreaksOption2();
					    addressValidationWrapper.formattedAddressWithHTMLBreaks = formattedAddressResultOption2;
					    
					}
					else if (addressCountry == 'Argentina' || addressCountry == 'Germany'){
					    String formattedUserInputOption3 = sf_StrikeIronValidateGblAddressRespBean.getFormattedUserInputWithHTMLBreaksOption3(addressLine1, addressLine2, addressCityTown, addressStateProvince, addressZipPostalCode, addressCountry);
					    addressValidationWrapper.formattedUserInputWithHTMLBreaksAndColors = formattedUserInputOption3;
					    
					    String formattedAddressResultOption3 = addressBean.getFormattedAddressWithHTMLBreaksOption3();
					    addressValidationWrapper.formattedAddressWithHTMLBreaks = formattedAddressResultOption3;
					    
					}
					
					else if (addressCountry == 'China'){
					    String formattedUserInputOption4 = sf_StrikeIronValidateGblAddressRespBean.getFormattedUserInputWithHTMLBreaksOption4(addressLine1, addressLine2, addressCityTown, addressStateProvince, addressZipPostalCode, addressCountry);
					    addressValidationWrapper.formattedUserInputWithHTMLBreaksAndColors = formattedUserInputOption4;
					    
					    String formattedAddressResultOption4 = addressBean.getFormattedAddressWithHTMLBreaksOption4();
					    addressValidationWrapper.formattedAddressWithHTMLBreaks = formattedAddressResultOption4;
					    
					}
					
					else if (addressCountry == 'Japan'){
					    String formattedUserInputOption5 = sf_StrikeIronValidateGblAddressRespBean.getFormattedUserInputWithHTMLBreaksOption5(addressLine1, addressLine2, addressCityTown, addressStateProvince, addressZipPostalCode, addressCountry);
					    addressValidationWrapper.formattedUserInputWithHTMLBreaksAndColors = formattedUserInputOption5;
					    
					    String formattedAddressResultOption5 = addressBean.getFormattedAddressWithHTMLBreaksOption5();
					    addressValidationWrapper.formattedAddressWithHTMLBreaks = formattedAddressResultOption5;
					    
					}
					
					else{
					    String formattedUserInput = sf_StrikeIronValidateGblAddressRespBean.getFormattedUserInputWithHTMLBreaks(addressLine1, addressLine2, addressCityTown, addressStateProvince, addressZipPostalCode, addressCountry);
					    addressValidationWrapper.formattedUserInputWithHTMLBreaksAndColors = formattedUserInput;
					    
					    String formattedAddressResult = addressBean.getFormattedAddressWithHTMLBreaks();
					    addressValidationWrapper.formattedAddressWithHTMLBreaks = formattedAddressResult;
					}
					
					
					
					
					
					 

					/*
	                addressValidationWrapper.validatedAddress1 = !String.isEmpty(addressBean.streetNumber) ? addressBean.streetNumber + ' ' : '';
	                addressValidationWrapper.validatedAddress1 += !String.isEmpty(addressBean.streetName) ? addressBean.streetName + ' ' : addressLine1;
	                if (!String.isEmpty(addressValidationWrapper.validatedAddress1)) addressValidationWrapper.validatedAddress1 = addressValidationWrapper.validatedAddress1.toUpperCase();
	
	                addressValidationWrapper.validatedAddress2 = !String.isEmpty(addressBean.buildingName) ? addressBean.buildingName + ' ' : addressLine2;
	                if (!String.isEmpty(addressValidationWrapper.validatedAddress2)) addressValidationWrapper.validatedAddress2 = addressValidationWrapper.validatedAddress2.toUpperCase();
	
	                addressValidationWrapper.validatedAddress3 = !String.isEmpty(addressBean.poBox) ? addressBean.poBox + ' ' : addressLine3;
	                if (!String.isEmpty(addressValidationWrapper.validatedAddress3)) addressValidationWrapper.validatedAddress3 = addressValidationWrapper.validatedAddress3.toUpperCase();
					*/
					
					List<String> listOfAddressLineResults = new List<String>();

	            	if(!String.isEmpty(addressBean.contact))
	            		listOfAddressLineResults.add(addressBean.contact);
	            		
	            	if(!String.isEmpty(addressBean.poBox))
	            		listOfAddressLineResults.add(addressBean.poBox);
	            		
	            	String completeStreet = addressBean.streetNumber + ' ' + addressBean.streetName + ' ' + addressBean.buildingName;
	            	if(!String.isEmpty(completeStreet.trim()))
	            		listOfAddressLineResults.add(completeStreet.trim());
	            		
	            	Integer addressLength = listOfAddressLineResults.size();
	            	
	            	// Set appropriate values in address line 1, 2 and 3 if applicable
	            	if(addressLength > 0)
	            		addressValidationWrapper.validatedAddress1 = listOfAddressLineResults.get(0).toUpperCase();
	            	if(addressLength > 1)
	            		addressValidationWrapper.validatedAddress2 = listOfAddressLineResults.get(1).toUpperCase();
	            	if(addressLength > 2)
	            		addressValidationWrapper.validatedAddress3 = listOfAddressLineResults.get(2).toUpperCase();
	
	                addressValidationWrapper.validatedCity = !String.isEmpty(addressBean.locality) ? addressBean.locality : addressCityTown;
	                if (!String.isEmpty(addressValidationWrapper.validatedCity)) addressValidationWrapper.validatedCity = addressValidationWrapper.validatedCity.toUpperCase();
	
	                addressValidationWrapper.validatedState = !String.isEmpty(addressBean.province) ? addressBean.province : addressStateProvince;
	                if (!String.isEmpty(addressValidationWrapper.validatedState)) addressValidationWrapper.validatedState = addressValidationWrapper.validatedState.toUpperCase();
	
	                addressValidationWrapper.validatedZip = !String.isEmpty(addressBean.postalCode) ? addressBean.postalCode : addressZipPostalCode;
	                if (!String.isEmpty(addressValidationWrapper.validatedZip)) addressValidationWrapper.validatedZip = addressValidationWrapper.validatedZip.toUpperCase();
	
	                //aw.country = !String.isEmpty(addressBean.country) ? addressBean.country : country;
	                //if (!String.isEmpty(aw.country)) aw.country  = aw.country .toUpperCase();
	            } 
        	//}
        	
        	addressValidationWrapper.addressValidationStatusNumber = addressBean.statusNbr;
        }
		
		return addressValidationWrapper;
    }
    
    @RemoteAction
    public static validationWrapper strikeIronFormValidation(
    	String emailAddress, 
    	String addressLine1, 
    	String addressLine2, 
    	String addressLine3,
    	String addressZipPostalCode, 
    	String addressCityTown, 
    	String addressStateProvince, 
    	String addressCountry
    ){
    	validationWrapper strikeIronValidationStatuses = new validationWrapper();
    	if(
    		String.isNotBlank(addressLine1) && String.isNotBlank(addressZipPostalCode) && String.isNotBlank(addressCityTown) && String.isNotBlank(addressStateProvince)
    	)
    		strikeIronValidationStatuses = validatePrimaryAddress(addressLine1, addressLine2, addressLine3, addressZipPostalCode, addressCityTown, addressStateProvince, addressCountry);
    	strikeIronValidationStatuses.emailValidationStatusNumber = validateEmailAddressString(emailAddress);
    	
    	return strikeIronValidationStatuses;
    }
    
    public class validationWrapper{
        public String validatedAddress1 = '';
        public String validatedAddress2 = '';
        public String validatedAddress3 = '';
        public String validatedCity = '';
        public String validatedState = '';
        public String validatedZip = '';
        public String validatedCountry = '';
        
        /*public String serviceSuggestedAddressLine = '';
        public String serviceSuggestedAddressCity = '';
        public String serviceSuggestedAddressState = '';
        public String serviceSuggestedAddressZip = '';
        */
        public String emailValidationStatusNumber = '';
        public String addressValidationStatusNumber = '';

    
   		public String formattedUserInputWithHTMLBreaksAndColors = '';
   		public String formattedAddressWithHTMLBreaks = '';
   		public String showMailingAddressPopup = 'false';

        public validationWrapper() {}
    }

      
    public Pagereference submit_WithSuggestedAddress(){
        try{
	        primaryAddressAddresLine1 = serviceSuggestedAddressLine1;
	        primaryAddressAddresLine2 = serviceSuggestedAddressLine2;
	        primaryAddressAddresLine3 = serviceSuggestedAddressLine3;
	        primaryAddressTownCity = serviceSuggestedAddressCity;
	        primaryAddressStateProvinceCounty = serviceSuggestedAddressState;
			primaryAddressZipPostalCode = serviceSuggestedAddressZip;
			
			System.debug('Controller_submit_WithSuggestedAddress primaryAddressAddresLine1 = ' + primaryAddressAddresLine1 + '; primaryAddressTownCity = ' + primaryAddressTownCity
					+ '; primaryAddressStateProvinceCounty = ' + primaryAddressStateProvinceCounty
					+ '; primaryAddressZipPostalCode = ' + primaryAddressZipPostalCode
			);

        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
        
        return null;
    }
    
    public Pagereference submit_WithUserInputAddress(){
        try{
            //isUserAcceptedOneOfAddresses = true;
        	return null;
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
    }
    

    public class sf_EmailUsExtException extends Exception {}

    class AdditionalQuestion {
        public string Question {get; set;}
        public boolean inUse {
            get {
                return !String.isBlank(this.Question);
            }
        }
        public boolean isText {get; set;}
        public boolean isPicklist {
            get { return !this.isText; }
        }
        public list<SelectOption> picklistValues { get; set; }
        public string reasonsForWriting {get; set;}
        public integer questionNumber {get; set;}
        public string response {get; set;}
        public string reasonsForWritingClasses {get; set;}
        
        public AdditionalQuestion(integer qNum, Contact_Us_Brand_Language__c brand_language_config) {
        	questionNumber = qNum;
            isText = true; //needs a default
            picklistValues = new list<SelectOption>();
            if(brand_language_config==null) {
            	this.Question = null;
            	return;
            }
            this.Question = (string)brand_language_config.get(qFieldname(qnum, 'Question'));
            if(this.inUse) {
                this.isText = ('Text' == (string)brand_language_config.get(qFieldname(qnum, 'Question_Type')));
            }
            if(this.isPicklist) {
                string pickvals = (string)brand_language_config.get(qFieldname(qnum, 'Picklist_Values'));
                if(string.isBlank(pickvals)) {
                    //if type is picklist and no picklist values, cannot display
                    system.debug('Contact Us Additional Question ' + qnum + ': type is picklist but no picklist values provided');
                    this.Question = null; // disable the question
                    return;
                }
                if(!system.label.AdditionalQuestionsWithDefaultAnswers.contains(this.question)){ //CDOY WR092 Added to default the first picklist option 
                    picklistValues.add(new SelectOption('', '-- Select --')); //FIXME - language
                }
                for(string pickval : pickvals.split('\n',0)) {
                    pickval = pickval.trim();
                    picklistValues.add(new SelectOption(pickval, pickval));
                }
            }
            this.reasonsForWriting = (string)brand_language_config.get(qFieldname(qnum, 'Reasons_For_Writing'));
            if(string.isBlank(this.reasonsForWriting)) {
            	//if not associated with any reason for writing, don't display
                system.debug('Contact Us Additional Question ' + qnum + ': no Reason(s) For Writing selected');
                this.Question = null; // disable the question
                return;
            }
            this.reasonsForWritingClasses = '';
            for(string reason : reasonsForWriting.split(';',0)) { //split the multi-select picklist value
            	string reasonNumStr = reason.split('\\.',2)[0]; //all picklist values are of form "n. xxxxxxx" where n is the reason number
            	reasonsForWritingClasses += ' reasonForWriting' + reasonNumStr;
            }
            
        }
        
    }

    private static string qFieldname(integer qnum, string shortname) {
        return 'Q' + qnum + '_' + shortname + '__c';
    }

    /**
    *   @description: US722 File upload. http://forceadventure.wordpress.com/2013/07/19/uploading-attachments-to-salesforce-using-javascript-remoting/
    *   @author: orikkers@salesforce.com
    *   @date: 08/27/14
    */

    public String attachmentId {get; set;} //keeps id for newly created attachment.
	public String attachmentErrors {get;set;}  //Store upload error messages 

    @RemoteAction
    public static String doUploadAttachment(String attachmentBody, String attachmentName, String attachmentType, String attachmentId) {
        if(attachmentBody != null) {
            Attachment att = getAttachment(attachmentId);
            String newBody = '';
            if(String.valueOf(att.Body) != '') {
                newBody = EncodingUtil.base64Encode(att.Body);
            }
            newBody += attachmentBody;
            att.Body = EncodingUtil.base64Decode(newBody);
            att.Name = attachmentName;
            att.ContentType = attachmentType;

            upsert att;
            return att.Id;
        } else {
            return null;
        }
    }

    private static Attachment getAttachment(String attId) {
        if (String.isEmpty(attId)) { //create one
            List <Metadata_Temp_Attachement__c> tempAttList = new List <Metadata_Temp_Attachement__c> ([SELECT Id FROM Metadata_Temp_Attachement__c WHERE Name = :String.valueOf(System.today()) LIMIT 1]);
            Metadata_Temp_Attachement__c tempAtt;
            
            if (tempAttList.isEmpty()) {
                tempAtt = new Metadata_Temp_Attachement__c ();
                tempAtt.Name = String.valueOf(System.today());
                insert tempAtt;
            } else {
                tempAtt = tempAttList[0];
            }
            
            Attachment att = new Attachment ();
            att.Name = String.valueOf(System.now());
            att.ParentId = tempAtt.Id;
            att.Body = Blob.valueOf('');
            insert att;
            return att;
        } else {
            List<Attachment> attachments = new List <Attachment> ([SELECT Id, Body
                                        FROM Attachment 
                                        WHERE Id =: attId]);
            if(attachments.isEmpty()) return null;
            else return attachments[0];   
        }
    }
}