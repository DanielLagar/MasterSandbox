/*
* @author: Laure OMeara
* @date: 07/17/2014

* @description: 
* US496:
* This class supports the custom create/edit/clone page for Fulfillment Item objects
*/
public with sharing class sf_CreateEditFulfillmentItemExt {

    private Fulfillment_Item__c ffitem { get; set; }

    public sf_CreateEditFulfillmentItemExt(ApexPages.StandardController stdController) {
        ffitem = (Fulfillment_Item__c)stdController.getRecord();
    }
    
    
    public List<selectOption> getBrands() 
    {
        List<selectOption> brands = new List<selectOption>();
        brands.add(new selectOption('','--None--'));
        system.debug('********** Country: '+ffitem.Contact_Country__c);
        List <AggregateResult> lps = [select Name from Local_Product__c where 
            path_level__c = 'BRAND' AND
            Country__c = :ffitem.Contact_Country__c AND Inactive__c=false AND
            Name != null
            GROUP BY Name
            ORDER BY Name];
        for(AggregateResult lp : lps) {
            String brand = String.valueOf(lp.get('Name'));
            brands.add(new selectOption(brand, brand));
        }
        
        if(brands.size()>1) brands.add(1,new selectOption('ALL', 'ALL'));
        return brands;
    }
    
    
    public List<selectOption> getSegments() 
    {
        List<selectOption> segments = new List<selectOption>();
        Set<string> setSegs=new Set<string>();
        List<string> listSegs=new List<string>();
        segments.add(new selectOption('','--None--'));
        system.debug('********* brand is ' + ffitem.Brand__c);
        system.debug('********* size: '+segments.size());
        if(ffitem.Brand__c =='ALL'){
            //SELECT Id, Global_Product__r.Segment__c FROM Local_Product__c WHERE Global_Product__r.Product_Level__c = ‘Segment’ AND Country__c = ‘United States’ Group By Global_Product__r.Segment__c
            for(Local_Product__c lp : [SELECT Name FROM Local_Product__c 
                WHERE path_level__c = 'SEGMENT' AND country__c = :ffitem.Contact_Country__c 
                AND Inactive__c=false 
                ORDER BY Name ])  
            {
              setSegs.add(lp.Name);
            }
        }
        else {
            String path = ffitem.Brand__c + '/%';
            //for(Local_Product__c lp : [select Name from Product_Local_Brand_Segment__c where country__c = :ffitem.Contact_Country__c and path_Level__c = 'SEGMENT' and Inactive__c=false and translated_path__c LIKE :path order by Name])  
            for(Local_Product__c lp : [SELECT Name FROM Local_Product__c 
                WHERE path_level__c = 'SEGMENT' AND country__c = :ffitem.Contact_Country__c 
                AND Inactive__c=false 
                AND Translated_Path__c LIKE :path
                ORDER BY Name ]) 
            {
              setSegs.add(lp.Name);            }      
        }
        listSegs.addAll(setSegs);
        listSegs.sort();
        for(string seg:listSegs)
            segments.add(new selectOption(seg,seg));
        
        if(segments.size()>1) segments.add(1,new selectOption('ALL', 'ALL'));
        return segments;
        
     }
}