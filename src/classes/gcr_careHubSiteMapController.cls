/*
* @author:       Accenture
* @date:         16/01/2017
* @description:  Controller class of care hub sitemap
* DATE              NAME                CHANGE DESCRIPTION
* 16/01/2017       Accenture           Initial Draft
*/
public class gcr_careHubSiteMapController {
    public List<String> lKaExtUrl { get; set; }
    public String strDate { get; set; }
    /*
     * CONTROLLER CONSTRUCTOR
     */
    public gcr_careHubSiteMapController() {
        strDate = String.valueOfGmt(SYSTEM.now()).substring(0, 10);
        SYSTEM.DEBUG('BRAND : ' + ApexPages.currentPage().getParameters().get('brand'));
        SYSTEM.DEBUG('COUNTRY : ' + ApexPages.currentPage().getParameters().get('country'));
        SYSTEM.DEBUG('LANGUAGE : ' + ApexPages.currentPage().getParameters().get('language'));
        List<GCRChannelContent__c> lChannelContent = [ SELECT Id
                                                    , CareHub__r.Brand__c
                                                    , CareHub__r.FAQCountry__c
                                                    , CareHub__r.LanguageLocaleKey__c
                                                    , CareHub__r.LanguageIsoCode__c
                                                    , CareHub__r.CountryIsoCode__c
                                               FROM GCRChannelContent__c 
                                               WHERE RecordTypeId = :gcr_helperClass.getRecordTypeIdByDevName('GCRChannelContent__c', 'faq') 
                                                AND CareHub__c != null
                                                AND CareHub__r.Brand__c = :ApexPages.currentPage().getParameters().get('brand')
                                                AND CareHub__r.CountryIsoCode__c = :ApexPages.currentPage().getParameters().get('country')
                                                AND CareHub__r.LanguageIsoCode__c = :ApexPages.currentPage().getParameters().get('language')
                                                AND isActive__c = true ];
        if (lChannelContent != null && !lChannelContent.isEmpty()) {
            String bclUrl = '';
            lKaExtUrl = new List<String>();
            bclUrl += lChannelContent.get(0).CareHub__r.Brand__c;
            lKaExtUrl.add(bclUrl);
            bclUrl += '/' + lChannelContent.get(0).CareHub__r.LanguageIsoCode__c 
                    + '-' + lChannelContent.get(0).CareHub__r.CountryIsoCode__c;
            lKaExtUrl.add(bclUrl);
            bclUrl += '/faq';
            lKaExtUrl.add(bclUrl);
            List<KnowledgeArticleVersion> lKaVersion = Database.query(
                gcr_helperClass.prepareKAQueryString(lChannelContent.get(0).CareHub__r.FAQCountry__c
                                                   , lChannelContent.get(0).CareHub__r.Brand__c
                                                   , lChannelContent.get(0).CareHub__r.LanguageLocaleKey__c
                                                   , 'Online', null));
            for (KnowledgeArticleVersion eachKaVar :lKaVersion) {
                lKaExtUrl.add(bclUrl + '/' + eachKaVar.UrlName);
            }
        }
    }
}