/*
* @author:       Accenture
* @date:         01/08/2016
* @description:  Controller class for email us component of gcr widget
* CHANGE LOG
* DATE			NAME				CHANGE DESCRIPTION
* 01/08/2016	Accenture			Initial Draft
*/
global class gcr_careHubFAQRewriter implements Site.UrlRewriter {
    private final String DIRECTORY = '/faq/';
    private final String VISUALFORCE_PAGE = 'gcr_faqRedirectPage?pageUrl=';

    /*
     * @author: 		Accenture
	 * @date: 		 	01/08/2016
	 * @description:  	IMPLEMENTED AS PART OF URL REWRITER INTERFACE,
	 * 				    USED FOR MAPPING REQUEST URL AND REDIRECT TO BRAND.COM PAGE
	 * @input:			PageReference
	 * @return:			PageReference
     */
    global PageReference mapRequestUrl(PageReference externalPage) {
        String pageUrl = externalPage.getUrl();
        if(pageUrl.toLowerCase().contains(DIRECTORY)) {
            return new PageReference(VISUALFORCE_PAGE + pageUrl);
        }
        
        return null;
    }
    
    /*
     * @author: 		Accenture
	 * @date: 		 	01/08/2016
	 * @description:  	
	 * @input:			List<PageReference>
	 * @return:			List<PageReference>
     */
    global List<PageReference> generateUrlFor(List<PageReference> myForcedotcomUrls) {
        return null;
    }
}