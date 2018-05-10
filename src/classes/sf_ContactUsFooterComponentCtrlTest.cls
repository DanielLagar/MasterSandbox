/*ChrisM rewriting as part of WR225*/
@isTest
private class sf_ContactUsFooterComponentCtrlTest {

    @testSetup static void setupData(){
        //Create Contact Us Brand
        Contact_Us_Brand__c brand = new Contact_Us_Brand__c();
        brand.name = 'P&G';
        brand.brand__c = 'P&G';
        insert brand;
        
        //Create Contact Us Language
		Contact_Us_Language__c lang = new Contact_Us_Language__c ();
        lang.name = 'Default';
		lang.Country__c = 'United States of America';
		lang.Language__c = 'English-US';
		insert lang;
        
        //Create Contact Us Brand Language
        Contact_Us_Brand_Language__c cubl = new Contact_Us_Brand_Language__c();
        cubl.Contact_Us_Brand__c = brand.Id;
        cubl.Contact_Us_Language__c = lang.Id;
        insert cubl;
    }   

	@istest
    static void testInit(){
		sf_ContactUsFooterComponentCtrl ctrl = new sf_ContactUsFooterComponentCtrl ();        
    }
	
}