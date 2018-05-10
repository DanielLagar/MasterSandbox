/*
* @author:          Accenture
* @date:            17/01/2017
* @description:     Controller for carehub sitemap index page
* DATE              NAME                CHANGE DESCRIPTION
* 17/01/2017        Accenture           Initial Draft
*/
public class gcr_careHubSitemapIndexController {
    public Map<String, String> mSitemaps { public get; private set; }

    public gcr_careHubSitemapIndexController() {
        mSitemaps = new Map<String, String>();
        for(GCRChannelContent__c eachChCont :[ SELECT Id
                                                    , CareHub__r.Brand__c
                                                    , CareHub__r.CountryIsoCode__c
                                                    , CareHub__r.LanguageIsoCode__c
                                                    , LastModifiedDate
                                               FROM GCRChannelContent__c 
                                               WHERE RecordTypeId = :gcr_helperClass.getRecordTypeIdByDevName('GCRChannelContent__c', 'faq') 
                                                AND CareHub__c != null
                                                AND isActive__c = true ]) {
			String strBrand = 'gcr_careHubSiteMap?brand=' + eachChCont.CareHub__r.Brand__c;
			// REPLACE ESCAPED CHARACTERS
			strBrand = strBrand.replace('&', '&amp;');
			strBrand = strBrand.replace('\'', '&apos;');
			strBrand = strBrand.replace('"', '&quot;');
			strBrand = strBrand.replace('>', '&gt;');
			strBrand = strBrand.replace('<', '&lt;');
            mSitemaps.put(strBrand + '&amp;country=' + eachChCont.CareHub__r.CountryIsoCode__c 
                        + '&amp;language=' + eachChCont.CareHub__r.LanguageIsoCode__c
                      , String.valueOfGmt(eachChCont.LastModifiedDate).substring(0, 10));
        }
    }
}