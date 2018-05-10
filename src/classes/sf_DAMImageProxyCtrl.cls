/*
* @author: salesforce.com
* @date: 05/11/2015
* @description:  Class for retrieving images from brandstore
*/


public with sharing class sf_DAMImageProxyCtrl {

    public sf_DAMImageProxyCtrl (ApexPages.StandardController sc) {}
    public sf_DAMImageProxyCtrl () {}
    public sf_DAMImageProxyCtrl (sf_ContactUsTemplateController mainCtrl) {}

    static String imageNotFoundUrl = getResourceUrl('sf_MissingProductImage');
    static String authToken = DAM_Brandstore_Settings__c.getInstance().Brandstore_Image_Token__c != null ? DAM_Brandstore_Settings__c.getInstance().Brandstore_Image_Token__c : '';
    static String brandStoreOriginalUrl = DAM_Brandstore_Settings__c.getInstance().Brandstore_Url__c != null ? DAM_Brandstore_Settings__c.getInstance().Brandstore_Url__c : '';


    @RemoteAction 
    public static String getDamImageUrl (String brandStoreUrl) {
        Http h = new Http();
        
        if (String.isEmpty(brandStoreUrl) || brandStoreUrl.equalsIgnoreCase('null')) {
            System.debug(LoggingLevel.INFO, 'image url passed is empty.');
            return imageNotFoundUrl;
        } else if (!brandStoreUrl.startsWith(brandStoreOriginalUrl)) {
            return brandStoreUrl;
        } else {
            try {
                HttpRequest req = new HttpRequest ();
            
                req.setEndpoint(brandStoreUrl);
                req.setMethod('GET');
                req.setHeader('x-auth-token', authToken);

                HttpResponse resp = h.send(req);
                String error404 = '/404.html?aspxerrorpath';
                System.debug(LoggingLevel.INFO, 'brandStoreUrl callout response - ' + resp);
                return resp.getStatusCode() == 302 && !resp.getHeader('Location').contains(error404) ? resp.getHeader('Location') : imageNotFoundUrl;  
            } catch (Exception e) {
                System.debug(LoggingLevel.INFO, 'exception occurred - ' + e.getMessage() + '-' + e.getStackTraceString());
                return imageNotFoundUrl;
            } 
        }
    }

    //NOTE! Setting Product_Search_Configuration__c result size to more than 100 will cause an exception!
    @RemoteAction 
    public static List <Local_Product__c> getDamImageThumbnailUrlInBulk (List <Id> productIds) {

        List <Local_Product__c> lpList = new List <Local_Product__c> ([SELECT Id, Image_Url_Thumb__c FROM Local_Product__c WHERE Id IN :productIds]);

        for (Local_Product__c lp : lpList) {
            Http h = new Http();
           
            if (String.isEmpty(lp.Image_Url_Thumb__c) || lp.Image_Url_Thumb__c.equalsIgnoreCase('null')) {
                System.debug(LoggingLevel.INFO, 'image url passed is empty.');
                lp.Image_Url_Thumb__c = imageNotFoundUrl;
            } else if (lp.Image_Url_Thumb__c.startsWith(brandStoreOriginalUrl)) {
                try {
                    HttpRequest req = new HttpRequest ();
                    req.setEndpoint(lp.Image_Url_Thumb__c);
                    req.setMethod('GET');
                    req.setHeader('x-auth-token', authToken);
                    HttpResponse resp = h.send(req);
                    String error404 = '/404.html?aspxerrorpath';
                    lp.Image_Url_Thumb__c = resp.getStatusCode() == 302 && !resp.getHeader('Location').contains(error404) ? resp.getHeader('Location') : imageNotFoundUrl;   
                } catch (Exception e) {
                    System.debug(LoggingLevel.INFO, 'exception occurred - ' + e.getMessage() + '-' + e.getStackTraceString());
                    lp.Image_Url_Thumb__c = imageNotFoundUrl;
                } 
            }
        }
        return lpList;
    }

    public static String getResourceUrl (String resourceName) {
        // Fetching the resource
        List <StaticResource> resourceList= [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName];

        // Checking if the result is returned or not
        if(resourceList.size() == 1){

           // Getting namespace
           String namespace = resourceList[0].NamespacePrefix;
           // Resource URL
           return '/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + resourceName; 
        }
        else return '';
    }
}