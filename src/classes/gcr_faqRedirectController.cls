/*
* @author:       Accenture
* @date:         01/08/2016
* @description:  Controller class for FAQ Temporary page to redirect to Brand.com site
* DATE              NAME                CHANGE DESCRIPTION
* 01/08/2016        Accenture           Initial Draft
* 17/01/2017        Accenture           Added constructor and removed redirect method used in action of page
* 26/04/2017        Accenture           WR500 - Get page language from language configuration instead of URL.
*/
public class gcr_faqRedirectController {
    public String urlToRediect { get; set; }
    public FAQ__kav article { get; set; }
    public String articleDesc { get; set; }
    public Integer rdTime { get; set; }
    public String lang { get; set; }
    
    public gcr_faqRedirectController() {
        // GET URL FROM PAGE PARAMETERS
        String strPageUrl = ApexPages.currentPage().getParameters().get('pageUrl');
        // IF PAGE URL IS NOT EMPTY - EXPECTED URL /[BRAND]/[LANGUAGE ISO]-[COUNTRY ISO]/faq/[ARTICLE TITLE]
        if (String.isNotBlank(strPageUrl)) {
            // GET STRING BEFORE "/faq/" STRING TO GET BRAND AND LANGUAGE FROM THE URL
            String brandDotComUrl = strPageUrl.toLowerCase().substringBefore('/faq/') + '/faq/';  
            // SPLIT BRAND AND LANGUAGE-COUNTRY
            List<String> lData = strPageUrl.split('/');
            if (lData != null && !lData.isEmpty()) {
                // SPLIT LANGUAGE AND COUNTRY
                List<String> lConLang = lData.get(2).split('-');
                brandDotComUrl = ('/' + EncodingUtil.urlDecode(lData.get(1), 'UTF-8') + '/' + lData.get(2) + '/faq/').toLowerCase();
                if (lConLang != null && !lConLang.isEmpty()) {
                    // WR500 - REMOVE SETTING UP PAGE LANGUAGE FROM URL
                    // lang = lConLang.get(0);
                    // QUERY CARE CORROSPONDING CARE HUB DATA TO GET ARTICLE LANGUAGE LOCALE KEY
                    List<GCRCareHub__c> lCareHub = [ SELECT Id
                                                          , LanguageLocaleKey__c
                                                     FROM GCRCareHub__c
                                                     WHERE Brand__c = :EncodingUtil.urlDecode(lData.get(1), 'UTF-8')
                                                        AND LanguageIsoCode__c = :lConLang.get(0)
                                                        AND CountryIsoCode__c = :lConLang.get(1) ];
                    // IF CARE HUB FOUND GET ARTICLE DETAILS
                    if (lCareHub != null && !lCareHub.isEmpty()) {
                        // QUERY ARTICLES
                        // WR500 - SETUP PAGE LANGUAGE FROM LANGUAGE CONFIGURATION
                        lang = lCareHub.get(0).LanguageLocaleKey__c;
                        article = gcr_helperClass.getArticleByUrlName(lData.get(lData.size() - 1)
                                                                    , lCareHub.get(0).LanguageLocaleKey__c, false);
                        // REMOVE HTML FROM ARTICLE CONTENT
                        articleDesc = String.isNotEmpty(article.Answer__c) ? article.Answer__c.replaceAll('<[^>]+>','') : '';
						articleDesc = articleDesc.length() > 500 ? articleDesc.substring(0, 500) : articleDesc;
                    }
                }
            }
            SYSTEM.DEBUG('brandDotComUrl  : ' + brandDotComUrl);
			// FETCH CORROSPONDING BRAND.COM URL FROM CUSTOM SETTING AND PREPARE URL TO REDIRECT
            urlToRediect = 'http://' + FaqBrandSiteMapping__c.getInstance(brandDotComUrl).BrandSiteUrl__c 
                		 + '?articleId=' + EncodingUtil.urlEncode(lData.get(lData.size() - 1), 'UTF-8');
            // GET REDIRECT DELAY DELAY VALUE FROM CONFIGURATION
            rdTime = Integer.valueOf(GCRGenericProperties__c.getInstance('FAQ_REDIRECT_TIME').value__c != null
                                   ? GCRGenericProperties__c.getInstance('FAQ_REDIRECT_TIME').value__c : '5000');
        }
    }
}