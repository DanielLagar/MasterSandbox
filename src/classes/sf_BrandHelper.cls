public with sharing class sf_BrandHelper {

    public static final string BRAND_DATA_CATEGORY = 'Brand';

    //map of brand data categories, name->label
    private static map<string,string> brandMap {
        get {
        	if(brandMap==null) {
        		map<string,string> brands = new map<string,string>();
		        try {

                    Schema.DataCategoryGroupSobjectTypePair pair = new Schema.DataCategoryGroupSobjectTypePair();
		            pair.setSObject(KnowledgeArticleVersion.sObjectType.getDescribe().getName());
		            pair.setDataCategoryGroupName('Brand');

		            LIST<Schema.DataCategoryGroupSobjectTypePair> pairs = new LIST<Schema.DataCategoryGroupSobjectTypePair>{pair};

		            list<Schema.DescribeDataCategoryGroupStructureResult> res = Schema.describeDataCategoryGroupStructures(pairs, false);

		            for(Schema.DataCategory cat: res[0].getTopCategories()) {
		                getBrands(brands, cat, true); //skip 'all'
		            }
		        }
		        catch (Exception e) { // do nothing
		        }
		        brandMap = brands;
        	}
        	return brandMap;
        }
        set;
    }

    public static boolean isValidBrandName(string brandName) {
    	return brandMap.keyset().contains(brandName);
    }

    public static boolean isValidBrandLabel(string brandLabel) {
    	set<string> labels = new set<string>();
    	labels.addAll(brandMap.values());
        return labels.contains(brandLabel);
    }

    public static list<string> getBrands() {
        list<string> result = brandMap.values();
        result.sort();
        return result;
    }

    public static list<SelectOption> getBrandSelectList() {
	    List <SelectOption> options = new List <SelectOption>();
	    string selectLabel = sf_ContactUsLanguageController.instance.language_config.Brand_Please_Select__c;
	    if (selectLabel==null) selectLabel = ''; 
	    options.add(new SelectOption('', selectLabel));

	    ////sort brands.  because DataCategory names are created by system from DataCategory labels (replacing space with _),
	    ////we can safely just sort by name
	    //list<string> brandNames = new list<string>();
	    //brandNames.addAll(brandMap.keyset());
     //   brandNames.sort();

	    //for(string brandName : brandNames) {
	    //    options.add(new SelectOption(brandName, brandMap.get(brandName)));
	    //}

        //ALM 626
        //pulling brands from configs. no config no brand in the menu
        

	    return options;
    }

    private static void getBrands(map<string,string> brands, Schema.DataCategory cat, boolean skip) {
        if(!skip) {
            brands.put(cat.getName(), cat.getLabel());
        }
        for(Schema.DataCategory child : cat.getChildCategories()) {
            getBrands(brands, child, false);
        }
    }

}