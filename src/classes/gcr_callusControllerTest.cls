/*
* @author: 		 Accenture
* @date: 		 30/08/2016
* @description:  Test class for call us Controller
* CHANGE LOG
* DATE			NAME				CHANGE DESCRIPTION
* 30/08/2016	Accenture			Initial Draft
*/
@isTest(SeeAllData = false)
public class gcr_callusControllerTest {
	/*
     * @author: 		Accenture
	 * @date: 		 	30/08/2016
	 * @description:  	TEST SETUP METHOD TO SETUP TEST DATA
     */
    @testSetup
    static void setupTestData() {
        gcr_TestUtility.createCustomSettings();
        String brandConLangId = gcr_TestUtility.createContactUsObjectData();
        sObject careHub = gcr_TestUtility.getCareHubData(brandConLangId);
        Database.insert(careHub, true);
        List<sObject> lCareHubChannels = gcr_TestUtility.getCareHubChannels(careHub.Id);
        Database.insert(lCareHubChannels, true);
    }
    
        /*
     * @author: 		Accenture
	 * @date: 		 	30/08/2016
	 * @description:  	TEST METHOD TO GET ALL SIDEBAR ICONS WITH THEIR FUNCTIONALITIES
     */
    static testmethod void telephonyRecordTest() {
        // CREATE TELEPHONY DATA
        Call_Center_Inventory__c ccInventory = new Call_Center_Inventory__c(Name = 'Call Center 1'
                                                                          , Call_Center_Location__c = 'Newcastle'
                                                                          , Call_Center_Management__c = 'Outsourced (OV)'
                                                                          , Region__c = 'NA');
        Database.insert(ccInventory, true);
        String profileId = [ SELECT Id FROM profile where Name = 'System Administrator' ].get(0).Id;
        User gcrContact = gcr_TestUtility.createUser(profileId);
        // CREATE 10 TELEPHONY RECORDS 5 TOLL FREE AND 2 PAID NUMBER AND 3 SUPER NUMBER
        List<Telephony__c> lTelephony = new List<Telephony__c>();
        lTelephony.add(gcr_TestUtility.getTelephonyData(true, 'Tide', 'Toll Free', ccInventory.Id, gcrContact.Id, '1800 (234) 5678'));
        lTelephony.add(gcr_TestUtility.getTelephonyData(false, 'Tide', 'Toll Free', ccInventory.Id, gcrContact.Id, '1800 (234) 5678'));
        lTelephony.add(gcr_TestUtility.getTelephonyData(false, 'Tide', 'Toll Free', ccInventory.Id, gcrContact.Id, '1800 (234) 5678'));
        lTelephony.add(gcr_TestUtility.getTelephonyData(false, 'Tide', 'Toll Free', ccInventory.Id, gcrContact.Id, '1800 (234) 5678'));
        lTelephony.add(gcr_TestUtility.getTelephonyData(false, 'Tide', 'Toll Free', ccInventory.Id, gcrContact.Id, '1800 (234) 5678'));

        lTelephony.add(gcr_TestUtility.getTelephonyData(true, 'Tide', 'Paid Number', ccInventory.Id, gcrContact.Id, '44 20 12345678'));
        lTelephony.add(gcr_TestUtility.getTelephonyData(false, 'Tide', 'Paid Number', ccInventory.Id, gcrContact.Id, '44 20 12345678'));
        lTelephony.add(gcr_TestUtility.getTelephonyData(false, 'Tide', 'Paid Number', ccInventory.Id, gcrContact.Id, '44 20 12345678'));
        
		lTelephony.add(gcr_TestUtility.getTelephonyData(false, 'Tide', 'Super Number', ccInventory.Id, gcrContact.Id, '1 301 34567890'));
        lTelephony.add(gcr_TestUtility.getTelephonyData(true, 'Tide', 'Super Number', ccInventory.Id, gcrContact.Id, '1 301 09876543'));
        
        Database.insert(lTelephony, true);
        
		Map<String, Schema.RecordTypeInfo> mRecordTypeInfoByName = GCRChannelContent__c.getSObjectType().getDescribe().getRecordTypeInfosByName();
		List<GCRCareHub__c> lCareHub = [ SELECT Id FROM GCRCareHub__c
                                         WHERE Brand__c = :gcr_TestUtility.DEFAULT_BRAND
                                             AND CountryIsoCode__c = :gcr_TestUtility.DEFAULT_COUNTRY_ISO 
                                             AND LanguageIsoCode__c = :gcr_TestUtility.DEFAULT_LANGUAGE_ISO ];

		gcr_callusController cuController = new gcr_callusController();
        cuController.inBrand = gcr_TestUtility.DEFAULT_BRAND;
        cuController.inCountry = gcr_TestUtility.DEFAULT_COUNTRY;
        cuController.inLanguage = gcr_TestUtility.DEFAULT_LANGUAGE;
        cuController.isRightToLeft = false;
        cuController.channelId = [ SELECT Id 
                                   FROM GCRChannelContent__c
                                   WHERE CareHub__c = :lCareHub.get(0).Id
									AND RecordTypeId = :mRecordTypeInfoByName.get('call us').getRecordTypeId() ].get(0).Id;

        Test.startTest();
        Boolean tempBool = cuController.controlInit;
        Test.stopTest();
        SYSTEM.assert(String.isNotEmpty(cuController.strOperationalHours)
                   && cuController.strOperationalHours.equalsIgnoreCase('We are available from 9:00 - 5:00 Monday - Friday'));
        SYSTEM.assert(cuController.mTelephoneNumbers != null && !cuController.mTelephoneNumbers.isEmpty());
    }
}