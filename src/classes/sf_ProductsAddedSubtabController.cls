/**
* @author: salesforce.com
* @date: 05/08/2014
* @description: page controller for productsadded.page
*/ 

global class sf_ProductsAddedSubtabController {

   /**
    * @author: Chris Southworth
    * @date: 05/08/2014
    * @description: Wrapper class used to hold the Case_Product__c record and it's list of Case_Comment_Codes__c. 
    *   Used as part of a repeat in the VF page sf_ProductSearchConsoleComponent.page to display the records.
    */ 
    public class productComments{
        public Case_Product__c product {get; set;}
        public List<Case_Comment_Code__c> caseCommentCodes {get; set;}
        public List <Local_Comment_Code__c> suggestedComments {get; set;}
        public String productDisplayPath {get; set;}
        public String levelOneFilter {get; set;} //used on vf page for filters
        public String levelTwoFilter {get; set;} //used on vf page for filters
        public String displayName {get; set;} //customer facing name or comma separated translated path (first 3 splits)
        public Integer aaeCount {get; set;} //keep track of Alleged Adverse Events count since we are no longer querying for data everytime
        public Integer pqcCount {get; set;} //keep track of Product Quality Complaint count since we are no longer querying for data everytime
        public productComments(){
            levelOneFilter = '';
            levelTwoFilter = '';
            aaeCount = 0;
            pqcCount = 0;
        }
    }
    
    public List <Case_Product__c> caseProducts {get; set;}
    public List <Case_Comment_Code__c> caseComments {get; set;}
    public String caseId {get; set;}
    public String localProductId {get; set;}  //Case Product Id
    public String local_product_id { get; set;} // local_product_id
    public String commentCodeId {get; set;}
    public Case caseRecord{get; set;}
    public List<productComments> productCommentsList {get; set;}
    public List <Survey__c> surveys {get; set;}
    public List <Local_Comment_Code__c> lccSuggestions {get; set;}
    public String quantitySelected {get; set;}
    public String reasonProvided {get; set;}
    public String userLanguage {get; set;}

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
    public Boolean displayCommentCodeDictionary {get; set;}  
    public String currentSelectedProductId {get;set;}

    //product association popup variables
    public Boolean displayProductAssociationPopup {get; set;}  
    public String productToAssociate {get; set;}  
    public String mstToAssociate {get; set;}

    
    public String caseProductId {get; set;}
    public String lastSavedTime {get; set;} //Keep track of last time saved
    
    //WTB Does country support WTB?
    public boolean wtbCountry{
        get{
            boolean wtbCountry = false;
            String caseCountry = caseRecord.Country__c;
            caseCountry = caseCountry.toUpperCase();
            Country_Region_SMO__c countrySetting = Country_Region_SMO__c.getValues(caseCountry);
            wtbCountry = countrySetting.WTB_Enabled__c;
            return wtbCountry;
        }
        set;
    }

    //ALM 373 keep popup open
    public Boolean shouldCloseProductAssociationPopup {get; set;}

    public sf_ProductsAddedSubtabController(ApexPages.StandardController sc) {
        Product_Search_Configuration__c psc = Product_Search_Configuration__c.getInstance();
        userLanguage = [SELECT Id, Comment_Language__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Comment_Language__c;
        if(String.isBlank(userLanguage)){
            userLanguage = psc.Default_Comment_Language__c;
        }
        
        productCommentsList = new List<productComments>();
        displayCommentCodeDictionary = false;
        shouldCloseProductAssociationPopup = true;
        caseProductIndex = 0;
        quantitySelected = '';
        reasonProvided = '';
        lastSavedTime = '';
        
        caseRecord = [SELECT Id, Brand__c, Country__c, CaseNumber, Language__c, CCM_Initial_Pull__c, Intake_Agent_Request__c, BigData_Locale_Code__c FROM Case WHERE Id = :sc.getId()];
        caseId = caseRecord.Id;
        
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
        
        buildPicklistMaps();
        refreshCaseProducts();
    }

   /**
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
            buildPicklistMaps();
            refreshCaseProducts();
        }
        return NULL;
    }

   /**
    * @author: Oleg Rikkers, Chris Southworth
    * @date: 05/08/2014
    * @param: None
    * @description: Query for Case_Product__c records related to the current case.  Then query for Case_Comment_Code__c 
    *   records related to those products.  Build a map of Case_Products__c and their list of related
    *   Case_Comment_Codes__c and store in the wrapper class productComments which is used to display 
    *   Products/Case Comment Codes on the Product/Case Comment search
    * @return: PageReference is returned NULL to stay on page
    */
    public PageReference refreshCaseProducts () {
        if(productCommentsList != null && productCommentsList.size() > 0){
            for(productComments pc : productCommentsList){
                level1Map.put(pc.product.Id, pc.levelOneFilter);
                level2Map.put(pc.product.Id, pc.levelTwoFilter);
            }
        }
        system.debug(logginglevel.WARN, '**refreshCaseProducts level1 map: '+level1Map); //productCommentsList
        surveys = [SELECT Id FROM Survey__c WHERE Case__c = :caseId];
        
        caseProducts = new List <Case_Product__c> ([SELECT Id
                                                        ,Name
                                                        ,Change_Reason__c 
                                                        ,Changed_By__c
                                                        ,Local_Product__r.Id
                                                        ,Consumer_Facing_Brand__c//WTB
                                                        ,Local_Product__r.Consumer_Facing_Name__c
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
                                                        ,Local_Product__r.Image_Url__c
                                                        ,Local_Product__r.Image_Url_Thumb__c
                                                        ,Local_Product__r.GTIN_Number__c 
                                                        ,Expiration_Date__c
                                                        ,Where_Bought__c
                                                        ,Same_Version__c
                                                        ,Status__c
                                                        ,ProductStatus__c
                                                        ,Production_Code_Verification__c
                                                        ,CCM_Retreival_Request__c
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
                npc.displayName = generateDisplayName(cp);
                
                npc.product = cp;
                npc.caseCommentCodes = new List<Case_Comment_Code__c>();
                npc.suggestedComments = new List <Local_Comment_Code__c> ();
                npc.aaeCount = Integer.valueOf(cp.Number_of_Adverse_Event_Comments__c);
                npc.pqcCount = Integer.valueOf(cp.Number_of_PQC_Comments__c);
                if(level1Map.containsKey(cp.Id)){
                    npc.levelOneFilter = level1Map.get(cp.Id);
                }
                if(level2Map.containsKey(cp.Id)){
                    npc.levelTwoFilter = level2Map.get(cp.Id);
                }
                
                npc.productDisplayPath = generateDisplayPath(cp);

                productCommentsList.add(npc);
            }
            level1Map.clear();
            level2Map.clear();
            
            if(!caseProductIdSet.isEmpty()){
                //Build map of Case_Comment_Code__c records to assign to the correct product in the productCommentsList
                Map<Id, List<Case_Comment_Code__c>> productCommentsMap = new Map<Id, List<Case_Comment_Code__c>>();

                caseComments = new List <Case_Comment_Code__c> ([SELECT Id
                                                                    ,GCC_Level_1__c //ChrisM
                                                                    ,Local_Comment_Code__c
                                                                    ,Local_Comment_Code__r.Name
                                                                    ,Local_Comment_Code__r.Full_Translated_Path__c
                                                                    ,Case_Product__c
                                                                    ,Local_Comment_Code__r.Criticality__c
                                                                    ,Local_Comment_Code__r.Global_Comment_Code_Group__c
                                                                    ,Local_Comment_Code__r.Global_Comment_Code_Language__c
                                                                    ,Local_Comment_Code__r.Level_1__c
                                                                    ,Local_Comment_Code__r.Level_2__c
                                                                    ,Local_Comment_Code__r.Level_3__c
                                                                    ,Quantity_Affected__c
                                                                    ,Status__c
                                                                    ,Change_Reason__c
                                                                    ,Changed_By__c
                                                                    ,Unable_To_Classify_Reason__c 
                                                                    ,Local_Comment_Code__r.Global_Comment_Code__r.Reason_Required__c
                                                                    FROM Case_Comment_Code__c 
                                                                    WHERE Case_Product__c IN :caseProductIdSet
                                                                    ORDER BY Local_Comment_Code__r.Full_Translated_Path__c]);

                Set <Id> localCommentsSet = new Set <Id> ();

                for(Case_Comment_Code__c ccc : caseComments){
                    if(!productCommentsMap.containsKey(ccc.Case_Product__c)){
                        productCommentsMap.put(ccc.Case_Product__c, new List<Case_Comment_Code__c>());
                    }
                    productCommentsMap.get(ccc.Case_Product__c).add(ccc);


                    localCommentsSet.add (ccc.Local_Comment_Code__c);

                } //end for (Case_Comment_Code__c ccc)

                //COMMENT SUGGESTIONS
                for (Case_Comment_Code__c ccc: caseComments) {
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
    	system.debug(logginglevel.WARN, '**refreshCaseProducts productCommentsList: '+productCommentsList); //productCommentsList
        return null;
    }
    
   /**
    * @author: Chris Southworth
    * @date: 09/02/2014
    * @param: cp - The Case_Product__c record to build a display name for.
    * @description: Generates the name to be displayed on the Product/Comment page.  If the Consumer_Facing_Name__c is blank
    *   then we will grab the first 3 parts of the Translated path, and make a comma separated string to show as the name,
    *   otherwise we just use the Consumer_Facing_Name__c.
    * @return: String representing the name of the product to be displayed on the page
    */    
    public String generateDisplayName(Case_Product__c cp){
        String dn = '';
        if(cp.Local_Product__r.Consumer_Facing_Name__c != null 
            && cp.Local_Product__r.Consumer_Facing_Name__c != ''){
            dn = cp.Local_Product__r.Consumer_Facing_Name__c;                   
        } else {
            List<String> split = cp.Local_Product__r.Translated_Path__c.split('/');
            dn = split[0];
            if(split.size() > 1){
                dn += ', ' + split[1];
            }
            if(split.size() > 2){
                dn += ', ' + split[2];
            }
        }
        
        return dn;
    }
    
   /**
    * @author: Chris Southworth
    * @date: 09/02/2014
    * @param: cp - The Case_Product__c record to build the path from.
    * @description: Generates the path as HTML separated by dividers on the Product/Comment page.  The dividerLine class
    *   in the CSS handles displaying the image of the divider.
    * @return: String that holds the HTML to show the translated path with divider lines
    */   
    public String generateDisplayPath(Case_Product__c cp){
        String dp = '';
        List<String> pathSplit = cp.Local_Product__r.Translated_Path__c.split('/');
        if(pathSplit.size() > 0){
            dp = pathSplit[0];
            for(Integer i = 1; i < pathSplit.size(); i++) {
                dp = dp + '<div class="dividerLine"></div>' + pathSplit[i];
            }
        }
        return dp;
    }
    
   /**
    * @author: Chris Southworth
    * @date: 07/15/2014
    * @param: None
    * @description: Query for Case_Product__c record related to the current case and clone the selected product.
    *   localProductId is passed from the VF page and holds the ID of the product to clone.
    *   Related Case_Comment_Code__c records are also cloned.
    * @return: PageReference is returned NULL to stay on page
    */    
  	public PageReference cloneCaseProduct(){
        try {
            if (!String.isEmpty(localProductId)){
                String cpQuery = buildCloneFieldQuery('Case_Product__c', 'id=\'' + localProductId + '\'');
                 Case_Product__c cp = (Case_Product__c) Database.query(cpQuery);
                 if(cp != null){
                    system.debug(logginglevel.WARN, '***CP to clone: '+cp);
                    Case_Product__c cloneProduct = cp.clone(false, true);
                    cloneProduct.Expiration_Date__c = null;
                    cloneProduct.Production_Code__c = null;
                    cloneProduct.Production_Code_Verification__c = null;
                    cloneProduct.Product_available_for_return__c = null;
                    cloneProduct.Where_Bought__c = null;
                    cloneProduct.Same_Version__c = null;
                    cloneProduct.CCM_Task_ID__c = null;
                    cloneProduct.Digital_Return_Id__c = null;
                    system.debug(logginglevel.WARN, '***CP to insert: '+cloneProduct);
                    insert cloneProduct;
                    System.debug(logginglevel.WARN,'***Cloned: Seg: ' + cloneProduct.Local_Product__r.Global_Product__r.Segment__c);
                    System.debug(logginglevel.WARN,'***Cloned: Brand: ' + cloneProduct.Local_Product__r.Global_Product__r.Brand__c);
                    System.debug(logginglevel.WARN,'***Cloned: GPID: ' + cloneProduct.GLOBAL_PRODUCT_ID__c);
                                        
                    productComments pc = new productComments();
                    pc.product = cloneProduct;
                    pc.caseCommentCodes = new List<Case_Comment_Code__c>();
                    pc.suggestedComments = new List<Local_Comment_Code__c>();
                    pc.displayName = generateDisplayName(cp);
                    pc.productDisplayPath = generateDisplayPath(cp);
                    pc.levelOneFilter = null;
                    pc.levelTwoFilter = null;
                    productCommentsList.add(0, pc); 
                                     
                    ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.INFO, pc.displayName + ' has been cloned.'));
                 }
            } else {
                ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, 'Product cannot be null.'));
            }
           
        } catch (Exception e) {
            System.debug(logginglevel.WARN,'***cloneCaseProduct error: '+e+' stack: '+e.getStackTraceString());
            ApexPages.addMessages (e);
        }
        
        //This works with javascript on the page to clear out the filters when a product is deleted or cloned
        for(productComments pcs : productCommentsList){
            pcs.levelOneFilter = null;
            pcs.levelTwoFilter = null;
        }        
        
        return null;
    }
    
   /**
    * @author: Chris Southworth
    * @date: 09/02/2014
    * @param: objectName - Name of the object to be cloned (in our case Case_Product__c)
    * @param: queryClause - String to limit the query to the specific record
    * @description: Builds a list of the fields on the object and returns a string of that query.  Additional Fields are used
    *   for Case_Product__c for use on the Product/Comments.
    * @return: String representing the name of the product to be displayed on the page
    */   
    public static String buildCloneFieldQuery(String objectName, String queryClause){
        String query = '';
        
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<String> fieldList = new List<String>();
        if(fMap != null){
            for(Schema.SObjectField field : fMap.values()){
                Schema.DescribeFieldResult dfr = field.getDescribe();
                if(dfr.isCreateable()){
                    fieldList.add(dfr.getName());
                }
            }
        }
        
        if(!fieldList.isEmpty()){
            for(String s : fieldList){
                query += s + ',';
            }
            if(objectName != 'Case_Product__c'){
                if(query.endsWith(',')){
                    query = query.substring(0, query.lastIndexOf(','));
                }
            } else {
                //Fields not grabbed by the describe, but needed on the page
                query += 'Local_Product__r.Consumer_Facing_Name__c,';
                query += 'Local_Product__r.Translated_Path__c,';
                query += 'Local_Product__r.Id,';
                query += 'Local_Product__r.Name,';
                query += 'Local_Product__r.Global_Product__r.Brand__c,';
                query += 'Local_Product__r.Global_Product__r.Segment__c,';
                query += 'Local_Product__r.Image_Url__c,';
                query += 'Local_Product__r.Image_Url_Thumb__c,';
                query += 'Local_Product__r.GTIN_Number__c,';
                query += 'Global_Product_ID__c';
            }
        }       
        
        return 'SELECT ' + query + ' FROM ' + objectName + ' WHERE ' + queryClause;
    }

   /**
    * @author: Oleg Rikkers
    * @date: 05/08/2014
    * @param: None
    * @description: Query for Case_Product__c records related to the current case and remove the selected product.
    *   localProductId is passed from the VF page and holds the ID of the product to delete.
    *   Related Case_Comment_Code__c records are also removed.
    * @return: PageReference is returned NULL to stay on page
    */
    public PageReference removeCaseProduct () {
        try {
            if (!String.isEmpty(localProductId) 
                && Schema.sObjectType.Case_Product__c.isDeletable()
                && Schema.sObjectType.Case_Comment_Code__c.isDeletable()){

                //Case c = [SELECT Id, CCM_Initial_Pull__c, Active_Products__c FROM Case WHERE Id = :caseRecord.Id];
                Case c = [SELECT Id, CCM_Initial_Pull__c, Active_Products__c, Product_Return_Status__c, Selected_Return_Type__c  FROM Case WHERE Id = :caseRecord.Id];//ChrisM April 2017 DPR cancelled product handling
                
                //7/13/15 sfdc fix for CCM Loop Condition

                //per Greg:  Recommended Correction: Code behind delete button should check only if CCM_INITIAL_PULL is not null and not if there is a comment code when deciding between DELETE vs ‘Cancel’.

                Boolean deletable = c.CCM_Initial_Pull__c == null;

                //Boolean deletable = true;
                //if(c.CCM_Initial_Pull__c != null){
                    
                    //for(Case_Comment_Code__c ccc : [SELECT Id, Is_Deletable__c FROM Case_Comment_Code__c WHERE Case_Product__c = :localProductId]){
                    //  if(ccc.Is_Deletable__c == false){
                    //      deletable = false;
                    //      break;
                    //  }
                    //}
                //}
                
                Case_Product__c cp = [SELECT Id FROM Case_Product__c WHERE Id=:localProductId];
                
                if(deletable){
                    if(cp != null){
                        delete [SELECT Id FROM Case_Comment_Code__c WHERE Case_Product__c=:localProductId];
                        delete cp;
                    }
                    String displayName = productCommentsList[caseProductIndex].displayName;
                    productCommentsList.remove(caseProductIndex);
                    ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.INFO, displayName + ' has been deleted.'));
                } else {
                    cp.ProductStatus__c = 'Cancelled';
                    update cp;
                    String displayName = productCommentsList[caseProductIndex].displayName;
                    productCommentsList[caseProductIndex].product.ProductStatus__c = 'Cancelled';
                    //ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.INFO, displayName + ' has linked AE/PQC Comment Codes and cannot be deleted.'));
                    //alm 1356 - update comments 
                    List <Case_Comment_Code__c> comments = new List <Case_Comment_Code__c> ([SELECT Id FROM Case_Comment_Code__c WHERE Case_Product__c = :cp.Id]);

                    if (!comments.isEmpty()) {
                        for (Case_Comment_Code__c ccc: comments) {
                            ccc.Status__c = 'Cancelled';
                        }
                        update comments;
                    }
                }
                
                //START ChrisM April 2017 DPR - Update Case return fields if/when appropriate
                //Only clear Case if return fields have a value and there is only 1 or less active products
                boolean updateCase = false;
                List<Case_Product__c> cpsRequiringReturn = new List<Case_Product__c>();
				cpsRequiringReturn = [SELECT Name, Consumer_Facing_Brand__c, Product_Path__c, ACR_Info__c, ACR_Return_Type__c, Case__r.Selected_Return_Type__c
                                        FROM Case_Product__c
                                        WHERE Case__c = :caseId 
                                        AND productstatus__c = 'Added'
                                      	AND (Status__c IN :trg_AutoComRuleHelper.physicalProductReturnStatuses OR Status__c IN :trg_AutoComRuleHelper.digitalProductReturnStatuses)
                                        AND ACR_Info__c != null
                                        AND Product_available_for_return__c = 'Yes - Product is Available'];
				
                system.debug(logginglevel.WARN, '!!! Cancelling CP, Case CPs requiring return: '+cpsRequiringReturn);
                //if(String.isNotBlank(c.Product_Return_Status__c) && String.isNotBlank(c.Selected_Return_Type__c) && c.Active_Products__c < 2){
                /*
                Other CP check:
					is available for return and has an ACR
					not in return process.
				*/
                if(String.isNotBlank(c.Product_Return_Status__c) && String.isNotBlank(c.Selected_Return_Type__c) && cpsRequiringReturn.size() == 0){
                    c.Product_Return_Status__c = '';
                    c.Selected_Return_Type__c = '';
                    updateCase = True;
                }
                //FIN ChrisM April 2017 DPR - Update Case return fields if/when appropriate

                //CDOY WR304 - This code whas changed to incorporate the segment update to the case. After a case product has been removed 
                //             the code will look to update the case with the product that was added after the product that has just been removed.
                if (c.Active_Products__c > 1) {
                    List <Case_Product__c> activeProds = new List <Case_Product__c> ([SELECT Id, Local_Product__r.Translated_Path__c, Local_Product__r.Global_Product__r.segment__C FROM Case_Product__c WHERE Case__c = :c.Id 
                                                                                        AND ProductStatus__c != 'Cancelled'
                                                                                        AND Local_Product__r.Translated_Path__c != null]);

                    if (!activeProds.isEmpty()) {
                        c.Brand__c = activeProds[0].Local_Product__r.Translated_Path__c.split('/')[0];
                        c.segment__c = activeProds[0].Local_Product__r.Global_Product__r.Segment__c;
                        
                        //update c; //ChrisM April 2017 DPR
                        updateCase = True;
                    }
                }

                //ChrisM April 2017 DPR update case only if required
                if(updateCase){
                    update c;
                }
              
            } else {
                String errorMessage = String.isEmpty(localProductId) ? 'Product cannot be null.' : Label.You_do_not_have_permission_to_delete_case_product;
                ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, errorMessage));
            }
           
        } catch (Exception e) {
            System.debug(e);
            ApexPages.addMessages (e);
        }
        
        //This works with javascript on the page to clear out the filters when a product is deleted or cloned
        for(productComments pcs : productCommentsList){
            pcs.levelOneFilter = null;
            pcs.levelTwoFilter = null;
        }
        
        //WR104 - regenerate productCommentsList so if user clicks save current values are used instead of in memory values
        refreshCaseProducts();

        return null;
    }
    
   /**
    * @author: Chris Southworth
    * @date: 05/08/2014
    * @param: None
    * @description: Query for Case_Comment_Code__c records related to the current case and remove the selected record.
    *   commentCodeId is passed from the VF page and holds the ID of the case comment code to delete.
    * @return: PageReference is returned NULL to stay on page
    */
    public PageReference removeCommentCode(){
        try{
            if(!String.isEmpty(commentCodeId) && !String.isEmpty(caseProductId) && Schema.sObjectType.Case_Comment_Code__c.isDeletable()){
                //DPR
                List<Case_Product__c> cpsToUpdate = new List<Case_Product__c>();//TODO: Probably don't need this not updating more than 1. Case Products that require udpating, may be 0,1 or many
                Set<String> returnStatuses = new Set<String>();
                returnStatuses.addAll(trg_AutoComRuleHelper.physicalProductReturnStatuses);
                returnStatuses.addAll(trg_AutoComRuleHelper.digitalProductReturnStatuses);
                //DPR

                Case c = [SELECT Id, CCM_Initial_Pull__c, Active_Products__c, Product_Return_Status__c, Selected_Return_Type__c FROM Case WHERE Id = :caseRecord.Id];
                Boolean deletable = true;
                Case_Comment_Code__c commentCode = [SELECT Id, Is_Deletable__c, ACR_Info__c, Case_Product__c FROM Case_Comment_Code__c WHERE Id = :commentCodeId];
				Case_Product__c cp = [SELECT Id, Number_of_Adverse_Event_Comments__c, Number_of_PQC_Comments__c, Consumer_Facing_Brand__c, ACR_Info__c, ACR_Return_Type__c, Status__c
                                        FROM Case_Product__c WHERE Id = :commentCode.Case_Product__c];
                
                if(c.CCM_Initial_Pull__c != null){
                    if(commentCode.Is_Deletable__c == false){
                        deletable = false;
                    }
                }
                
                if(deletable){
                    delete commentCode;
                    
                    Integer cccIndex = 0;
                    for(Case_Comment_Code__c ccc : productCommentsList[caseProductIndex].caseCommentCodes){
                        if(ccc.Id == commentCodeId){
                            productCommentsList[caseProductIndex].caseCommentCodes.remove(cccIndex);
                            break;
                        }
                        cccIndex++;
                    }

                    productCommentsList[caseProductIndex].aaeCount = Integer.valueOf(cp.Number_of_Adverse_Event_Comments__c);
                    productCommentsList[caseProductIndex].pqcCount = Integer.valueOf(cp.Number_of_PQC_Comments__c);
                } else {
                    Integer cccIndex = 0;
                    for(Case_Comment_Code__c ccc : productCommentsList[caseProductIndex].caseCommentCodes){
                        if(ccc.Id == commentCodeId){
                            productCommentsList[caseProductIndex].caseCommentCodes[cccIndex].Status__c = 'Cancelled';
                            break;
                        }
                        cccIndex++;
                    }
                    commentCode.Status__c = 'Cancelled';
                    update commentCode;
                }
                
                //START DPR Case Comment Remove logic
                //If cp.ACR_Info__c is blank no previous match found, therefore fields are already null, no further processing required
                if(String.isNotBlank(cp.ACR_Info__c)){
                    //Are there other CC records with ACR_Info__c?
                    List<Case_Comment_Code__c> ccList = new List<Case_Comment_Code__c>([SELECT Id, ACR_Info__c FROM Case_Comment_Code__c WHERE Case_Product__c = :cp.Id AND ACR_Info__c !='' AND ACR_Info__c != :getProductReturnACR.NO_MATCH AND Status__c != 'Cancelled' ORDER BY CreatedDate]);
                    system.debug(LoggingLevel.WARN, '*** the ccList: '+ccList);

                    if(ccList.isEmpty()){
                        cp.ACR_Info__c = '';
                        cp.ACR_Return_Type__c = '';
                        if(returnStatuses.contains(cp.Status__c)){
                            cp.Status__c = '';
                        }
                        cpsToUpdate.add(cp);
                        //update cp;
                    }
                    else{
                        //update CP with oldest CC values
                        //only update if ACR Info doesn't match
                        system.debug(LoggingLevel.WARN, 'ccList'+ccList);
						if(cp.ACR_Info__c != ccList[0].ACR_Info__c){
                            cp.ACR_Info__c = ccList[0].ACR_Info__c;
                            Auto_Communication_Rule__c acr = [SELECT Id, Supported_Return_Type__c FROM Auto_Communication_Rule__c WHERE Name = :ccList[0].ACR_Info__c];
                            system.debug(LoggingLevel.WARN, '*** the acr: '+acr);
                            cp.ACR_Return_Type__c = String.isBlank(acr.Supported_Return_Type__c) ? 'Physical' : acr.Supported_Return_Type__c; //Historical support, won't have return type 
                            if(returnStatuses.contains(cp.Status__c)){
                                cp.Status__c = '';
                            }
                            cpsToUpdate.add(cp);
                            //update cp;
                        }
                        system.debug(LoggingLevel.WARN,'cp.ACR_Info__c = '+cp.ACR_Info__c+ ' ccList[0].ACR_Info__c = '+ccList[0].ACR_Info__c);
                    }

                    //Is CP.Status__c in trg_AutoComRuleHelper.physicalProductReturnStatuses OR trg_AutoComRuleHelper.digitalProductReturnStatuses, clear cp.Status__c
                    //Always do this
                    /*if(returnStatuses.contains(cp.Status__c)){
                        cp.Status__c = '';
                    }*/

                    update cpsToUpdate;
                    //Are there other CPs in return process? 
                    boolean clearCaseACR = True;
                    if(c.Active_Products__c > 1){
                        //TODO: Needs for loop? Can be done in query alone?
                        
                        for(Case_Product__c caseCP : [SELECT Id, Status__c FROM Case_Product__c WHERE Case__c = : c.Id AND productstatus__c != 'Cancelled' AND Id != :cp.Id]){
                            if(returnStatuses.contains(caseCP.Status__c)){
                                clearCaseACR =  false;
                                break;//As long as one other CP is in progress we do NOT update the Case
                            }
                        }

                    }//More than 1 active CP if
                    
                    //No set Case.Product_Return_Status__c to null
                    system.debug(LoggingLevel.WARN, '*** case: '+c);
                    if(clearCaseACR && String.isNotBlank(c.Product_Return_Status__c) && String.isNotBlank(c.Selected_Return_Type__c)){
                        c.Product_Return_Status__c = '';
                        c.Selected_Return_Type__c = '';
                        update c;
                    }//Clear case if
                    
                }
                //FIN DPR Case Comment Remove logic 
                
            } else {
                String errorMessage = String.isEmpty(commentCodeId) || String.isEmpty(caseProductId) ? 'Comment Code Id and Product Id cannot be null.' : Label.You_do_not_have_permission_to_delete_comment_code;
                ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, errorMessage));
            }
        } catch(Exception e){
            System.debug(e);
            System.enqueueJob(new exceptionHelperQueable(e,'Error on Remove Case Comment Code. *Case CommentId: '+commentCodeId+' *Case Product Id'+caseProductId));
            ApexPages.addMessages (e);
        }
        
        return NULL;
    }
        
   /**
    * @author: Chris Southworth
    * @date: 05/08/2014
    * @param: gPId - Used to locate product specific comment codes
    * @param: term - The search term passed from the jquery autocomplete search in the VF page
    * @param: country - The country listed on the related Case record, or selected from the drop down on the VF page
    * @param: language - The language listed on the related Case record, needed for filtering results
    * @param: levelOneFilter = the value of the first picklist on the vf page.  Contains Level_1__c values.
    * @param: levelOneFilter = the value of the second picklist on the vf page.  Contains Level_2__c values, based on Level_1__c.
    * @description: Search for Local_Comment_Code__c records that match or partially match the search term provided from
    *   the user on the sf_ProductSearchConsoleComponent.page.  Results are filtered by language, and any picklist filters selected
    *   on the vf page.  
    * @return: searchList[0] - List of Local_Comment_Code__c records found from the SOSL query
    */ 
    @RemoteAction
    global static List <Local_Comment_Code__c> doCaseCommentSoslSearch(String gpId, String gpBrand, String gpSegment, String term, String country, String language, String levelOneFilter, String levelTwoFilter){
        term = String.escapeSingleQuotes(term) + '*';
        List<Local_Comment_Code__c> codesList = new List<Local_Comment_Code__c>();
        if(!String.isEmpty(gpId)){
            Set<String> gcc = new Set<String>();
            String gccStringSet = '';
            for(Product_Comment_Code__c pcc : [SELECT Id, Global_Comment_Code__c FROM Product_Comment_Code__c
                                            WHERE Global_Product_Segment__c = :gpSegment
                                            AND Global_Product_Brand__c = :gpBrand AND Inactive__c = false]){ 
                if(gcc.add(pcc.Global_Comment_Code__c)){
                    String pccGId = '\'' + pcc.Global_Comment_Code__c + '\'';
                    gccStringSet += (gccStringSet.length() == 0 ? '' : ',') + pccGId;
                }
            }

            if(!gcc.isEmpty()){
                String commentQuery = 'FIND \'' + term;
                commentQuery += '\' IN ALL FIELDS RETURNING Local_Comment_Code__c (Id, Criticality__c, Full_Translated_Path__c, Name, Description__c, Level_1__c, Level_2__c, Level_3__c, Global_Comment_Code__r.Reason_Required__c ';
                
                if(!String.isEmpty(language)){
                    commentQuery += ' WHERE Translated_Language__c = \'' + language + '\' AND ';
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
                
                System.debug(logginglevel.WARN,'***StringQuery: ' + commentQuery);
                List<List<SObject>> searchList = search.query(commentQuery);
                

                //07/30/15 sfdc
                //Unable to Classify-The business would like for it to not display always in the Search. 
                // We have it loaded as a Product Quality Complaint so if they filter and browse it does not show.  
                //However, it does show when they enter something in the search box.  The request is to have it searchable like all other comments.
                
                if(searchList[0].size() > 0){
                    codesList = searchList[0];
                }
                //Integer utcIndex = -1;
                //if(searchList[0].size() > 0){
                //  codesList = searchList[0];
                //  for(Integer i = 0; i < codesList.size(); i++){
                //      if(codesList[i].Global_Comment_Code__r.Reason_Required__c){
                //          utcIndex = i;
                //      }
                //  }
                //}
                //if(utcIndex >= 0){
                //  Local_Comment_Code__c utcLCC = codesList.remove(utcIndex);
                //  codesList.add(utcLcc);
                //} else {
                //  List<Local_Comment_Code__c> utcLCC = [SELECT Id, Criticality__c, Full_Translated_Path__c, Name, Description__c, 
                //      Level_1__c, Level_2__c, Level_3__c, Global_Comment_Code__r.Reason_Required__c FROM 
                //      Local_Comment_Code__c WHERE Global_Comment_Code__r.Reason_Required__c = true AND Inactive__c = false
                //      AND Translated_Language__c LIKE :(language + '%') LIMIT 1];
                //  if(utcLCC.size() > 0){
                //      codesList.add(utcLCC[0]);
                //  }
                //}
            }
        }

        return codesList;
    }
    
   /**
    * @author: Chris Southworth
    * @date: 05/08/2014
    * @param: caseId - The Id of the case record to add the Case_Comment_Code__c record.
    * @param: localCommentCodeId - The Id of the Local_Comment_Code__c record.
    * @param: productId - The Id of the Case_Product__c record.
    * @description: Create a new Case_Comment_Code__c record for the provided caseId, and create a lookup to the provided
    *   Local_Comment_Code__c Id and Case_Product__c Id.
    * @return: None.
    */ 

    //orikkers need to return an object rather than a string in the addcomment call so that we can have case comment code id and more if needed
    global class CommentAddedInfo {
        public String mstId {get; set;}
        public String cccId {get; set;}
    }

    @RemoteAction
    global static CommentAddedInfo addCaseCommentCode(String caseId, String localCommentCodeId, String productId){
        if(!String.isEmpty(localCommentCodeId) && !String.isEmpty(productId)){

            Case_Comment_Code__c newCCC = new Case_Comment_Code__c();
            newCCC.Case__c = caseId;
            newCCC.Local_Comment_Code__c = localCommentCodeId;
            newCCC.Case_Product__c = productId;
            newCCC.Quantity_Affected__c = 1;
            newCCC.Change_Reason__c = 'Initial Value';
            insert newCCC;
            
            if(newCCC.Id != null){
                CommentAddedInfo info =new CommentAddedInfo ();
                info.mstId = createCommentCodeSurvey(newCCC.Id);
                info.cccId = newCCC.Id;
                return info;
            }           
            
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Product Id and Local Comment Code Id cannot be null'));
        }

        return null;
    }
    
   /**
    * @author: Chris Southworth
    * @date: 09/02/2014
    * @param: None
    * @description: Checks for new Case_Comment_Code__c that are not in the list for a specified caseProductId (sent from VF)
    *   If new Case_Comment_Code__c records are found, adds them to the list for that Case_Product__c and sorts the list by
    *   Full_Translated_Path__c.  Also updates the count of AAE and PQC records.
    * @return: PageReference is returned NULL to stay on page
    */
    public PageReference updateCaseCommentList(){
        if(!String.isEmpty(caseProductId)){
           Map <String, Case_Comment_Code__c> savedMap = new Map <String, Case_Comment_Code__c>([SELECT Id
                                                                                        ,Local_Comment_Code__c
                                                                                        ,Local_Comment_Code__r.Name
                                                                                        ,Local_Comment_Code__r.Full_Translated_Path__c
                                                                                        ,Case_Product__c
                                                                                        ,Local_Comment_Code__r.Criticality__c
                                                                                        ,Local_Comment_Code__r.Global_Comment_Code_Group__c
                                                                                        ,Local_Comment_Code__r.Global_Comment_Code_Language__c
                                                                                        ,Local_Comment_Code__r.Level_1__c
                                                                                        ,Local_Comment_Code__r.Level_2__c
                                                                                        ,Local_Comment_Code__r.Level_3__c
                                                                                        ,Quantity_Affected__c
                                                                                        ,Status__c
                                                                                        ,Change_Reason__c
                                                                                        ,Changed_By__c
                                                                                        ,Unable_To_Classify_Reason__c
                                                                                        ,Local_Comment_Code__r.Global_Comment_Code__r.Reason_Required__c
                                                                                        ,Case_Product__r.Number_of_Adverse_Event_Comments__c
                                                                                        ,Case_Product__r.Number_of_PQC_Comments__c
                                                                                    FROM Case_Comment_Code__c 
                                                                                    WHERE Case_Product__c = :caseProductId]);
            
            if(!savedMap.isEmpty()){
                Integer cpIndex = 0;
                for(productComments pc : productCommentsList){
                    if(pc.product.Id == caseProductId){
                        break;
                    }
                    cpIndex++;
                }
                
                Set<String> existingIds = new Set<String>();
                for(Case_Comment_Code__c ccc : productCommentsList[cpIndex].caseCommentCodes){
                    existingIds.add(ccc.Id);
                }
                

                Boolean newCCCs = false;
                for(Case_Comment_Code__c ccc : savedMap.values()){
                    if(!existingIds.contains(ccc.Id)){
                        productCommentsList[cpIndex].caseCommentCodes.add(ccc);
                        productCommentsList[cpIndex].aaeCount = Integer.valueOf(ccc.Case_Product__r.Number_of_Adverse_Event_Comments__c);
                        productCommentsList[cpIndex].pqcCount = Integer.valueOf(ccc.Case_Product__r.Number_of_PQC_Comments__c);
                        newCCCs = true;
                    }
                }
                
                if(newCCCs){
                    productCommentsList[cpIndex].caseCommentCodes = sortCommentCodesList(productCommentsList[cpIndex].caseCommentCodes);
                }
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Product Id cannot be null'));
        }
        return null;
    }
    
   /**
    * @author: Chris Southworth
    * @date: 09/02/2014
    * @param: cccList - List of Case_Comment_Code__c records to be sorted by Full_Translated_Path__c
    * @description: return a sorted version of the list provided
    * @return: returnList - List of Case_Comment_Code__c records sorted by Full_Translated_Path__c
    */
    public static List<Case_Comment_Code__c> sortCommentCodesList(List<Case_Comment_Code__c> cccList){
        List <Case_Comment_Code__c> returnList = new List <Case_Comment_Code__c>();
        
        Map <String, List <Case_Comment_Code__c>> cccMap = new Map <String, List <Case_Comment_Code__c>>();
        
        for(Case_Comment_Code__c ccc: cccList){
            if(!cccMap.containsKey(ccc.Local_Comment_Code__r.Full_Translated_Path__c)){
                cccMap.put(ccc.Local_Comment_Code__r.Full_Translated_Path__c, new List<Case_Comment_Code__c>());
            }
            cccMap.get(ccc.Local_Comment_Code__r.Full_Translated_Path__c).add(ccc);
        }
        
        List <String> keys = new List <String>(cccMap.keySet());
        keys.sort();
        
        for(String k : keys){
            returnList.addAll(cccMap.get(k));
        }

        return returnList;
    }
    
   /**
    * @author: Chris Southworth
    * @date: 09/02/2014
    * 
    * @description: Saves product and comment code changes.
    * @return: None.
    */ 
    public PageReference saveProductCommentChanges(){
        try{

            List<Case_Product__c> updateProducts = new List<Case_Product__c>();
            List<Case_Comment_Code__c> updateComments = new List<Case_Comment_Code__c>();
            
            for(productComments pc : productCommentsList){
                if(pc.product != null){
                    updateProducts.add(pc.product);
                }
                if(!pc.caseCommentCodes.isEmpty()){
                    updateComments.addAll(pc.caseCommentCodes);
                }
            }
            
            upsert updateProducts;
            upsert updateComments;
            
            //need to get the list again 
            refreshCaseProducts();

            DateTime lastSaved = System.now();
            TimeZone tz = UserInfo.getTimeZone();
            //lastSaved = lastSaved.AddSeconds(tz.getOffset(lastSaved)/1000);
            lastSavedTime = lastSaved.format('h:mm:ss a');

        } catch (Exception e){
            ApexPages.addMessages (e);
        }
        return null;
    }

   /**
    * @author: Oleg Rikkers, Chris Southworth
    * @date: 07/28/2014
    * @param: cccId - The Id of a Case_Comment_Code__c that has been added to a case.
    * @description: Creates Survey__c/Safety_Assessment_Survey__c/Survey_Comment_Product__c based on if an 
    *   Metadata_Survey_Trigger__c is found that matches the Case_Comment_Code__c fields for the provided Id.
    *
    * @return: MST Id to associate product to if any.
    */  
    public static String createCommentCodeSurvey(Id cccId){
        try{
            Case_Comment_Code__c ccc = [SELECT Id, Case_Direction__c, Case_Contact_Method__c, Product_Country__c,
                Comment_Language__c, Global_Product_Segment__c, Product_Brand__c, GCC_Level_1__c, GCC_Level_2__c, GCC_Level_3__c,
                Global_Product_Path__c, Global_Comment_Path__c, Comment_Code_Path__c, Case__c, Case_Product__c, Case_Contact_Id__c
                FROM Case_Comment_Code__c WHERE Id = :cccId LIMIT 1];
                
            String q = '';
            String likeDirection = '%' + ccc.Case_Direction__c + '%';
            String likeContactMethod =  '%' + ccc.Case_Contact_Method__c + '%';
            String likeCountry =  '%' + ccc.Product_Country__c + '%';
            String likeLanguage =  '%' + ccc.Comment_Language__c + '%';
            String likeSegment =  '%' + ccc.Global_Product_Segment__c + '%';
            String likeBrand =  '%' + ccc.Product_Brand__c + '%';
            String likeL1 =  '%' + sf_OverrideMSTNewEditExt.JOIN_DELIMITER + ccc.GCC_Level_1__c + sf_OverrideMSTNewEditExt.JOIN_DELIMITER + '%';
            String likeL2 =  '%' + sf_OverrideMSTNewEditExt.JOIN_DELIMITER + ccc.GCC_Level_2__c + sf_OverrideMSTNewEditExt.JOIN_DELIMITER + '%';
            String likeL3 =  '%' + sf_OverrideMSTNewEditExt.JOIN_DELIMITER + ccc.GCC_Level_3__c + sf_OverrideMSTNewEditExt.JOIN_DELIMITER + '%';

            //these will match beginning of the string to the end if the element is f
            String likeL11 =  ccc.GCC_Level_1__c + sf_OverrideMSTNewEditExt.JOIN_DELIMITER + '%';
            String likeL22 =  ccc.GCC_Level_2__c + sf_OverrideMSTNewEditExt.JOIN_DELIMITER + '%';
            String likeL33 =  ccc.GCC_Level_3__c + sf_OverrideMSTNewEditExt.JOIN_DELIMITER + '%';


            q += 'SELECT Id, Name, Comment_Code_Path__c, Survey_Object__c, Type__c, Segment__c FROM Metadata_Survey_Trigger__c ';
            q += ' WHERE (Direction__c LIKE :likeDirection OR Direction__c = \'*|\')';
            q += 'AND (Contact_Method__c LIKE :likeContactMethod OR Contact_Method__c = \'*|\')';
            
            q += ' AND (';

            //level trigger type
            q += ' (Trigger_Type__c = \'Level\' ';
                q += ' AND ( ';
           
                q += ' (Country__c LIKE :likeCountry OR Country__c = \'*|\')';
                q += ' AND ';
                q += ' (Language__c LIKE :likeLanguage OR Language__c = \'*|\')';
                
                //Removing from the query so that we can use long text fields to accomodate more segments. 
                //We will loop through the records later to match on segment
                //q += ' AND ';
                //q += ' (Segment__c LIKE :likeSegment OR Segment__c = \'*|\')';
                
                q += ' AND ';
                q += ' (Brand__c LIKE :likeBrand OR Brand__c = \'*|\')';
                q += ' AND ';
                q += ' (Comment_Code_L1__c LIKE :likeL11 OR Comment_Code_L1__c LIKE :likeL1 OR Comment_Code_L1__c = \'*|\')';
         
                q += ' AND ';
                q += ' (Comment_Code_L2__c LIKE :likeL22 OR Comment_Code_L2__c LIKE :likeL2 OR Comment_Code_L2__c = \'*|\')';
                
                q += ' AND ';
                q += ' (Comment_Code_L3__c LIKE :likeL33 OR Comment_Code_L3__c LIKE :likeL3 OR Comment_Code_L3__c = \'*|\')';
                

                q += ' ) '; // end level type

            q += ') OR (';

            //path level
            q += ' Trigger_Type__c = \'Path\' AND (';
            
            //ChrisM
            q += ' (Country__c LIKE :likeCountry OR Country__c = \'*|\') AND';

            List <String> productPathList = new List <String> ();
            
            if (ccc.Global_Product_Path__c != null) productPathList = ccc.Global_Product_Path__c.split('/');
            
            //ChrisM Debug start:
            system.debug('>>> CCC product path: '+ccc.Global_Product_Path__c);
            system.debug('>>> productPathList: '+productPathList);
            //ChrisM Debug fin:

            Integer i = 0;
            
            q += '(';
            String prodPath = '';
            for (String s: productPathList) {
                
                if (i==0) {
                    prodPath += s;
                } else {
                    prodPath += '/' + s;
                }

                if (i+1 != productPathList.size()) {
                    q += ' Product_Path__c =  \'' + String.escapeSingleQuotes(prodPath) + '\' OR ';
                } else {
                    q += ' Product_Path__c =  \'' + String.escapeSingleQuotes(prodPath) + '\'';
                }
                
                i++;
            }
            
            q+= ') ';

            List <String> commentCodePathList = new List <String> ();
            
            //ChrisM changing to local
            /*if (ccc.Global_Comment_Path__c != null){
                commentCodePathList = ccc.Global_Comment_Path__c.split('/'); 
            }*/ 
            if(ccc.Comment_Code_Path__c != null){
                commentCodePathList = ccc.Comment_Code_Path__c.split('/');
            }
            
            Integer n = 0;
            
            q+= ' AND (';
            String comPath = '';
            for (String s: commentCodePathList) {
                
                if (n==0) {
                    comPath += s;
                } else {
                    comPath += '/' + s;
                }

                if (n+1 != commentCodePathList.size()) {
                    q += ' Comment_Code_Path__c =  \'' + comPath + '\' OR ';
                } else {
                    q += ' Comment_Code_Path__c =  \'' + comPath + '\' )';
                }
                
                n++;
            }
            
            q += ')'; // end level

            q += '))'; //end path or level

            q += ' AND Active__c = true';
            q += ' AND (Expiration_Date__c >= TODAY OR Expiration_Date__c = null)';
            
            System.debug(LoggingLevel.INFO, '####### MST query = \n ' + q);

            List <Metadata_Survey_Trigger__c> mstList = new List <Metadata_Survey_Trigger__c>();
            try {
                mstList = Database.query(q);
                System.debug(LoggingLevel.INFO, '####### MST query records returned \n ' + mstList);


   
            } catch (Exception e) {
                System.debug('####### MST EXCEPTION: \n ' + e.getStackTraceString() + '-' + e.getLineNumber() + ' - ' + e.getTypeName());
            }
            
            system.debug('>>> mstList size Pre Segment check: '+mstList.size());

            if (!mstList.isEmpty()) {
                List <Metadata_Survey_Trigger__c> tempMstList = new List <Metadata_Survey_Trigger__c> ();
                
                for (Integer j=0; j<mstList.size(); j++) {
                    system.debug('>>> for loop iteration: '+j+' mstList: '+mstList[j]);

            /* WR96 christopher.macduff@accenture.com
             */ 
                    if(mstList[j].Segment__c != null && mstList[j].Segment__c.contains(ccc.Global_Product_Segment__c) || mstList[j].Segment__c == '*|'){
                        tempMstList.add(mstList[j]);
                    }
                    //START: ChrisM update
                    else if(mstList[j].Comment_Code_Path__c != null && ccc.Comment_Code_Path__c.contains(mstList[j].Comment_Code_Path__c)){ 
                        tempMstList.add(mstList[j]);
                    }
                    //FIN: ChrisM update
                }
                
                mstList = tempMstList;
            }
            
            if (!mstList.isEmpty()) {

                //ALM 763 reset survey__c relate to the case
                Set <Id> mstIdsForSurveys = new Set <Id> ();

                // list of new surveys to insert
                List <SObject> surveysToInsert = new List <SObject> ();
                List <MST_Action_Count__c> mstAction = new List <MST_Action_Count__c> ();
                
                Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
                for (Metadata_Survey_Trigger__c mst: mstList) {
                    
                    if (globalDescribe.get(mst.Survey_Object__c) != null) {
                        sObject sObj = globalDescribe.get(mst.Survey_Object__c).newSObject();
                      
                        sObj.put ('Case__c', ccc.Case__c);
                        sObj.put ('Metadata_Survey_Trigger__c', mst.Id);
                            
                        if (mst.Survey_Object__c == 'Survey__c') {
                            mstIdsForSurveys.add(mst.Id);
                            sObj.put ('Survey_Type__c', mst.Type__c);
                            sObj.put ('Case_Product__c', ccc.Case_Product__c);
                            sObj.put ('Case_Comment_Code__c', ccc.Id);
                        }
                        
                        System.debug('***SOBJ - before insert: ' + sObj);
                        surveysToInsert.add (sObj);                        
                    } 
                }
                
                /*
                check for surveys 
                */

                List <Safety_Assessment_Survey__c> existingSASList = new List <Safety_Assessment_Survey__c> ();
                existingSASList = [SELECT Id, Metadata_Survey_Trigger__c 
                                    FROM Safety_Assessment_Survey__c 
                                    WHERE Case__c = :ccc.Case__c 
                                    AND Metadata_Survey_Trigger__c IN :mstList
                                    ORDER BY CreatedDate DESC];
                System.debug(LoggingLevel.INFO, 'existingSASList - ' + existingSASList);
                if (existingSASList.isEmpty ()) {
                    insert surveysToInsert;

                    //alm 763 - yes, I know, but this is better than other options
                    List <Survey__c> probingQuestionsToReset = new List <Survey__c> ([SELECT Id FROM Survey__c WHERE Metadata_Survey_Trigger__c IN :mstIdsForSurveys AND Case__c = :ccc.Case__c]);
                    
                    if (!probingQuestionsToReset.isEmpty()) {
                        for (Survey__c sur: probingQuestionsToReset) {
                            sur.Status__c = 'Incomplete';
                        }

                        update probingQuestionsToReset;
                    }

                    List <Survey_Comment_Product__c> scpList = new List<Survey_Comment_Product__c> ();
                    for(SObject sti : surveysToInsert){
                        if(sti.getSObjectType().getDescribe().getName() == 'Safety_Assessment_Survey__c'){
                            Survey_Comment_Product__c scp = new Survey_Comment_Product__c ();
                            scp.Case_Product__c = ccc.Case_Product__c;
                            scp.Safety_Assessment_Survey__c = sti.Id;
                            scp.Case_Comment_Code__c = ccc.Id;
                            scpList.add(scp);
                        }
                    }
                    if(!scpList.isEmpty()){
                        insert scpList;
                    }
            
                    for (SObject so: surveysToInsert) {
                        Id mstId = (Id) so.get('Metadata_Survey_Trigger__c');
                        mstAction.add (new MST_Action_Count__c (Metadata_Survey_Trigger__c = mstId, Date_Triggered__c = System.now()));
                    }
                    insert mstAction;   
                    return null;

                } else { // we need to open a popup
                    System.debug(LoggingLevel.INFO, 'returning - ' + existingSASList[0].Metadata_Survey_Trigger__c);
                    return existingSASList[0].Metadata_Survey_Trigger__c;
                }
            } else {
                return null;
            } //else list is empty and no action required
            
        } catch(Exception e){
            System.debug('***Survey Error: ' + e);
            return null;
        }
    }

   /**
    * @author: Chris Southworth
    * @date: 08/12/2014
    * @param: caseId - The Id of the current case
    * @description: Query for each of the case products.  The resulting list will be used to build a map in the javascript,
    *   to keep track of the number of the case products added to the Case.  This list will be used to refresh the page
    *   if one of the existing Case_Product__c records are deleted from the case.
    * @return: None
    */ 
    @RemoteAction
    global static List<Case_Product__c> getCaseProducts(String caseId){
        return [SELECT Id FROM Case_Product__c WHERE Case__c = :caseId];
    }
    
    /********************************************
        Comment Code Dictionary Methods below
    *********************************************/
    
   /**
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

        Map<String, Set<String>> filterMap = new Map<String, Set<String>>();
        for(AggregateResult ar : [SELECT Level_1__c level1, Level_2__c level2 FROM Local_Comment_Code__c WHERE Inactive__c = false AND Translated_Language__c = :userLanguage GROUP BY Level_1__c, Level_2__c]){
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

   /**
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

        return oneList;
    }

   /**
    * @author: Chris Southworth
    * @date: 06/12/2014
    * @param: None
    * @description: sorts the comment codes in the comment code dictionary by the selected header value.  If the header value was the last
    *   selected, then the sort direction is changed.  Initial sort direction is ASC, the header toggles if clicked again.
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

   /**
    * @author: Chris Southworth
    * @date: 06/12/2014
    * @param: None
    * @description: Used when the Level 1 filter is changed in the comment code dictionary. The Level 2 filter is reset, and the
    *   table of comment codes is refiltered by the new Level 1 value.
    * @return: PageReference is returned NULL to stay on page
    */
    public PageReference filterByLevel1(){
        levelTwo = '';
        refreshCodeFilterList();
        return null;
    }

   /**
    * @author: Chris Southworth
    * @date: 06/12/2014
    * @param: None
    * @description: Adds the comment code selected from the comment code dictionary to the Case record
    * @return: PageReference is returned NULL to stay on page
    */
    public PageReference addSelectedCommentCode(){
        
        Case_Comment_Code__c ccc = new Case_Comment_Code__c();
        ccc.Case__c = caseId;
        ccc.Local_Comment_Code__c = selectedLocalCommentId;
        ccc.Case_Product__c = dictionaryProductId;
        ccc.Quantity_Affected__c = 1;
        ccc.Change_Reason__c = 'Initial Value';
        insert ccc;
        mstToAssociate = createCommentCodeSurvey(ccc.Id);
        if (mstToAssociate != null) {
            displayProductAssociationPopup = true; 
            currentSelectedProductId = dictionaryProductId;
            lastAddedCommentCode = ccc.id;
        }
        return null;
    }

   /**
    * @author: Chris Southworth
    * @date: 06/12/2014
    * @description: refreshes the comment codes displayed in the comment code dictionary based on the Case.Language__c,
    *   Level 1 and Level 2 filters, and sort field and order.
    * @return: PageReference is returned NULL to stay on page
    */
    public PageReference refreshCodeFilterList(){
        
        String language = userLanguage;

        List<List<SObject>> searchList = new List<List<SObject>>();
        if(!String.isEmpty(globalProductId)){
            Set<String> gcc = new Set<String>();
            String gccStringSet = '';
            Global_Product__c gp = [SELECT Id, Brand__c, Segment__c FROM Global_Product__c WHERE Id =:globalProductId];
            for(Product_Comment_Code__c pcc : [SELECT Id, Global_Comment_Code__c FROM Product_Comment_Code__c
                                            WHERE Global_Product_Segment__c = :gp.Segment__c
                                            AND Global_Product_Brand__c = :gp.Brand__c AND Inactive__c = false]){ 
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

   /**
    * @author: Chris Southworth
    * @date: 06/12/2014
    * @description: Queries for the product that was selected on the search page, and grabs the data to be displayed on the comment
    *   code dictionary.  Calls methods to reset the sort field, sort direction, and clears the comment code list.
    * @return: PageReference is returned NULL to stay on page
    */
    public PageReference openCommentCodeDictionary(){
        displayCommentCodeDictionary = true;
        currentSelectedProductId = dictionaryProductId;
        levelOne = productCommentsList.get(caseProductIndex).levelOneFilter;
        levelTwo = productCommentsList.get(caseProductIndex).levelTwoFilter;
        if(!String.isBlank(dictionaryProductId)){
            dictionaryProduct = [SELECT Id, Case__c, Local_Product__r.Name, Local_Product__r.Translated_Path__c from Case_Product__c WHERE Id =:dictionaryProductId];
        }
        resetCommentCodeDictionary();
        refreshCodeFilterList();
        return null;
    }
    
   /**
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
    
   /**
    * @author: Chris Southworth
    * @date: 07/16/2014
    * @description: Hides the comment code dictionary on the Products/Comment code tab
    * @return: PageReference is returned NULL to stay on page
    */
    public PageReference closeCommentCodeDictionary(){
        displayCommentCodeDictionary = false;
        resetCommentCodeDictionary();
        return null;
    }

   /**
    * @author: Oleg Rikkers
    * @date: 08/16/2014
    * @description: Hides the comment code dictionary on the Products/Comment code tab
    * @return: PageReference is returned NULL to stay on page
    */
    public PageReference openProductAssociationPopup () {
        return null;
    }

    public String sasId {get; set;}

   /**
    * @author: Oleg Rikkers
    * @date: 08/16/2014
    * @description: Returns a list of Safety_Assessment_Survey__c records associated to the specified Metadata_Survey_Trigger__c
    *   and Case.
    * @return: List<Safety_Assessment_Survey__c> - list of surveys associated to the specified MST and Case
    */
    public List <Safety_Assessment_Survey__c> getSasList () {
        return [SELECT Id
                    ,Case__c
                    ,Name
                    ,Metadata_Survey_Trigger__c
                    ,(SELECT Id
                            ,Name
                            ,Case_Product__r.Product_Path__c
                        FROM Survey_Comment_Products__r)
            FROM Safety_Assessment_Survey__c 
            WHERE Metadata_Survey_Trigger__c = :mstToAssociate

            AND Case__c = :caseId];
    }

   /**
    * @author: Oleg Rikkers
    * @date: 08/16/2014
    * @description: Returns fields to display on the product association popup
    * @return: Case_Product__c record
    */
    public Case_Product__c getcurrentProduct () {
        return [SELECT Id, Product_Path__c, Local_Product__r.Image_Url__c, Local_Product__r.Image_Url_Thumb__c,  GTIN_Number__c FROM Case_Product__c WHERE Id = :currentSelectedProductId];
    }

   /**
    * @author: Oleg Rikkers
    * @date: 08/16/2014
    * @description: Associates the product with the given Case_Product__c Id (currentSelectedProductId) to the specified
    *   survey with Id (sasId) both from the VF page.
    * @return: PageReference is returned NULL to stay on page
    */

    public String lastAddedCommentCode {get; set;}
    public PageReference addProductToSAS () {
        Survey_Comment_Product__c scp = new Survey_Comment_Product__c ();
        scp.Safety_Assessment_Survey__c = sasId;
        scp.Case_Product__c = currentSelectedProductId;
        scp.Case_Comment_Code__c = lastAddedCommentCode;
        insert scp;

        displayProductAssociationPopup = !shouldCloseProductAssociationPopup;

        return ApexPages.currentPage();
    }

   /**
    * @author: Oleg Rikkers
    * @date: 08/16/2014
    * @description: Creates a new Safety_Assessment_Survey record linked to the case and associates the product
    * @return: PageReference is returned NULL to stay on page
    */
    public PageReference createNewSAS () {
        Safety_Assessment_Survey__c sas = new Safety_Assessment_Survey__c ();
        sas.Case__c = caseId;
        sas.Metadata_Survey_Trigger__c = mstToAssociate;
        insert sas;
        System.debug('Inserting new SAS ' + sas.Id);
        sasId = sas.Id;
        
        return addProductToSAS();
    }

    public PageReference cancelAssociation () {
        displayProductAssociationPopup = false;
        return ApexPages.currentPage();
    }
}