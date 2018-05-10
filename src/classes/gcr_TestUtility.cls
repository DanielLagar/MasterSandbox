/*
* @author:       	Accenture
* @date:         	25/08/2016
* @description:  	Utility class to create test data for carehub
* CHANGE LOG
* DATE          	NAME                CHANGE DESCRIPTION
* 25/08/2016    	Accenture           Initial Draft
* 12/10/2016		Accenture			CR392 - Proactive Chat
*										1. Updated createCustomSettings() method to add proactive chat related custom settings data
*										2. Updated getCareHubChannelData() and createContactUsObjectData() to set chat image url, 
*										   deploymentId and buttonid for care hub and v3 respectively.
*										3. Added DEPLOYMENT_ID, BUTTON_ID and CHAT_IMAGE_URL constants
* 13/10/2016		Accenture			CR392 - Proactive Chat
* 										1. Added new method pageMessageCheck() to check if expected page message added in page
* 10/01/2017		Accenture			Added additional custom settings "ChatPage__c" for in "createCustomSettings()"" method
* 11/01/2017		Accenture			Added additional CONSTANTS to create data other than default country language and products
*										Added new method "createContactUsData()" to create contact us records other than default records
* 25/01/2017		Accenture			Added new method "getDataCategoriesOther()" to create data categores for products other
*										than default BCL
*/
public class gcr_TestUtility {
    public static final String DEFAULT_COUNTRY = 'United States of America';
    public static final String DEFAULT_BRAND = 'Tide';
    public static final String DEFAULT_LANGUAGE = 'English-US';
    
    public static final String DEFAULT_COUNTRY_ISO = 'us';
    public static final String DEFAULT_LANGUAGE_ISO = 'en';
    public static final String DEFAULT_LANGUAGE_LOCALE = 'en_US';
    
    // ADDITIONAL CONSTANTS FOR BRAND, COUNTRY AND LANGUAGE
    public static final String COUNTRY_DATA = 'United Kingdom';
    public static final String BRAND_DATA = 'Olay';
    public static final String LANGUAGE_DATA = 'English-GB';
    
    public static final String LANGUAGE_ISO = 'gb';
    public static final String COUNTRY_ISO = 'en';
    public static final String LANGUAGE_LOCALE = 'en_US';
    
    // ADDED FOLLOWING CONSTATNS TO CREATE TEST CASES OTHER THAN DEFAULT BCL
    public static final String SELECTED_COUNTRY = 'France';
    public static final String SELECTED_BRAND = 'Gillette Body';
    public static final String SELECTED_LANGUAGE = 'fr';
    
    public static final String SELECTED_LANGUAGE_ISO = 'fr';
    public static final String SELECTED_COUNTRY_ISO = 'fr';
    public static final String SELECTED_LANGUAGE_LOCALE = 'fr';
    
    // PRODUCT RELATED CONSTANTS
    public static final String GLOBALBRAND_PATH = 'Tide/Laundry Additive';
    public static final String GLOBAL_PROD_ID = '1102906349';
    public static final String GCR_PROD_ID = '100001324';
    public static final Integer FEATURED_ARTICLE_COUNT = 5;
    
    // PRODUCT RELATED CONSTANTS SELECTED
    public static final String GLOBALBRAND_PATH_SELECTED = 'Gillette Body';
    public static final String GLOBAL_PROD_ID_SELECTED = '1108095775';
    public static final String GCR_PROD_ID_SELECTED = '101016820';
    
    // PROACTIVE CHAT RELATED CONSTANTS
    public static final String DEPLOYMENT_ID = 'DEPLOYMENTID';
    public static final String BUTTON_ID = 'BUTTONID';
    public static final String CHAT_IMAGE_URL = 'http://chatimageurl.com';
    public static final String VISUALFORCE_URL = 'https://c.cs40.visual.force.com';
    public static final String CAREHUB_GUESTSITE_URL = 'https://pgconsumersupport.force.com/carehub/';
    public static final String V3_GUESTSITE_URL = 'https://pgconsumersupport.force.com/ContactUs/';
    
    /*
     * @author:         Accenture
     * @date:           25/08/2016
     * @description:    Method to create sObject data
     * @input:          String, Map<String, String>
     * @return:         sObject
     */
    public static sObject createObjectData(String sObjName, Map<String, String> mFieldValMap) {
        sObject retVal = Schema.getGlobalDescribe().get(sObjName).newSObject();
        Schema.DescribeFieldResult descFieldResult = null;

        for (String eachField :mFieldValMap.keySet()) {
            descFieldResult = Schema.getGlobalDescribe().get(sObjName).getDescribe().fields.getMap().get(eachField).getDescribe();
            if (descFieldResult != null
            && descFieldResult.isAccessible() 
            && descFieldResult.isCreateable() 
            && !descFieldResult.isUnique()
            && !descFieldResult.isAutoNumber()
            && !descFieldResult.isCalculated()
            && descFieldResult.getType() != null) {
                retVal.put(eachField, mFieldValMap.get(eachField));
            }
        }
        return retVal;
    }
    
    /*
     * @author:         Accenture
     * @date:           25/08/2016
     * @description:    Method to create Knowledge Article data in bulk
     * @input:          String, String
     * @return:         sObject
     */
    public static sObject getArticeData(String strArticleType, String language) {
        sObject retVal = Schema.getGlobalDescribe().get(strArticleType + '__kav').newSObject();

        String uniqueIdentifier = EncodingUtil.convertToHex(crypto.generateAesKey(128)).substring(0, 10);
        retVal.put('Title', 'Featured test Article' + uniqueIdentifier);
        retVal.put('UrlName', uniqueIdentifier);
        retVal.put('Summary', 'This is the summary of the featured test article ' + uniqueIdentifier);
        retVal.put('Answer__c', 'Answer body: This is the summary of the featured test article ' + uniqueIdentifier);
        retVal.put('IsVisibleInPkb', true);
        retVal.put('Language', language);
        
        return retVal;
    }

    /*
     * @author:         Accenture
     * @date:           25/08/2016
     * @description:    Method to create sObject data in bulk
     * @input:          String, Integer, String
     * @return:         List<sObject>
     */
    public static List<sObject> getArticleDataBulk(String strArticleType, Integer recordCount, String language) {
        List<sObject> retVal = new List<sObject>();
        while (recordCount > 0) {
            retVal.add(gcr_TestUtility.getArticeData(strArticleType, language));
            recordCount--;
        }
        return retVal;
    }
    
    /*
     * @author:         Accenture
     * @date:           25/08/2016
     * @description:    Method to assign data category to knowledge article
     * @input:          String, Id, String, String
     * @return:         sObject
     */
    public static sObject getDataCategory(String strArticleType, Id parentId, String strDataCatGrpName, String strDataCatname) {
        sObject retVal = Schema.getGlobalDescribe().get(strArticleType + '__DataCategorySelection').newSObject();
        
        retVal.put('ParentId', parentId);
        retVal.put('DataCategoryGroupName', strDataCatGrpName);
        retVal.put('DataCategoryName', strDataCatname);
        
        return retVal;
    }
    
    /*
     * @author:         Accenture
     * @date:           25/08/2016
     * @description:    Method to assign all possible data categories to passed knowledge articles
     * @input:          String, List<sObject>
     * @return:         List<sObject>
     */
    public static List<sObject> getDataCategories(String strArticleType, List<sObject> lKArticle) {
        List<sObject> retVal = new List<sObject>();
        for (sObject eachArticle :lKArticle) {
            retVal.add(gcr_TestUtility.getDataCategory(strArticleType, eachArticle.Id, 'Brand', 'Tide'));
            retVal.add(gcr_TestUtility.getDataCategory(strArticleType, eachArticle.Id, 'Region', 'United_States'));
            retVal.add(gcr_TestUtility.getDataCategory(strArticleType, eachArticle.Id, 'Product', 'Laundry'));
        }
        return retVal;
    }
    
    /*
     * @author:         Accenture
     * @date:           25/01/2017
     * @description:    Method to assign all possible data categories to passed knowledge articles
     * @input:          String, List<sObject>
     * @return:         List<sObject>
     */
    public static List<sObject> getDataCategoriesOther(String strArticleType, List<sObject> lKArticle) {
        List<sObject> retVal = new List<sObject>();
        for (sObject eachArticle :lKArticle) {
            retVal.add(gcr_TestUtility.getDataCategory(strArticleType, eachArticle.Id, 'Brand', 'Olay'));
            retVal.add(gcr_TestUtility.getDataCategory(strArticleType, eachArticle.Id, 'Region', 'United_Kingdom'));
            retVal.add(gcr_TestUtility.getDataCategory(strArticleType, eachArticle.Id, 'Product', 'Cosmetics'));
        }
        return retVal;
    }
    
    /*
     * @author:         Accenture
     * @date:           25/08/2016
     * @description:    Create faq type knowledge articles 
     * @input:          Integer
     * @return:         List<sObject>
     */
    public static List<sObject> createArticles(String strArticleType, Integer articleCount, String language) {
        List<sObject> retVal = gcr_TestUtility.getArticleDataBulk(strArticleType, articleCount, language);
        Database.insert(retVal, true);
        List<sObject> lKaId = Database.query('SELECT Id, KnowledgeArticleId FROM ' + strArticleType 
                                             + '__kav WHERE Id IN :retVal');

        for(sObject eachArticle :lKaId) {
            KbManagement.PublishingService.publishArticle((Id) eachArticle.get('KnowledgeArticleId'), true);
        }
        retVal = Database.query('SELECT Id, ArticleNumber, UrlName FROM KnowledgeArticleVersion WHERE Id IN :retVal');
        
        return retVal;
    }
    
    /*
     * @author:         Accenture
     * @date:           25/08/2016
     * @description:    get channel properties data
     * @input:          none
     * @return:         sObject
     */
    public static void createCustomSettings() {
        List<sObject> lInsertData = new List<sObject>();
        Map<Id, Schema.RecordTypeInfo> mRecordTypeInfo = GCRChannelContent__c.getSObjectType().getDescribe().getRecordTypeInfosById();
        // CREATE CHANNEL PROPERTY DATA
        for (Id eachRecordTypeId :mRecordTypeInfo.keySet()) {
            lInsertData.add(gcr_TestUtility.getChannelProperty(mRecordTypeInfo.get(eachRecordTypeId).getName()
                                                             , 'question15.svg', 'contacts/svg/', 'GCRWidgetContent', false, false, true));
        }
        lInsertData.add(gcr_TestUtility.getChannelProperty('next', 'more.svg', 'contacts/svg/', 'GCRWidgetContent', true, false, true));
        lInsertData.add(gcr_TestUtility.getChannelProperty('previous', 'more.svg', 'contacts/svg/', 'GCRWidgetContent', false, true, true));
        // CREATE FAQ BRAND AND SITE MAPPING
        lInsertData.add(new FaqBrandSiteMapping__c(Name = '/aussie/en-us/faq/'
                                                 , BrandSiteUrl__c = 'uat1.aussie.pgsitecore.com/en-us/contact-us'));
        lInsertData.add(new FaqBrandSiteMapping__c(Name = '/tide/en-us/faq/'
                                                 , BrandSiteUrl__c = 'uat1.tide.pgsitecore.com/en-us/contact-us'));
        // CREATE CARE HUB GENERIC PROPERTIES
        lInsertData.add(new GCRGenericProperties__c(Name = 'EMAILUS_MAXSELECTEDPRODUCT', value__c = '5'));
        lInsertData.add(new GCRGenericProperties__c(Name = 'EMAILUS_PRODSEARCH_MAXQUERYLIMIT', value__c = '2000'));
        lInsertData.add(new GCRGenericProperties__c(Name = 'EMAILUS_PRODUCT_SEARCH_PAGESIZE', value__c = '10'));
        lInsertData.add(new GCRGenericProperties__c(Name = 'FAQ_KASEARCH_MAXQUERYLIMIT', value__c = '2000'));
        lInsertData.add(new GCRGenericProperties__c(Name = 'FAQ_KASEARCH_PAGESIZE', value__c = '5'));
        lInsertData.add(new GCRGenericProperties__c(Name = 'gcr_ChannelCount', value__c = '5'));
        lInsertData.add(new GCRGenericProperties__c(Name = 'GCR_FATAL_ERRMSG'
                                                  , value__c = 'An unexpected error occured, please contact your system administrator'));
        lInsertData.add(new GCRGenericProperties__c(Name = 'RTL_LANGUAGES', value__c = 'ar,he'));
        lInsertData.add(new GCRGenericProperties__c(Name = 'FAQ_REDIRECT_TIME', value__c = '5000'));
        lInsertData.add(new GCRGenericProperties__c(Name = 'PROCHAT_PARAM', value__c = 'source'));
        // CREATE CHAT RELATED PROPERTIES
        lInsertData.add(new ChatPage__c(SetupOwnerId = UserInfo.getOrganizationId()
                                      , CareHubChat__c = 'sf_ContactUsChat'
                                      , ProactiveChat__c = 'sf_ContactUsChat'
                                      , ProactivePrechat__c = 'sf_PreChatForm'
                                      , StandaloneChat__c = 'sf_ContactUsChat'
                                      , StandalonePreChat__c = 'sf_PreChatForm'));
        // CREATE COUNTRY STATUS PROPERTIES
        lInsertData.add(new Country_Status__c(Name = 'France'
                                            , Uses_Postal_Codes__c = true, Uses_States__c = false));
        lInsertData.add(new Country_Status__c(Name = gcr_TestUtility.DEFAULT_COUNTRY
                                            , Uses_Postal_Codes__c = true, Uses_States__c = true));
        lInsertData.add(new Country_Status__c(Name = 'Germany'
                                            , Uses_Postal_Codes__c = false, Uses_States__c = false));
        // CREATE CONTACT US URL DATA
        lInsertData.add(new ContactUsURL__c(SetupOwnerId=UserInfo.getOrganizationId()
                                          , LA_BtnVisibilityEndpoint__c = '/chat/rest/Visitor/Availability'
                                          , Live_Agent_Endpoint__c = 'https://d.la4-c2cs-chi.salesforceliveagent.com'
                                          , URL__c = 'http://pgconsumersupport.force.com/ContactUs'));
        
        // STRIKE IRON RELATED CONFIGURATION
        lInsertData.add(new StrikeIronConfiguration__c(Name = 'globalCodeLookUpUrl'
                                                     , Value__c = 'http://ws.strikeiron.com/StrikeIron/'
                                                       	+ 'GlobalPostalCodeLookup3/GlobalPostalCodeLookup'));
        lInsertData.add(new StrikeIronConfiguration__c(Name = 'password', Value__c = 'Password01'));
        lInsertData.add(new StrikeIronConfiguration__c(Name = 'username', Value__c = 'hawn.jf@pg.com'));
        lInsertData.add(new StrikeIronConfiguration__c(Name = 'validateAddressUrl'
                                                     , Value__c = 'http://ws.strikeiron.com/StrikeIron/'
                                                       	+ 'GlobalAddressVerification5/GlobalAddressVerification'));
        lInsertData.add(new StrikeIronConfiguration__c(Name = 'validateEmailTimeoutSeconds', Value__c = '5'));
        lInsertData.add(new StrikeIronConfiguration__c(Name = 'validateEmailUrl'
                                                     , Value__c = 'http://ws.strikeiron.com/StrikeIron/emv6Hygiene'));
        lInsertData.add(new StrikeIronConfiguration__c(Name = 'zipCodeLookUpUrl'
                                                     , Value__c = 'http://ws.strikeiron.com/StrikeIron/'
                                                       	+ 'ZIPPostalCodeInfo5/AdvancedZipInfo'));
        Database.insert(lInsertData, true);
    }
    
    /*
     * @author:         Accenture
     * @date:           25/08/2016
     * @description:    get channel properties data
     * @input:          none
     * @return:         sObject
     */
    public static GCRChannelProperties__c getChannelProperty(String name, String contentName
                                                           , String resourcePath, String resourceName
                                                           , Boolean isNext, Boolean isPrv
                                                           , Boolean isActive) {
        GCRChannelProperties__c retVal = new GCRChannelProperties__c(Name = name
                                                                   , ContentName__c = contentName
                                                                   , StaticResourceName__c = resourceName
                                                                   , ResourcePath__c = resourcePath
                                                                   , isActive__c = isActive
                                                                   , isNext__c = isNext
                                                                   , isPrevious__c = isPrv);
        return retVal;
    }
    
    /*
     * @author:         Accenture
     * @date:           25/08/2016
     * @description:    get care hub data
     * @input:          none
     * @return:         sObject
     */
    public static sObject getCareHubData(String brandConLangId) {
        GCRCareHub__c retVal = new GCRCareHub__c(BrandCountryLanguage__c = brandConLangId
                                               , LandingPageText__c = 'How can we help'
                                               , GCRLabelNext__c = 'Next'
                                               , GCRLabelPrevious__c = 'Previous'
                                               , PrivacyPolicyLabel__c = 'Privacy Policy [Some content here]');
        return retVal;
    }
    
    /*
     * @author:         Accenture
     * @date:           25/08/2016
     * @description:    get care hub data
     * @input:          none
     * @return:         sObject
     */
    public static List<sObject> getCareHubChannels(String careHubId) {
        List<sObject> retVal = new List<sObject>();

        Map<Id, Schema.RecordTypeInfo> mRecordTypeInfo 
            = GCRChannelContent__c.getSObjectType().getDescribe().getRecordTypeInfosById();
        Integer displayOrder = 0;
        for (Id eachRecordTypeId :mRecordTypeInfo.keySet()) {
            if (!mRecordTypeInfo.get(eachRecordTypeId).isMaster()) {
                retVal.add(gcr_TestUtility.getCareHubChannelData(careHubId
                                                               , eachRecordTypeId
                                                               , mRecordTypeInfo.get(eachRecordTypeId).getname()
                                                               , displayOrder, true, false));
            }
            displayOrder++;
        }
        
        return retVal;
    }
    
    /*
     * @author:         Accenture
     * @date:           25/08/2016
     * @description:    get care hub channel data
     * @input:          none
     * @return:         sObject
     */
    public static sObject getCareHubChannelData(String careHubId, String recordTypeId
                                              , String displayName, Integer displayOrder
                                              , Boolean isActive, Boolean isDefault) {
        GCRChannelContent__c retVal;
        if (displayName.equalsIgnoreCase('email us')) {
            retVal = new GCRChannelContent__c(CareHub__c = careHubId
                                            , RecordTypeId = recordTypeId
                                            , DisplayName__c = displayName
                                            , DisplayOrder__c = displayOrder
                                            , isActive__c = isActive
                                            , Default__c = isDefault
                                            , EmailReason1__c = 'Send a testimonial'
                                            , EmailReason2__c = 'Ask a question'
                                            , EmailReason3__c = 'Product availability / Where to buy'
                                            , EmailReason4__c = 'Report a problem'
                                            , EmailReason5__c = 'Coupons, Samples, Sponsorship'
                                            , EmailReason6__c = 'Promotions'
                                            , EmailReasonLabel__c = 'Reason for writing?'
                                            , AddProductLimit__c = 5
                                            , NumberOfProdLabel__c = 'Number of Prod'
                                            , NumberProdCount__c = 10
                                            , PlTranslationYes__c = 'Yes'
                                            , PiTranslationNo__c = 'No'
                                            , EmailStillProdLabel__c = 'Still Have'
                                            , EmailProdUsedLabel__c = 'Product Used');
        } else if (displayName.equalsIgnoreCase('chat')) {
            retVal = new GCRChannelContent__c(CareHub__c = careHubId
                                            , RecordTypeId = recordTypeId
                                            , DisplayName__c = displayName
                                            , DisplayOrder__c = displayOrder
                                            , isActive__c = isActive
                                            , Default__c = isDefault
                                            // PROACTIVE CHAT RELATED TEST DATA
                                            , ChatImageUrl__c = gcr_TestUtility.CHAT_IMAGE_URL
                                            , LADeploymentId__c = gcr_TestUtility.DEPLOYMENT_ID
                                            , LAButtonId__c = gcr_TestUtility.BUTTON_ID);
        } else if (displayName.equalsIgnoreCase('faq')) {
            List<KnowledgeArticleVersion> lFeaturedArticle 
                = gcr_TestUtility.createArticles('FAQ', gcr_TestUtility.FEATURED_ARTICLE_COUNT, 'en_US');
            Database.insert(gcr_TestUtility.getDataCategories('FAQ', lFeaturedArticle), true);
            retVal = new GCRChannelContent__c(CareHub__c = careHubId
                                            , RecordTypeId = recordTypeId
                                            , DisplayName__c = displayName
                                            , DisplayOrder__c = displayOrder
                                            , isActive__c = isActive
                                            , Default__c = isDefault
                                            , FAQFeaturedArticle1__c = lFeaturedArticle.get(0).ArticleNumber
                                            , FAQFeaturedArticle2__c = lFeaturedArticle.get(1).ArticleNumber
                                            , FAQFeaturedArticle3__c = lFeaturedArticle.get(2).ArticleNumber
                                            , FAQFeaturedArticle4__c = lFeaturedArticle.get(3).ArticleNumber
                                            , FAQFeaturedArticle5__c = lFeaturedArticle.get(4).ArticleNumber);
            
        } else {
            retVal = new GCRChannelContent__c(CareHub__c = careHubId
                                            , RecordTypeId = recordTypeId
                                            , DisplayName__c = displayName
                                            , DisplayOrder__c = displayOrder
                                            , isActive__c = isActive
                                            , Default__c = isDefault);
        }

        return retVal;
    }

    /*
     * @author:         Accenture
     * @date:           25/08/2016
     * @description:    create contact us data 
     * @input:
     * @return:         String
     */
    public static String createContactUsObjectData() {
        List<sObject> lDataToInsert = new List<sObject>();
        // GET CONTACT US BRAND DATA
        Contact_Us_Brand__c brandData = new Contact_Us_Brand__c (name = gcr_TestUtility.DEFAULT_BRAND
                                                               , Brand__c = gcr_TestUtility.DEFAULT_BRAND);
        lDataToInsert.add(brandData);
        // GET CONTACT US LANGUAGE DATA
        Contact_Us_Language__c langData = new Contact_Us_Language__c (Name = 'Default'
                                                                    , GCRCountryIsoCode__c = gcr_TestUtility.DEFAULT_COUNTRY_ISO
                                                                    , GCRLanguageIsoCode__c = gcr_TestUtility.DEFAULT_LANGUAGE_ISO
                                                                    , Language__c = gcr_TestUtility.DEFAULT_LANGUAGE
                                                                    , Country__c = gcr_TestUtility.DEFAULT_COUNTRY
                                                                    , Country_Label__c = gcr_TestUtility.DEFAULT_COUNTRY
                                                                    , Language_Locale_Key__c = gcr_TestUtility.DEFAULT_LANGUAGE_LOCALE);
        lDataToInsert.add(langData);
        Database.insert(lDataToInsert);
        // GET CONTACT US BRAND LANGUAGE COUNTRY DATA
        Contact_Us_Brand_Language__c brandLangData = new Contact_Us_Brand_Language__c (Contact_Us_Brand__c = lDataToInsert.get(0).Id
                                                                                     , Contact_Us_Language__c = lDataToInsert.get(1).Id
                                                                                     // ADDITIONAL FIELDS FOR PROACTIVE CHAT TEST DATA
                                                                                     , ChatImageUrl__c = gcr_TestUtility.CHAT_IMAGE_URL
                                                                                     , Live_Agent_Deployment_Id__c = gcr_TestUtility.DEPLOYMENT_ID
                                                                                     , Live_Agent_Button_Id__c = gcr_TestUtility.BUTTON_ID);
        Database.insert(brandLangData);
        lDataToInsert.clear();
        // GET NOTIFICATION TEMPLATE DATA
        Notification_Templates__c nTemplate = new Notification_Templates__c(Name = 'NotificationTemplate'
                                                                          , Brand__c = gcr_TestUtility.DEFAULT_BRAND
                                                                          , Language__c = gcr_TestUtility.DEFAULT_LANGUAGE
                                                                          , Template_Id__c = [ SELECT Id FROM EmailTemplate 
                                                                                               WHERE IsActive = true LIMIT 1].Id
                                                                          , Template_Name__c = [ SELECT Id, DeveloperName 
                                                                                                 FROM EmailTemplate 
                                                                                                 WHERE IsActive = true LIMIT 1].DeveloperName);
        lDataToInsert.add(nTemplate);
        // GET NOTIFICATION TEMPLATE DATA
        Metadata_Site_Rule__c msr = new Metadata_Site_Rule__c(Reason_for_Writing__c = '1;2;3;4;5;6;7;8;9;10'
                                                            , Keywords__c = 'email'
                                                            , Country__c = gcr_TestUtility.DEFAULT_COUNTRY
                                                            , Brand__c = gcr_TestUtility.DEFAULT_BRAND
                                                            , Language__c = gcr_TestUtility.DEFAULT_LANGUAGE
                                                            , Priority__c = '1;2;3;4;5;6;');
        lDataToInsert.add(msr);
        Database.insert(lDataToInsert);
        return brandLangData.Id;
    }
    
    /*
     * @author:         Accenture
     * @date:           23/01/2017
     * @description:    create contact us data 
     * @input:
     * @return:         String
     */
    public static String createContactUsObjectStdData() {
        List<sObject> lDataToInsert = new List<sObject>();
        // GET CONTACT US BRAND DATA
        Contact_Us_Brand__c brandData = new Contact_Us_Brand__c (name = gcr_TestUtility.BRAND_DATA
                                                               , Brand__c = gcr_TestUtility.BRAND_DATA);
        lDataToInsert.add(brandData);
        // GET CONTACT US LANGUAGE DATA
        Contact_Us_Language__c langData = new Contact_Us_Language__c (Name = 'English-GB'
                                                                    , GCRCountryIsoCode__c = gcr_TestUtility.COUNTRY_ISO
                                                                    , GCRLanguageIsoCode__c = gcr_TestUtility.LANGUAGE_ISO
                                                                    , Language__c = gcr_TestUtility.LANGUAGE_DATA
                                                                    , Country__c = gcr_TestUtility.COUNTRY_DATA
                                                                    , Country_Label__c = gcr_TestUtility.COUNTRY_DATA
                                                                    , Language_Locale_Key__c = gcr_TestUtility.LANGUAGE_LOCALE);
        lDataToInsert.add(langData);
        Database.insert(lDataToInsert);
        // GET CONTACT US BRAND LANGUAGE COUNTRY DATA
        Contact_Us_Brand_Language__c brandLangData = new Contact_Us_Brand_Language__c (Contact_Us_Brand__c = lDataToInsert.get(0).Id
                                                                                     , Contact_Us_Language__c = lDataToInsert.get(1).Id
                                                                                     // ADDITIONAL FIELDS FOR PROACTIVE CHAT TEST DATA
                                                                                     , ChatImageUrl__c = gcr_TestUtility.CHAT_IMAGE_URL
                                                                                     , Live_Agent_Deployment_Id__c = gcr_TestUtility.DEPLOYMENT_ID
                                                                                     , Live_Agent_Button_Id__c = gcr_TestUtility.BUTTON_ID);
        Database.insert(brandLangData);
        lDataToInsert.clear();
        // GET NOTIFICATION TEMPLATE DATA
        Notification_Templates__c nTemplate = new Notification_Templates__c(Name = 'NotificationTemplate'
                                                                          , Brand__c = gcr_TestUtility.BRAND_DATA
                                                                          , Language__c = gcr_TestUtility.LANGUAGE_DATA
                                                                          , Template_Id__c = [ SELECT Id FROM EmailTemplate 
                                                                                               WHERE IsActive = true LIMIT 1].Id
                                                                          , Template_Name__c = [ SELECT Id, DeveloperName 
                                                                                                 FROM EmailTemplate 
                                                                                                 WHERE IsActive = true LIMIT 1].DeveloperName);
        lDataToInsert.add(nTemplate);
        // GET NOTIFICATION TEMPLATE DATA
        Metadata_Site_Rule__c msr = new Metadata_Site_Rule__c(Reason_for_Writing__c = '1;2;3;4;5;6;7;8;9;10'
                                                            , Keywords__c = 'email'
                                                            , Country__c = gcr_TestUtility.COUNTRY_DATA
                                                            , Brand__c = gcr_TestUtility.BRAND_DATA
                                                            , Language__c = gcr_TestUtility.LANGUAGE_DATA
                                                            , Priority__c = '1;2;3;4;5;6;');
        lDataToInsert.add(msr);
        Database.insert(lDataToInsert);
        return brandLangData.Id;
    }
    
    /*
     * @author:         Accenture
     * @date:           11/01/2016
     * @description:    create contact us data other than default data
     * @input:
     * @return:         String
     */
    public static String createContactUsData() {
        List<sObject> lDataToInsert = new List<sObject>();
        // GET CONTACT US BRAND DATA
        Contact_Us_Brand__c brandData = new Contact_Us_Brand__c (name = gcr_TestUtility.SELECTED_BRAND
                                                               , Brand__c = gcr_TestUtility.SELECTED_BRAND);
        lDataToInsert.add(brandData);
        // GET CONTACT US LANGUAGE DATA
        Contact_Us_Language__c langData = new Contact_Us_Language__c (Name = 'French-FR'
                                                                    , GCRCountryIsoCode__c = gcr_TestUtility.SELECTED_COUNTRY_ISO
                                                                    , GCRLanguageIsoCode__c = gcr_TestUtility.SELECTED_LANGUAGE_ISO
                                                                    , Language__c = gcr_TestUtility.SELECTED_LANGUAGE
                                                                    , Country__c = gcr_TestUtility.SELECTED_COUNTRY
                                                                    , Country_Label__c = gcr_TestUtility.SELECTED_COUNTRY
                                                                    , Language_Locale_Key__c = gcr_TestUtility.SELECTED_LANGUAGE_LOCALE);
        lDataToInsert.add(langData);
        Database.insert(lDataToInsert);
        // GET CONTACT US BRAND LANGUAGE COUNTRY DATA
        Contact_Us_Brand_Language__c brandLangData = new Contact_Us_Brand_Language__c (Contact_Us_Brand__c = lDataToInsert.get(0).Id
                                                                                     , Contact_Us_Language__c = lDataToInsert.get(1).Id
                                                                                     // ADDITIONAL FIELDS FOR PROACTIVE CHAT TEST DATA
                                                                                     , ChatImageUrl__c = gcr_TestUtility.CHAT_IMAGE_URL
                                                                                     , Live_Agent_Deployment_Id__c = gcr_TestUtility.DEPLOYMENT_ID
                                                                                     , Live_Agent_Button_Id__c = gcr_TestUtility.BUTTON_ID);
        Database.insert(brandLangData);
        lDataToInsert.clear();
        // GET NOTIFICATION TEMPLATE DATA
        Notification_Templates__c nTemplate = new Notification_Templates__c(Name = 'NotificationTemplate'
                                                                          , Brand__c = gcr_TestUtility.SELECTED_BRAND
                                                                          , Language__c = gcr_TestUtility.SELECTED_LANGUAGE
                                                                          , Template_Id__c = [ SELECT Id FROM EmailTemplate 
                                                                                               WHERE IsActive = true LIMIT 1].Id
                                                                          , Template_Name__c = [ SELECT Id, DeveloperName
                                                                                                 FROM EmailTemplate 
                                                                                                 WHERE IsActive = true LIMIT 1].DeveloperName);
        lDataToInsert.add(nTemplate);
        // GET NOTIFICATION TEMPLATE DATA
        Metadata_Site_Rule__c msr = new Metadata_Site_Rule__c(Reason_for_Writing__c = '1;2;3;4;5;6;7;8;9;10'
                                                            , Keywords__c = 'email'
                                                            , Country__c = gcr_TestUtility.SELECTED_COUNTRY
                                                            , Brand__c = gcr_TestUtility.SELECTED_BRAND
                                                            , Language__c = gcr_TestUtility.SELECTED_LANGUAGE
                                                            , Priority__c = '1;2;3;4;5;6;');
        lDataToInsert.add(msr);
        Database.insert(lDataToInsert);
        return brandLangData.Id;
    }
    
    /*
     * @author:         Accenture
     * @date:           25/08/2016
     * @description:    create product data 
     * @input:          none
     * @return:         void
     */
    public static void createProductData(Integer localProdCount) {
        List<Global_Product__c> lGlobalProd = new List<Global_Product__c>();
        lGlobalProd.add(new Global_Product__c(Path__c = gcr_TestUtility.GLOBALBRAND_PATH
                                            , GPID__c = gcr_TestUtility.GLOBAL_PROD_ID
                                            , Product_Level_Number__c = 5
                                            , GCR_Product_ID__c = gcr_TestUtility.GCR_PROD_ID
                                            , Consumer_Facing_Brand__c = gcr_TestUtility.DEFAULT_BRAND + ' CUNSUMERFACING DATA'));
        lGlobalProd.add(new Global_Product__c(Path__c = gcr_TestUtility.GLOBALBRAND_PATH_SELECTED
                                            , GPID__c = gcr_TestUtility.GLOBAL_PROD_ID_SELECTED
                                            , Product_Level_Number__c = 4
                                            , GCR_Product_ID__c = gcr_TestUtility.GCR_PROD_ID_SELECTED
                                            , Consumer_Facing_Brand__c = gcr_TestUtility.SELECTED_BRAND + ' CUNSUMERFACING DATA'));
        Database.insert(lGlobalProd);
        List<Local_Product__c> lLocalProduct = new List<Local_Product__c>();
        while (localProdCount > 0) {
            lLocalProduct.add(gcr_TestUtility.createLocalProductData(lGlobalProd.get(0).Id));
            lLocalProduct.add(gcr_TestUtility.createLocalProductData(lGlobalProd.get(1).Id));
            localProdCount--;
        }
        Database.insert(lLocalProduct, true);
    }
    
    /*
     * @author:         Accenture
     * @date:           25/08/2016
     * @description:    get local product data 
     * @input:          none
     * @return:         void
     */
     public static Local_Product__c createLocalProductData(Id globalProdId) {
         String uniqueIdentifier = EncodingUtil.convertToHex(crypto.generateAesKey(128)).substring(0, 10);
         Local_Product__c retVal = new Local_Product__c (Name = gcr_TestUtility.DEFAULT_BRAND
                                                       , Country__c = gcr_TestUtility.DEFAULT_COUNTRY
                                                       , Brand__c = gcr_TestUtility.DEFAULT_BRAND
                                                       , Consumer_Facing_Brand__c = gcr_TestUtility.DEFAULT_BRAND
                                                       , Consumer_Facing_Name__c = gcr_TestUtility.DEFAULT_BRAND + ' ' + uniqueIdentifier
                                                       , Consumer_Facing__c = true
                                                       , Inactive__c = false
                                                       , Translated_Path__c = gcr_TestUtility.DEFAULT_BRAND
                                                       , Product_Description__c = 'Tide data'
                                                       , Image_Url_Thumb__c = 'https://getsatisfaction.pg.com'
                                                         	+ '/SFDC/HairCare/Aussie_00381519061103_front_thumb.jpg'
                                                       , Image_Url__c = 'https://getsatisfaction.pg.com/SFDC/HairCare' 
                                                         	+ '/Aussie_00381519061103_front.jpg'
                                                       , Global_Product__c = globalProdId);
        return retVal;
     }
    
    /*
     * @author:         Accenture
     * @date:           25/08/2016
     * @description:    Method to create Knowledge Article data in bulk
     * @input:          String, String
     * @return:         sObject
     */
    public static Telephony__c getTelephonyData(Boolean labelNotVisible
                                              , String brand
                                              , String phoneType
                                              , String callCenterId
                                              , String gcrContact
                                              , String itfsNumber) {
        String uniqueIdentifier = EncodingUtil.convertToHex(crypto.generateAesKey(128)).substring(0, 10);
        List<GCRCareHub__c> lCareHub = [ SELECT Id
                                              , BrandCountryLanguage__r.Contact_Us_Brand__c
                                              , Brand__c, Country__c, Language__c
                                         FROM GCRCareHub__c
                                         WHERE Brand__c = :gcr_TestUtility.DEFAULT_BRAND
                                            AND CountryIsoCode__c = :gcr_TestUtility.DEFAULT_COUNTRY_ISO 
                                            AND LanguageIsoCode__c = :gcr_TestUtility.DEFAULT_LANGUAGE_ISO ];
        Telephony__c retVal = new Telephony__c(Contact_Us_Brand__c = lCareHub.get(0).BrandCountryLanguage__r.Contact_Us_Brand__c
                                             , Country__c = lCareHub.get(0).Country__c, Language__c = lCareHub.get(0).Language__c
                                             , Telephony_Name__c = lCareHub.get(0).Brand__c + ' - ' 
                                               + lCareHub.get(0).Country__c + ' - ' + lCareHub.get(0).Language__c + uniqueIdentifier
                                             , localBrand__c = phoneType, isLabelNotVisibleCareHub__c = labelNotVisible
                                             , Call_Center__c = callCenterId, GCR_Contact__c = gcrContact, Region__c = 'NA'
                                             , Carrier__c = 'Carrier', Carrier_Contact_Information__c = 'Carrier_Contact_Information__c'
                                             , LocalOperationalHours__c = 'We are available from 9:00 - 5:00 Monday - Friday'
                                             , Accept_Calls_from_Landline_Phone__c = 'Yes', Accept_Calls_from_Mobile__c = 'Yes'
                                             , Accept_Calls_from_Prepaid_Phone__c = 'Yes',  ITFS_Status__c = 'Active'
                                             , ITFS_Number__c = itfsNumber, Visible_to_contact_us_pages__c = true);
        return retVal;
    }
    
    /*
     * @author:         Accenture
     * @date:           30/08/2016
     * @description:    Method to create user request
     * @input:          String
     * @return:         User
     */
    public static User createUser(String profileId) {
        String uniqueIdentifier = EncodingUtil.convertToHex(crypto.generateAesKey(128)).substring(0, 10);
        User retVal = new User(FirstName = 'fname' + uniqueIdentifier
                             , LastName = 'lname' + uniqueIdentifier
                             , Email = 'fname.lname' + uniqueIdentifier + '@test.com'
                             , UserName = 'fname.lname' + uniqueIdentifier + '@test.com'
                             , Alias = uniqueIdentifier.substring(0, 8)
                             , ProfileId = profileId
                             , TimeZoneSidKey = 'America/New_York'
                             , LocaleSidKey = 'en_US'
                             , EmailEncodingKey = 'ISO-8859-1'
                             , LanguageLocaleKey = 'en_US'
                             //, UserRoleId = roleId
                             , CommunityNickname = uniqueIdentifier);
        Database.insert(retVal, true);
        return retVal;
    }
    
    /*
     * @author:         Accenture
     * @date:           13/10/2016
     * @description:    Method to create user request
     * @input:          String
     * @return:         User
     */
    public static Boolean pageMessageCheck(List<Apexpages.Message> pageMessages
                                         , ApexPages.Severity severity
                                         , String strSummary
                                         , String strDetail) {
        for(ApexPages.Message eachMsg :pageMessages) {
            if(eachMsg.getSeverity() == severity
            && eachMsg.getSummary().equalsIgnoreCase(strSummary)
            && eachMsg.getDetail().equalsIgnoreCase(strDetail)) {
                return true;        
    		}
    	}
        return false;
    }
}