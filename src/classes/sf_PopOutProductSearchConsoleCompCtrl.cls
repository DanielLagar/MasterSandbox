global class sf_PopOutProductSearchConsoleCompCtrl {
    public boolean isCase {get; set;}
    public boolean text {get; set;}

   /*
	* @author: Chris Southworth
	* @date: 05/08/2014
	* @description: Wrapper class used to hold the Case_Product__c record and it's list of Case_Comment_Codes__c. 
	*	Used as part of a repeat in the VF page sf_ProductSearchConsoleComponent.page to display the records.
	*/ 
    public class productComments{
		public Case_Product__c product {get; set;}
		public List<Case_Comment_Code__c> caseCommentCodes {get; set;}
		public List <Local_Comment_Code__c> suggestedComments {get; set;}
		public String levelOneFilter {get; set;}
		public String levelTwoFilter {get; set;}
		public productComments(){
			levelOneFilter = '';
			levelTwoFilter = '';
		}
	}

	public String testFilter {get; set;}
	
    public List <Case_Product__c> caseProducts {get; set;}
    public String caseId {get; set;}
    public String localProductId {get; set;}
    public String commentCodeId {get; set;}
    public Case caseRecord{get; set;}
    public List<productComments> productCommentsList {get; set;}
    public List <Survey__c> surveys {get; set;}
    public List <Local_Comment_Code__c> lccSuggestions {get; set;}

    //Comment Code dictionary variables:
    public String dictionaryProductId {get; set;}
	public Case_Product__c dictionaryProduct {get; set;}
	public String globalProductId {get; set;}
	public List<Local_Comment_Code__c> localCodes {get; set;}
	public String levelOne {get; set;}
	public String levelTwo {get; set;}
	public String sortBy {get; set;}
	public String lastSort {get; set;}
	public String sortDirection {get; set;}
	public String selectedLocalCommentId {get; set;}
	public Map<String, List<SelectOption>> optionMap {get; set;}
	public integer caseProductIndex {get; set;}
	public Map<Id, String> level1Map {get; set;}
	public Map<Id, String> level2Map {get; set;}
    
    public sf_PopOutProductSearchConsoleCompCtrl(ApexPages.StandardController sc) {
    	caseProductIndex = 0;
        //surveys = new List <Survey__c> ();

        //Comment Code Filter setup:
        levelOne = '';
		levelTwo = '';
		globalProductId = '';
		optionMap = new Map<String, List<SelectOption>>();
		//prevent picklists from erroring out on page load.  Populated with actual values in buildPicklistMaps();
		optionMap.put(null, new List<SelectOption>());
		optionMap.get(null).add(new SelectOption('', Label.CommentCodeDictionary_No_Level2_Filter));
		optionMap.put('', new List<SelectOption>());
		optionMap.get('').add(new SelectOption('', Label.CommentCodeDictionary_No_Level2_Filter));
		level1Map = new Map<Id, String>();
		level2Map = new Map<Id, String>();
    }
    
   /*
	* @author: John Casimiro
	* @date: 05/09/2014
	* @param: unknownId - Id of the record currently selected in the service cloud console
	* @description: Returns the name of the sObject type based on the unknownId.
	* @return: String value of the sObject type
	*/
    @RemoteAction
    global static String checkObjectId(Id unknownId){
        Schema.SObjectType s =  unknownId.getSObjectType();
        return string.valueof(s);
    } 

   /*
	* @author: Chris Southworth
	* @date: 05/14/2014
	* @param: None
	* @description: A method that grabs the case fields based on the caseId sent from the VF page as part of an action function
	* @return: PageReference is returned NULL to stay on page
	*/
    public PageReference setCaseId(){
    	if(caseId != null && !String.isBlank(caseId)){
    		caseRecord = [SELECT Id, Country__c, CaseNumber, Language__c FROM Case WHERE Id =:caseId];
    		caseId = caseRecord.Id;
    		System.debug('****CaseId: ' + caseId);
    		System.debug('*** Language: ' + caseRecord.Language__c);
    		buildPicklistMaps();
    		refreshCaseProducts();
    	}
    	return NULL;
    }

   /*
	* @author: Oleg Rikkers, Chris Southworth
	* @date: 05/08/2014
	* @param: None
	* @description: Query for Case_Product__c records related to the current case.  Then query for Case_Comment_Code__c 
	*	records related to those products.  Build a map of Case_Products__c and their list of related
	*	Case_Comment_Codes__c and store in the wrapper class productComments which is used to display 
	*	Products/Case Comment Codes on the Product/Case Comment search
	* @return: PageReference is returned NULL to stay on page
	*/
    public PageReference refreshCaseProducts () {
		if(productCommentsList != null && productCommentsList.size() > 0){
			for(productComments pc : productCommentsList){
				level1Map.put(pc.product.Id, pc.levelOneFilter);
				level2Map.put(pc.product.Id, pc.levelTwoFilter);
			}
		}
    	surveys = [SELECT Id FROM Survey__c WHERE Case__c = :caseId];
    	
        caseProducts = new List <Case_Product__c> ([SELECT Id
                                                        ,Name
                                                        ,Local_Product__r.Translated_Path__c
                                                        ,Local_Product__r.Name 
                                                        ,Product_in_Hand__c
                                                        ,Product_available_for_return__c
                                                        ,Production_Code__c
                                                        ,Number_of_Adverse_Event_Comments__c
                                                        ,Number_of_PQC_Comments__c
                                                        ,Global_Product_ID__c
                                                        ,Local_Product__r.Global_Product__r.Brand__c
                                                        ,Local_Product__r.Global_Product__r.Segment__c
                                                    FROM Case_Product__c 
                                                    WHERE Case__c = :caseId
                                                    ORDER BY createdDate DESC LIMIT 1000]);
                                                    
		
        


		productCommentsList = new List<productComments>();

    	if(!caseProducts.isEmpty()){
    		//Add Case_Products__c to the productCommentsList
			Set<Id> caseProductIdSet = new Set<Id>();
	    	for(Case_Product__c cp : caseProducts){
	        	caseProductIdSet.add(cp.Id);
	    		productComments npc = new productComments();
	    		npc.product = cp;
	    		npc.caseCommentCodes = new List<Case_Comment_Code__c>();
	    		npc.suggestedComments = new List <Local_Comment_Code__c> ();
	    		if(level1Map.containsKey(cp.Id)){
	    			npc.levelOneFilter = level1Map.get(cp.Id);
	    		}
	    		if(level2Map.containsKey(cp.Id)){
	    			npc.levelTwoFilter = level2Map.get(cp.Id);
	    		}
	    		productCommentsList.add(npc);
	    	}
	    	level1Map.clear();
	    	level2Map.clear();
	    	
	    	if(!caseProductIdSet.isEmpty()){
	    		//Build map of Case_Comment_Code__c records to assign to the correct product in the productCommentsList
	    		Map<Id, List<Case_Comment_Code__c>> productCommentsMap = new Map<Id, List<Case_Comment_Code__c>>();

	    		List <Case_Comment_Code__c> cccList = new List <Case_Comment_Code__c> ([SELECT Id
	    																				,Local_Comment_Code__c
									    												,Local_Comment_Code__r.Name
									    												,Local_Comment_Code__r.Full_Translated_Path__c
									    												,Case_Product__c
									    												,Local_Comment_Code__r.Criticality__c
									    												,Local_Comment_Code__r.Global_Comment_Code_Group__c
									    												,Local_Comment_Code__r.Global_Comment_Code_Language__c
									    												FROM Case_Comment_Code__c 
									    												WHERE Case_Product__c IN :caseProductIdSet
									    												ORDER BY Local_Comment_Code__r.Full_Translated_Path__c]);

	    		Set <Id> localCommentsSet = new Set <Id> ();

	    		for(Case_Comment_Code__c ccc : cccList){
	    			if(!productCommentsMap.containsKey(ccc.Case_Product__c)){
	    				productCommentsMap.put(ccc.Case_Product__c, new List<Case_Comment_Code__c>());
	    			}
	    			productCommentsMap.get(ccc.Case_Product__c).add(ccc);


	    			localCommentsSet.add (ccc.Local_Comment_Code__c);

	    		} //end for (Case_Comment_Code__c ccc)


	    		//COMMENT SUGGESTIONS
	    		for (Case_Comment_Code__c ccc: cccList) {
			        if (ccc.Local_Comment_Code__r.Global_Comment_Code_Group__c != null) {
			        	lccSuggestions = new List <Local_Comment_Code__c> (
			        		[SELECT Id, Full_Translated_Path__c FROM Local_Comment_Code__c 
			        		WHERE Global_Comment_Code_Group__c = :ccc.Local_Comment_Code__r.Global_Comment_Code_Group__c
			        		AND Global_Comment_Code_Language__c = :ccc.Local_Comment_Code__r.Global_Comment_Code_Group__c
			        		AND Id NOT IN :localCommentsSet]
			        	);
	        		}
	    		}
			        

        		//END SUGGESTIONS

	    		
	    		if(!productCommentsMap.isEmpty()){
	    			//Assign Case_Comment_Code__c list to the product in the productCommentsList
	    			for(ProductComments pc : productCommentsList){
	    				if(productCommentsMap.containsKey(pc.product.Id)){
	    					pc.caseCommentCodes = productCommentsMap.get(pc.product.Id);
	    				}
	    			}
	    		}
	    	}
    	}
	
        return null;
    }

   /*
	* @author: Oleg Rikkers
	* @date: 05/08/2014
	* @param: None
	* @description: Query for Case_Product__c records related to the current case and remove the selected product.
	*	localProductId is passed from the VF page and holds the ID of the product to delete.
	*	Related Case_Comment_Code__c records are also removed.
	* @return: PageReference is returned NULL to stay on page
	*/
    public PageReference removeCaseProduct () {
        try {
            if (!String.isEmpty(localProductId)){
                 Case_Product__c cp = [SELECT Id FROM Case_Product__c WHERE Id=:localProductId];
                 if(cp != null){
					delete [SELECT Id FROM Case_Comment_Code__c WHERE Case_Product__c=:localProductId];
					delete cp;
                 }
                ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.INFO, 'Product deleted.'));
            } else {
                ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, 'Product cannot be null.'));
            }
           
        } catch (Exception e) {
            System.debug(e);
            ApexPages.addMessages (e);
        }

        return null;
    }
    
   /*
	* @author: Chris Southworth
	* @date: 05/08/2014
	* @param: None
	* @description: Query for Case_Comment_Code__c records related to the current case and remove the selected record.
	*	commentCodeId is passed from the VF page and holds the ID of the case comment code to delete.
	* @return: PageReference is returned NULL to stay on page
	*/
    public PageReference removeCommentCode(){
    	try{
    		if(!String.isEmpty(commentCodeId)){
				delete [SELECT Id FROM Case_Comment_Code__c WHERE Id=:commentCodeId];
				//ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.INFO, 'Comment Code deleted.'));
			} else {
				ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, 'Comment Code Id cannot be null.'));
			}
    	} catch(Exception e){
            System.debug(e);
            ApexPages.addMessages (e);
    	}
    	
    	return NULL;
    }

   /*
	* @author: Chris Southworth
	* @date: 05/08/2014
	* @param: caseId - The Id of the case record to add the Case_Comment_Code__c record.
	* @description: Queries for and returns the case Language__c if a valid Id is passed
	* @return: String - Case Language
	*/
    @RemoteAction
    global static String getCaseLanguage(String sCaseId){
    	if(sCaseId != null && !String.isBlank(sCaseId)){
    		return [Select Id, Language__c FROM Case WHERE Id =:sCaseId].Language__c;
    	}
    	return '';
    }

   /*
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
    global static List <Local_Product__c> doSoslSearch (String term, String country, Boolean gtin) {
        term = String.escapeSingleQuotes(term) + '*';
        
        System.debug('***gtin: ' + gtin);
        if(gtin){
        	term = '0*' + term;
        }
        String searchquery='FIND \'';
        searchquery += term;
        searchquery += '\' IN ALL FIELDS RETURNING Local_Product__c (Id, Name, Translated_Path__c, Country__c ';
        if (!String.isEmpty(country)) searchquery += ' WHERE Country__c = \''+ country + '\'';
        searchquery += ' ORDER BY Translated_Path__c ASC ';
        //searchquery += '), IPMS__c (Id, Local_Product__c ';
        //if (!String.isEmpty(country)) searchquery += ' WHERE Local_Product__r.Country__c = \''+ country + '\'';
        searchquery += ') LIMIT 250'; 
        
        List<List<SObject>> searchList = search.query(searchquery);
        
        //Don't inclide Local Products related to IPMS when doing a GTIN search
        if(searchList[0].size() < 250){
        	Integer searchCount = 250 - searchList[0].size();
        	String ipmsquery='FIND \'';
	        ipmsquery += term;
	        ipmsquery += '\' IN ALL FIELDS RETURNING IPMS__c (Id, Local_Product__c ';
	        if (!String.isEmpty(country)) ipmsquery += ' WHERE Local_Product__r.Country__c = \''+ country + '\'';
	        ipmsquery += ') LIMIT :searchCount'; 
        	System.debug('***IMPSSEARCH: ' + ipmsquery);
        	System.debug('***SearchCount: ' + searchCount);
        	List<List<SObject>> impsList = search.query(ipmsquery);
        	
	        if(!gtin){
	        	//IPMS records were found in above query        	
	        	if(impsList[0].size() > 0){
	        		List<Local_Product__c> localList = new List<Local_Product__c>();
	        		Set<String> lpIds = new Set<String>();
	        		//Build map of Local Product Ids to query necessary fields
	        		for(IPMS__c ip : (List<IPMS__C>)impsList[0]){
	        			lpIds.add(ip.Local_Product__c);
	        		}
	        		//remove Ids from LP that are already in the search results
	        		if(searchList[0].size() > 0){
	        			for(Local_Product__c lp : (List<Local_Product__c>)searchList[0]){
	        				if(lpIds.contains(lp.Id)){
	        					lpIds.remove(lp.Id);
	        				}
	        			}
	        		}
					
					//Query for Local Products
	        		localList = [SELECT Id, Name, Translated_Path__c, Country__c FROM Local_Product__c WHERE Id IN :lpIds ORDER BY Translated_Path__c ASC];
	        		//If Local Products were found related to the search term along with IPMS records, put them in the same list, then sort
	        		if(searchList[0].size() > 0){
	        			localList.addAll((List<Local_Product__c>)searchList[0]);
	        			localList = sortLocalProductList(localList);
	        		}
	        		return localList;
	        	}
	        }
        }

        //System.debug(searchList);

		//return Local_Product__c with no related IPMS__c records matching term
        return searchList[0];
    }

   /*
	* @author: Chris Southworth
	* @date: 06/26/2014
	* @param: lpList - List of Local_Product__c records to be sorted by Translated_Path__c
	* @description: return a sorted version of the list provided
	* @return: returnList - List of Local_Product__c records sorted by Translated_Path__c
	*/
    public static List<Local_Product__c> sortLocalProductList(List<Local_Product__c> lpList){
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
    }
    
   /*
	* @author: Chris Southworth
	* @date: 05/08/2014
	* @param: gPId - Used to locate product specific comment codes
	* @param: term - The search term passed from the jquery autocomplete search in the VF page
	* @param: country - The country listed on the related Case record, or selected from the drop down on the VF page
	* @param: language - The language listed on the related Case record, needed for filtering results
	* @param: levelOneFilter = the value of the first picklist on the vf page.  Contains Level_1__c values.
	* @param: levelOneFilter = the value of the second picklist on the vf page.  Contains Level_2__c values, based on Level_1__c.
	* @description: Search for Local_Comment_Code__c records that match or partially match the search term provided from
	*	the user on the sf_ProductSearchConsoleComponent.page.  Results are filtered by language, and any picklist filters selected
	*	on the vf page.  
	* @return: searchList[0] - List of Local_Comment_Code__c records found from the SOSL query
	*/ 
	@RemoteAction
	global static List <Local_Comment_Code__c> doCaseCommentSoslSearch(String gpId, String gpBrand, String gpSegment, String term, String country, String language, String levelOneFilter, String levelTwoFilter){
		//System.debug('***CaseLanguage: ' + language);
		//System.debug('***LevelOneFilter: ' + levelOneFilter);
		//System.debug('***LevelTwoFilter: ' + levelTwoFilter);
		System.debug('***Brand: ' + gpBrand);
		System.debug('***Segment: ' + gpSegment);
		term = String.escapeSingleQuotes(term) + '*';
		
		//String gpid = [SELECT Id, Global_Product__c FROM Case_Product__c WHERE Id =:productId].Global_Product__c;
		//System.debug('***GPID: ' + gpId);
		List<Local_Comment_Code__c> codesList = new List<Local_Comment_Code__c>();
		if(!String.isEmpty(gpId)){
			Set<String> gcc = new Set<String>();
			String gccStringSet = '';
			//Global_Product__c gp = [SELECT Id, Brand__c, Segment__c FROM Global_Product__c WHERE Id =:gpID];
			for(Product_Comment_Code__c pcc : [SELECT Id, Global_Comment_Code__c FROM Product_Comment_Code__c
											WHERE Global_Product_Segment__c = :gpSegment
											AND Global_Product_Brand__c = :gpBrand]){ 
				if(gcc.add(pcc.Global_Comment_Code__c)){
					String pccGId = '\'' + pcc.Global_Comment_Code__c + '\'';
        			gccStringSet += (gccStringSet.length() == 0 ? '' : ',') + pccGId;
				}
			}

			if(!gcc.isEmpty()){
				String commentQuery = 'FIND \'' + term;
				commentQuery += '\' IN ALL FIELDS RETURNING Local_Comment_Code__c (Id, Criticality__c, Full_Translated_Path__c, Name, Description__c';
		        //if (!String.isEmpty(country)) commentQuery += ' WHERE Country__c = \''+ country + '\'';
				if(!String.isEmpty(language)){
					commentQuery += ' WHERE Translated_Language__c LIKE \'' + language + '%\' AND ';
				} else {
					commentQuery += ' WHERE ';
				}
				if(!String.isEmpty(levelOneFilter)){
					commentQuery += ' Level_1__c = \'' + levelOneFilter + '\' AND ';
				}
				if(!String.isEmpty(levelTwoFilter)){
					commentQuery += ' Level_2__c = \'' + levelTwoFilter + '\' AND ';
				}
				commentQuery += ' Global_Comment_Code__c IN (' + gccStringSet + ') AND ';
				commentQuery += ' Inactive__c = false';
				commentQuery += ' ORDER BY Full_Translated_Path__c ASC ';
				commentQuery += ') LIMIT 250';
				
				//System.debug('***StringQuery: ' + commentQuery);
				List<List<SObject>> searchList = search.query(commentQuery);
				
				//Uncomment this and the section below to also query for comment codes that don't have Product Comment Code record linkages
				if(searchList[0].size() > 0){
					codesList = searchList[0];
				}
			}
		}
		return codesList;
		
		/*//Seach through all records if no Global Product is linked, or no results displayed for search filtered by product
		String commentQuery = 'FIND \'' + term;
		commentQuery += '\' IN ALL FIELDS RETURNING Local_Comment_Code__c (Id, Criticality__c, Full_Translated_Path__c, Name, Description__c';
        //if (!String.isEmpty(country)) commentQuery += ' WHERE Country__c = \''+ country + '\'';
		if(!String.isEmpty(language)){
			commentQuery += ' WHERE Translated_Language__c LIKE \'' + language + '%\' AND ';
		} else {
			commentQuery += ' WHERE ';
		}
		if(!String.isEmpty(levelOneFilter)){
			commentQuery += ' Level_1__c = \'' + levelOneFilter + '\' AND ';
		}
		if(!String.isEmpty(levelTwoFilter)){
			commentQuery += ' Level_2__c = \'' + levelTwoFilter + '\' AND ';
		}
		commentQuery += ' Inactive__c = false';
		commentQuery += ' ORDER BY Full_Translated_Path__c ASC ';
		commentQuery += ') LIMIT 250';
		List<List<SObject>> searchList = search.query(commentQuery);

		return searchList[0];*/
    }

   /*
	* @author: Oleg Rikkers
	* @date: 05/08/2014
	* @param: lpId - The Id of the Local_Product__c record
	* @param: caseId - The Id of the current case
	* @description: Create a new Case_Product__c record for the provided caseId, and create a lookup to the provided
	*	Local_Product__c Id.
	* @return: None
	*/ 
    @RemoteAction
    global static void addProduct (String lpId, String caseId) {
       	if (!String.isEmpty(lpId)) {
            Case_Product__c cp = new Case_Product__c ();
            cp.Case__c = caseId;
            cp.Local_Product__c = lpId;
            insert cp;
        } else {
            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, 'Product Id cannot be null'));
        }
    }
    
   /*
	* @author: Chris Southworth
	* @date: 05/08/2014
	* @param: caseId - The Id of the case record to add the Case_Comment_Code__c record.
	* @param: localCommentCodeId - The Id of the Local_Comment_Code__c record.
	* @param: productId - The Id of the Case_Product__c record.
	* @description: Create a new Case_Comment_Code__c record for the provided caseId, and create a lookup to the provided
	*	Local_Comment_Code__c Id and Case_Product__c Id.
	* @return: None.
	*/ 
	@RemoteAction
	global static void addCaseCommentCode(String caseId, String localCommentCodeId, String productId){
		if(!String.isEmpty(localCommentCodeId) && !String.isEmpty(productId)){

	        Case_Comment_Code__c ccc = new Case_Comment_Code__c();
	        ccc.Case__c = caseId;
	        ccc.Local_Comment_Code__c = localCommentCodeId;
	        ccc.Case_Product__c = productId;
	        insert ccc;
	        
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Product Id and Local Comment Code Id cannot be null'));
		}
    }

     /*
	* @author: Oleg Rikkers
	* @date: 05/20/2014
	* 
	* @description: saves product changes
	* @return: None.
	*/ 
    public PageReference saveProductChanges () {
    	try {
    		upsert caseProducts;
		} catch (Exception e) {
    		ApexPages.addMessages (e);
    	}

    	return null;
    }
    
	/********************************************
		Comment Code Dictionary Methods below
	*********************************************/
	
   /*
	* @author: Chris Southworth
	* @date: 06/12/2014
	* @param: None
	* @description: build a map of the possible picklist values for use on the product search and comment code dictionary pages
	* @return: None.
	*/
	public void buildPicklistMaps(){
		levelOne = '';
		levelTwo = '';
		globalProductId = '';
		
    	resetCommentCodeDictionary();
		//refreshCodeFilterList();

		Map<String, Set<String>> filterMap = new Map<String, Set<String>>();
		for(AggregateResult ar : [SELECT Level_1__c level1, Level_2__c level2 FROM Local_Comment_Code__c WHERE Inactive__c = false AND Translated_Language__c LIKE :(caseRecord.Language__c + '%') GROUP BY Level_1__c, Level_2__c]){
			if(ar.get('level1') != null){
				System.debug('***AR: ' + ar);
				String s1 = String.valueOf(ar.get('level1'));
				s1 = s1.replaceAll('(\\s+)', ' ');
				if(!filterMap.containsKey(s1)){
					filterMap.put(s1, new Set<String>());
				}
				if(ar.get('level2') != null){
					String s2 = String.valueOf(ar.get('level2'));
					s2 = s2.replaceAll('(\\s+)', ' ');
					filterMap.get(s1).add(s2);
				}
			}
		}
		//System.debug('***FILTERMAP: ' + filterMap);
		
		/*Map<String, Set<String>> filterMap = new Map<String, Set<String>>();
		for(Local_Comment_Code__c lcc : localCodes){
			String s1 = lcc.Level_1__c;
			s1 = s1.replaceAll('(\\s+)', ' ');
			
			if(!filterMap.containsKey(s1)){
				filterMap.put(s1, new Set<String>());
			}
			if(!String.isEmpty(lcc.Level_2__c)){
				String s2 = lcc.Level_2__c;
				s2 = s2.replaceAll('(\\s+)', ' ');
				filterMap.get(s1).add(s2);
			}
		} */
		
		optionMap.clear();
		optionMap.put(null, new List<SelectOption>());
		optionMap.get(null).add(new SelectOption('', Label.CommentCodeDictionary_No_Level2_Filter));
		optionMap.put('', new List<SelectOption>());
		optionMap.get('').add(new SelectOption('', Label.CommentCodeDictionary_No_Level2_Filter));		

		for(String s : filterMap.keySet()){
			List<String> tempSet = new List<String>();
			tempSet.addAll(filterMap.get(s));
			tempSet.sort();
			optionMap.put(s, new List<SelectOption>());
			optionMap.get(s).add(new SelectOption('', Label.CommentCodeDictionary_No_Level2_Filter));
			for(String t : tempSet){
				if(t != null && t != ''){
					optionMap.get(s).add(new SelectOption(t, t));
				}
			}
		}
		//System.debug('***LevelTwoMap: ' + optionMap);
    }

   /*
	* @author: Chris Southworth
	* @date: 06/12/2014
	* @param: None
	* @description: Assembles the Picklist to filter on the Level_1__c field
	* @return: List of SelectOption values for Level 1 Filter picklist
	*/
	public List<SelectOption> getLevelOneList(){
		List<SelectOption> oneList = new List<SelectOption>();
		//Schema.DescribeFieldResult fieldResult = Global_Comment_Code__c.Level_1__c.getDescribe();
		//List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

		List<String> sortedList = new List<String>();
		sortedList.addAll(optionMap.keySet());
		sortedList.sort();

		oneList.add(new SelectOption('', Label.CommentCodeDictionary_No_Level1_Filter));

		for(String s : sortedList){
			if(s != null && s != ''){
				oneList.add(new SelectOption(s, s));
			}
		}

		System.debug('***LevelOneList: ' + oneList);
		return oneList;
	}

	/*public List<SelectOption> getLevelTwoList(){
		List<SelectOption> twoList = new List<SelectOption>();

		twoList.add(new SelectOption('', '--No Filter--'));
		
		System.debug('***LevelOne: ' + levelOne);

		if(levelOne != null && levelOne != ''){
			List<String> sortedList = new List<String>();
			sortedList.addAll(filterMap.get(levelOne));
			sortedList.sort();
		
			Set<String> level2Set = new Set<String>();
			if(!String.isBlank(levelOne)){
				for(String s : sortedList){
					twoList.add(new SelectOption(s, s));
				}
			}
		}

		return twoList;
	}*/

   /*
	* @author: Chris Southworth
	* @date: 06/12/2014
	* @param: None
	* @description: sorts the comment codes in the comment code dictionary by the selected header value.  If the header value was the last
	*	selected, then the sort direction is changed.  Initial sort direction is ASC, the header toggles if clicked again.
	* @return: None.
	*/
	public void setSortDirection(){
		if(lastSort == sortBy){
			if(sortDirection == 'ASC'){
				sortDirection = 'DESC';
			} else {
				sortDirection = 'ASC';
			}
		} else {
			lastSort = sortBy;
			sortDirection = 'ASC';
		}
		refreshCodeFilterList();
	}

   /*
	* @author: Chris Southworth
	* @date: 06/12/2014
	* @param: None
	* @description: Used when the Level 1 filter is changed in the comment code dictionary. The Level 2 filter is reset, and the
	*	table of comment codes is refiltered by the new Level 1 value.
	* @return: PageReference is returned NULL to stay on page
	*/
	public PageReference filterByLevel1(){
		levelTwo = '';
		refreshCodeFilterList();
		return null;
	}

   /*
	* @author: Chris Southworth
	* @date: 06/12/2014
	* @param: None
	* @description: Adds the comment code selected from the comment code dictionary to the Case record
	* @return: PageReference is returned NULL to stay on page
	*/
	public PageReference addSelectedCommentCode(){
		System.debug('***Added Code: CaseId: ' + caseId + ', LCC: ' + selectedLocalCommentId + ', CaseProduct: ' + dictionaryProductId);
		//sf_PopOutProductSearchConsoleCompCtrl.addCaseCommentCode(caseId, selectedLocalCommentId, productId);
		//if(!String.isEmpty(selectedLocalCommentId) && !String.isEmpty(dictionaryProductId)){
			//try{ // removed try catch - we need it to throw an exception so we can catch it in the javascript. otherwise event.status is always true... 
		        Case_Comment_Code__c ccc = new Case_Comment_Code__c();
		        ccc.Case__c = caseId;
		        ccc.Local_Comment_Code__c = selectedLocalCommentId;
		        ccc.Case_Product__c = dictionaryProductId;
		        insert ccc;
       		//} catch(Exception e){
            //    System.debug(e);
            //	ApexPages.addMessages(e);
       		//}
		//} else {
		//	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Product Id and Local Comment Code Id cannot be null'));
		//}
		return null;
	}

   /*
	* @author: Chris Southworth
	* @date: 06/12/2014
	* @description: refreshes the comment codes displayed in the comment code dictionary based on the Case.Language__c,
	*	Level 1 and Level 2 filters, and sort field and order.
	* @return: PageReference is returned NULL to stay on page
	*/
	public PageReference refreshCodeFilterList(){
		System.debug('***LevelOne BeforeQuery: ' + levelOne);
		System.debug('***LevelTwo BeforeQuery: ' + levelTwo);
		String language = caseRecord.Language__c;
		System.debug('***CaseLanguage: ' + language);
		
		System.debug('***GPID: ' + globalProductId);
		List<List<SObject>> searchList = new List<List<SObject>>();
		if(!String.isEmpty(globalProductId)){
			Set<String> gcc = new Set<String>();
			String gccStringSet = '';
			Global_Product__c gp = [SELECT Id, Brand__c, Segment__c FROM Global_Product__c WHERE Id =:globalProductId];
			for(Product_Comment_Code__c pcc : [SELECT Id, Global_Comment_Code__c FROM Product_Comment_Code__c
											WHERE Global_Product_Segment__c = :gp.Segment__c
											AND Global_Product_Brand__c = :gp.Brand__c]){ 
			//for(Product_Comment_Code__c pcc : [SELECT Id, Global_Comment_Code__c FROM Product_Comment_Code__c WHERE Global_Product__c =:globalProductId]){
				if(gcc.add(pcc.Global_Comment_Code__c)){
					String pccGId = '\'' + pcc.Global_Comment_Code__c + '\'';
        			gccStringSet += (gccStringSet.length() == 0 ? '' : ',') + pccGId;
				}
			}

			if(!gcc.isEmpty()){
				String queryString = 'SELECT Id, Criticality__c, Level_1__c, Level_2__c, Level_3__c, Description__c, Synonyms__c ';
				queryString += 'FROM Local_Comment_Code__c ';
				queryString += 'WHERE Translated_Language__c LIKE \'' + language + '%\' ';
				//queryString += 'AND Country__c = \'' + caseRecord.Country__c + '\' ';
				if(!String.isBlank(levelOne)){
					queryString += 'AND Level_1__c = \'' + levelOne + '\' ';
				}
				if(!String.isBlank(levelTwo)){
					queryString += 'AND Level_2__c = \'' + levelTwo + '\' ';
				}
				queryString += 'AND Global_Comment_Code__c IN (' + gccStringSet + ') ';
				queryString += 'ORDER BY ' + sortBy + ' ' + sortDirection + ' ';
				if(sortDirection == 'ASC'){
					queryString += 'Nulls Last ';
				} else{
					queryString += 'Nulls First ';
				}
				queryString += 'LIMIT 1000';
		
				System.debug('***Code Filter Query String: ' + queryString);
				localCodes = Database.query(queryString);
			}
		} else {
			String queryString = 'SELECT Id, Criticality__c, Level_1__c, Level_2__c, Level_3__c, Description__c, Synonyms__c ';
			queryString += 'FROM Local_Comment_Code__c ';
			queryString += 'WHERE Translated_Language__c LIKE \'' + language + '%\' ';
			//queryString += 'AND Country__c = \'' + caseRecord.Country__c + '\' ';
			if(!String.isBlank(levelOne)){
				queryString += 'AND Level_1__c = \'' + levelOne + '\' ';
			}
			if(!String.isBlank(levelTwo)){
				queryString += 'AND Level_2__c = \'' + levelTwo + '\' ';
			}
			queryString += 'ORDER BY ' + sortBy + ' ' + sortDirection + ' ';
			if(sortDirection == 'ASC'){
				queryString += 'Nulls Last ';
			} else{
				queryString += 'Nulls First ';
			}
			queryString += 'LIMIT 1000';
	
			System.debug('***Code Filter Query String: ' + queryString);
			localCodes = Database.query(queryString);
		}

		return NULL;
	}

   /*
	* @author: Chris Southworth
	* @date: 06/12/2014
	* @description: Queries for the product that was selected on the search page, and grabs the data to be displayed on the comment
	*	code dictionary.  Calls methods to reset the sort field, sort direction, and clears the comment code list.
	* @return: PageReference is returned NULL to stay on page
	*/
	public PageReference openCommentCodeDictionary(){
		levelOne = productCommentsList.get(caseProductIndex).levelOneFilter;
		levelTwo = productCommentsList.get(caseProductIndex).levelTwoFilter;
	    System.debug('***ProductList: ' + productCommentsList);
		System.debug('***LevelOne: ' + levelOne);
		System.debug('***LevelTwo: ' + levelTwo);
		System.debug('***Dicitonary Product Id ' + dictionaryProductId);
		if(!String.isBlank(dictionaryProductId)){
			dictionaryProduct = [SELECT Id, Case__c, Local_Product__r.Name, Local_Product__r.Translated_Path__c from Case_Product__c WHERE Id =:dictionaryProductId];
		}
		resetCommentCodeDictionary();
		refreshCodeFilterList();
		return null;
	}

   /*
	* @author: Chris Southworth
	* @date: 06/12/2014
	* @description: Resets the sort field, sort direction, and clears the comment code list.
	* @return: PageReference is returned NULL to stay on page
	*/
	public PageReference resetCommentCodeDictionary(){
		lastSort = 'Level_1__c';
		sortBy = 'Level_1__c';
		sortDirection = 'ASC';
		if(localCodes != null){
			localCodes.clear();
		} else {
			localCodes = new List<Local_Comment_Code__c>();
		}
		return null;
	}
}