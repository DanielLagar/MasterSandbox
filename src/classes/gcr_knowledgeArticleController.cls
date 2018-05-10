/*
* @author: 		 Accenture
* @date: 		 02/06/2016
* @description:  Controller class for faq component for gcr widget
* CHANGE LOG
* DATE				NAME				CHANGE DESCRIPTION
* 02/06/2016		Accenture			INITIAL DRAFT
* 18/11/2016		Accenture			Added new property "lastArticleId" to capture id of last article in list of articles to
*										to identify last article in the page .
*/
public class gcr_knowledgeArticleController {
    public Boolean feedbackInit { get; set; }
    public Boolean feedbackProvided { get; set; }
    public Boolean feedbackPositive { get; set; }
    public String strComments { get; set; }
    public Boolean isRightToLeft { get; set; }
    // PUBLIC URL FOR FAQ
    public String strFaqUrl { get; set; }
    public Boolean blnTempFeedback { get {
        if (sPrvArticleId != null) {
            if(!sPrvArticleId.contains(kArticleView.Id)) {
                feedbackProvided = false;
                feedbackInit = false;
                sPrvArticleId.add(kArticleView.Id);
            }
        } else {
            sPrvArticleId = new Set<String>();
        }
        return false;
    } set; }
    public Set<String> sPrvArticleId { get; set; }

    // ARTICLE SEARCH COMPONENT VARIABLES
    public String chlContentId { public get; public set; }
    public String strKaUrlName {  get; set; }
    // PATCH VARIABLE TO PATCH BACK TO FAQ FROM ARTICLE VIEW AFTER ORGANIC SEARCH
    private Boolean gotoLanding { private get; private set; }

    /*
     * @author: 		Accenture
	 * @date: 		 	01/08/2016
	 * @description:  	get method for channel content record this is here due to vf component limitation
	 * @input:			none
	 * @return:			void
     */
    public GCRChannelContent__c chlContentRec { get {
        if (chlContentRec == null) {
            String queryString = gcr_helperClass.createQueryString('SELECT'
                                                                 , gcr_helperClass.getAllFieldsForQuery('GCRChannelContent__c')
                                                                   + ',CareHub__r.BackgroundImgLanding__c'
                                                                   + ',CareHub__r.FAQCountry__c,CareHub__r.LanguageLocaleKey__c'
                                                                   + ',CareHub__r.CountryIsoCode__c,CareHub__r.LanguageIsoCode__c'
                                                                   + ',CareHub__r.Brand__c,CareHub__r.SearchMinCharMsg__c,RecordType.Name'
                                                                 , 'GCRChannelContent__c')
                + ' WHERE Id = \'' + chlContentId + '\'' ;
			chlContentRec = (GCRChannelContent__c) Database.query(queryString).get(0);
            strFaqUrl = '/' + chlContentRec.CareHub__r.Brand__c + '/' 
                + chlContentRec.CareHub__r.LanguageIsoCode__c + '-' + chlContentRec.CareHub__r.CountryIsoCode__c + '/faq/';
        }
        return chlContentRec;
    } set; }

    public Boolean blnTemp { get {
        // FLAG VARIABLE TO CHECK IF LANDING PAGE REQUESTED
        gotoLanding = gotoLanding == null ? true : gotoLanding; 
        if (String.isNotBlank(strKaUrlName) && gotoLanding) {
            if (kArticleView == null) {
            	kArticleView = gcr_helperClass.getArticleByUrlName(strKaUrlName, chlContentRec.CareHub__r.LanguageLocaleKey__c, true);
            }
            showArticleList = false;
        } else {
            if (blnTemp == null && lKnowledgeArticle == null) {
                lKnowledgeArticle = gcr_helperClass.getFeaturedArticleData(chlContentRec, chlContentRec.CareHub__r.Brand__c
                                                                         , chlContentRec.CareHub__r.LanguageLocaleKey__c);
                if (lKnowledgeArticle != null && !lKnowledgeArticle.isEmpty()) {
                	lastArticleId = lKnowledgeArticle.get(lKnowledgeArticle.size() - 1).KnowledgeArticleId;
                }
                showArticleList = true;
            }
        }
		return false; } set; }
    // FEATURED KNOWLEDGE ARTICELS
    public List<KnowledgeArticleVersion> lKnowledgeArticle { get; set; }
	// KNOWLEDGE ARTICLES SEARCH STRING
    public String strSearch { get; set; }
    public Boolean isMinCharError { get; set; }
	// SELECTED KNOWLEDGE ARTICLE TO VIEW
    public FAQ__kav kArticleView { get; set; }
    public Id kArticleId { get; set; }
    // BOOLEANS TO CONTROL THE LIST OF ARTICLES
    public Boolean showArticleList { get; set; }
    // DECEMBER CHANGE
    public Boolean isLanding { get; private set; }
    public String lastArticleId { get; private set; }
	// PAGINATION RELATED VARIABLES
    public Integer currentPage { get; set; }
    public Integer totalPages { get; private set; }
    public Integer offsetValue { get; private set; }
    public Integer totalSearchArticles { get; private set; }
    public Integer intPageSize { get; private set; }
    public List<Integer> lPageNumbers { get; private set; }
    // CONSTANTS FOR PAGINATION
    public final Integer TOTAL_VISIBLE_PAGES = 3;

    /*
     * @author: 		Accenture
	 * @date: 		 	02/06/2016
	 * @description:  	CONSTRUCTOR FOR PAGE CONTROLLER
     */
    public gcr_knowledgeArticleController() {
        isLanding = true;
        feedbackProvided = false;
        totalSearchArticles = 0;
        offsetValue = 0;
        totalPages = 0;
        currentPage = 1;
        isMinCharError = false;
        lPageNumbers = new List<Integer>();
        intPageSize = GCRGenericProperties__c.getInstance('FAQ_KASEARCH_PAGESIZE') != null ? 
            			   Integer.valueOf(GCRGenericProperties__c.getInstance('FAQ_KASEARCH_PAGESIZE').value__c) : 5;
    }
    
    public void getArticleDetail() {
        showArticleList = false;
        isLanding = false;
        lPageNumbers.clear();
        lKnowledgeArticle.clear();
        lKnowledgeArticle = new List<KnowledgeArticleVersion>();
        try {
        	kArticleView = gcr_helperClass.getArticleById(kArticleId, chlContentRec.CareHub__r.LanguageLocaleKey__c, true);
        } catch (Exception thrownException) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, LABEL.errMsgGeneric));
        }
    }
    
    /*
     * @author: 		Accenture
	 * @date: 		 	01/08/2016
	 * @description:  	method to get knowledge article search results based on entered string
	 * @input:			none
	 * @return:			void
     */
    public void getSearchResult() {
        //CDOY WR467. Changed the min search lenght from 3 to 2
        if (String.isNotBlank(strSearch) && strSearch.length() > 1) {
            isMinCharError = false;
            currentPage = 1;
            offsetValue = 0;
            // CLEAR PAGENUMBER LIST AND GET ARTICLES FOR SEARCH STRING
            lPageNumbers.clear();
            // GET SIZE OF TOTAL NUMBER OF ARTICLES RETURNED
            try {
                List<KnowledgeArticleVersion> lArticles = gcr_helperClass.getSearchedArticle(String.escapeSingleQuotes(strSearch), 0, 0
                                                                                           , chlContentRec.CareHub__r.LanguageLocaleKey__c
                                                                                           , chlContentRec.CareHub__r.Brand__c
                                                                                           , chlContentRec.CareHub__r.FAQCountry__c);
                if (lArticles != null && !lArticles.isEmpty()) {
                    totalSearchArticles = lArticles.size();
                    lArticles.clear();
                    showArticleList = true;
                    Integer pageSize = Integer.valueOf(GCRGenericProperties__c.getInstance('FAQ_KASEARCH_PAGESIZE').value__c);
                    lKnowledgeArticle = gcr_helperClass.getSearchedArticle(String.escapeSingleQuotes(strSearch)
                                                                         , offsetValue, pageSize
                                                                         , chlContentRec.CareHub__r.LanguageLocaleKey__c
                                                                         , chlContentRec.CareHub__r.Brand__c
                                                                         , chlContentRec.CareHub__r.FAQCountry__c);
                    // RETRIEVE PAGE RECORDS FROM STANDARD SET CONTROLLER
                    totalPages = Math.mod(totalSearchArticles, pageSize) > 0 ? (totalSearchArticles / pageSize) + 1 : totalSearchArticles / pageSize;
                    Integer itr = 1;
                    Integer lastPage = totalPages < 3 ? totalPages : 3;
                    while (itr <= lastPage) {
                        lPageNumbers.add(itr);
                        itr++;
                    }
                    lastArticleId = lKnowledgeArticle.get(lKnowledgeArticle.size() - 1).KnowledgeArticleId;
                } else {
                    totalSearchArticles = 0;
                    lKnowledgeArticle.clear();
                }
                isLanding = false;
            } catch (Exception caughtException) {
                SYSTEM.DEbug('EXCEPTION: ' + caughtException.getStackTraceString());
            }
        } else {
            isMinCharError = true;
        }
    }
    
    /*
     * @author: 		Accenture
	 * @date: 		 	01/08/2016
	 * @description:  	method to go back to search page from article view page
	 * @input:			none
	 * @return:			void
     */
    public void goToLanding() {
        strKaUrlName = null;
        gotoLanding = false;
        showArticleList = true;
        isLanding = true;
        strSearch = '';
        offsetValue = 0;
        lPageNumbers.clear();
        lKnowledgeArticle = gcr_helperClass.getFeaturedArticleData(chlContentRec
                                                                 , chlContentRec.CareHub__r.Brand__c
                                                                 , chlContentRec.CareHub__r.LanguageLocaleKey__c);
        if (lKnowledgeArticle != null && !lKnowledgeArticle.isEmpty()) {
        	lastArticleId = lKnowledgeArticle.get(lKnowledgeArticle.size() - 1).KnowledgeArticleId;
        }
    }
    
    /*
     * @author: 		Accenture
	 * @date: 		 	01/08/2016
	 * @description:  	method to display selected page via pagination
	 * @input:			none
	 * @return:			void
     */
    public void displaySelectedPage() {
        offsetValue = (intPageSize * currentPage) - intPageSize;
        lKnowledgeArticle = gcr_helperClass.getSearchedArticle(strSearch, offsetValue, intPageSize
                                                             , chlContentRec.CareHub__r.LanguageLocaleKey__c
                                                             , chlContentRec.CareHub__r.Brand__c
                                                             , chlContentRec.CareHub__r.FAQCountry__c);
        lastArticleId = lKnowledgeArticle.get(lKnowledgeArticle.size() - 1).KnowledgeArticleId;
        lPageNumbers.clear();
		// TODO: HERE "3" SHOULD REPLACE WITH TOTAL VISIBLE PAGES FROM CONFIGURATION
        Integer itr;
        Integer lastPage;
        if (totalPages > 3) {
            if (currentPage + 1 > totalPages) {
                itr = totalPages - 2;
                lastPage = totalPages;
            } else {
                if (currentPage - 1 > 0) {
                	itr = currentPage - 1;
                    lastPage = currentPage + 1;
                } else {
                    itr = 1;
                    lastPage = 3;
                }
            }
        } else {
            itr = 1;
            lastPage = totalPages;
        }
        while (itr <= lastPage) {
            lPageNumbers.add(itr);
            itr++;
        }
    }
    
    /*
     * @author: 		Accenture
	 * @date: 		 	01/08/2016
	 * @description:  	method to display previous page via pagination
	 * @input:			none
	 * @return:			void
     */
    public void previous() {
        offsetValue = offsetValue - intPageSize;
        currentPage--;
        lKnowledgeArticle = gcr_helperClass.getSearchedArticle(strSearch, offsetValue, intPageSize
                                                             , chlContentRec.CareHub__r.LanguageLocaleKey__c
                                                             , chlContentRec.CareHub__r.Brand__c
                                                             , chlContentRec.CareHub__r.FAQCountry__c);
        lastArticleId = lKnowledgeArticle.get(lKnowledgeArticle.size() - 1).KnowledgeArticleId;
        if (totalPages > 3) {
        	Integer intFirstPage = lPageNumbers.get(0);
            if (currentPage - intFirstPage < 1 && intFirstPage > 1) {
                lPageNumbers.add(0, intFirstPage - 1);
                lPageNumbers.remove(lPageNumbers.size() - 1);
            }
        }
    }
    
    /*
     * @author: 		Accenture
	 * @date: 		 	01/08/2016
	 * @description:  	method to display next page via pagination
	 * @input:			none
	 * @return:			void
     */
    public void next() {
        offsetValue = offsetValue + intPageSize;
        currentPage++;
        lKnowledgeArticle = gcr_helperClass.getSearchedArticle(strSearch, offsetValue, intPageSize
                                                             , chlContentRec.CareHub__r.LanguageLocaleKey__c
                                                             , chlContentRec.CareHub__r.Brand__c
                                                             , chlContentRec.CareHub__r.FAQCountry__c);
        lastArticleId = lKnowledgeArticle.get(lKnowledgeArticle.size() - 1).KnowledgeArticleId;
        if (totalSearchArticles > 3) {
        	Integer intLastPage = lPageNumbers.get(lPageNumbers.size() - 1);
            if (intLastPage - currentPage < 1 && intLastPage < totalPages) {
                lPageNumbers.add(intLastPage + 1);
                lPageNumbers.remove(0);
            }
        }
    }
    
    /*
     * @author: 		Accenture
	 * @date: 		 	01/08/2016
	 * @description:  	method to display first page via pagination
	 * @input:			none
	 * @return:			void
     */
    public void firstPage() {
		offsetValue = 0;
        currentPage = 1;
        lKnowledgeArticle = gcr_helperClass.getSearchedArticle(strSearch, offsetValue, intPageSize
                                                             , chlContentRec.CareHub__r.LanguageLocaleKey__c
                                                             , chlContentRec.CareHub__r.Brand__c
                                                             , chlContentRec.CareHub__r.FAQCountry__c);
        lastArticleId = lKnowledgeArticle.get(lKnowledgeArticle.size() - 1).KnowledgeArticleId;
        lPageNumbers.clear();
		Integer itr = 1;
        Integer lastPage = totalPages < 3 ? totalPages : 3;
		while (itr <= lastPage) {
			lPageNumbers.add(itr);
			itr++;
		}
    }
    
    /*
     * @author: 		Accenture
	 * @date: 		 	01/08/2016
	 * @description:  	method to display last page via pagination
	 * @input:			none
	 * @return:			void
     */
    public void lastPage() {
        offsetValue = (totalPages - 1) * intPageSize;
        currentPage = totalPages;
        lKnowledgeArticle = gcr_helperClass.getSearchedArticle(strSearch, offsetValue, intPageSize
                                                             , chlContentRec.CareHub__r.LanguageLocaleKey__c
                                                             , chlContentRec.CareHub__r.Brand__c
                                                             , chlContentRec.CareHub__r.FAQCountry__c);
        lastArticleId = lKnowledgeArticle.get(lKnowledgeArticle.size() - 1).KnowledgeArticleId;
        lPageNumbers.clear();
		Integer itr = totalPages > 3 ? totalPages - 2 : 1;
		while (itr <= totalPages) {
			lPageNumbers.add(itr);
			itr++;
		}
    }
    // FEEDBACK COMPONENT RELATED METHODS
    /*
     * @author: 		Accenture
	 * @date: 		 	01/08/2016
	 * @description:  	method to display cancel feedback after initiating negative feedback
	 * @input:			none
	 * @return:			void
     */
    public void cancelFeedback() {
        feedbackProvided = false;
        feedbackInit = false;
    }
    
    /*
     * @author: 		Accenture
	 * @date: 		 	01/08/2016
	 * @description:  	method to initiate negative feedback
	 * @input:			none
	 * @return:			void
     */
    public void negativeFeedback() {
        feedbackInit = true;
        feedbackProvided = false;
    }
    
    /*
     * @author: 		Accenture
	 * @date: 		 	01/08/2016
	 * @description:  	method to submit negative feedback
	 * @input:			none
	 * @return:			void
     */
    public void submitNegativeFeedback() {
        recordFeeback(this.kArticleView, strComments, this.strSearch, 'Search', false);
        strComments = '';
    }

    /*
     * @author: 		Accenture
	 * @date: 		 	01/08/2016
	 * @description:  	method to submit positive feedback
	 * @input:			none
	 * @return:			void
     */
    public void positiveFeedback() {
        feedbackInit = true;
        recordFeeback(this.kArticleView, strComments, this.strSearch, 'Search', true);
        strComments = '';
    }
    
    /*
     * @author: 		Accenture
	 * @date: 		 	01/08/2016
	 * @description:  	method to record feedback and create feedback deflection record
	 * @input:			none
	 * @return:			void
     */
    private void recordFeeback(FAQ__kav kArticle, String strComments, String strSearch, String strSource, Boolean deflection) {
		PKB_Article_Feedback_Deflection__c aFbDeflection 
            = new PKB_Article_Feedback_Deflection__c (
                  Article_ID__c = kArticle.Id
                , Article_Number__c = kArticle.articleNumber
                , Article_Title__c = kArticle.title
                , Feedback_Source__c = strSource
                , Comments__c = strComments
                , Session_ID__c = ''
                , Deflection__c = deflection
                , Keyword_Searched__c = strSearch
    	);
        Database.saveResult saveResult = Database.insert(aFbDeflection, false);
        if (saveResult.isSuccess()) {
            feedbackProvided = true;
            sPrvArticleId.add(kArticle.Id);
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GCRGenericProperties__c.getInstance('GCR_FATAL_ERRMSG').value__c));
        }
    }
}