/*
* @author: Lauren OMeara
* @date: 07/31/2014

* @description: sf_ContactUsHeaderComponentCtrl test
* US668 - re-architect contact us page
*
* @Updates
* 27-01-2016 - Updated to test multiple language, added asserts and @TestSetup - christopher.macduff@accenture.com
*/

@isTest
private class sf_ContactUsHeaderComponentCtrlTest {
    @TestSetup
    static void setupData(){
        List<Contact_Us_Language__c> langList = new List<Contact_Us_Language__c>();
        List<Contact_Us_Brand_Language__c> cublList = new List<Contact_Us_Brand_Language__c>();
        
        Contact_Us_Brand__c brand = new Contact_Us_Brand__c ();
		brand.Brand__c = sf_ContactUsHelperCtrl.DEFAULT_BRAND;
		insert brand;
        
        Contact_Us_Language__c lang1 = new Contact_Us_Language__c(
            Name = 'EnglishTest',
            Country__c = 'United States of America',
            Country_Picklist_Label__c = 'USA - United States of America',
            Language_Picklist_Label__c = 'English',
            Language__c = 'English-US',
            Language_Locale_Key__c = 'en_US'
        );
        langList.add(lang1);
        
		Contact_Us_Language__c lang2 = new Contact_Us_Language__c(
            Name = 'SpanishTest',
            Country__c = 'United States of America',
            Country_Picklist_Label__c = 'USA - United States of America',
            Language_Picklist_Label__c = 'Spanish',
            Language__c = 'Spanish',
            Language_Locale_Key__c = 'es'
        );
        langList.add(lang2);
        
        insert langList;
        
        Contact_Us_Brand_Language__c brandLang1 = new Contact_Us_Brand_Language__c(
            Contact_Us_Brand__c = brand.Id,
            Contact_Us_Language__c = lang1.Id
        );
        cublList.add(brandLang1);
        
		Contact_Us_Brand_Language__c brandLang2 = new Contact_Us_Brand_Language__c(
            Contact_Us_Brand__c = brand.Id,
            Contact_Us_Language__c = lang2.Id
        );
        cublList.add(brandLang2);
        
        insert cublList;
    }
	
	@isTest static void testInit() {
		sf_ContactUsHeaderComponentCtrl ctrl = new sf_ContactUsHeaderComponentCtrl ();

		ctrl.goPKB();
		ctrl.goEmailUs();
		ctrl.getCountryList();
        ctrl.selectedCountry = 'United States of America';

        List <SelectOption> langOptions = new List<SelectOption>(ctrl.getLanguageList());
        system.assertEquals(2, langOptions.size());

        List <SelectOption> brandOptions = new List<SelectOption>(ctrl.getBrandSelectList());
		system.assertEquals(1, brandOptions.size());

		ctrl.processCountrySelect();
		ctrl.processLanguageSelect();
		ctrl.processBrandSelect();
		ctrl.getChatStartUrl();
	}
}