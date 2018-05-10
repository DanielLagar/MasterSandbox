/*
* @author: Lauren OMeara
* @date: 07/31/2014

* @description:
* US668 - re-architect contact us page
*/

public with sharing class sf_ContactUsTemplateController {

    public String brand {get; set;}
    public Contact_Us_Brand__c brand_config {get; set;}
    public sf_ContactUsLanguageController langContr {get; set;}
    public sf_ContactUsTemplateController templateCon {get; set;}

    //sfdc 06/14/15 - fix page url and redirect
	public sf_ContactUsTemplateController() {
		init();
	}

    public sf_ContactUsTemplateController(ApexPages.StandardController sc) {
        init();
    }


    public void init () {
        brand = sf_ContactUsHelperCtrl.getBrand();

        if (String.isEmpty(brand))
          brand = sf_ContactUsHelperCtrl.DEFAULT_BRAND;
       

        String brandWhereClause = ' brand__c = :brand ';
        
        String brandQueryString = sf_ContactUsHelperCtrl.createSelectAllQueryString ('Contact_Us_Brand__c', brandWhereClause, ' 1 '); //object, where, limit
        
        System.debug('#### sf_ContactUsTemplateController brandQueryString ### \n' + brandQueryString + '\n');
        

        List <Contact_Us_Brand__c> brandList = (List <Contact_Us_Brand__c>) Database.query(brandQueryString);
        System.debug('***** brandList '+ brandList);
        
        brand_config = !brandList.isEmpty() ? brandlist[0] : null;

        if (brand_config == null) { //get default brand
            brandList = (List <Contact_Us_Brand__c>) Database.query(sf_ContactUsHelperCtrl.createSelectAllQueryString ('Contact_Us_Brand__c', 'brand__c = \'' + sf_ContactUsHelperCtrl.DEFAULT_BRAND +  '\'' , ' 1 '));
        }

        if (!brandList.isEmpty())
            brand_config = brandlist[0]; //this will fail if no default brand is created.

        else brand_config = new Contact_Us_Brand__c ();

        System.debug('***** brand config '+brand_config);
        
        langContr = new sf_ContactUsLanguageController();
    }
}