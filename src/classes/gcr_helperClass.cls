/*
* @author:       Accenture
* @date:         14/06/2016
* @description:  Helper class for care hub gcr widget
* DATE              NAME                CHANGE DESCRIPTION
* 27/06/2016        Accenture           Initial Draft
* 22/06/2016        Accenture           Added additional parameter "String imageField" to method "getProducts" which is added to assign
*                                       image url returned from get satisfaction api in product list; Added line 
*                                       "gcr_helperClass.getImageUrl(retVal, imageField);" line in "getProducts" method method to achieve the same
* 30/09/2016        Accenture           DEFECT FIX - TO MATCH WITH LEGACY AS TIBCO PICKS UP FROM CASE PRODUCT HISTORY RECORD
*                                       Introduced new method createCaseProductHistory to collect case product id and status.
* 07/10/2016        Accenture           Refactored ischatBtnAvailable() method into two methods to make it more generic and reusable.
*                                       Used for proactive chat related development.
* 18/11/2016		Accenture			Added additional page message for method getFeaturedArticleData() to show exception message.
* 14/12/2016		Accenture			Added an order by clause (ORDER BY Translated_Path__c ASC) to product search results in "getProducts()"" method
* 16/01/2017		Accenture			Added new method "getRecordTypeIdByDevName()" to get record type id by recordtype developer name
* 17/01/2017		Accenture			Changed method "prepareKAQueryString()" and made it a generic so can be so can be used in 
*										different implementations
* 31/01/2017		Accenture			Added additional boolean parameter in methods getArticleById, getArticleByUrlName to decide whether 
*										view stat required to captured in Salesforce
* 22/02/2017		Accenture			WR467: Featured articles requried to be sorted as entered in featured article fields for e.g. Featured 
*										Article 1 should be on top and Featured Article 5 should be in bottom of featured article list on faq landing.
* 										Return type of method "getFeaturedArticles()" changed from set to List. Added additional logic of featured
*										article sorting in method "getArticles()". Input parameter of method "prepareKAQueryString()" from Set to List.
*/
global class gcr_helperClass {
    /*  SI Statuses for BASIC VALIDATE

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
        522 -  No validation performed because reference database not found */
    public static Contact validateCareHubAddress(Contact contactAddress) {
        Contact retVal;
        sf_EmailUsExt.validationWrapper valWrapper = sf_EmailUsExt.validatePrimaryAddress(contactAddress.Primary_Address_Line_1__c
                                                                                        , contactAddress.Primary_Address_Line_2__c
                                                                                        , contactAddress.Primary_Address_Line_3__c
                                                                                        , contactAddress.Primary_Postal_Code__c
                                                                                        , contactAddress.Primary_City__c
                                                                                        , contactAddress.Primary_State_Province__c
                                                                                        , contactAddress.Primary_Country__c);

        // INCASE OF STATUS 221 DO NOT SEND VALIDATED ADDRESS AS 221 MEANS ADDRESS ENTERED IS CORRECT
        if (valWrapper.addressValidationStatusNumber.equals('222')
        //|| valWrapper.addressValidationStatusNumber.equals('221')
        || valWrapper.addressValidationStatusNumber.equals('323')
        || valWrapper.addressValidationStatusNumber.equals('324')
        || valWrapper.addressValidationStatusNumber.equals('325')) {
            retVal = new Contact();
            retVal.Primary_Address_Line_1__c = valWrapper.validatedAddress1;
            retVal.Primary_Address_Line_2__c = valWrapper.validatedAddress2;
            retVal.Primary_Address_Line_3__c = valWrapper.validatedAddress3;
            retVal.Primary_City__c = valWrapper.validatedCity;
            if(String.isNotBlank(valWrapper.validatedCountry)) {
                retVal.Primary_Country__c = valWrapper.validatedCountry;
            } else {
                retVal.Primary_Country__c = contactAddress.Primary_Country__c;
            }
            retVal.Primary_State_Province__c = valWrapper.validatedState;
            retVal.Primary_Postal_Code__c = valWrapper.validatedZip;
        }

        return retVal;
    }
    
    /*
     * @author:         Accenture
     * @date:           30/09/2016
     * @description:    DEFECT FIX - TO MATCH WITH LEGACY AS TIBCO PICKS UP FROM CASE PRODUCT HISTORY RECORD
     *                  This method created as downstream system are collecting data from Case Product history records.
     *                  So logic is created strictly to keep up with legacy implementation. Prepares a map of case product Id and
     *                  corrosponding product status and which required to be sent to future method to create case history record.
     * @input:          List<sObject>
     * @return:         Map<Id, String>
     */
    public static Map<Id, String> createCaseProductHistory(List<Case_Product__c> lCaseProduct) {
        Map<Id, String> retVal = new Map<Id, String>();
        for (Case_Product__c eachCaseProd :lCaseProduct) {
            retVal.put(eachCaseProd.Id, eachCaseProd.Product_available_for_return__c);
        }

        return retVal;
    }
    
    /*
     * @author:         Accenture
     * @date:           20/07/2016
     * @description:    manage attachment for email us page
     * @input:          String, String, Boolean
     * @return:         void
     */
    public static void manageAttachment(String strAttachmentId, String parentId, Boolean isCreate) {
        List<String> lAttachemntId = new List<String>();
        List<Attachment> lAttachment = new List<Attachment>();
        List<Attachment> lAttachmentDel = new List<Attachment>();
        if (String.isNotEmpty(strAttachmentId)) {
            lAttachemntId = strAttachmentId.split(',');
            Attachment newAttachment;
            for (Attachment eachAttachment :[ SELECT Id
                                                   , Name
                                                   , Body
                                                   , ContentType
                                              FROM Attachment
                                              WHERE Id = :lAttachemntId ]) {
                if (isCreate) {
                    newAttachment = new Attachment();
                    newAttachment.Name = eachAttachment.Name;
                    newAttachment.Body = eachAttachment.Body;
                    newAttachment.ContentType = eachAttachment.ContentType;
                    newAttachment.ParentId = parentId;
    
                    lAttachment.add(newAttachment);
                }
                lAttachmentDel.add(eachAttachment);
            }
            if (lAttachment != null && !lAttachment.isEmpty()) {
                Database.insert(lAttachment, true);
            }
            if (lAttachmentDel != null && !lAttachmentDel.isEmpty()) {
                Database.delete(lAttachmentDel, true);
            }
        }
    }
    
    /*
     * @author:         Accenture
     * @date:           20/07/2016
     * @description:    get assignment rule queue for smart care
     * @input:          String, String, String, String, sObject
     * @return:         void
     */
    public static void assignmentRuleQueue(String emailId, String language, String country, String reasonCode, Case newCase) {
        Metadata_Case_Assignment_Rule__c matchedCaseAssignmentRule
            = sf_CaseAssignmentRuleUtility.getMCARRecord(newCase.Brand__c
                                                       , language
                                                       , country
                                                       , newCase.Priority
                                                       , newCase.Status
                                                       , emailId
                                                       , newCase.Origin //CDOY WR114 - Add case origin to MCAR Rules
                                                       , reasonCode);
        if (matchedCaseAssignmentRule != null) {
            String queueId = sf_CaseAssignmentRuleUtility.getQueueIdByName (matchedCaseAssignmentRule.Queue_Name__c);
            if (queueId != null){
                newCase.OwnerId = queueId;
            } else {
                newCase.OwnerId = sf_CaseAssignmentRuleUtility.getQueueIdByName(sf_Constants.DEFAULT_QUEUE_NAME);
            }
              
            //ChrisM: The field Case_Record_Type_Name__c is no longer used
            String recordTypeId = sf_CaseAssignmentRuleUtility.getRecordTypeIdByName('Case', matchedCaseAssignmentRule.Case_Record_Type_Name__c);
            if (recordTypeId != null){
                newCase.RecordTypeId =  recordTypeId;
            }   
        }
    }
    
    /*
     * @author:         Accenture
     * @date:           20/07/2016
     * @description:    check for chat button availability via salesforce live agent api
     * @input:          Boolean
     * @return:         String
     */
    public static Boolean ischatBtnAvailable(String chlContentId) {
        Boolean retVal = false;
        GCRChannelContent__c chatChannelContent = [ SELECT Id
                                                         , LAButtonId__c
                                                         , LADeploymentId__c 
                                                    FROM GCRChannelContent__c 
                                                    WHERE Id = :chlContentId  ];
        HttpRequest htpRequest = new HttpRequest();
        retVal = gcr_helperClass.ischatBtnAvailable(chatChannelContent.LADeploymentId__c, chatChannelContent.LAButtonId__c);
        return retVal;
    }
    
    /*
     * @author:         Accenture
     * @date:           20/07/2016
     * @description:    check for email validity via strike iron.
     * @input:          Boolean
     * @return:         String
     */
    public static Boolean isEmailAddressValid (String emailAddress) {
        String statusCode = gcr_helperClass.validateEmailAddressString(emailAddress);
        return !(statusCode == '300' || statusCode == '310' || statusCode == '400');
    }
    
    /*
     * @author:         Accenture
     * @date:           20/07/2016
     * @description:    insert/update attachment based on passed attachment id
     * @input:          sObject
     * @return:         String, String, String, String, Blob
     */
    public static Attachment getAttachment(String strAttId, String strAttName, String strAttContent, String strAttBody) {
        if (String.isNotEmpty(strAttId)) {
            Attachment extAttach = [ SELECT Id
                                          , Body
                                     FROM Attachment 
                                     WHERE Id = :strAttId ].get(0);
            String newBody = EncodingUtil.base64Encode(extAttach.Body) + strAttBody;
            extAttach.Body = EncodingUtil.base64Decode(newBody);
            extAttach.ContentType = strAttContent;
            update extAttach;
            return extAttach;
        } else {
            List <Metadata_Temp_Attachement__c> lTempAttachment 
                = new List <Metadata_Temp_Attachement__c> ([SELECT Id 
                                                            FROM Metadata_Temp_Attachement__c 
                                                            WHERE Name = :String.valueOf(System.today()) LIMIT 1]);
            Metadata_Temp_Attachement__c tempAtt;
            
            if (lTempAttachment != null && !lTempAttachment.isEmpty()) {
                tempAtt = lTempAttachment.get(0);
            } else {
                tempAtt = new Metadata_Temp_Attachement__c ();
                tempAtt.Name = String.valueOf(System.today());
                Database.insert(tempAtt, false);
            }
            Attachment newAttachment = new Attachment();
            newAttachment.Name = String.isNotEmpty(strAttName) ? strAttName : String.valueOf(System.now());
            newAttachment.ContentType = strAttContent;
            newAttachment.ParentId = tempAtt.Id;
            newAttachment.Body = String.isNotEmpty(strAttBody) ? EncodingUtil.base64Decode(strAttBody) : Blob.valueOf('');
            insert newAttachment;
            return newAttachment;
        }
    }
    
    /*
     * @author:         Accenture
     * @date:           20/07/2016
     * @description:    insert/update attachment based on passed attachment id
     * @input:          sObject
     * @return:         String, String, String, String, Blob
     */
    public static Attachment upsertAttachment(String strId, String strName, String strContent, String strParentId, Blob blobBody) {
        Attachment retVal = String.isNotEmpty(strId) ? (Attachment) Attachment.getSObjectType().newSObject(strId) : new Attachment();
        retVal.Name = strName;
        retVal.ContentType = String.isNotEmpty(strContent) ? strContent : '';
        if (String.isEmpty(strId)) {
            retVal.ParentId = strParentId;
        }
        retVal.Body = blobBody;
        upsert retVal;
        return retVal;
    }

    /*
     * @author:         Accenture
     * @date:           20/07/2016
     * @description:    validate email through strike iron api
     * @input:          String
     * @return:         String
     */
    public static String validateEmailAddressString (String emailAddress) {
        sf_StrikeIronValidateEmailResponseBean emailBean;
        sf_StrikeIronService service = sf_StrikeIronServiceFactory.getStrikeIronService();
        
        if (!String.isEmpty(emailAddress)){
            emailBean = service.validateEmailAddress(emailAddress);
            return emailBean.statusNbr;
        } else return '';
    }
    
    /*
     * @author:         Accenture
     * @date:           20/07/2016
     * @description:    validates format of the string email passed in the method
     * @input:          String
     * @return:         Boolean
     */
    public static Boolean validateEmailFormat(String strEmail) {
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';

        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(strEmail);

        return MyMatcher.matches();
    }
    
    /*
     * @author:         Accenture
     * @date:           20/07/2016
     * @description:    get featured articles from passed channel content
     * @input:          sObject
     * @return:         Set<String>
     */
    public static List<String> getFeaturedArticles(GCRChannelContent__c gcrCareHub) {
        // WR467: CHANGED RETURN TYPE FROM SET TO LIST
        List<String> retVal = new List<String>();
        retVal.add(gcrCareHub.FAQFeaturedArticle1__c);
        retVal.add(gcrCareHub.FAQFeaturedArticle2__c);
        retVal.add(gcrCareHub.FAQFeaturedArticle3__c);
        retVal.add(gcrCareHub.FAQFeaturedArticle4__c);
        retVal.add(gcrCareHub.FAQFeaturedArticle5__c);
        return retVal;
    }
    
    /*
     * @author:         Accenture
     * @date:           20/07/2016
     * @description:    get picklist label, value map for passed object and field name
     * @input:          String, String
     * @return:         Map<String, String>
     */
    public static Map<String, String> getAllPicklistValues(String objectName, String fieldName) {
        Map<String, String> retVal = new Map<String, String>();
        for(Schema.PicklistEntry eachPLEntry :Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
            retVal.put(eachPLEntry.getLabel(), eachPLEntry.getValue());
        }

        return retVal;
    }
    
    /*
     * @author:         Accenture
     * @date:           20/07/2016
     * @description:    prepare query string of SOQL to find knowledge articles
     * @input:          String, String, String, String, Set<String>
     * @return:         String
     */
    public static List<KnowledgeArticleVersion> getArticles(String strCountry, String strBrand, String strLanguage, String articleStatus, List<String> lFArticles) {
        // WR467 - SORT FEATURED ARTICLES BASED ON FEATURED ARTICLE FIELD FOR E.G. FA1 ON TOP AND FA5 AT BOTTOM
        List<KnowledgeArticleVersion> retVal = new List<KnowledgeArticleVersion>();
        // PREPARE KA MAP BY ARTICLE NUMBER
        Map<String, KnowledgeArticleVersion> mKaByArtNumber = new Map<String, KnowledgeArticleVersion>();
        for (KnowledgeArticleVersion eachKav :Database.query(prepareKAQueryString(strCountry, strBrand, strLanguage, articleStatus, lFArticles))) {
            mKaByArtNumber.put(eachKav.ArticleNumber, eachKav);
        }
        // COLLECT SORTED VALUES IN RETURN LIST
        for (String eachArticleNo :lFArticles) {
            if (mKaByArtNumber.keySet().contains(eachArticleNo)) {
            	retVal.add(mKaByArtNumber.get(eachArticleNo));
            }
        }
        return retVal;
    }

    /*
     * @author:         Accenture
     * @date:           20/07/2016
     * @description:    prepare query string of SOQL to find knowledge articles
     * @input:          String, String, String, String, Set<String>
     * @return:         String
     */
    // WR467 - CHANGED PARAMETER TYPE "lFArticles" FROM SET TO LIST
    public static String prepareKAQueryString(String strCountry, String strBrand
                                            , String strLanguage, String articleStatus, List<String> lFArticles) {
        String queryString = 'SELECT Id, Title, Summary, UrlName, ArticleNumber'
            + ', LastModifiedDate, FirstPublishedDate, LastPublishedDate,'
            + ' Language, PublishStatus, KnowledgeArticleId FROM KnowledgeArticleVersion'
            + ' WHERE PublishStatus = \'Online\' AND Language = \''+ strLanguage + '\'';
        queryString += lFArticles != null && !lFArticles.isEmpty() ? ' AND ArticleNumber IN :lFArticles' : '';
        queryString += strBrand != null && String.isNotEmpty(strBrand)
            ? ' WITH DATA CATEGORY Brand__c AT (' + getBrandfilter(strBrand) + '__c, All__c)' : '';
        queryString += strCountry != null && String.isNotEmpty(strCountry) 
            ? strBrand != null && String.isNotEmpty(strBrand) 
            	? ' AND Region__c ABOVE_OR_BELOW ' + strCountry + '__c'
            	: ' WITH DATA CATEGORY Region__c ABOVE_OR_BELOW ' + strCountry + '__c' 
            : '';
        return queryString;
    }
    
    /*
     * @author:         Accenture
     * @date:           20/07/2016
     * @description:    prepare query string of SOSL to find knowledge articles
     * @input:          String, String, String, String
     * @return:         void
     */  
    public static void prepareSearchKAQueryString(String strSearch, String strCountry, String strBrand, String strLanguage) {
        String retVal = 'FIND ' + strSearch + ' RETURNING KnowledgeArticleVersion '
                        + '(Id, Title, Summary, ArticleType WHERE )';
    }

    /*
     * @author:         Accenture
     * @date:           20/07/2016
     * @description:    get featured article by Id and Language
     * @input:          Id, String, Boolean
     * @return:         sObject
     */    
    public static FAQ__kav getArticleById(Id articleId, String strLanguage, Boolean addViewStat) {
        String strArticleNumber = [ SELECT ArticleNumber FROM FAQ__ka WHERE Id = :articleId ].get(0).ArticleNumber;
        String strQuery = 'SELECT Id, Title, Answer__c, ArticleNumber, Helpful_Links__c' 
            + ' FROM FAQ__kav WHERE ArticleNumber = :strArticleNumber'
            + ' AND PublishStatus = \'Online\' AND Language = :strLanguage';
        // ADDED TO GET VIEW STAT CAPTURED IN SALESFORCE WHENEVER REQUIRED
        if (addViewStat) {
            strQuery += ' UPDATE VIEWSTAT';
        }
        return (FAQ__kav) Database.query(strQuery).get(0);
    }
    
    /*
     * @author:         Accenture
     * @date:           20/07/2016
     * @description:    Get Article details by URL name
     * @input:          String, String, Boolean
     * @return:         List<sObject>
     */
    public static FAQ__kav getArticleByUrlName(String articleUrlName, String strLanguage, Boolean addViewStat) {
        String strQuery = 'SELECT Id, Title, Answer__c, ArticleNumber, Helpful_Links__c FROM FAQ__kav'
            + ' WHERE UrlName = :articleUrlName AND PublishStatus = \'Online\' AND Language = :strLanguage';
        // ADDED TO GET VIEW STAT CAPTURED IN SALESFORCE WHENEVER REQUIRED
        if (addViewStat) {
            strQuery += ' UPDATE VIEWSTAT';
        }
        List<sObject> lKArticle = Database.query(strQuery);
        return lKArticle != null && !lKArticle.isEmpty() ? (FAQ__kav) lKArticle.get(0) : null;
    }

    /*
     * @author:         Accenture
     * @date:           20/07/2016
     * @description:    get all featured articles for passed channel contect, brand and language
     * @input:          sObject, String, String
     * @return:         List<sObject>
     */
    public static List<KnowledgeArticleVersion> getFeaturedArticleData(GCRChannelContent__c chlContent, String strBrand, String strLaguage) {
         List<KnowledgeArticleVersion> retVal = new List<KnowledgeArticleVersion>();
        try {
            retVal = gcr_helperClass.getArticles(chlContent.CareHub__r.FAQCountry__c
                                      , strBrand
                                      , strLaguage
                                      , 'Online'
                                      , gcr_helperClass.getFeaturedArticles(chlContent));
        } catch (Exception caughtException) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, LABEL.errMsgGeneric));
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, caughtException.getMessage()));
            SYSTEM.DEBUG('EXCEPTION: ' + caughtException.getMessage());
        }
        return retVal;
    }
    
    /*
     * @author:         Accenture
     * @date:           20/07/2016
     * @description:    search a knowledge article with passed string, offset, brand, country and language 
     * @input:          String, Integer, Integer, String, String, String
     * @return:         List<sObject>
     */
    public static List<KnowledgeArticleVersion> getSearchedArticle(String strSearch, Integer offset, Integer pageSize
                                                                   , String strLang, String strBrand, String strCountry) {
        String strKAQuery = 'Id, Title, KnowledgeArticleId, Summary, UrlName WHERE PublishStatus=\'online\' ' 
                            + 'AND Language = \'' + strLang + '\' ';
        // IF PAGE SIZE IS NOT NULL AND GREATER THAN 0 ADD LIMIT TO QUERY
        if (pageSize != null && pageSize > 0) {
            strKAQuery += ' LIMIT ' + String.valueOf(pageSize);
        }
        // IF OFFSET IS NOT NULL AND GREATER THAN 0 ADD LIMIT TO QUERY
        if (offset != null && offset > 0) {
           strKAQuery += ' OFFSET ' + String.valueOf(offset);
        }
        // GET COUNTRY FOR KA DATA CATEGORY FILTER
        String strQuery = 'FIND \'' + strSearch + '\' RETURNING KnowledgeArticleVersion ' + '(' + strKAQuery + ') '
                            + 'WITH DATA CATEGORY Brand__c AT (' + getBrandfilter(strBrand) + '__c, All__c) '
                            + 'AND Region__c ABOVE_OR_BELOW ' + strCountry + '__c';
        List<List<sObject>> articles = Search.query(strQuery);
        return articles != null && !articles.isEmpty() ? (List<KnowledgeArticleVersion>) articles.get(0) : null;
    }
    
    /*
     * @author:         Accenture
     * @date:           20/07/2016
     * @description:    construct query string for passed object, columns and query type i.e. SOQL or SOSL
     * @input:          String, String, String
     * @return:         String
     */
    public static String createQueryString(String strQueryType, String strColumns, String strObjectName) {
        String retVal = '';
        if (strQueryType.equalsIgnoreCase('SELECT')) {
            retVal = 'SELECT ' + strColumns + ' FROM ' + strObjectName;
        } else if (strQueryType.equalsIgnoreCase('FIND')) {
            retVal = strColumns + ' WHERE ';
        }
        return retVal;
    }
    
    /*
     * @author:         Accenture
     * @date:           20/07/2016
     * @description:    get all fields for passed Object
     * @input:          String, String
     * @return:         String
     */
    public static String getAllFieldsForQuery(String strObject) {
        String retVal = '';
        Map<String, Schema.SObjectField> mFieldData = Schema.getGlobalDescribe().get(strObject).getDescribe().fields.getMap();
        Integer itr = mFieldData.size();
        for (String eachField :mFieldData.keySet()) {
            itr--;
            if (mFieldData.get(eachField).getDescribe().isAccessible()) {
                retVal += String.isEmpty(retVal) ? eachField : ',' + eachField;
            }
        }
        return retVal;
    }
    
    /*
     * @author:         Accenture
     * @date:           20/07/2016
     * @description:    get all fields and query string of child object to use the same for parent query string
     * @input:          String, Set<String>
     * @return:         String
     */
    public static String getChildQueryString(String strObject, Set<String> sRelationshipName) {
        String retVal = '';
        String strObjectName;
        List<Schema.ChildRelationship> lChildRels = Schema.getGlobalDescribe().get(strObject).getDescribe().getChildRelationships();
        Integer itr = sRelationshipName != null && !sRelationshipName.isEmpty() ? sRelationshipName.size() : lChildRels.size();
        for(Schema.ChildRelationship eachChild :lChildRels) {
            strObjectName = eachChild.getChildSObject().getDescribe().getName();
            if (sRelationshipName != null && !sRelationshipName.isEmpty()) {
                itr--;
                if(sRelationshipName.contains(eachChild.getRelationshipName())) {
                    if (String.isNotEmpty(eachChild.getRelationshipName())) {
                        retVal += itr > 0 ? '(' + createQueryString('SELECT', gcr_helperClass.getAllFieldsForQuery(strObjectName), eachChild.getRelationshipName()) + '),'
                            : '(' + createQueryString('SELECT', gcr_helperClass.getAllFieldsForQuery(strObjectName), eachChild.getRelationshipName()) + ')';
                    }
                }
            } else {
                itr--;
                if (String.isNotEmpty(eachChild.getRelationshipName())) {
                    retVal += itr > 0 ? '(' + createQueryString('SELECT', gcr_helperClass.getAllFieldsForQuery(strObjectName), eachChild.getRelationshipName()) + '),'
                        : '(' + createQueryString('SELECT', gcr_helperClass.getAllFieldsForQuery(strObjectName), eachChild.getRelationshipName()) + ')';
                }
            }
            
        }
        return retVal;
    }
    
    /*
     * @author:         Accenture
     * @date:           20/07/2016
     * @description:    get all fields of passed field set and object
     * @input:          String, String
     * @return:         String
     */
    public static String getFieldSetFieldsForQuery(String strSobject, String strFieldSet) {
        String retVal = '';
        for(Schema.FieldSetMember eachField :Schema.getGlobalDescribe().get(strSobject).getDescribe().fieldSets.getMap().get(strFieldSet).getFields()) {
            retVal = String.isNotBlank(retVal) ? retVal + ',' + eachField.getFieldPath() : retVal + eachField.getFieldPath();
        }
        return retVal;
    }
    
    /*
     * @author:         Accenture
     * @date:           20/07/2016
     * @description:    get data category api name for selected brand
     * @input:          String
     * @return:         String
     */
    public static String getBrandfilter(String strBrand) {
        // GET VALID BRAND NAMES FROM SCHEMA
        Schema.DataCategoryGroupSobjectTypePair pair = new Schema.DataCategoryGroupSobjectTypePair();
        pair.setSObject(KnowledgeArticleVersion.sObjectType.getDescribe().getName());
        pair.setDataCategoryGroupName('Brand');
    
        List <Schema.DataCategoryGroupSobjectTypePair> pairs = new List<Schema.DataCategoryGroupSobjectTypePair>{pair};
    
        List <Schema.DescribeDataCategoryGroupStructureResult> res = Schema.describeDataCategoryGroupStructures(pairs, false);
        Map <String, String> brandLabelNameMap = new Map <String, String> ();
    
        for(Schema.DataCategory cat :res[0].getTopCategories()[0].getChildCategories()) {
            brandLabelNameMap.put(cat.getLabel().toLowerCase(), cat.getName());
        }
            
        return brandLabelNameMap.get(strBrand.toLowerCase());
    }
    
    /*
     * @author:         Accenture
     * @date:           20/07/2016
     * @description:    get products for passed search string, brand, country, language and offset
     * @input:          String, String, String, Integer, Integer
     * @return:         List<sObject>
     */
    // TODO: TRY MERGING THIS METHOD WITH KNOWLEDGE ARTICLE SEARCH METHOD AND HAVE A SINGLE METHOD FOR SEARCH
    // TODO: REFECTOR THIS METHOD
    public static List<sObject> getProducts(String strSearch, String selectedCountry, String selectedBrand, String imageField, Integer intPageSize, Integer intOffsetVal) {
        List<sObject> retVal = new List<sObject>();
        // GET QUERY RECORD LIMIT OF PRODUCT SEARCH FROM CONFIGURATION
        Integer intQueryLimit = Integer.valueOf(GCRGenericProperties__c.getInstance('EMAILUS_PRODSEARCH_MAXQUERYLIMIT').value__c);
        String queryString = '';
        strSearch = String.escapeSingleQuotes(strSearch);
        if (strSearch.split('\\s').size() > 1) {
            queryString += 'FIND :strSearch IN ALL FIELDS ' 
                + 'RETURNING Local_Product__c (Id, Image_Url_Thumb__c, Image_Url__c, Consumer_Facing_Name__c '
                + 'WHERE Country__c = :selectedCountry '
                + 'AND Inactive__c = false '
                + 'AND Consumer_Facing_Brand__c = :selectedBrand '
                + 'AND Consumer_Facing__c = true '
                + 'AND Consumer_Facing__c != null '
                // ADD ADDITIONAL CONDITION TO ORDER RESULTS WITH TRANSLATED PATH
                + 'ORDER BY Translated_Path__c ASC ';
            
            if (intPageSize != null && intOffsetVal != null) {
                queryString += 'LIMIT :intPageSize OFFSET :intOffsetVal)';
            } else {
                queryString += 'LIMIT :intQueryLimit)';
            }
            retVal = Search.query(queryString).get(0);
        } else {
            String strTemp = '%' + strSearch + '%';
            queryString += 'SELECT Id, Image_Url_Thumb__c, Image_Url__c, Consumer_Facing_Name__c '
                + 'FROM Local_Product__c WHERE Country__c = :selectedCountry '
                + 'AND Inactive__c = false AND Consumer_Facing_Brand__c = :selectedBrand '
                + 'AND Consumer_Facing__c = true ';
            
            if (!strSearch.isNumeric()) {
                queryString += ' AND (Consumer_Facing_Name__c LIKE :strTemp OR Product_Description__c LIKE :strTemp)'; 
            } else {
                queryString += ' AND GTIN_Number__c LIKE :strTemp ';
            }
            // ADD ADDITIONAL CONDITION TO ORDER RESULTS WITH TRANSLATED PATH
            queryString += 'ORDER BY Translated_Path__c ASC ';
            if (intPageSize != null && intOffsetVal != null) {
                queryString += 'LIMIT :intPageSize OFFSET :intOffsetVal';
            } else {
                queryString += 'LIMIT :intQueryLimit';
            }
            retVal = Database.query(queryString);
        }
        //gcr_helperClass.getImageUrl(retVal, imageField);
        return retVal;
    }
    
    /*
     * @author:         Accenture
     * @date:           20/08/2016
     * @description:    Method to check if current time is in the passed business hour
     * @input:          String
     * @return:         Boolean
     */
    public static Boolean isBusinessHoursActive(String businessHourId) {
        List<BusinessHours> lBhours = new List<BusinessHours>();
        if (String.isNotEmpty(businessHourId)) {
            lBhours = [ SELECT Id FROM BusinessHours WHERE Id = :businessHourId AND isActive = true ];
            if (lBhours.isEmpty()) {
                lBhours = [ SELECT Id FROM BusinessHours WHERE isDefault = true AND isActive = true ];
            }
        } else {
            lBhours = [ SELECT Id FROM BusinessHours WHERE isDefault = true ];
        }

        return lBhours != null && !lBhours.isEmpty() ? BusinessHours.isWithin(lBhours.get(0).Id, SYSTEM.Now()) : false;
    }
    
    /*
     * @author:         Accenture
     * @date:           20/08/2016
     * @description:    Method to get image url via api
     * @input:          List<sObject>, String
     * @return:         List<sObject>
     */
    public static List<Local_Product__c> getImageUrl(List<Local_Product__c> lLocalProduct, String fieldName) {
        List<Local_Product__c> retVal = new List<Local_Product__c>();
        String authToken = DAM_Brandstore_Settings__c.getInstance().Brandstore_Image_Token__c != null 
                         ? DAM_Brandstore_Settings__c.getInstance().Brandstore_Image_Token__c : '';
        String brandStoreUrl = DAM_Brandstore_Settings__c.getInstance().Brandstore_Url__c != null 
                             ? DAM_Brandstore_Settings__c.getInstance().Brandstore_Url__c : '';
        for (Local_Product__c eachProd :lLocalProduct) {
            eachProd.put(fieldName, gcr_helperClass.getImageUrl((String) eachProd.get(fieldName), authToken, brandStoreUrl));
            retVal.add(eachProd);
        }
        return retVal;
    }
    
    /*
     * @author:         Accenture
     * @date:           20/08/2016
     * @description:    Method to get image url via api
     * @input:          String, String, String
     * @return:         String
     */
    public static String getImageUrl(String imageUrl, String authToken, String brandStoreUrl) {
        String retVal = imageUrl;
        if (String.isNotEmpty(authToken) && String.isNotEmpty(brandStoreUrl)) {
            if (String.isEmpty(imageUrl) || imageUrl.equalsIgnoreCase('null')) {
                retVal = '';
            } else if (imageUrl.startsWith(brandStoreUrl)) {
                Http htp = new Http();
                try {
                    HttpRequest req = new HttpRequest ();
                    req.setEndpoint(imageUrl);
                    req.setMethod('GET');
                    req.setHeader('x-auth-token', authToken);
                    HttpResponse resp = htp.send(req);
                    String error404 = '/404.html?aspxerrorpath';
                    retVal = resp.getStatusCode() == 302 && !resp.getHeader('Location').contains(error404) ? resp.getHeader('Location') : '';   
                } catch (Exception e) {
                    SYSTEM.DEBUG(LoggingLevel.INFO, 'exception occurred - ' + e.getMessage() + '-' + e.getStackTraceString());
                    retVal = '';
                }
            }
        }
        
        return retVal;
    }
    
    /*
     * @author:         Accenture
     * @date:           10/10/2016
     * @description:    check for chat button availability via salesforce live agent api
     * @input:          Boolean
     * @return:         String
     */
    public static Boolean ischatBtnAvailable(String deploymentId, String buttonId) {
        Boolean retVal = false;
        HttpRequest htpRequest = new HttpRequest();
        ContactUsURL__c contactUsCsInstance = ContactUsURL__c.getInstance();
        String endpoint = contactUsCsInstance.Live_Agent_Endpoint__c + contactUsCsInstance.LA_BtnVisibilityEndpoint__c
            + '?org_id=' + UserInfo.getOrganizationId().left(15) + '&deployment_id=' + deploymentId + '&Availability.ids=' + buttonId;
        htpRequest.setHeader('X-LIVEAGENT-API-VERSION', '35');
        htpRequest.setEndpoint(endpoint);
        htpRequest.setMethod('GET');
        Http htp = new Http();
        try {
            HttpResponse htpResponse = htp.send(htpRequest);
            gcr_LiveChatResponse responseData = (gcr_LiveChatResponse) JSON.deserialize(htpResponse.getBody(), gcr_LiveChatResponse.class);
            if (responseData.messages.get(0).message.results.get(0).isAvailable != null) {
                retVal = responseData.messages.get(0).message.results.get(0).isAvailable;
            } else {
                retVal = false;
            }
        } catch(Exception caughtException) {
            SYSTEM.DEBUG('EXCEPTION : ' + caughtException.getMessage());
        }
        return retVal;
    }
    
    /*
     * @author:         Accenture
     * @date:           16/01/2017
     * @description:    check for chat button availability via salesforce live agent api
     * @input:          String, String
     * @return:         String
     */
    public static String getRecordTypeIdByDevName(String objectName, String rtDevName) {
        Map<String, String> mRecordTypeById = new Map<String, String>();
        for (Schema.RecordTypeInfo eachRtInfo :Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfos()) {
            mRecordTypeById.put(eachRtInfo.getName(), eachRtInfo.getRecordTypeId());
        }
        
        return mRecordTypeById.get(rtDevName);
    }
    
    /*
     * @author:         Accenture
     * @date:           13/07/2017
     * @description:    map address string in contact's address field
     * @input:          String
     * @return:         Contact
     */
    Public static Contact mapAddressDetails(String addressString, Contact inContact) {
        Contact retVal = inContact != null ? inContact : new Contact();
        List<String> lAddress = addressString.split(';');
        
        if (lAddress != null && !lAddress.isEmpty() && lAddress.size() == 6) {
            retVal.Primary_Address_Line_1__c = lAddress.get(0);
            retVal.Primary_Address_Line_2__c = lAddress.get(1);
			// STRIKE IRON LIMITATION
			retVal.Primary_Address_Line_3__c = '';
            retVal.Primary_City__c = lAddress.get(2);
            retVal.Primary_State_Province__c = lAddress.get(3);
            retVal.Primary_Country__c = lAddress.get(4);
            retVal.Primary_Postal_Code__c = lAddress.get(5);
        }
        
        return retVal;
    }
    
    public static void mapContactData(String strFName, String strLName, String strEmail, String strPhone, String strAddress, Contact updatedContact) {
        if (String.isNotEmpty(strFName)) updatedContact.FirstName = strFName;
        if (String.isNotEmpty(strLName)) updatedContact.LastName = strLName;
        if (String.isNotEmpty(strEmail)) updatedContact.Email = strEmail;
        if (String.isNotEmpty(strPhone)) updatedContact.Phone = strPhone;
        if (String.isNotEmpty(strAddress)) {
            gcr_helperClass.mapAddressDetails(strAddress, updatedContact);
        }
    }
    // PULLED THIS METHOD FROM PII CONTACT US CONTROLLER
    public static QueueRecordType__c getRecordType(string strcountry, string strlanguage){
        QueueRecordType__c queueRec;
        List <QueueRecordType__c> qrrecs = QueueRecordType__c.getall().values();
        for (QueueRecordType__c qr : qrrecs){
            if (qr.Country__c == strcountry && qr.Language__c == strlanguage) {
                queueRec = qr;
                break;
            }
        }
        return queueRec;
    }
}