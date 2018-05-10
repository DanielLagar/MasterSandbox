/*
* @author:       Accenture
* @date:         01/06/2016
* @description:  Controller class for call us page component of GCR widget
* DATE					NAME					CHANGE DESCRIPTION
* 01/06/2016			Accenture				Initial Draft
* 10/11/2016			Accenture				Query for Ireland for United Kingdom
* 14/11/2016			Accenture				Get channel content from care hub channel
*/
public class gcr_callusController {    
    public String inBrand { public get; public set; }
    public String inCountry { public get; public set; }
    public String inLanguage { public get; public set; }
    public String channelId { public get; public set; }
    
    public Boolean isRightToLeft { get; set; }
    public GCRChannelContent__c channelContent { public get; private set; }
    
    // PUBLIC VARIABLES
    public String strOperationalHours { public get; private set; }
    public Map<String, List<Telephony__c>> mTelephoneNumbers { public get; private set; }
    public Boolean controlInit { public get {
       if(controlInit == null || !controlInit) init(); return false;
    } private set; }
    public void init() {
        setTelephony();
        getChannelContent();
    }
    
    private void getChannelContent() {
        channelContent = [ SELECT ChannelHeader__c
                          		, CareHub__r.BackgroundImgLanding__c
                           FROM GCRChannelContent__c 
                           WHERE Id = :channelId ];
    }
    
    private void setTelephony() {
        // PATCH FOR UNITED KINGDOM REQUIREMENT
        // GET TELEPHONY NUMBERS FROM UK AND IRELAND IF INCOMING COUNTRY IS UK
        Set<String> sCountry = new Set<String>();
        sCountry.add(inCountry);
        if (inCountry.equalsIgnoreCase('United Kingdom')) {
			sCountry.add('Ireland');
        }

        mTelephoneNumbers = new Map<String, List<Telephony__c>>();
        List<Telephony__c> lTelephony = [ SELECT Id
                                               , ITFS_Number__c
                                               , LocalOperationalHours__c
                                         	   , Phone_Charge_Type__c
                                               , localBrand__c
                                               , Country_Has_1_Phone_Number__c
                                         	   , isLabelNotVisibleCareHub__c
                                          FROM Telephony__c 
                                          WHERE Country__c IN :sCountry
                                            AND Visible_to_contact_us_pages__c = true
                                            AND ITFS_Status__c = 'Active'
                                            AND ITFS_Number__c != null
                                            AND (Country_Has_1_Phone_Number__c = true 
                                                OR (Language__c = :inLanguage
                                                    AND Contact_Us_Brand__r.Name = :inBrand))
                                          ORDER BY isLabelNotVisibleCareHub__c ];
        if(lTelephony != null && !lTelephony.isEmpty()) {
            for(Telephony__c eachTelephony : lTelephony) {
                strOperationalHours = String.isEmpty(strOperationalHours) && eachTelephony.Country_Has_1_Phone_Number__c ? 
                                        eachTelephony.LocalOperationalHours__c : '';
                
                    if (mTelephoneNumbers.get(eachTelephony.localBrand__c) != null) {
                        mTelephoneNumbers.get(eachTelephony.localBrand__c).add(eachTelephony);
                    } else {
                        if (!eachTelephony.isLabelNotVisibleCareHub__c) {
                        	mTelephoneNumbers.put(eachTelephony.localBrand__c, new List<Telephony__c>{eachTelephony});
                        } else {
                            mTelephoneNumbers.put('', new List<Telephony__c>{eachTelephony});
                        }
                    }
            }
            strOperationalHours = String.isEmpty(strOperationalHours) ? lTelephony.get(0).LocalOperationalHours__c : '';
        }      
    }
}