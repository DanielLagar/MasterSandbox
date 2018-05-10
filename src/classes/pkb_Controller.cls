/**
  *  Controller for PKB Pages.  Part of Salesforce Labs' PKB3: https://appexchange.salesforce.com/listingDetail?listingId=a0N300000059QxXEAU
  *  Additional customization by Salesforce.com
  * 
  * christoper.macduff@accenture.com
  * Stripping out unnecessary code
  * Back up: pkb_Controller_ORIG
  */

public without sharing class pkb_Controller {

    /* ***** SEARCH DEFAULTS ***** */
    private final static Integer CASE_SUBJECT_LENGTH = 250;

    // this needs to be public and not final so that it can be overridden during unit tests, since
    // kav records created in apex cannot be set to 'online', and can only stay at 'draft'
    public static String DEFAULT_PUBLISH_STATUS = 'online';

    // this also needs to be public to allow setting during unit tests
    public static String DEFAULT_SITE_NAME = Site.getName();

    public static String DEFAULT_LANGUAGE_NAME = 'Default';

    public String searchPrompt { get { return langCon.language_config.Search_Placeholder__c; } }

    /* ***** URL PARAM CONSTANTS AND GETTERS ***** */
    public final static String QUERY_PARAM = 'q';
    public final static String LANGUAGE_PARAM = 'Language';
    public final static String LANGUAGE_CODE_PARAM = 'l';
    public final static String CATEGORY_PARAM = 'c';
    public final static String BRAND_PARAM = 'Brand';
    public final static String SESSION_PARAM = 's';
    public final static String FEEDBACK_PARAM = 'f';
    public final static String CONTACT_US_PARAM = 'cu';
    public final static String FEEDBACK_SOURCE_PARAM = 'fs';
    public final static String PAGE_NUM_PARAM = 'pn';
    public final static String COUNTRY_PARAM = 'Country';

    public String queryParam            { get { return QUERY_PARAM; } }
    public String languageParam         { get { return LANGUAGE_PARAM; } }
    public String categoryParam         { get { return CATEGORY_PARAM; } }
    public String brandParam            { get { return BRAND_PARAM; } }
    public String sessionParam          { get { return SESSION_PARAM; } }
    public String feedbackParam         { get { return FEEDBACK_PARAM; } }
    public String feedbackSourceParam   { get { return FEEDBACK_SOURCE_PARAM; } }
    public String contactUsParam        { get { return CONTACT_US_PARAM; } }
    public String pageNumParam          { get { return PAGE_NUM_PARAM; } }

    //TODO: wire to language
    public string brandSelectLabel      { get { return 'Select your P&G Brand'; } }

    /* ***** KAV EXTENSION, used in VF pages when need to derive article type name from whole object name ***** */
    private final static String KAV_EXTENSION = '__kav';
    public String kavExtension          { get { return KAV_EXTENSION; } }

    // value for the contact us param
    private final static String CONTACT_US_VALUE = '1';
    public String contactUsValue        { get { return CONTACT_US_VALUE; } }

    // values for the feedback params, informs conditionals about which panel to display on the pkb_Feedback page
    private final static String FEEDBACK_SHOW_YESNO = 'yesno';
    private final static String FEEDBACK_SHOW_DIALOG = 'dialog';
    public String feedbackShowYesNo     { get { return FEEDBACK_SHOW_YESNO; } }
    public String feedbackShowDialog    { get { return FEEDBACK_SHOW_DIALOG; } }

    // values for the feedback source param; these *MUST* match the picklist values for the Feedback_Source__c field of the deflection object
    private final static String FEEDBACK_CONTACT_US = 'ContactUs';
    private final static String FEEDBACK_SEARCH = 'Search';
    private final static String FEEDBACK_RELATED = 'RelatedArticle';
    public String feedbackContactUs     { get { return FEEDBACK_CONTACT_US; } }
    public String feedbackSearch        { get { return FEEDBACK_SEARCH; } }
    public String feedbackRelated       { get { return FEEDBACK_RELATED; } }

    /* ***** STANDARD CONTROLLER AND RECORD PROPS AND COLLECTIONS ***** */
    public ApexPages.StandardController theSC { get; set; }
    public KnowledgeArticle theArticle { get; set; }
    public KnowledgeArticleVersion theAV { get; set; }
    public KnowledgeArticleData theKad { get; set; }

    public String publishStatus { get { return DEFAULT_PUBLISH_STATUS; } }

    public Boolean facebook { get {return Site.getTemplate().getUrl().endsWith('pkb_Template_fb');} }

    public String chosenLanguage {
        get {
          return sf_ContactUsHelperCtrl.getLanguage();
        }
    }
    public String chosenCountry  {
        get {
          return sf_ContactUsHelperCtrl.getCountry();
        }
    }

    public String brand {
        get {
            return sf_ContactUsHelperCtrl.getBrand();
        }
    }

    public sf_ContactUsLanguageController langCon {
        get {
            return sf_ContactUsLanguageController.instance;
        }
    }


    public PageReference updateBrand() {
        PageReference pageRef = ApexPages.currentPage();

        system.debug('redirecting with ' + chosenLanguage + ' and ' + chosenCountry + ' and ' + selectedBrand);
        pageRef.getParameters().put('language',chosenLanguage);
        pageRef.getParameters().put('country',chosenCountry);
        pageRef.getParameters().put('brand',brand);
        if(pageRef.getParameters().containsKey('q')) {
            pageRef.getParameters().remove('q');
        }
        pageRef.setRedirect(true);
        return pageRef;
    }


    public String getCurrentLanguageDump() {
        return 'currentLanguage NO LONGER USED';// JSON.serializePretty(currentLanguage);
    }
    
	//Get brand name for matching with data category
	//Prevents mismatches on brands with spaces or
	//special charaters in name
    public String getBrandFilter{
        get{
            String brandFilter = '';
            //get valid brand names from Schema
            Schema.DataCategoryGroupSobjectTypePair pair = new Schema.DataCategoryGroupSobjectTypePair();
            pair.setSObject(KnowledgeArticleVersion.sObjectType.getDescribe().getName());
            pair.setDataCategoryGroupName('Brand');
    
            List <Schema.DataCategoryGroupSobjectTypePair> pairs = new LIST<Schema.DataCategoryGroupSobjectTypePair>{pair};
    
            List <Schema.DescribeDataCategoryGroupStructureResult> res = Schema.describeDataCategoryGroupStructures(pairs, false);
            Map <String, String> brandLabelNameMap = new Map <String, String> ();
    
            for(Schema.DataCategory cat :res[0].getTopCategories()[0].getChildCategories()) {
                brandLabelNameMap.put(cat.getLabel().toLowerCase(), cat.getName());
            }
            
            brandFilter = brandLabelNameMap.get(brand.toLowerCase());
            
            return brandFilter;
        }
    }

    public pkb_Controller() { }

    /* ***** CONTROLLER EXTENSION CONSTRUCTOR ***** */
    public pkb_Controller(ApexPages.StandardController sc) {


    // Note that when an article is being viewed via its "url name" url (and not via a url that has the article ID in it),
    // the standard controller record will only have the Id field populated, and not any other field. This is true even if
    // other article fields are placed on the VF page; they will still not be populated.
    //
    // It is for this reason that to get basic information
    // about the article (such as title) when an article is being viewed, the KnowledgeArticleVersion object must be queried
    // using the Id of the article. To assist with this, there is a wrapper class in this controller called KnowledgeArticleData
    // that pulls together KAV data and combines it with the article type data from describe calls.

        sObject obj = sc.getRecord();
        if (obj.getSObjectType() == KnowledgeArticle.SObjectType) {
            theArticle = (KnowledgeArticle)sc.getRecord();
        }


        else if (obj.getSObjectType() == FAQ__kav.SObjectType) {
                FAQ__kav faqKav = (FAQ__kav) sc.getRecord();

                faqKav = [SELECT Id, KnowledgeArticleId FROM FAQ__kav WHERE Id = :faqKav.Id];
                theArticle = new KnowledgeArticle(Id=faqKav.KnowledgeArticleId);
        }
            
            
        else {
            theArticle = new KnowledgeArticle();
        }

        System.debug('loading PKB Controller with theArticle =' + theArticle + ' AND obj.getSObjectType() = ' + obj.getSObjectType());

        // populate the props with ural param values as needed
        String q = ApexPages.currentPage().getParameters().get(QUERY_PARAM);
        String fs = ApexPages.currentPage().getParameters().get(FEEDBACK_SOURCE_PARAM);
        
        //Set region category
		String selectedCountryString = chosencountry.equals('United States of America') ? 'United_States' :chosencountry;
        selectedCountryString = selectedCountryString.replace(' ', '_');
		selectedCategory = 'Region:' + selectedCountryString;       

        //Set brand category
        if (!isBlank(brand)) {
            selectedBrand = String.escapeSingleQuotes(brand);
            //don't filter from main PG site
            if (selectedBrand != sf_ContactUsHelperCtrl.DEFAULT_BRAND) {
            	selectedCategory += ',Brand: ' + getBrandFilter;
            }
        }

        if (!isBlank(fs)) feedbackSource = fs; // need to validate this value is in the picklist when inserting

        Cookie sessionCookie = ApexPages.currentPage().getCookies().get('PKB2SessionId');

        if (sessionCookie == null) {
            sessionId = randomUUID();
            sessionCookie = new Cookie('PKB2SessionId', sessionId, '/', -1, false);
            ApexPages.currentPage().setCookies(new Cookie[]{sessionCookie});
        } else {
            sessionId = sessionCookie.getValue();
        }
        enteredSearchQuery = searchPrompt;

        if (!isBlank(q) && q.length() > 2) {
            urlSearchQuery = q;
            enteredSearchQuery = q;
        }else{
            String errorMsg  = System.Label.PKB2_js_search_string_length;
            errorMsg = errorMsg.replace('NNN','3');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,errorMsg));
         }

        theKad = new KnowledgeArticleData();
        if (viewingArticle) {
            System.debug('\n\n[DEBUG-PKB CONTROLLER] viewingArticle.... \n=========\n');
            theKad = new KnowledgeArticleData(theArticle.Id, selectedLanguage);
            theAV = theKad.theAV;
            List<PKB_Article_Feedback_Deflection__c> afds = [
              select
                Id
              from PKB_Article_Feedback_Deflection__c
              where
                Session_ID__c = :sessionId and
                Article_Number__c = :theKad.articleNumber
            ];
            feedbackRecorded = !afds.isEmpty();
        }

        if (searchExecuted) {
            //alm 1425
            system.debug('\n\n[DEBUG-PKB CONTROLLER - Search executed] Now showing articles via VF tag knowledge:articleList...no code here :)');
        }


        if (displayContactUs) {
            System.debug('\n\n[DEBUG-PKB CONTROLLER] displayContactUs\n=========\n');
            theCud = new ContactUsData();
        }
    }

    public String randomUUID(){
        String kHexChars = '0123456789abcdefABCDEF';
        String returnValue = '';
        Integer nextByte = 0;
        for(Integer i = 0; i < 16; i++){
            if(i==4 || i==6 || i==8 || i==10){
                returnValue += '-';
            }
            //generate a "byte"; i.e., number in range [-2^7,2^7-1]
            nextByte = (Math.round(Math.random() * 255)-128) & 255;

            if(i==6){
                nextByte = nextByte & 15;
                nextByte = nextByte | (4 << 4);
            }
            if(i==8){
                nextByte = nextByte & 63;
                nextByte = nextByte | 128;
            }

            returnValue += charAt(kHexChars,nextByte >> 4);
            returnValue += charAt(kHexChars,nextByte & 15);
        }
        return returnValue;
    }

    private String charAt(String str, Integer index) {
        if(str == null){
            return null;
        }
        if(str.length() <= 0){
            return str;
        }
        if(index < 0 || index >= str.length()){
            return null;
        }
        return str.substring(index, index+1);
    }

    public Boolean foundRecommended { get; set; }

    /* ***** GENERAL DISPLAY AND PROCESSING CONDITIONALS ***** */
    public Boolean viewingArticle { get { return (!isBlank(theArticle.Id)); } }
    public Boolean searchExecuted { get { return (!isBlank(allSearchParams) && enteredSearchQuery != searchPrompt); } }
    public Boolean displaySearchResultsLink { get { return (!isBlank(allSearchParams)); } }
    public Boolean isSite { get { return !isBlank(Site.getName()); } }

    /* ***** HANDLE TO CURRENT INSTANCE OF CONTROLLER (to be passed to rendered VF components, avoids re-instantiation of controller) ***** */
    public pkb_Controller pkbCon { get { return this; } }

    /* ***** SEARCH RELATED PROPS AND METHODS ***** */
    public String selectedBrand { get; set; }
    public String selectedCategory { get; set; }
    public String urlSearchQuery { get; set; }
    public String feedbackSource { get; set; }
    public String enteredSearchQuery {
        set;
        get {
            if (enteredSearchQuery == null) enteredSearchQuery = searchPrompt;
                return enteredSearchQuery;
            }
    }

  // url-formatted (e.g. key1=value1&key2=value2) string containing the params related to a search
    public String allSearchParams {
        get {
            String s;
            string language = sf_ContactUsHelperCtrl.getLanguage();
            string country = sf_ContactUsHelperCtrl.getCountry();
            List<String> keyValues = new List<String>();
            if (!isBlank(urlSearchQuery))   keyValues.add(QUERY_PARAM+ '=' +EncodingUtil.urlEncode(urlSearchQuery, 'UTF-8'));
            if (!isBlank(selectedLanguage)) keyValues.add(LANGUAGE_CODE_PARAM+ '=' +EncodingUtil.urlEncode(selectedLanguage, 'UTF-8'));
            if (!isBlank(selectedBrand))    keyValues.add(BRAND_PARAM+ '=' +EncodingUtil.urlEncode(selectedBrand, 'UTF-8'));
            if (!isBlank(language))    keyValues.add(LANGUAGE_PARAM+ '=' +EncodingUtil.urlEncode(language, 'UTF-8'));
            if (!isBlank(country))    keyValues.add(COUNTRY_PARAM+ '=' +EncodingUtil.urlEncode(country, 'UTF-8'));
            if (displayContactUs)           keyValues.add(CONTACT_US_PARAM+ '=' +CONTACT_US_VALUE);
            s = join(keyValues, '&');
          return s;
        }
    }

  public String pageTitle {
    get {
      String t = siteBaseTitle.replaceAll('_', ' ')+ ' - Home';
      if (viewingArticle) t = siteBaseTitle.replaceAll('_', ' ')+ ' - ' +theKad.title;
      return t;
    }
  }

  // note that siteName will be null when accessing page internally
  public String siteBaseTitle {
    get {
        String s = siteName;
        if (isBlank(s)) s = 'Public Knowledge Base';
      return s;
    }
  }

  public String selectedLanguageURL {
    get {
      return '/' +(multiLanguage ? selectedLanguage+'/' : '');
    }
  }

  public String selectedCategoryLabel {
    get {
        return selectedCategory.replace(',', ', ').replace(':', ': ').replace('_', ' ');
    }
  }

    public String selectedLanguage {
        get {
                selectedLanguage = sf_ContactUsLanguageController.instance.languageCode;

                if (String.isEmpty(selectedLanguage))
                    selectedLanguage = 'en_US';
                return selectedLanguage;
            } 
        set;
    }



  /* ***** NARROW SEARCH DISPLAY CONDITIONALS ***** */

  public Boolean displayCategory1 { get { return (!isBlank(categoryGroup1) && !isBlank(rootCategory1)); } }
  public Boolean displayCategory2 { get { return (!isBlank(categoryGroup2) && !isBlank(rootCategory2)); } }
  public Boolean displayCategory3 { get { return (!isBlank(categoryGroup3) && !isBlank(rootCategory3)); } }
  public Boolean displayNarrow    { get { return (displayCategory1 || displayCategory2 || displayCategory3); } }


  /* ***** FEEDBACK AND CASE DEFERRAL CONDITIONALS AND PROCESSING ***** */

  public Boolean displayFeedbackYesNo   { get { return ApexPages.currentPage().getParameters().get(FEEDBACK_PARAM) == FEEDBACK_SHOW_YESNO; } }
  public Boolean displayFeedbackDialog  { get { return ApexPages.currentPage().getParameters().get(FEEDBACK_PARAM) == FEEDBACK_SHOW_DIALOG; } }
  public String sessionId { get; set; }
  public String feedbackComments { get; set; }
  public String createCaseErrorMsg { get; set; }

  public Boolean feedbackRecorded {
    set;
    get {
      if (feedbackRecorded == null) feedbackRecorded = false;
      return feedbackRecorded;
    }
  }

  public void deferred() {
    createDeferral(true);
    feedbackRecorded = true;
  }

  public void recordArticleFeedback() {
    if (!isBlank(feedbackComments)) {
        createDeferral(false);
      feedbackRecorded = true;
    }
  }

  public void createDeferral(Boolean isDeferred) {
    // validate that the feedback source option is a valid option
    String fs = (feedbackSourceOptions.contains(feedbackSource) ? feedbackSource : null);

    PKB_Article_Feedback_Deflection__c afd = new PKB_Article_Feedback_Deflection__c(
      Article_ID__c = theKad.id,
      Article_Number__c = theKad.articleNumber,
      Article_Title__c = theKad.title,
      Feedback_Source__c = fs,
      Comments__c = feedbackComments,
      Session_ID__c = sessionId,
      Deflection__c = isDeferred,
      Keyword_Searched__c = urlSearchQuery
    );
    insert afd;
  }

  public Set<String> feedbackSourceOptions {
    set;
    get {
      if (feedbackSourceOptions == null) feedbackSourceOptions = getActivePicklistOptions('PKB_Article_Feedback_Deflection__c', 'Feedback_Source__c').keySet();
      return feedbackSourceOptions;
    }
  }

  /* ***** CONTACT US CONDITIONALS AND PROCESSING ***** */
  public Boolean displayContactUs   { get { return (ApexPages.currentPage().getParameters().get(CONTACT_US_PARAM) == CONTACT_US_VALUE); } }
  public ContactUsData theCud       { get; set; }

  public PageReference contactUsDeferral() {
    feedbackComments = urlSearchQuery;
    feedbackSource = 'ContactUs';
    deferred();
    PageReference p = new PageReference(currentSiteUrl);
    p.setRedirect(true);
    return p;
  }

  /* ***** SITE-SPECIFIC VALUES THAT CAN BE OVERRIDDEN IF NOT VIEWING IN A SITE ***** */
  public String currentSiteUrl {
    set;
    get {
      if (currentSiteUrl == null) {
        currentSiteUrl = Site.getCurrentSiteUrl();
        if (!isSite) {
          currentSiteUrl = Page.pkb_Home.getUrl();
        }
      }
      return currentSiteUrl;
    }
  }

  public string backToSearchUrl {
    get {
        return Site.getCurrentSiteUrl() + 'pkb_Home?' + allSearchParams;
    }

  }

  public String siteName { get { return DEFAULT_SITE_NAME; } }

  /* ***** CUSTOM SETTINGS (note that defaults are retrieved from the pkb_SettingsController) ***** */

  private PKB__c kbSettings { get { return PKB__c.getValues(siteName); }  }
  public Boolean showArticleSummary { get { return (kbSettings == null ? pkb_SettingsController.DEFAULT_DISPLAY_SUMMARY : kbSettings.Display_Article_Summary__c); } }
  public Integer popularArticles    { get { return (kbSettings == null ? pkb_SettingsController.DEFAULT_POPULAR_SIZE : Integer.valueOf(kbSettings.Popular_Articles_Size__c)); } }
  public Integer relatedArticles    { get { return (kbSettings == null ? pkb_SettingsController.DEFAULT_RELATED_SIZE : Integer.valueOf(kbSettings.Related_Articles_Size__c)); } }
  public Integer articlesPerPage    { get { return (kbSettings == null ? pkb_SettingsController.DEFAULT_RESULTS_SIZE : Integer.valueOf(kbSettings.Results_Page_Size__c)); } }
  public Boolean multiLanguage      { get { return (kbSettings == null ? pkb_SettingsController.DEFAULT_MULTI_LANGUAGE : kbSettings.Multi_Language_Enabled__c); } }
  public Boolean createAcctCon      { get { return (kbSettings == null ? pkb_SettingsController.DEFAULT_CREATE_ACCOUNT_CONTACT : kbSettings.Create_Contact_and_Account__c); } }
  public String availableLanguages  { get { return (kbSettings == null ? pkb_SettingsController.DEFAULT_LANGUAGE : kbSettings.Selected_Languages__c); } }
  public String categoryGroup1      { get { return (kbSettings == null ? null : kbSettings.Category_Group_1__c); } }
  public String categoryGroup2      { get { return (kbSettings == null ? null : kbSettings.Category_Group_2__c); } }
  public String categoryGroup3      { get { return (kbSettings == null ? null : kbSettings.Category_Group_3__c); } }
  public String rootCategory1       { get { return (kbSettings == null ? null : kbSettings.Root_Category_1__c); } }
  public String rootCategory2       { get { return (kbSettings == null ? null : kbSettings.Root_Category_2__c); } }
  public String rootCategory3       { get { return (kbSettings == null ? null : kbSettings.Root_Category_3__c); } }
  public String fbAppId             { get { return (kbSettings == null ? null : kbSettings.FBAppId__c); } }

  /* ***** SEARCH RESULTS PAGINATION NAVIGATION ***** */
  public Integer currPage {
    set;
    get {
        if (currPage == null) {
            currPage = 1;
            String p = ApexPages.currentPage().getParameters().get(PAGE_NUM_PARAM);
        if (!isBlank(p)) currPage = Integer.valueOf(p);
        }
      return currPage;
    }
  }
  public void nextPage() {
    currPage++;
  }
  public void prevPage() {
    currPage--;
  }

  /* ***** RETRIEVE LANGUAGE LABELS AND VALUES AND CONSTRUCT SELECT OPTIONS ***** */
  public Set<String> availableLanguagesSet {
    set;
    get {
      if (availableLanguagesSet == null) {
        availableLanguagesSet = new Set<String>();
        List<String> langs = ( isBlank(availableLanguages) ? new List<String>{pkb_SettingsController.DEFAULT_LANGUAGE} : availableLanguages.split(';') );
        for (String s : langs)
          availableLanguagesSet.add(s);
      }
      return availableLanguagesSet;
    }
  }

  public List<SelectOption> languageOptions {
    set;
    get {
      if (languageOptions == null) {
        languageOptions = new List<SelectOption>();
        for (SelectOption so : allLanguageOptions) {
            if (availableLanguagesSet.contains(so.getValue())) {
                languageOptions.add(so);
            }
        }
        languageOptions = sortOptionList(languageOptions);
      }
        return languageOptions;
    }
  }

  public static List<SelectOption> allLanguageOptions {
    set;
    get {
      if (allLanguageOptions == null) {
        Map<String,String> optionsMap = getActivePicklistOptions('User', 'LanguageLocaleKey');
        allLanguageOptions = new List<SelectOption>();
        for (String s : optionsMap.keySet()) {
          allLanguageOptions.add(new SelectOption(s, 'pkb2_lang_'+s));
        }
        allLanguageOptions = sortOptionList(allLanguageOptions);
      }
      return allLanguageOptions;
    }
  }


  /* ***** DYNAMIC RETRIEVAL OF ARTICLE TYPES VIA DESCRIBES AND OBJECT ID PREFIXES ***** */
  public static Set<String> kavNames {
    set;
    get {
        if (kavNames == null) {
            kavNames = new Set<String>();
        Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();

        for (String s : gd.keySet()) {
          if (s.contains(KAV_EXTENSION)) {
            kavNames.add(s);
          }
        }
        }
      return kavNames;
    }
  }

  public static Map<String,Schema.DescribeSObjectResult> kavObjPrefixMap {
    get {
        if (kavObjPrefixMap == null) {
            kavObjPrefixMap = new Map<String,Schema.DescribeSObjectResult>();
        Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
        Schema.DescribeSObjectResult sor;
        for (String s : kavNames) {
            sor = gd.get(s).getDescribe();
            kavObjPrefixMap.put(sor.getKeyPrefix().toLowerCase(), sor);
        }
        }
      return kavObjPrefixMap;
    }
  }

  public static Schema.DescribeSObjectResult getKAVDescribeById(String i) {
    if (isBlank(i) || i.length() < 15) return null;
    return kavObjPrefixMap.get(i.substring(0,3).toLowerCase());
  }


  /* ***** CONTACT US FORM WRAPPER CLASS ***** */
  public class ContactUsData {
    public String firstName { get; set; }
    public String lastName  { get; set; }
    public String email     { get; set; }
    public String reqType   { get; set; }
    public String query     { get; set; }
    /** fields added to covert new fields on Mobile app**/
    public Decimal  location_Latitude   { get; set; }
    public Decimal  location_Longitude { get; set; }
    public String User_Experience       { get; set; }


    public ContactUsData() { }
  }


  /* ***** KNOWLEDGE ARTICLE DATA (KAD) WRAPPER CLASS ***** */

  /*
    This wrapper class mimics the quasi article/article version object that is given to the loop executed by the
    VF tag knowledge:articleList. It implements all of the fields of that object plus articleNumber, and also exposes a handle to the
    underlying KAV object that was used to populate most of the fields

    A single instance can be instantiated by passing the constructor a single ID of a KnowledgeArticle record (this constructor uses a soql query to retrieve the article)
    or an already-queried KAV record.

    Multiple instances can be instantiated from a list of KnowledgeArticle or KAV IDs by using the KAD static initializers (initFromListOfArticleNumbers, etc).
  */
  public class KnowledgeArticleData {
    public String id                     { get; set; } // note this is the ID of the KnowledgeArticle record, not the ID of the KAV record
    public String title                  { get; set; }
    public String summary                { get; set; }
    public String urlName                { get; set; }
    public String articleTypeName        { get; set; }
    public String articleTypeLabel       { get; set; }
    public DateTime lastModifiedDate     { get; set; }
    public DateTime firstPublishedDate   { get; set; }
    public DateTime lastPublishedDate    { get; set; }
    public String articleNumber          { get; set; }
    public KnowledgeArticleVersion theAV { get; set; }

    // ctor for empty KAD
    public KnowledgeArticleData() { }

    // ctor that takes an already constructed-KAV record
    public KnowledgeArticleData(KnowledgeArticleVersion kav) {
      init(kav);
    }

    // ctore that takes the ID of a KnowledgeArticle record and queries the KAV record from it
    public KnowledgeArticleData(Id i, String lang) {
      String q = '';
      String pub = pkb_Controller.DEFAULT_PUBLISH_STATUS;
      q += 'select ' +join(kavFields, ',')+ ' from KnowledgeArticleVersion';
      q += ' where PublishStatus = :pub and Language = :lang and KnowledgeArticleId = :i limit 1';
      KnowledgeArticleVersion kav = (KnowledgeArticleVersion)Database.query(q);
      init(kav);
    }

    public void init(KnowledgeArticleVersion kav) {
        this.theAV = kav;

      id = this.theAV.KnowledgeArticleId;
      title = this.theAV.Title;
      summary = this.theAV.Summary;
      urlName = this.theAV.UrlName;
      articleTypeName = getKAVDescribeById(id).getLocalName();
      articleTypeLabel = getKAVDescribeById(id).getLabel();
      lastModifiedDate = this.theAV.LastModifiedDate;
      firstPublishedDate = this.theAV.FirstPublishedDate;
      lastPublishedDate = this.theAV.LastPublishedDate;
      articleNumber = this.theAV.ArticleNumber;
    }
  }

  public static Set<String> excludedSoslWords {
    get {
        if (excludedSoslWords == null) {
            excludedSoslWords = new Set<String>();
            /*{'and','or','the','a'};*/
        }
        return excludedSoslWords;
    }
    private set;
  }

  // these fields must be queried when instantiating a KAD wrapper object, so this set is
  // used in the sosl and soql queries to ensure that all queries get the right fields
  public static Set<String> kavFields {
    get {
        if (kavFields == null) {
            kavFields = new Set<String>{
          'Id'
          ,'Title'
          ,'Summary'
          ,'UrlName'
          ,'ArticleNumber'
          ,'LastModifiedDate'
          ,'FirstPublishedDate'
          ,'LastPublishedDate'
          ,'Language'
          ,'PublishStatus'
          ,'KnowledgeArticleId'
            };
        }
      return kavFields;
    }
    private set;
  }


    /* ***** KNOWLEDGE ARTICLE DATA CLASS STATIC INITIALIZERS/FACTORIES ***** */
    
    /* Used to generate list of featured articles to be displayed via
     * component pkb_featured Christopher.macduff@accenture.com*/
    public static list<KnowledgeArticleData> getFeaturedArticles(){
        List<KnowledgeArticleData> artList = new List<KnowledgeArticleData>();
        pkb_Controller pkbCon = new pkb_Controller();
        artList = pkbCon.initFromListOfArticleNumbers(new List<String>(sf_ContactUsLanguageController.artNums), sf_ContactUsLanguageController.selectedLang);

        //no need to sort if list size is 0 or 1...
        if(artList.size() > 1){
            //Populate map to be used in reapplying article order as query will be sorted differently
            Map<String, KnowledgeArticleData> artMap = new Map<String, KnowledgeArticleData>();
            For(KnowledgeArticleData k : artList){
                artMap.put(k.ArticleNumber, k);
            }

            //Correct order to match language brand record
            List<String> artNumListCheck = new List<String>(sf_ContactUsLanguageController.artNums);
            Integer i = 0;
            
            //Remove invalid items from list
            For(String ka : sf_ContactUsLanguageController.artNums){
                If(!artMap.containsKey(ka)){
                    artNumListCheck.remove(i);
                }
                else{
                    i++;
                }
            }
            
            //Now reorder
            i = 0;
            For(String kav : artNumListCheck){
                artList[i] = artMap.get(kav);
                i++;                
            }
        }
        return artList;
    }

    public List <KnowledgeArticleData> initFromListOfArticleNumbers(List<String> anums, String lang) {

        List<KnowledgeArticleData> kads = new List<KnowledgeArticleData>();

        if (anums == null || anums.isEmpty()) return kads;

        String brand = sf_ContactUsHelperCtrl.getBrand();

        String q = '';
        q += 'SELECT ' +join(kavFields, ',')+ ' FROM KnowledgeArticleVersion';
        q += ' WHERE PublishStatus = \'' +pkb_Controller.DEFAULT_PUBLISH_STATUS+ '\' AND Language = \'' +lang+ '\' and ArticleNumber in :anums';
        
        String selectedCountryString = sf_ContactUsHelperCtrl.getCountry().equals('United States of America') ? 'United_States' : sf_ContactUsHelperCtrl.getCountry();
        selectedCountryString = selectedCountryString.replace(' ', '_');

		/* Moving to it's own method getBrandFilter to allow for reuse
        //get valid brand names from Schema
        Schema.DataCategoryGroupSobjectTypePair pair = new Schema.DataCategoryGroupSobjectTypePair();
        pair.setSObject(KnowledgeArticleVersion.sObjectType.getDescribe().getName());
        pair.setDataCategoryGroupName('Brand');

        List <Schema.DataCategoryGroupSobjectTypePair> pairs = new LIST<Schema.DataCategoryGroupSobjectTypePair>{pair};

        List <Schema.DescribeDataCategoryGroupStructureResult> res = Schema.describeDataCategoryGroupStructures(pairs, false);
        Map <String, String> brandLabelNameMap = new Map <String, String> ();

        for(Schema.DataCategory cat :res[0].getTopCategories()[0].getChildCategories()) {
            brandLabelNameMap.put(cat.getLabel().toLowerCase(), cat.getName());
        }

        System.debug ('++++++++++ brandLabelNameMap++++++++ \n' + brandLabelNameMap);

        if (brand != sf_ContactUsHelperCtrl.DEFAULT_BRAND && brandLabelNameMap.get(brand.toLowerCase()) != null) { //don't filter from main PG site*/
        String brandFilter = getBrandFilter;
        if (brand != sf_ContactUsHelperCtrl.DEFAULT_BRAND && brandFilter != null) { //don't filter from main PG site
            // do not filter on an invalid brand, will cause an exception
            /*q += '  WITH DATA CATEGORY Brand__c AT (' + brandLabelNameMap.get(brand.toLowerCase()) +'__c, All__c) AND ';*/
            q += '  WITH DATA CATEGORY Brand__c AT (' + brandFilter +'__c, All__c) AND ';
            q += ' Region__c ABOVE_OR_BELOW ' + selectedCountryString  + '__c ';
            
        } else {
            q += ' WITH DATA CATEGORY  Region__c ABOVE_OR_BELOW ' + selectedCountryString  + '__c ';
            
        }

        q += ' ORDER BY LastPublishedDate DESC';

        System.debug('\n\n[DEBUG-PKB CONTROLLER] initFromListOfArticleNumbers query\n===='+q+'=====\n');
        
        try {
            List <KnowledgeArticleVersion> kavs = (List <KnowledgeArticleVersion>)Database.query(q);

            for (KnowledgeArticleVersion kav : kavs) {
              kads.add(new KnowledgeArticleData(kav));
            }
        } catch (Exception e) {
            System.debug('>>> KnowledgeArticleData list fail '+e);
        }

        System.debug('\n\n[DEBUG-PKB CONTROLLER] initFromListOfArticleNumbers \n===='+kads+'=====\n');
        return kads;
    }

    // instantiates and returns a list of the KAD wrapper class objects from a list of KnowledgeArticle IDs and the specified language.
    public static List<KnowledgeArticleData> initFromListOfArticleIds(List <String> aids, String lang) {
        List <KnowledgeArticleData> kads = new List<KnowledgeArticleData>();

        if (aids == null || aids.isEmpty()) return kads;

        String q = '';
        q += 'select ' +join(kavFields, ',')+ ' from KnowledgeArticleVersion';
        q += ' where PublishStatus = \'' +pkb_Controller.DEFAULT_PUBLISH_STATUS+ '\' and Language = \'' +lang+ '\' and KnowledgeArticleId in :aids order by LastPublishedDate desc';

        List<KnowledgeArticleVersion> kavs = (List<KnowledgeArticleVersion>)Database.query(q);
        return initFromListOfKAVs(kavs);
    }

    // instantiates and returns a list of the KAD wrapper class objects from a list of KAV IDs and the specified language.
    public static List<KnowledgeArticleData> initFromListOfKAVIds(List<String> kids, String lang) {
        List<KnowledgeArticleData> kads = new List<KnowledgeArticleData>();

        if (kids == null || kids.isEmpty()) return kads;

        String q = '';
        q += 'select ' +join(kavFields, ',')+ ' from KnowledgeArticleVersion';
        q += ' where PublishStatus = \'' +pkb_Controller.DEFAULT_PUBLISH_STATUS+ '\' and Language = \'' +lang+ '\' and Id in :kids order by LastPublishedDate desc';

        List<KnowledgeArticleVersion> kavs = (List<KnowledgeArticleVersion>)Database.query(q);
        return initFromListOfKAVs(kavs);
    }

    // instantiates a list of KADs from already-queried KAVs
    public static List <KnowledgeArticleData> initFromListOfKAVs(List <KnowledgeArticleVersion> kavs) {
        List <KnowledgeArticleData> kads = new List <KnowledgeArticleData>();

        if (kavs == null || kavs.isEmpty()) return kads;

        for (KnowledgeArticleVersion kav : kavs) {
          kads.add(new KnowledgeArticleData(kav));
        }
        return kads;
    }

    public List <SelectOption> getBrandSelectList() {
        return sf_BrandHelper.getBrandSelectList();
    }

    /* ***** GENERAL UTIL METHODS ***** */

    // returns true if string is null or empty
    public static Boolean isBlank(String s) {
        return ( s == null || s == '');
    }

    // joins elements in the passed list of strings by the passed string c
    // c can be a single character or a longer string -- useful for joinging segments of a dynamic sosl or soql query
    public static String join(List<String> strings, String c) {
        if (strings == null || strings.isEmpty()) return null;

        String sep = (isBlank(c) ? ',' : c);
        Integer i, size;
        String s = strings[0];

        size = strings.size();
        for (i = 1; i < size; i++) {
          s += (sep + strings[i]);
        }
        return s;
    }

  // version of join method that takes a set of strings
  public static String join(Set<String> strings, String c) {
    return join(new List<String>(strings), c);
  }


  public static String getPicklistDefault(String so, String field) {
    String defVal = null;
    for (Schema.PicklistEntry ple : getActivePicklistEntries(so, field)) {
        if (ple.isDefaultValue()) {
            defVal = ple.getValue();
            break;
        }
    }
    return defVal;
  }

  public static Map<String,String> getActivePicklistOptions(String so, String field) {
    Map<String,String> options = new Map<String,String>();

    for (Schema.PicklistEntry ple : getActivePicklistEntries(so, field)) {
      options.put(ple.getValue(), ple.getLabel());
    }
    return options;
  }

  public static List<Schema.PicklistEntry> getActivePicklistEntries(String so, String field) {
    Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
    List<Schema.PicklistEntry> ples = new List<Schema.PicklistEntry>();

    // return empty list if object name was not found in the schema
    if (!gd.containsKey(so)) return ples;

    Schema.DescribeSObjectResult sor = gd.get(so).getDescribe();
    Map<String,Schema.SObjectField> sofs = sor.fields.getMap();

    // return empty list if field name was not found in the object's field list
    if (!sofs.containsKey(field)) return ples;

    Schema.DescribeFieldResult dfr = sofs.get(field).getDescribe();

    // return empty list if the field type is not picklist
    if (dfr.getType() != Schema.DisplayType.Picklist) return ples;

    for (Schema.PicklistEntry ple : dfr.getPicklistValues()) {
      if (ple.isActive()) {
        ples.add(ple);
      }
    }
    return ples;
  }

  public static Boolean isEmail(String s) {
    if (isBlank(s)) return false;

    String p = '\\w+([-+.\']\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*';
    Pattern pat = Pattern.compile(p);
    Matcher mat = pat.matcher(s);
    return mat.matches();
  }

  public User siteAdmin {
    set;
    get {
        if (siteAdmin == null) siteAdmin = getSiteAdmin();
        return siteAdmin;
    }
  }

  public static User getSiteAdmin() {
    List<Site> sites = [
      select
        Id
        ,Name
        ,Admin.Id
        ,Admin.FirstName
        ,Admin.LastName
        ,Admin.Name
        ,Admin.Email
      from Site
      where
        Name = :DEFAULT_SITE_NAME
    ];

    // send the admin back if it's a site, send null back if not a site
    User u = (!sites.isEmpty() && sites[0].Admin != null ? sites[0].Admin : null);
    return u;
  }

  /*
    Retrieved from http://improveit360.blogspot.com/2010/09/implementing-quicksort-to-sort-list-of.html on 22 July 2011
    Author: Jason Hartfield

    This is a simple quicksort algorithm to sort a SelectOption list (dropdown)
    by label alphabetically.
  */
    public static List<SelectOption> sortOptionList(List<SelectOption> listToSort) {
        if (listToSort == null || listToSort.size() <= 1)
            return listToSort;

        List<SelectOption> less = new List<SelectOption>();
        List<SelectOption> greater = new List<SelectOption>();
        integer pivot = listToSort.size() / 2;

        // save the pivot and remove it from the list
        SelectOption pivotValue = listToSort[pivot];
        listToSort.remove(pivot);

        for (SelectOption x : listToSort) {
            if (x.getLabel() <= pivotValue.getLabel()) {
              less.add(x);
            } else if (x.getLabel() > pivotValue.getLabel()) {
                greater.add(x);
            }
        }
        List<SelectOption> returnList = new List<SelectOption> ();
        returnList.addAll(sortOptionList(less));
        returnList.add(pivotValue);
        returnList.addAll(sortOptionList(greater));
        return returnList;
    }
}