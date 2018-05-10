global with sharing class sf_ProductSearchConsoleComponentCtrl {
    
   /*
	* @author: Chris Southworth
	* @date: 05/08/2014
	* @description: Wrapper class used to hold the Case_Product__c record and it's list of Case_Comment_Codes__c. 
	*	Used as part of a repeat in the VF page sf_ProductSearchConsoleComponent.page to display the records.
	*/ 
    public class productComments{
		public Case_Product__c product {get; set;}
		public List<Case_Comment_Code__c> caseCommentCodes {get; set;}
		
		public productComments(){}
	}
	
    public List <Case_Product__c> caseProducts {get; set;}
    public String caseId {get; set;}
    public String localProductId {get; set;}
    public String commentCodeId {get; set;}
    public List<productComments> productCommentsList {get; set;}
    
   /*
	* @author: Oleg Rikkers, Chris Southworth
	* @date: 05/08/2014
	* @description: Get the case Id from the standard controller and build productComments list.
	*/ 
    public sf_ProductSearchConsoleComponentCtrl(ApexPages.StandardController sc) {
        caseId = sc.getId();
        refreshCaseProducts();
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
        caseProducts = new List <Case_Product__c> ([SELECT Id
                                                        ,Name
                                                        ,Local_Product__r.Translated_Path__c
                                                        ,Local_Product__r.Name 
                                                    FROM Case_Product__c 
                                                    WHERE Case__c = :caseId
                                                    ORDER BY Local_Product__r.Name LIMIT 1000]);
                                                    
		productCommentsList = new List<productComments>();    	
    	if(!caseProducts.isEmpty()){
    		//Add Case_Products__c to the productCommentsList
			Set<Id> caseProductIdSet = new Set<Id>();
	    	for(Case_Product__c cp : caseProducts){
	        	caseProductIdSet.add(cp.Id);
	    		productComments npc = new productComments();
	    		npc.product = cp;
	    		npc.caseCommentCodes = new List<Case_Comment_Code__c>();
	    		productCommentsList.add(npc);
	    	}
	    	
	    	if(!caseProductIdSet.isEmpty()){
	    		//Build map of Case_Comment_Code__c records to assign to the correct product in the productCommentsList
	    		Map<Id, List<Case_Comment_Code__c>> productCommentsMap = new Map<Id, List<Case_Comment_Code__c>>();
	    		for(Case_Comment_Code__c ccc : [SELECT Id, Local_Comment_Code__r.Name, 
	    												Local_Comment_Code__r.Translated_Path__c, Case_Product__c 
	    												FROM Case_Comment_Code__c WHERE Case_Product__c IN :caseProductIdSet
	    												Order By Local_Comment_Code__r.Translated_Path__c]){
	    			if(!productCommentsMap.containsKey(ccc.Case_Product__c)){
	    				productCommentsMap.put(ccc.Case_Product__c, new List<Case_Comment_Code__c>());
	    			}
	    			productCommentsMap.get(ccc.Case_Product__c).add(ccc);
	    		}
	    		
	    		if(!productCommentsMap.isEmpty()){
	    			//Assign Case_Comment_Code__c list to the product in the productCommentsList
	    			for(productComments pc : productCommentsList){
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
	* @author: Oleg Rikkers
	* @date: 05/08/2014
	* @param: term - The search term passed from the jquery autocomplete search in the VF page
	* @param: country - The country listed on the related Case record, or selected from the drop down on the VF page
	* @description: Search for Local_Product__c records that match or partially match the search term provided from
	*	the user on the sf_ProductSearchConsoleComponent.page.  Results are filtered by selected country.
	* @return: searchList[0] - List of Local_Product__c records found from the SOSL query
	*/
    @RemoteAction
    global static List <Local_Product__c> doSoslSearch (String term, String country) {
        term = String.escapeSingleQuotes(term) + '*';
        String searchquery='FIND \'';
        searchquery += term;
        searchquery += '\' IN ALL FIELDS RETURNING Local_Product__c (Id, Name, Translated_Path__c, Country__c ';
        if (!String.isEmpty(country)) searchquery += ' WHERE Country__c = \''+ country + '\'';
        searchquery += ' ORDER BY Translated_Path__c ASC ';
        searchquery += ') LIMIT 1000'; 

        
        List<List<SObject>> searchList = search.query(searchquery);

        System.debug(searchList);

        return searchList[0];
    }
    
   /*
	* @author: Chris Southworth
	* @date: 05/08/2014
	* @param: term - The search term passed from the jquery autocomplete search in the VF page
	* @param: country - The country listed on the related Case record, or selected from the drop down on the VF page
	* @param: language - The language listed on the related Case record, needed for filtering results
	* @description: Search for Local_Comment_Code__c records that match or partially match the search term provided from
	*	the user on the sf_ProductSearchConsoleComponent.page.  Results are filtered by language.
	* @return: searchList[0] - List of Local_Comment_Code__c records found from the SOSL query
	*/ 
	@RemoteAction
	global static List <Local_Comment_Code__c> doCaseCommentSoslSearch(String term, String country, String language){
		term = String.escapeSingleQuotes(term) + '*';
		String commentQuery = 'FIND \'' + term;
		commentQuery += '\' IN ALL FIELDS RETURNING Local_Comment_Code__c (Id, Translated_Path__c ';
        //if (!String.isEmpty(country)) commentQuery += ' WHERE Country__c = \''+ country + '\'';
		if(!String.isEmpty(language)){
			commentQuery += ' WHERE Translated_Language__c LIKE \'' + language + '%\' AND ';
		} else {
			commentQuery += ' WHERE ';
		}
		commentQuery += ' Inactive__c = false';
		commentQuery += ' ORDER BY Translated_Path__c ASC ';
		commentQuery += ') LIMIT 1000';
		List<List<SObject>> searchList = search.query(commentQuery);
		return searchList[0];
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
			try{
		        Case_Comment_Code__c ccc = new Case_Comment_Code__c();
		        ccc.Case__c = caseId;
		        ccc.Local_Comment_Code__c = localCommentCodeId;
		        ccc.Case_Product__c = productId;
		        insert ccc;
       		} catch(Exception e){
                System.debug(e);
            	ApexPages.addMessages(e);
       		}
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Product Id and Local Comment Code Id cannot be null'));
		}
    }
    
}