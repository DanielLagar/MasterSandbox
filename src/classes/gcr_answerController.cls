/*
* @author:       Accenture
* @date:         10/11/2016
* @description:  Controller class for style component of GCR widget
* DATE					NAME					CHANGE DESCRIPTION
* 10/11/2016			Accenture				Initial Draft
*/
public class gcr_answerController {
	public String chlContentId { public get; public set; }
    public Boolean tempBln { get {
        if (channelContent == null) {
            String queryString = gcr_helperClass.createQueryString('SELECT'
                                                                 , gcr_helperClass.getAllFieldsForQuery('GCRChannelContent__c')
                                                                   + ',CareHub__r.BackgroundImgLanding__c,CareHub__r.FAQCountry__c,CareHub__r.LanguageLocaleKey__c'
                                                                   + ',CareHub__r.Brand__c'
                                                                 , 'GCRChannelContent__c')
                												+ ' WHERE Id = \'' + chlContentId + '\'' ;
			channelContent = (GCRChannelContent__c) Database.query(queryString).get(0);
        }
        return false;
    } set; }
    
    public GCRChannelContent__c channelContent { get; set; }
}