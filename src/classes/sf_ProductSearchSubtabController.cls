global class sf_ProductSearchSubtabController {
	
	global class SearchResult{
		public Local_Product__c product {get; set;}
		public String GTIN {get; set;}
		public String IPMS {get; set;}
		public SearchResult(){
			GTIN = '';
			IPMS = '';
		}
	}
	
    public Case caseRecord{get; set;}

    public sf_ProductSearchSubtabController(ApexPages.StandardController sc) {
        caseRecord = [SELECT Id, Country__c, CaseNumber, Language__c FROM Case WHERE Id = :sc.getId()];
    }
    
	/**
	* @author: John Casimiro
	* @date 10/17/2014
	* @description Build a list of countries pulled from the Case.Country__c
	*/
	public list<SelectOption> getCountries(){
		list<SelectOption> options = new list<SelectOption>();
		Schema.DescribeFieldResult F = Case.Country__c.getDescribe();
		for (Schema.PicklistEntry a : F.getPicklistValues()) { 
        	options.add(new SelectOption(a.getLabel(), a.getValue())); 
        }
        return options;
	}

   /**
	* @author: Oleg Rikkers, Chris Southworth
	* @date: 05/08/2014, Updated 06/26/2014
	* @param: term - The search term passed from the jquery autocomplete search in the VF page
	* @param: country - The country listed on the related Case record, or selected from the drop down on the VF page
	* @param: gtin - Boolean value of the GTIN checkbox on the VF page
	* @description: Search for Local_Product__c records that match or partially match the search term provided from
	*	the user on the sf_ProductSearchConsoleComponent.page.  Results are filtered by selected country.
	*	If the gtin value is true, prepend 0* to search terms to look for GTIN values
	*	Sosl query updated to search for IPMS__c records related to Local_Products__c.  These results are added to the 
	*	search results if found and the GTIN checkbox is unchecked.
	* @return: searchList[0] - List of Local_Product__c records found from the SOSL query
	* @return: localList - List of Local_Product__c records found from the SOSL query along with LP records found through
	*		matching IPMS records
	*/
    @RemoteAction
    global static List <SearchResult> doSoslSearch (String term, String country, String searchType) {
    	List<SearchResult> searchResultsList = new List<SearchResult>();
    	Product_Search_Configuration__c psc = Product_Search_Configuration__c.getInstance();
    	Integer maxResults = Integer.valueOf(psc.Max_Search_Results_Returned__c);
    	
    	if (maxResults == null) maxResults = 100; //DE655 when custom settings missing...

        term = String.escapeSingleQuotes(term) + '*';
        
		List<Local_Product__c> localList = new List<Local_Product__c>();
        if(searchType == 'barCode'){
	        String searchquery='FIND \'';
        	term = '0*' + term;
	        searchquery += term;
	        searchquery += '\' IN ALL FIELDS RETURNING GTIN__c (Id, Name, Local_Product__c ';
	        searchquery += ' WHERE Local_Product__r.Inactive__c = false ';
	        
	        //5/27/15 post launch log 5C remove country from ipms and gtin
	        if (!String.isEmpty(country)) searchquery += ' AND Local_Product__r.Country__c = \''+ country + '\''; //Uncomented out CDOY WR191 (July 2016)
	        searchquery += ' ORDER BY Name ASC ';
	        searchquery += ') LIMIT ' + String.valueOf(maxResults);
	        
	        List<List<SObject>> gtinList = search.query(searchQuery);
	        if(gtinList[0].size() > 0){
	        	Map<Id, List<GTIN__c>> gtinMap = new Map<Id, List<GTIN__c>>();
	    		Set<String> lpIds = new Set<String>();
	    		//Build map of Local Product Ids to query necessary fields;
	    		for(GTIN__c g : (List<GTIN__c>)gtinList[0]){
	    			lpIds.add(g.Local_Product__c);
	    			
	    			if(!gtinMap.containsKey(g.Local_Product__c)){
	    				gtinMap.put(g.Local_Product__c, new List<GTIN__c>());
	    			}
	    			gtinMap.get(g.Local_Product__c).add(g);
	    		}
	    		
        		localList = [SELECT Id
        							,Name
        							,Translated_Path__c
        							,Consumer_Facing_Name__c
        							,Consumer_Facing_Brand__c
        							,Product_Description__c
        							,Image_Url__c
        							,Image_Url_Thumb__c
                             		,GTIN_Number__c

        			FROM Local_Product__c 
        			WHERE Id IN :lpIds AND Inactive__c = false ORDER BY Translated_Path__c ASC];
	        	for(Local_Product__c lp : localList){
	        		if(gtinMap.containsKey(lp.Id)){
		        		for(GTIN__c gtin : gtinMap.get(lp.Id)){
		        			SearchResult sr = new SearchResult();
		        			sr.product = lp;
		        			sr.GTIN = gtin.Name;
		        			searchResultsList.add(sr);	
		        		}
	        		}
	        	}
	        } 
        } else if(searchType == 'ipmsSearch'){
	    	String ipmsquery='FIND \'';
	    	//term = '0*' + term;
	        ipmsquery += term;
	        ipmsquery += '\' IN ALL FIELDS RETURNING IPMS__c (Id, Name, Local_Product__c ';
	        ipmsquery += ' WHERE Local_Product__r.Inactive__c = false ';
	        
	        //5/27/15 post launch log 5C remove country from ipms and gtin
	        if (!String.isEmpty(country)) ipmsquery += ' AND Local_Product__r.Country__c = \''+ country + '\''; //Uncomented out CDOY WR191 (July 2016)

	       	ipmsquery += ' ORDER BY Name ASC ';
	        ipmsquery += ') LIMIT :maxResults'; 
	    	List<List<SObject>> impsList = search.query(ipmsquery);
	    	
        	//IPMS records were found in above query        	
        	if(impsList[0].size() > 0){
        		Map<Id, List<IPMS__c>> ipmsMap = new Map<Id, List<IPMS__c>>();
        		Set<String> lpIds = new Set<String>();
        		//Build map of Local Product Ids to query necessary fields
        		for(IPMS__c ip : (List<IPMS__C>)impsList[0]){
        			lpIds.add(ip.Local_Product__c);
        			
        			if(!ipmsMap.containsKey(ip.Local_Product__c)){
	    				ipmsMap.put(ip.Local_Product__c, new List<IPMS__c>());
	    			}
	    			ipmsMap.get(ip.Local_Product__c).add(ip);
        			
        		}
				
				//Query for Local Products
        		localList = [SELECT Id
        							,Name
        							,Translated_Path__c
        							,Consumer_Facing_Name__c
        							,Consumer_Facing_Brand__c
        							,Product_Description__c
        							,Image_Url__c 
        							,Image_Url_Thumb__c
                             		,GTIN_Number__c

        			FROM Local_Product__c 
        			WHERE Id IN :lpIds AND Inactive__c = false
        			ORDER BY Translated_Path__c ASC];
        		//If Local Products were found related to the search term along with IPMS records, put them in the same list, then sort
        	
				for(Local_Product__c lp : localList){
	        		if(ipmsMap.containsKey(lp.Id)){
		        		for(IPMS__c ipms : ipmsMap.get(lp.Id)){
		        			SearchResult sr = new SearchResult();
		        			sr.product = lp;
		        			sr.IPMS = ipms.Name;
		        			searchResultsList.add(sr);	
		        		}
	        		}
	        	}
        	}
        } else {
	        String searchquery='FIND \'';
	        searchquery += term;
			searchquery += '\' IN ALL FIELDS RETURNING Local_Product__c (Id, Name, Translated_Path__c, Consumer_Facing_Name__c, Consumer_Facing_Brand__c, Product_Description__c, Image_Url__c, Image_Url_Thumb__c, GTIN_Number__c';
	        searchquery += ' WHERE Inactive__c = false ';
	        if (!String.isEmpty(country)) searchquery += ' AND Country__c = \''+ country + '\'';
	       	// NOTE this filter was added for defect of top level results 11/5/2014 - ljo
	       	searchquery += ' AND Path_Level__c!=\'BRAND\' ';
	        searchquery += ' ORDER BY Translated_Path__c ASC ';
	        searchquery += ') LIMIT ' + String.valueOf(maxResults); 
	        
	        List<List<SObject>> searchList = search.query(searchquery);
	        
	        for(Local_Product__c lp : (List<Local_Product__c>)searchList[0]){
		        SearchResult sr = new SearchResult();
    			sr.product = lp;
    			searchResultsList.add(sr);	
	        }
        }

        return searchResultsList;
    }

   /**
	* @author: Chris Southworth
	* @date: 06/26/2014
	* @param: lpList - List of Local_Product__c records to be sorted by Translated_Path__c
	* @description: return a sorted version of the list provided
	* @return: returnList - List of Local_Product__c records sorted by Translated_Path__c
	*/
    /*public static List<Local_Product__c> sortLocalProductList(List<Local_Product__c> lpList){
    	List<Local_Product__c> returnList = new List<Local_Product__c>();
    	
    	Map<String, List<Local_Product__c>> lpMap = new Map<String, List<Local_Product__c>>();
    	
    	for(Local_Product__c lp: lpList){
    		if(!lpMap.containsKey(lp.Translated_Path__c)){
    			lpMap.put(lp.Translated_Path__c, new List<Local_Product__c>());
    		}
    		lpMap.get(lp.Translated_Path__c).add(lp);
    	}
    	
    	List<String> keys = new List<String>(lpMap.keySet());
    	keys.sort();
    	
    	for(String k : keys){
    		returnList.addAll(lpMap.get(k));
    	}

		return returnList;
    }*/
    
   /**
	* @author: Oleg Rikkers
	* @date: 05/08/2014
	* @param: lpId - The Id of the Local_Product__c record
	* @param: caseId - The Id of the current case
	* @param: lastSearch - Store the text of the user search on the Case Product record
	* @description: Create a new Case_Product__c record for the provided caseId, and create a lookup to the provided
	*	Local_Product__c Id.
	* @return: None
	*/ 
    @RemoteAction
    global static Integer addProduct (String lpId, String lpBrand, String caseId, String lastSearch, String gtin, String ipms) {
       	if (!String.isEmpty(lpId)) {
            Case_Product__c cp = new Case_Product__c ();
            cp.Case__c = caseId;
            cp.Local_Product__c = lpId;
            cp.Search_Term__c = lastSearch;
            cp.Change_Reason__c = 'Initial Value';
            if(!String.isEmpty(gtin)){
            	cp.GTIN__c = gtin;
            }
            
            if(!String.isEmpty(ipms)){
            	cp.IPMS__c = ipms;
            }
            insert cp;

            Case_Product__c cprod = [SELECT Id, Local_Product__r.Global_Product__r.Segment__c, Local_Product__r.Translated_Path__c FROM Case_Product__c WHERE Id = :cp.Id];
            Case c = [SELECT Id, Brand__c, Segment__c, Case_Products__c, Active_Products__c FROM Case WHERE Id = :caseId];
            

            //post go live improvement 7/9/2015 populate brand every time it's null or default one until an actual brand is populated
            //if(String.isEmpty(c.Brand__c) || c.Brand__c.equalsIgnoreCase(sf_Constants.DEFAULT_CUSTOMER_FACING_BRAND)){ 
            //	c.Brand__c = String.isEmpty(lpBrand) ?sf_Constants.DEFAULT_CUSTOMER_FACING_BRAND : lpBrand;
            //}


            //post go live improvement 7/14/2015 if still empty or default, try getting it from translated path of local product.
            //if((String.isEmpty(c.Brand__c) || c.Brand__c.equalsIgnoreCase(sf_Constants.DEFAULT_CUSTOMER_FACING_BRAND)) 
            //	&& !String.isEmpty(cprod.Local_Product__r.Translated_Path__c)){ 

            //	c.Brand__c = cprod.Local_Product__r.Translated_Path__c.split('/')[0];

            //}

            //so, after long conversations and testing the latest and greatest as of 7/24/2015 is to take it from the first product added at all times!!!!


            if ((c.Active_Products__c == 1 
					&& cprod.Local_Product__r.Translated_Path__c != null)) //first active aka != cancelled product being added
            	c.Brand__c = c.Brand__c = cprod.Local_Product__r.Translated_Path__c.split('/')[0];

            //alm 623

            if (String.isEmpty(c.Segment__c)){
            	
            	if (!String.isEmpty(cprod.Local_Product__r.Global_Product__r.Segment__c))
            		c.Segment__c = cprod.Local_Product__r.Global_Product__r.Segment__c;
            }

            update c;
            
            return [SELECT COUNT() FROM Case_Product__c WHERE Local_Product__c = :lpId AND Case__c = :caseId];
        } else {
            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, 'Product Id cannot be null'));
        }
        return -1;//return -1 on fail
    }
    
   /**
	* @author: Chris Southworth
	* @date: 08/11/2014
	* @param: caseId - The Id of the current case
	* @description: Query for each of the case products.  The resulting list will be used to build a map in the javascript,
	*	to keep track of the number of each local product added to the Case, which is shown under the Add button on the search
	*	page.
	* @return: None
	*/ 
    @RemoteAction
    global static List<Case_Product__c> getCaseProducts(String caseId){
    	return [SELECT Local_Product__c FROM Case_Product__c WHERE Case__c = :caseId];
    }
    
}