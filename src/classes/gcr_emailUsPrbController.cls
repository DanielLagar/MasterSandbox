/*
* @author:       Accenture
* @date:         27/06/2016
* @description:  Controller class for email us report a problem component of gcr widget
* DATE              NAME                CHANGE DESCRIPTION
* 14/12/2016		Accenture			Fetch images for each displayed page in the product list added "gcr_helperClass.getImageUrl()" method call to
* 										searchProducts(), displaySelectedPage(), previous(), next(), firstPage(), lastPage().
* 24/02/2017		Accenture			WR467 - Add field set for dynamic sequence for address fields
*/
public class gcr_emailUsPrbController {
    public GCRChannelContent__c chlContentRec { get; set; }
    public gcr_WidgetHandshake iHandshake { get; set; }
    public Boolean isRightToLeft { get; set; }
    // WR467 FIELD SET LIST TO BE USED
    //public String fieldSetName { public get; private set; }
    
    // PUBLIC VARIABLES FOR THE COMPONENTS
    // VARIABLES FOR gcr_cmpEmailUsProblem COMPONENT
    public String selectedProduct { get; set; }
    public List<SelectOption> lCountry { public get {
        Map<String, String> mCountryPlVal = gcr_helperClass.getAllPicklistValues('GCRChannelContent__c', 'Country__c');
        lCountry = new List<SelectOption>();
		for (String eachVal :mCountryPlVal.keySet()) {
            lCountry.add(new SelectOption(eachVal, mCountryPlVal.get(eachVal)));
        } return lCountry;
    } private set; }

	// SEARCHED PRODUCTS PAGINATION RELATED VARIABLES
    public List<sObject> lProduct { get; set; }
    public String strProdSearch { get; set; }
    public Boolean isMinCharError { get; set; }
    
    private Integer intOffsetVal { get; set; }
    public Integer intCurrentPage { get; set; }
    public Integer intTotalPages { get; private set; }
    public Integer intTotalRecords { get; private set; }
    public List<Integer> lPageNumbers { get; private set; }
    public Boolean isProdLimit { get; private set; }

    public Boolean isSearch { get; set; }
    public Integer selectedProdId  { get; set; }
    public Integer fieldSetCount { get; set; }
    
    /*
     * @author: 		Accenture
	 * @date: 		 	27/06/2016
	 * @description:  	CONSTRUCTOR FOR EMAIL US PROBLEM CONTROLLER
     */
    public gcr_emailUsPrbController() {
        // INITIALIZE VARIABLES ON PAGE LOAD
        intCurrentPage = 1;
        intOffsetVal = 0;
        intTotalPages = 0;
        intTotalRecords = 0;
        isSearch = true;
        isMinCharError = false;
        selectedProdId = 0;
        isProdLimit = false;
        if (lProduct != null && !lProduct.isEmpty()) {
			lProduct.clear();
		}

        fieldSetCount = 0;
    }
    
    /*
     * @author: 		Accenture
	 * @date: 		 	27/06/2016
	 * @description:  	METHOD TO RETRIEVE SELECT OPTIONS FOR REASON FOR WRITING DROPDOWN
     * @param:			none 
     * @return:			List<SelectOption>
     */
    public void actionSelectProduct() {
        if (iHandshake.lCaseProduct.size() < chlContentRec.AddProductLimit__c) {
            Local_Product__c selectedProd = [ SELECT Id
                                                   , Image_Url_Thumb__c
                                             	   , Image_Url__c
                                                   , Consumer_Facing_Name__c 
                                             	   , Global_Product__r.Segment__c
                                              FROM Local_Product__c 
                                              WHERE Id = :selectedProduct ];
            Case_Product__c newCaseProd = new Case_Product__c();
            newCaseProd.Local_Product__c = selectedProd.Id;
            newCaseProd.Search_Term__c = strProdSearch;
            selectedProd.Image_Url__c = gcr_helperClass.getImageUrl((String) selectedProd.get(chlContentRec.ImageField__c)
                                      							  , DAM_Brandstore_Settings__c.getInstance().Brandstore_Image_Token__c
                                      							  , DAM_Brandstore_Settings__c.getInstance().Brandstore_Url__c);
            CaseProductWrapper newSelectedProd 
                = new CaseProductWrapper(selectedProdId, selectedProd.Consumer_Facing_Name__c, selectedProd.Image_Url__c, newCaseProd);
            newSelectedProd.numberProd = '0';
            newSelectedProd.stillHaveProd = '0';
            newSelectedProd.usedBefore = '0';
            iHandshake.mValidationMap.put('stillHave' + String.valueOf(selectedProdId), false);
            iHandshake.mValidationMap.put('prodUse' + String.valueOf(selectedProdId), false);
            iHandshake.mValidationMap.put('expiryDate' + String.valueOf(selectedProdId), false);
            selectedProdId++;
            iHandshake.lCaseProduct.add(newSelectedProd);
            if (String.isEmpty(iHandshake.newCase.Segment__c)) {
            	iHandshake.newCase.Segment__c = selectedProd.Global_Product__r.Segment__c;
            }
            this.clearSearchResults();
            isProdLimit = false;
        } else {
            this.clearSearchResults();
            isProdLimit = true;
        }
    }
    
    public void actionRemoveProduct() {
        for (Integer itr = 0; itr < iHandshake.lCaseProduct.size(); itr++) {
            CaseProductWrapper eachProdWrapper = iHandshake.lCaseProduct.get(itr);
            if(eachProdWrapper.uniqueId == Integer.valueOf(selectedProduct)) {
                iHandshake.lCaseProduct.remove(itr);
				iHandshake.mValidationMap.remove('stillHave' + String.valueOf(eachProdWrapper.uniqueId));
            	iHandshake.mValidationMap.remove('prodUse' + String.valueOf(eachProdWrapper.uniqueId));
                isProdLimit = isProdLimit ? false : isProdLimit;
                break;
            }
        }
    }
    
    // METHOD TO GET DROPDOWN VALUES FOR NUMBER OF PRODUCTS
    public List<SelectOption> getLNumProdOption() {
        List<SelectOption> retVal = new List<SelectOption>();
        if (String.isNotEmpty(chlContentRec.NumberOfProdLabel__c)) {
        	retVal.add(new SelectOption('0', chlContentRec.NumberOfProdLabel__c, true));
        }
        if (chlContentRec.NumberProdCount__c != null) {
        	Integer intIterator = 1;
            while (intIterator < chlContentRec.NumberProdCount__c) {
                retVal.add(new SelectOption(String.valueOf(intIterator), String.valueOf(intIterator)));
                intIterator++;
            }
        }
        return retVal;
    }
    
    // METHOD TO GET DROPDOWN VALUES FOR NUMBER OF PRODUCTS
    public List<SelectOption> getLStillHaveProd() {
        List<SelectOption> retVal = new List<SelectOption>();
        retVal.add(new SelectOption('0', chlContentRec.EmailStillProdLabel__c, true));
        retVal.add(new SelectOption(chlContentRec.PlTranslationYes__c, chlContentRec.PlTranslationYes__c));
        retVal.add(new SelectOption(chlContentRec.PiTranslationNo__c, chlContentRec.PiTranslationNo__c));
        return retVal;
    }
    
    // METHOD TO GET DROPDOWN VALUES FOR NUMBER OF PRODUCTS
    public List<SelectOption> getLProdUsed() {
        List<SelectOption> retVal = new List<SelectOption>();
        retVal.add(new SelectOption('0', chlContentRec.EmailProdUsedLabel__c, true));
        retVal.add(new SelectOption(chlContentRec.PlTranslationYes__c, chlContentRec.PlTranslationYes__c));
        retVal.add(new SelectOption(chlContentRec.PiTranslationNo__c, chlContentRec.PiTranslationNo__c));
        return retVal;
    }

    // TODO: GENERATE (DYNAMIC) QUERY FROM HELPER CLASS
    public void searchProducts() {
        //CDOY WR467 - search langth changed to greater than 1
        if (String.isNotEmpty(strProdSearch) && strProdSearch.length() > 1) {
            isMinCharError = false;
            // RESET CURRENT PAGE AND OFFSET VALUE ON SEARCH
            intCurrentPage = 1;
            intOffsetVal = 0;
            intTotalRecords = 0;
            isSearch = true;
            // GET PAGE SIZE OF PRODUCT SEARCH FROM CONFIGURATION
            Integer intPageSize = GCRGenericProperties__c.getInstance('EMAILUS_PRODUCT_SEARCH_PAGESIZE') != null ?
                Integer.valueOf(GCRGenericProperties__c.getInstance('EMAILUS_PRODUCT_SEARCH_PAGESIZE').value__c) : 5;
            // GET TOTAL RECORDS RETURNED ON SEARCH
            // IF SEARCH STRING IS TEXT SEARCH ALL PRODUCTS ELSE SEARCH PRODUCT GTIN
            List<sObject> lTotalProduct = new List<sObject>();
            try {
                lTotalProduct = gcr_helperClass.getProducts(strProdSearch, chlContentRec.CareHub__r.Country__c, chlContentRec.CareHub__r.Brand__c, chlContentRec.ImageField__c, null, null);
            } catch (Exception caughtException) {
                SYSTEM.DEBUG('CAUGHT EXCEPTION: ' + caughtException.getMessage());
            }
        
            // GET COUNT OF TOTAL RETURNED RECORDS MAXIMIZED TO 2000
            intTotalRecords = lTotalProduct.size();
            lTotalProduct.clear();
            intTotalPages = Math.mod(intTotalRecords, intPageSize) > 0 ? (intTotalRecords/intPageSize) + 1 : intTotalRecords/intPageSize;
            
            try {
            	lProduct = gcr_helperClass.getProducts(strProdSearch, chlContentRec.CareHub__r.Country__c, chlContentRec.CareHub__r.Brand__c, chlContentRec.ImageField__c, intPageSize, intOffsetVal);
                // RETRIEVE IMAGE URLS
                gcr_helperClass.getImageUrl(lProduct, chlContentRec.ImageField__c);
            } catch (Exception caughtException) {
                SYSTEM.DEBUG('CAUGHT EXCEPTION: ' + caughtException.getMessage());
            }
            lPageNumbers = new List<Integer>();
            Integer itr = 1;
            Integer lastPage = intTotalPages < 3 ? intTotalPages : 3;
            // TODO: REMOVE HARDCODING GET THIS SIZE FROM CUSTOM SETTINGS
            while (itr <= lastPage) {
                lPageNumbers.add(itr);
                itr++;
            }
            iHandshake.newCase.Unable_To_Find_Product__c = strProdSearch;
        } else {
            isMinCharError = true;
        }
    }
    
    public void displaySelectedPage() {
		Integer intPageSize = GCRGenericProperties__c.getInstance('EMAILUS_PRODUCT_SEARCH_PAGESIZE') != null ?
            Integer.valueOf(GCRGenericProperties__c.getInstance('EMAILUS_PRODUCT_SEARCH_PAGESIZE').value__c) : 5;
        intOffsetVal = (intPageSize * intCurrentPage) - intPageSize;
        lProduct = gcr_helperClass.getProducts(strProdSearch, chlContentRec.CareHub__r.Country__c, chlContentRec.CareHub__r.Brand__c, chlContentRec.ImageField__c, intPageSize, intOffsetVal);
        // RETRIEVE IMAGE URLS
        gcr_helperClass.getImageUrl(lProduct, chlContentRec.ImageField__c);
        lPageNumbers.clear();
		// TODO: HERE "3" SHOULD REPLACE WITH TOTAL VISIBLE PAGES FROM CONFIGURATION
        Integer itr;
        Integer lastPage;
        if (intTotalPages > 3) {
            if (intCurrentPage + 1 > intTotalPages) {
                itr = intTotalPages - 2;
                lastPage = intTotalPages;
            } else {
                if (intCurrentPage - 1 > 0) {
                	itr = intCurrentPage - 1;
                    lastPage = intCurrentPage + 1;
                } else {
                    itr = 1;
                    lastPage = 3;
                }
            }
        } else {
            itr = 1;
            lastPage = intTotalPages;
        }
        while (itr <= lastPage) {
            lPageNumbers.add(itr);
            itr++;
        }
    }
    
    public void previous() {
        Integer intPageSize = GCRGenericProperties__c.getInstance('EMAILUS_PRODUCT_SEARCH_PAGESIZE') != null ?
            Integer.valueOf(GCRGenericProperties__c.getInstance('EMAILUS_PRODUCT_SEARCH_PAGESIZE').value__c) : 5;
        intOffsetVal = intOffsetVal - intPageSize;
		intCurrentPage--;
        lProduct = gcr_helperClass.getProducts(strProdSearch, chlContentRec.CareHub__r.Country__c, chlContentRec.CareHub__r.Brand__c, chlContentRec.ImageField__c, intPageSize, intOffsetVal);
        // RETRIEVE IMAGE URLS
        gcr_helperClass.getImageUrl(lProduct, chlContentRec.ImageField__c);
        if (intTotalPages > 3) {
        	Integer intFirstPage = lPageNumbers.get(0);
            if (intCurrentPage - intFirstPage < 1 && intFirstPage > 1) {
                lPageNumbers.add(0, intFirstPage - 1);
                lPageNumbers.remove(lPageNumbers.size() - 1);
            }
        }
    }
    
    public void next() {
        Integer intPageSize = GCRGenericProperties__c.getInstance('EMAILUS_PRODUCT_SEARCH_PAGESIZE') != null ?
            Integer.valueOf(GCRGenericProperties__c.getInstance('EMAILUS_PRODUCT_SEARCH_PAGESIZE').value__c) : 5;
        intOffsetVal = intOffsetVal + intPageSize;
        intCurrentPage++;
        lProduct = gcr_helperClass.getProducts(strProdSearch, chlContentRec.CareHub__r.Country__c, chlContentRec.CareHub__r.Brand__c, chlContentRec.ImageField__c, intPageSize, intOffsetVal);
        // RETRIEVE IMAGE URLS
        gcr_helperClass.getImageUrl(lProduct, chlContentRec.ImageField__c);
        if (intTotalPages > 3) {
        	Integer intLastPage = lPageNumbers.get(lPageNumbers.size() - 1);
            if (intLastPage - intCurrentPage < 1 && intLastPage < intTotalPages) {
                lPageNumbers.add(intLastPage + 1);
                lPageNumbers.remove(0);
            }
        }
    }
    
    public void firstPage() {
        Integer intPageSize = GCRGenericProperties__c.getInstance('EMAILUS_PRODUCT_SEARCH_PAGESIZE') != null ?
            Integer.valueOf(GCRGenericProperties__c.getInstance('EMAILUS_PRODUCT_SEARCH_PAGESIZE').value__c) : 5;
        intOffsetVal = 0;
        intCurrentPage = 1;
		lProduct = gcr_helperClass.getProducts(strProdSearch, chlContentRec.CareHub__r.Country__c, chlContentRec.CareHub__r.Brand__c, chlContentRec.ImageField__c, intPageSize, intOffsetVal);
        // RETRIEVE IMAGE URLS
        gcr_helperClass.getImageUrl(lProduct, chlContentRec.ImageField__c);
        lPageNumbers.clear();
		Integer itr = 1;
        Integer lastPage = intTotalPages < 3 ? intTotalPages : 3;
		while (itr <= lastPage) {
			lPageNumbers.add(itr);
			itr++;
		}
    }
    
    public void lastPage() {
        Integer intPageSize = GCRGenericProperties__c.getInstance('EMAILUS_PRODUCT_SEARCH_PAGESIZE') != null ?
            Integer.valueOf(GCRGenericProperties__c.getInstance('EMAILUS_PRODUCT_SEARCH_PAGESIZE').value__c) : 5;
        intOffsetVal = (intTotalPages - 1) * intPageSize;
        intCurrentPage = intTotalPages;
		lProduct = gcr_helperClass.getProducts(strProdSearch, chlContentRec.CareHub__r.Country__c, chlContentRec.CareHub__r.Brand__c, chlContentRec.ImageField__c, intPageSize, intOffsetVal);
        // RETRIEVE IMAGE URLS
        gcr_helperClass.getImageUrl(lProduct, chlContentRec.ImageField__c);
        lPageNumbers.clear();
		Integer itr = intTotalPages > 3 ? intTotalPages - 2 : 1;
		while (itr <= intTotalPages) {
			lPageNumbers.add(itr);
			itr++;
		}
    }
    
    private void clearSearchResults() {
        isSearch = false;
		lProduct.clear();
        intCurrentPage = 1;
        intOffsetVal = 0;
        intTotalPages = 0;
    }

    public void isActionMethod() {
        isSearch = false;
        if (lProduct != null && !lProduct.isEmpty()) lProduct.clear();
        intCurrentPage = 1;
        intOffsetVal = 0;
        intTotalPages = 0;
        if (iHandshake.lCaseProduct != null && !iHandshake.lCaseProduct.isEmpty()) iHandshake.lCaseProduct.clear();
    }
    
    public void changeCountry() {
        Country_Status__c countryStatus = Country_Status__c.getInstance(chlContentRec.Country__c);
        if (countryStatus != null) {
        	iHandshake.isStateMandatory = countryStatus.Uses_States__c ? true : false;
            iHandshake.isZipMandatory = countryStatus.Uses_Postal_Codes__c ? true : false;
        } else {
            iHandshake.isStateMandatory = true;
            iHandshake.isZipMandatory = true;
        }
    }

    public class CaseProductWrapper {
        public Integer uniqueId { public get; private set; }
        public String productName { public get; private set; }
        public String imageUrl { public get; private set; }
        public Case_Product__c caseProduct { public get; private set; }
        
        public String numberProd { public get; public set; }
        public String stillHaveProd { public get; public set; }
        public String usedBefore { public get; public set; }
        public String expiryDate { public get; public set; }
        public String productionCode { public get; public set; }
        
        public caseProductWrapper(Integer uniqueId, String productName, String imageUrl, Case_Product__c caseProduct) {
            this.uniqueId = uniqueId;
            this.productName = productName;
            if (String.isNotEmpty(imageUrl)) {
            	this.imageUrl = imageUrl;
            }
            this.caseProduct = caseProduct;
        }
    }
}