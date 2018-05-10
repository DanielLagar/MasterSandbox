/**
* @author: Laure OMeara
* @date: 06/26/2014
* @description: 
* US496:
* This is the Fulfillment Order Controller from the old org
*/
public with sharing class sf_FulfillmentOrderCtrl {
    String cno = 'Case';
    String cNum;
    String action = 'Action';
    String selection = 'Select';
    //String selectTopic = 'Select a Topic to Associate with this Fulfillment Order:'; //ChrisM Not used - confirmed
    //String ffSearch = 'Fulfillment Search'; //ChrisM Not used - confirmed
    public Id caseId = null;
    //String noResults = 'No Results Returned'; //ChrisM replaced with label
    public Id ffId =null;   
    String caseNumber;
    String brand;
    String segment;
    String comment;
    String description;
    String country;
    String  contactCountry='';
    String agentLanguage;
    String localproductPath;
    String localcommentPath;
    public String commentId;
    //FIXME - remove this variable once all references are removed
    public String topicId;
    public String fromPage;
    String localComment;
    String localProduct;
    String globalProduct;
    String display;
    String desc1;  
    String quickCode; 
    public Id gpId; 
    public boolean showResults = false;
    public String promoitems= '0';
    public String promocreated= '0';
    public boolean showButton = false;
    public boolean showError = false;
    public boolean showValidationError = false;
    String itemType;
    Double amount;
    String fiType;
    String itemId;
    Integer flag = 0;
    //String atLeastOne = 'Select Atleast one Fulfillment Item'; //ChrisM replaced with label
    List<Case_Comment_Code__c> comments = new List<Case_Comment_Code__c>();
    List<Fulfillment_Item__c> fulfillmentItems = new List<Fulfillment_Item__c>();
    List<Fulfillment_Item__c> selectedLineItems = new List<Fulfillment_Item__c>();
    //String searchMsg = 'Searching...'; //ChrisM Not used - confirmed
    Map<String, String> mergemap = new Map<String,String>();
    Set<String> mm=new Set<String>();
    String[] itemTypeList2= new String[]{};
    String contactCenter='';
    public Id invId =null;  
    public String cId {get; set;} //Store full 18 character case Id to compare with PushTopics for refresh.
    public String cCurrency {get;set;} //Christopher.macduff@accenture.com to store case currency
    public String redirectUrl {get; set;}
    Contact caseContact; //WR66
    
    //START - Multiple Contacts
    public String selectedConId {get;set;}
    public List <SelectOption> contactOptions{
        get{
            contactOptions = new List<SelectOption>();
            //Use Name for locales where LastName FirstName is the norm?
            //Primary Contact should be handled first - want it to be default on page load
            for(Case_Contact__c cc : [SELECT Id, Contact__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Name, Case_Primary_Contact__c FROM Case_Contact__c WHERE Case__c = :caseId ORDER By Case_Primary_Contact__c DESC]){
                contactOptions.add(new SelectOption(cc.Contact__c, cc.Contact__r.Name));
            }
            return contactOptions;
        }
        set;
    }
    //END - Multiple Contacts

    public sf_FulfillmentOrderCtrl(ApexPages.StandardSetController controller){   
        User u = [Select Contact_Center__c from User where Id =:userInfo.getUserId()];
        contactCenter=u.Contact_Center__c;
        caseId = ApexPages.currentPage().getParameters().get('id');
        invId= ApexPages.currentPage().getParameters().get('invId');
        showResults = false;
        showButton = false;
        showError = false;
        showValidationError = false;
        if (caseId<> null){
            Case c=[Select caseNumber,Country__c,Id,Language__c,ContactId, currency__c from case where id=:caseId];
            cId = c.Id;
            country = c.Country__c;
            agentLanguage = c.Language__c;
            caseNumber = c.caseNumber;        
            cNum = caseNumber;
            cCurrency = c.Currency__c;
            if(c.ContactId<>null){
                caseContact = [Select Email, Country__c from Contact where Id = :c.ContactId];
                if(caseContact.Country__c!=null && caseContact.Country__c!=''){
                    contactCountry = caseContact.Country__c;
                }    
            }
            if(contactCountry!=null && contactCountry!=''){
                contactCountry = c.Country__c;
            }
                
        }

        fromPage= ApexPages.currentPage().getParameters().get('fromPage'); 
        //CMD WR256 start
        system.debug('>>> Controller get fromPage param: '+fromPage);
        //CMD WR256 fin        
        
        if(fromPage=='Additems'|| fromPage=='oneTopic'){
            commentId = ApexPages.currentPage().getParameters().get('comment');
            if(fromPage=='Additems'){     
                ffId=ApexPages.currentPage().getParameters().get('ffOrderid');
                if(ApexPages.currentPage().getParameters().get('pro')!=null){
                    promoitems=ApexPages.currentPage().getParameters().get('pro'); 
                }
            } 

            if(commentId<>null){
                getCommentAndProductInfo();
            }
        }

        //added by Ian Barker 3/11/2016
        //needed to pass brand, segment, and comments from Fulfillment page
        if (brand == null) brand = (ApexPages.currentPage().getParameters().get('brand') != null) ? ApexPages.currentPage().getParameters().get('brand') : null;
        if (segment == null) segment = (ApexPages.currentPage().getParameters().get('segment') != null) ? ApexPages.currentPage().getParameters().get('segment') : null;
        if (comment == null) comment = (ApexPages.currentPage().getParameters().get('comment') != null) ? ApexPages.currentPage().getParameters().get('comment') : null;
    }

    public String[] getItemTypeList2() {
            return itemTypeList2;
    }
    public void setItemTypeList2(String[] itemTypeList2){
        this.itemTypeList2= itemTypeList2;
    }

    /*ChrisM not used?
    public String getSearchMsg(){return searchMsg;}
    public void setSearchMsg(String s) {searchMsg= s;}*/

    public String getcNum(){return cNum;}
    public void setcNum(String s) { cNum = s;}
    
    public String getfiType(){return fiType;}
    public void setfiType(String s) { fiType = s;}
    
    public Double getAmount(){return amount;}
    public void setAmount(Double s) { amount= s;}    
    
    public String getSelection(){return selection;}
    public void setSelection(String s) {selection= s;}
    
    public String getAction(){return Action;}
    public void setAction(String s) {Action = s;}
    
    /*ChrisM Not used?
    public String getSelectTopic(){return selectTopic;}
    public void setSelectTopic(String s) {selectTopic = s;}*/
    
    //ChrisM Not used?
    /*public String getFfSearch(){return ffSearch;}
    public void setFfSearch(String s) {ffSearch = s;}*/

    public String getCountry(){return country;}
    public void setCountry(String s) {country= s;}
    
    public String getBrand(){return brand;}
    public void setBrand(String s) {brand= s;}
    
    public String getSegment(){return segment;}
    public void setSegment(String s) {segment= s;}

    public String getDesc1(){return desc1;}
    public void setDesc1(String s) {desc1 = s;}
    public String getDescription(){return description;}
    public void setDescription(String s) {description= s;}
    public String getAgentLanguage(){return agentLanguage;}
    public void setAgentLanguage(String s) {agentLanguage= s;}

    public List<Case_Comment_Code__c> getComments(){
        try{
            comments = [SELECT Id, Comment_Code_Path__c, Local_Comment_Code__c, Case_Product__r.id, Global_Comment_Path__c,
                            Case_Product__r.Local_Product__c, Case_Product__r.Local_Product__r.Translated_Path__c 
                        from Case_Comment_Code__c where Case__c = :caseId];     
 
            if(comments.size()==0){
                throw new noResultsFoundException();
            }   
        }
        catch(noResultsFoundException e){
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Fulfillment_caseCommentRequired);
             ApexPages.addMessage(myMsg);
        }    
        return comments;
    }
        
    //ChrisM - Not used anymore?
    public PageReference save(){
        fromPage= ApexPages.currentPage().getParameters().get('fromPage'); 

        commentId = ApexPages.currentPage().getParameters().get('comment');
        if(commentId<>null){
            getCommentAndProductInfo();
        }      
        return Page.sf_SelectFulfillmentItems;
    }
    
    private void getCommentAndProductInfo(){
        Case_Comment_Code__c c = [SELECT Id, Comment_Code_Path__c, Local_Comment_Code__c, Case_Product__r.id, 
                                        Case_Product__r.Product_Path__c, Case_Product__r.Local_Product__c, 
                                        Product_Brand__c, Case_Product__r.Local_Product__r.Translated_Path__c, 
                                        Global_Product_Path__c, Global_Comment_Path__c, GCR_CID__c, 
                                        Case_Product__r.Global_Product_ID__c
                                    from Case_Comment_Code__c where Id = :commentId];
            
        localproductPath =c.Case_Product__r.Local_Product__r.Translated_Path__c;      
        localProduct=c.Case_Product__r.Local_Product__c;                 
        localComment =c.Local_Comment_Code__c;
        globalProduct=c.Global_Product_Path__c;                                                                                                      
        localcommentPath = c.Global_Comment_Path__c;   
        display = localproductPath+' '+localcommentPath;
        gpId= c.Case_Product__r.Global_Product_ID__c;
        quickCode = c.GCR_CID__c;
        
        String[] productLevels = localproductPath.split('/');
        if (productLevels.size() > 0){
            brand = productLevels[0];
        }
        if (productLevels.size() > 1){
            segment = productLevels[1];
        }
            
    }
    
    public String getDisplay(){return display;}
    public void setDisplay(String s) {display = s;}
    
    public String getLocalproductPath(){return localproductPath;}
    public void setLocalproductPath(String s) {localproductPath= s;}
    
    public String getLocalcommentPath(){return localcommentPath;}
    public void setLocalcommentPath(String s) {localcommentPath = s;}
    
    public PageReference changeProductComment(){
        PageReference topicPage = new PageReference('/apex/sf_CreateFulfillmentOrder?id='+caseId);
        topicPage.setRedirect(true);
        return topicPage;
    }
    
    public PageReference search(){        
        PageReference tempPage = new PageReference('/'+caseId);
        tempPage.setRedirect(true);
        return tempPage;
    }
    
    
    public List<selectOption> getItemTypes(){
        List<selectOption> itemTypeList = new List<selectOption>();
        itemTypeList.add(new selectOption('',System.label.Olympic_Picklist_None));
        Schema.DescribeFieldResult fieldResult = Fulfillment_Item__c.Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                    
        for(Schema.PicklistEntry f : ple){
            itemTypeList.add(new SelectOption(f.getLabel(), f.getValue()));
        } 
        return itemTypeList;      

    }
    
    public List<selectOption> getItemTypesNew(){
        List<selectOption> itemTypeList = new List<selectOption>();
        itemTypeList.add(new selectOption('',System.label.Olympic_Picklist_None));
        try{
            Metadata_Item_Type_Selection__c mt=[Select Item_Type__c from Metadata_Item_Type_Selection__c where Contact_Center__c=:contactCenter];
            if(mt.Item_Type__c<>null){
                String[] str=(mt.Item_Type__c).split(';');
                if(str.size()>0){
                    for(String s:str)
                    itemTypeList.add(new SelectOption(s,s));
                }
            }
        }
        catch(Exception e){
            Schema.DescribeFieldResult fieldResult = Fulfillment_Item__c.Type__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                        
            for(Schema.PicklistEntry f : ple){
                itemTypeList.add(new SelectOption(f.getLabel(), f.getValue()));
            } 
        }
        return itemTypeList;      
    }
    
    public Id GetGlobalProductSegment(){
        Id parentgpId = GetParentGlobalProduct();
        return parentgpId;      
    }
    
    public Id GetParentGlobalProduct(){
        try{
            if(gpId == null){
                System.debug('exception null');
            }
           
            Global_Product__c currentGlobalProduct = [SELECT path_level__c,Parent_Product__c
                                                      FROM Global_Product__c
                                                      WHERE Id = :gpId ];
             
            if(currentGlobalProduct.path_level__c == 'BRAND'){
                system.debug('Brand Exception');
                return null;
            }
            else if(currentGlobalProduct.path_level__c == 'SEGMENT'){
                return currentGlobalProduct.Id;
            }
            else{
                gpId = currentGlobalProduct.Parent_Product__c;         
                return GetParentGlobalProduct(); 
            }
        }
        catch(Exception e){
            return null;
        }
    }
    
    public String GetSegmentName(){
        String segmentLocalName='';
        try{
            Local_Product__c lc = [Select Name From Local_Product__c  
                            WHERE Global_Product__r.Id= :gpId
                            AND Country__c = :country AND path_level__c = 'SEGMENT' and Inactive__c=false LIMIT 1];
                            
            segmentLocalName = lc.Name;  
        }
        catch(Exception e){}
        return segmentLocalName;
    }
    
    public String getItemType(){ return itemType; }
    public void setItemType(String itemType){this.itemType= itemType;}
    
    public Boolean getShowResults(){return showResults;}    
    public void setShowResults(Boolean s){showResults = s;}
    
    public Boolean getShowButton(){return showButton;}    
    public void setShowButton(Boolean s){showButton = s;}

    public Boolean getShowError(){return showError;}    
    public void getShowError(Boolean s){showError = s;}
    
    public Boolean getShowValidationError(){return showValidationError;}    
    public void getShowValidationError(Boolean s){showValidationError = s;}

    public class ffFulfillmentItem{
        //christopher.macduff@accenture.com - local currencies
        public Boolean keepAmount {
            get{
                if(keepAmount==null){
                    keepAmount = false;
                }
                return keepAmount;
            }
            set;
        }
            
        public Fulfillment_Item__c f{get; set;}
        public Boolean selected {get; set;}
        public Double amount{get;set;}
        public String bankName {get;set;}
        public String Description {get;set;}
        public String bankRoutingNumber{get; set;}
        public Integer quantity {get;set;}
        public ffFulfillmentItem(Fulfillment_Item__c wrapperFfItem){
            f = wrapperFfItem;
            selected = false;
            amount = null;
            quantity = null;
        }
    }
    
    public void searchFulfillmentItems(){
        system.debug(logginglevel.WARN,'!!!!!!! in searchFulfillmentItems');
        String query = 'Select Id,Name,Type__c,Segment__c,Brand__c,Description__c,SKU__c,Fulfillment_Item_ID__c from Fulfillment_Item__c WHERE Active__c = true AND Contact_Country__c = :country AND Crisis__c=false AND Contact_Language__c = :agentLanguage  AND Bundle_Parent__c = null AND Promo_Flag__c = false';
        String all = 'All';
        String space = '';
        String desc2 = desc1;
        String description1=description;
        fulfillmentItems = new List<Fulfillment_Item__c> ();
        List<String> tt=new List<String>();
        if(itemTypeList2.size()>0){
            for(String s:itemTypeList2)
                if(s<>'')tt.add(s);
        }
        if(tt<> null && tt.size()>0){ 
            query+= ' AND Type__c in :tt'; 
        } 
        if(brand<> null && brand<>''){ 
            query+= ' AND ((Brand__c = :brand OR Brand__c like :all) AND Brand__c <> :space)'; 
        } 
        if(segment <> null && segment<>''){ 
            query+= ' AND ((Segment__c = :segment OR Segment__c like :all) AND Segment__c <> :space)'; 
        } 
        
        if(desc2 <> null && desc2 <> ''){ 
            desc2 = desc2.replace('*','%');
            query+= ' AND (Name like :desc2 AND Name <> :space)'; 
        } 
        if(description<> null && description<> ''){ 
            description1= description1.replace('*','%');
            query+= ' AND  (Description__c like :description1 AND Description__c <> :space)'; 
        }
        query+= ' Order by Type__c limit 150'; 

        system.debug(logginglevel.WARN,'>>> query: '+query);
        
        fulfillmentItems = Database.Query(query); 
        try{   
           if(flag == 0){                
            ffItemsList = new List<ffFulfillmentItem>();           
            for(Integer i = 0;i<fulfillmentItems.size();i++){             
                ffItemsList.add(new ffFulfillmentItem(fulfillmentItems[i]));
            }
            }         
            if(ffItemsList.size()==0){   
                ffItemsList = null;         
                throw new noResultsFoundException();
             }              
             else{
                 showResults = true;
                 showButton = true;           
             }   
        }
        catch(noResultsFoundException e){        
                showError = false;
                showButton = false;

                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.INFO, System.Label.Fulfillment_NoResultsReturned);
                ApexPages.addMessage(myMsg);
                //return null;
        }
        /*@WR66: Mobile Payment Support
         *@Author: christopher.macduff@accenture.com
         *@Date: 3rd Mar 2016
         *@Description: If MP selected then shows current Contacts email or warns Agent that it is required if null
         */ 
        
        //Convert to set so we can use contains
        Set<String> typeSet = new Set<String>(tt);
        
        if(String.isBlank(caseContact.Email) && typeSet.contains('MP')){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Fulfillment_mpEmailRequired);
            ApexPages.addMessage(msg);
        }
        else if(!String.isBlank(caseContact.Email) && typeSet.contains('MP')){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.Info, System.Label.Fulfillment_mpEmailCheck+' '+caseContact.Email);
            ApexPages.addMessage(msg);
        }
        
    }
    
    public List<ffFulfillmentItem> ffItemsList {get; set;}
        
    public List<ffFulfillmentItem> getfulfillmentItems(){        
        return ffItemsList; 
    }     

    /************************************
    *   WR343 Are selected FOLIs valid  *
    *   to continue processing?         *
    ************************************/
    Private set<String> restrictedTypes = new Set<String>{'CH','ET','MO','MP','PP'};
    Public void validateFOLIs(){
        Integer restrictedTypeCount = [SELECT COUNT() FROM Fulfillment_Order_Line_Item__c WHERE Case__c= :caseId AND Fulfillment_Order__c= :ffId AND (Fulfillment_Item__r.Type__c IN :restrictedTypes)];

        for(ffFulfillmentItem ffItem :ffItemsList){
            if(ffItem.quantity > 0 && restrictedTypes.contains(ffItem.f.Type__c)){
                system.debug(logginglevel.WARN, '>>> adding to type count: '+ffItem);
                restrictedTypeCount ++;
                if(restrictedTypeCount > 1){
                    throw new userDefinedException(System.Label.Fulfillment_oneCHorET);
                }
            }
        }
    }     

    /************************************
    *    ADD NEW LINE ITEMS             *
    ************************************/
    //public PageReference processSelected(){
    public PageReference addNewLineItems(){
        try{
            validateFOLIs();
            Integer i=0;
            flag = 1;
            Integer flag2=0;
        
        //try{  
            for(ffFulfillmentItem ffItem :ffItemsList){
                if(ffItem.quantity>0){
                    if(ffItem.amount == 0 && (ffItem.f.Type__c == 'CH' || ffItem.f.Type__c == 'PP' || ffItem.f.Type__c == 'ET'))
                        throw new amountMandatoryException();
                        //CDOY WR302 - Amended below VVVVVV
                        if(ffItem.f.Type__c == 'ET' || contactCenter == 'AMR BR' && (  ffItem.f.Type__c == 'CP' || ffItem.f.Type__c == 'CD' || ffItem.f.Type__c == 'PR'))
                        flag2=1;
                    selectedLineItems.add(ffItem.f); 
                }    
            } 
            if(selectedLineItems.size()>0){
                system.debug('>>> fromPage: '+fromPage);//CMD WR256)
                if(!String.isBlank(fromPage)){
                    fromPage = fromPage.toLowerCase();//CMD WR256 to support turkish locale
                }
                //If hit monetary threshold VR an FF is already created - use that instead of creating a new one
                if(String.isBlank(ffId) && (fromPage=='sf_selectfulfillmentitems' || fromPage=='oneTopic')){
                    system.debug('$$$ Add Line Item - in processSelected about to call CreateFulfillmentOrder');//WR95
                    ffId = CreateFulfillmentOrder();
                }
                String result=CreateFulfillmentOrderLineItem();
                if(result == 'Success'){
                    i=1; 
                }
                else{
                    i=2;
                }
                                           
            }
            else{
                throw new noResultsFoundException(); 
            }    
            if(i==1){ 
                //CDOY WR302 - Amended below VVVVVV
                //List<Fulfillment_Order_Line_Item__c> ffi=[Select Id from Fulfillment_Order_Line_Item__c where Fulfillment_Order__c= :ffId   AND ( Fulfillment_Item__r.Type__c ='ET' OR Fulfillment_Item__r.Type__c ='CP' OR Fulfillment_Item__r.Type__c ='CD' OR Fulfillment_Item__r.Type__c ='PR' )];
                //WR343 Order by last modified so redirects to latest FO
                List<Fulfillment_Order_Line_Item__c> ffi=[Select Id from Fulfillment_Order_Line_Item__c where Fulfillment_Order__c= :ffId   AND ( Fulfillment_Item__r.Type__c ='ET' OR Fulfillment_Item__r.Type__c ='CP' OR Fulfillment_Item__r.Type__c ='CD' OR Fulfillment_Item__r.Type__c ='PR' ) ORDER BY LastModifiedDate DESC];
                if(ffi.size()>0 && flag2==1){
                    system.debug(logginglevel.WARN, '%%%%%% Setting redirect 5');
                PageReference tempPage = new PageReference('/'+ffi[0].Id+'/e?retURL=/'+ffId);
                tempPage.setRedirect(true);
                return tempPage;
                }
                else{    
                    system.debug(logginglevel.WARN, '%%%%%% Setting redirect 6');              
                PageReference tempPage = new PageReference('/'+ffId);
                tempPage.setRedirect(true);
                return tempPage;
                }  
            }
            else if(i == 0){
                throw new noResultsFoundException();
            }
            else{
                throw new userDefinedException();
            }
       
        }
        catch(noResultsFoundException e){
             flag = 0;
             showError = true;
             showValidationError = false;
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Fulfillment_atLeastOne);
             ApexPages.addMessage(myMsg);
             return null;   
        }
        catch(amountMandatoryException e){
            showValidationError = true;
            showError = false;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Fulfillment_AmountMandatory);
            ApexPages.addMessage(myMsg);
            return null; 
        }
        catch(userDefinedException e){
            system.debug('exception'+e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
            return null;
        }
    }

    /************************************
    *    SAVE AND NEW                   *
    ************************************/
    //public Pagereference goToProcessSelected2(){     
    public PageReference goToSaveAndNew(){
        ApexPages.currentPage().getParameters().put('comment',commentId);
        //return processSelected2();
        return saveAndNew();
    }
   
    //public PageReference processSelected2(){
    public PageReference saveAndNew(){
        try{
            validateFOLIs();
            String fforder = null;
            Integer i=0;
            flag = 1;
            Integer flag2=0;
                    
            fromPage= ApexPages.currentPage().getParameters().get('fromPage'); // added 8/15 - 

        //try{  
            for(ffFulfillmentItem ffItem :ffItemsList){
                if(ffItem.quantity>0){
                    if(ffItem.amount == 0 && (ffItem.f.Type__c == 'CH' || ffItem.f.Type__c == 'PP' || ffItem.f.Type__c == 'ET')){
                        throw new amountMandatoryException();
                    }
            //CDOY WR302 - Amended below VVVVVV
                        if(ffItem.f.Type__c == 'ET' || contactCenter == 'AMR BR' && ( ffItem.f.Type__c == 'CP' || ffItem.f.Type__c == 'CD' || ffItem.f.Type__c == 'PR'))
                        flag2=1;
                        selectedLineItems.add(ffItem.f); 
                }    
            }                         
            if(selectedLineItems.size()>0){
                system.debug('@!@ffId ' + ffId);
                system.debug('@@@fromPage: ' + fromPage);
                
                if(!String.isBlank(fromPage)){ 
                    fromPage = fromPage.toLowerCase();//CMD WR256
                }
                if(String.isBlank(ffId) && (fromPage=='sf_selectfulfillmentitems' || fromPage=='oneTopic')){
                    system.debug('$$$ Save and New - in processSelected2 about to call CreateFulfillmentOrder');//WR95
                    ffId = CreateFulfillmentOrder();
                }     
                String result=CreateFulfillmentOrderLineItem();
                if(result=='Success'){
                    i=1; 
                }else{
                    i=2;                       
                }

            }
            else{
                throw new noResultsFoundException();
            }    
            system.debug('??? invId: '+invId+' i: '+i);
            if(i==1){
                if(invId<>null){
                    List<Fulfillment_Order_Line_Item__c> ffi=[Select Id from Fulfillment_Order_Line_Item__c where Fulfillment_Order__c= :ffId   AND Fulfillment_Item__r.Type__c ='ET' ORDER BY LastModifiedDate DESC ];
                    if(ffi.size()>0 && flag2==1){
                        system.debug(logginglevel.WARN, '%%%%%% Setting redirect 1');
                        PageReference tempPage = new PageReference('/'+ffi[0].Id+'/e?retURL=/apex/sf_SelectFulfillmentItems?id='+caseId+'%26pro%3D'+promocreated+'%26fromPage%3DAdditems%26ffOrderid%3D'+ffId+'%26invId%3D'+invId);

                        tempPage.setRedirect(true);
                        tempPage.getParameters().put('brand', brand);
                        tempPage.getParameters().put('segment', segment);
                        tempPage.getParameters().put('comment', comment);
                        return tempPage;
                    }
                    else{
                        system.debug(logginglevel.WARN, '%%%%%% Setting redirect 2');
                        PageReference tempPage = new PageReference('/apex/sf_SelectFulfillmentItems?id='+caseId+'&pro='+promocreated+'&fromPage=Additems&ffOrderid='+ffId+'&invId='+invId);
                        tempPage.setRedirect(true);
                        tempPage.getParameters().put('brand', brand);
                        tempPage.getParameters().put('segment', segment);
                        tempPage.getParameters().put('comment', comment);
                        return tempPage;
                        
                    }
                }
                else{
                    //CDOY WR302 - Amended below VVVVVV
                    //List<Fulfillment_Order_Line_Item__c> ffi=[Select Id from Fulfillment_Order_Line_Item__c where Fulfillment_Order__c= :ffId  AND ( Fulfillment_Item__r.Type__c ='ET' OR Fulfillment_Item__r.Type__c ='CP' OR Fulfillment_Item__r.Type__c ='CD' OR Fulfillment_Item__r.Type__c ='PR')  ];
                    //WR343 Order by last modified so redirects to latest FO
                    List<Fulfillment_Order_Line_Item__c> ffi=[Select Id from Fulfillment_Order_Line_Item__c where Fulfillment_Order__c= :ffId  AND ( Fulfillment_Item__r.Type__c ='ET' OR Fulfillment_Item__r.Type__c ='CP' OR Fulfillment_Item__r.Type__c ='CD' OR Fulfillment_Item__r.Type__c ='PR') ORDER BY LastModifiedDate DESC ];
                    if(ffi.size()>0 && flag2==1){
                        system.debug(logginglevel.WARN, '%%%%%% Setting redirect 3');
                        PageReference tempPage = new PageReference('/'+ffi[0].Id+'/e?retURL=/apex/sf_SelectFulfillmentItems?id='+caseId+'%26pro%3D'+promocreated+'%26fromPage%3DAdditems%26ffOrderid%3D'+ffId);
                        tempPage.setRedirect(true);
                        tempPage.getParameters().put('brand', brand);
                        tempPage.getParameters().put('segment', segment);
                        tempPage.getParameters().put('comment', comment);
                        return tempPage;
                    }
                    else{ 
                        system.debug(logginglevel.WARN, '%%%%%% Setting redirect 4');    
                        PageReference tempPage = new PageReference('/apex/sf_SelectFulfillmentItems?id='+caseId+'&pro='+promocreated+'&fromPage=Additems&ffOrderid='+ffId);
                        tempPage.setRedirect(true);
                        tempPage.getParameters().put('brand', brand);
                        tempPage.getParameters().put('segment', segment);
                        tempPage.getParameters().put('comment', comment);
                        return tempPage;
                    }
                }
                
            }

            else if(i == 0){
                throw new noResultsFoundException();
            }  
            else{
                throw new userDefinedException();
            }  
        }
        catch(noResultsFoundException e)
        {
             flag = 0;
             showError = true;
             showValidationError = false;
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Fulfillment_atLeastOne);
             ApexPages.addMessage(myMsg);
             return null;   
        }
        catch(amountMandatoryException e)
        {
            showValidationError = true;
            showError = false;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Fulfillment_AmountMandatory);
            ApexPages.addMessage(myMsg);
            return null; 
        }
        catch(userDefinedException e)
        {
            system.debug('exception'+e); 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));      
            return null;
        }
   }

    public Id CreateFulfillmentOrder(){
        system.debug('$$$ in CreateFulfillmentOrder');//WR95
        
        Fulfillment_Order__c newFulfillmentOrder = new Fulfillment_Order__c();       
        Case sfCase = [SELECT Id,Country__c,Contact_Center__c, Language__c,ContactId,
                              CaseNumber, Brand__c, Segment__c, Origin 
                              FROM Case WHERE Id = :caseId];

        mm.add('{Case.Brand}');
        mm.add('{Case.Country}');
        mm.add('{Case.Language}');
        mm.add('{Case.ContactMethod}');
        mm.add('{Case.Segment}');
        mm.add('{Account.LastName}');
        mm.add('{Account.FirstName}');
        mm.add('{Account.Salutation}');
        mm.add('{Case.Id}');
        String country = '';
        String language = '';
        String contact = '';
        String brand='';
        if(sfCase.Country__c != null){
           country = sfCase.Country__c;
           mergemap.put('{Case.Country}',country);
        }
        if(sfCase.Origin != null){
            mergemap.put('{Case.ContactMethod}',sfCase.Origin);
        }
        if(sfCase.CaseNumber != null){
            mergemap.put('{Case.Id}',sfCase.CaseNumber);
        }
        if(sfCase.Language__c != null){
           language = sfCase.Language__c;
           mergemap.put('{Case.Language}',language);
        }
        if(sfCase.ContactId != null){
            //START - Mutli Contact support changes
            contact = selectedConId;
            //FIN - Multi Contact support changes
            Contact sfContact = [SELECT FirstName, Salutation, LastName FROM Contact WHERE Id =:contact];
            if(sfContact.FirstName != null){
                mergemap.put('{Account.FirstName}',sfContact.FirstName);
            }   
            if(sfContact.LastName != null){
                mergemap.put('{Account.LastName}',sfContact.LastName);
            }
            if(sfContact.Salutation != null){
                mergemap.put('{Account.Salutation}',sfContact.Salutation);
            }     
        }
        if(sfCase.Brand__c != null){
            mergemap.put('{Case.Brand}',sfCase.Brand__c);
            brand=sfCase.Brand__c;
         }
        if(sfCase.Segment__c != null){
            mergemap.put('{Case.Segment}',sfCase.Segment__c);
        }

        List<APXTConga4__Conga_Template__c> template = [SELECT Id,HTML_Content__c,RTL_Language__c
          FROM APXTConga4__Conga_Template__c WHERE Country__c includes (:country) AND Followup__c=false AND
          Language__c includes (:language) AND Contact_Center__c includes (:contactCenter) AND Default_Template_Active__c = TRUE];

        If(template.size() > 0){
            If(template[0].Id != null){
                newFulfillmentOrder.Conga_Merge_Template_Id__c = template[0].Id;
            }
            If(template[0].RTL_Language__c != null){
                newFulfillmentOrder.RTL_Language__c = template[0].RTL_Language__c;
            }
            If(template[0].HTML_Content__c != null){
                String temp=template[0].HTML_Content__c;
                for(String s:mm)
                {
                    if(mergemap.get(s) != null){
                        temp = (temp).replace(s,mergemap.get(s));
                    } 
                    else{
                        temp = (temp).replace(s,'');
                    }   
                }
                newFulfillmentOrder.Letter_Body__c = temp;
            }   
        } 
        List<Letter_Head__c> lh=[Select Header_ID__c from Letter_Head__c  where country__c=:country AND language__c=:language AND  Brand__c=:brand];
        if(lh.size()>0){
            If(lh[0].Header_ID__c<>null){
                newFulfillmentOrder.FF_Header__c=lh[0].Header_ID__c;
            }   
        }        
        
        //sfdc 7/29/15
        if (commentId != null){
            getCommentAndProductInfo();
        }
        
        newFulfillmentOrder.Case__c = caseId;
        
        // set default contact on fulfillment order to be case contact
        if(contact!=null){
            newFulfillmentOrder.Contact__c = contact;
        }

        newFulfillmentOrder.Trans_Country__c = contactCountry;
        newFulfillmentOrder.Case_Comment_Code__c = commentId;
        
        try{        
            insert newFulfillmentOrder;
        }
        catch(Exception e) {
            System.enqueueJob(new exceptionHelperQueable(e,'FO Ctr - error on inserting FO: '+String.valueOf(newFulfillmentOrder)));
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
        return newFulfillmentOrder.Id;
    }
   
    public String CreateFulfillmentOrderLineItem(){        
        String ffItemType='';
        String ffItemSKU='';
        String ffItemDescription='';
        String ffItemIdc='';
        String ffOLIRecordTypeId='';
        String currencyType='';
        Set<String> itemTypes=new Set<String>();
        try{
            List<Fulfillment_Order_Line_Item__c> insertLineItems = new List<Fulfillment_Order_Line_Item__c> ();
            
            for(ffFulfillmentItem ffItem :ffItemsList){
                if(ffItem.quantity>0){
                    itemTypes.add(ffItem.f.Type__c);                
                    ffItemType = ffItem.f.Type__c;
                    ffItemSKU =  ffItem.f.SKU__c;
                    ffItemDescription =  ffItem.f.Description__c;
                    ffItemIdc =  ffItem.f.Fulfillment_Item_ID__c;
                    system.debug('###ffItemType: ' + ffItemType);
           
                    Metadata_FF_Order_Line_Item_Record_Type__c m = 
                        [SELECT FF_Order_Line_Item_Record_Type_Id__c 
                        FROM Metadata_FF_Order_Line_Item_Record_Type__c 
                        WHERE Item_Type__c= :ffItem.f.Type__c LIMIT 1];
                 
                    ffOLIRecordTypeId = m.FF_Order_Line_Item_Record_Type_Id__c;
                
                    Fulfillment_Order_Line_Item__c newFulfillmentOrderLineItem = new Fulfillment_Order_Line_Item__c();
    
                    //WR343 - moved to ValidateFOLIs();
                    /*if (ffItemType=='CH' || ffItemType=='ET'){
                        Integer ffCount = [SELECT count() 
                            FROM Fulfillment_Order_Line_Item__c 
                            WHERE Case__c= :caseId 
                            AND Fulfillment_Order__c= :ffId  
                            AND (Fulfillment_Item__r.Type__c ='CH' OR Fulfillment_Item__r.Type__c ='ET')];                  
                        if (ffCount > 0){           
                            throw new MoreThanOneRecordsReturnedException();
                        }
                    }*/

            newFulfillmentOrderLineItem.Fulfillment_Order__c = ffId;
            newFulfillmentOrderLineItem.RecordTypeId = ffOLIRecordTypeId;
            newFulfillmentOrderLineItem.Case__c = caseId;
            newFulfillmentOrderLineItem.Fulfillment_Item__c = ffItem.f.Id;

            newFulfillmentOrderLineItem.Type__c = ffItemType;
            if((ffItemType=='MO'|| ffItemType=='MI')&&(ffItem.bankName!=null && ffItem.bankName!=''))
            {                    
                newFulfillmentOrderLineItem.Description__c = ffItem.bankName;
            }
            else
            {
            newFulfillmentOrderLineItem.Description__c = ffItemDescription;
            }
            newFulfillmentOrderLineItem.Fulfillment_SKU__c = ffItemSKU;
            newFulfillmentOrderLineItem.Fulfillment_Item_ID__c = ffItemIdc;
            if(ffItem.quantity == 0)
            newFulfillmentOrderLineItem.Quantity__c = 1;
            else
            newFulfillmentOrderLineItem.Quantity__c = ffItem.quantity;        
            newFulfillmentOrderLineItem.Amount_currency__c = ffItem.amount;
            /*christopher.macduff@accenture.com local currency support */
            newFulfillmentOrderLineItem.Keep_Amount__c = ffItem.keepAmount;
                    
            //newFulfillmentOrderLineItem.Bank_Name__c = ffItem.bankName;
            if(ffItem.bankRoutingNumber!=null && ffItem.bankRoutingNumber!='')
            newFulfillmentOrderLineItem.Handling_Instructions__c = ffItem.bankRoutingNumber;

            insertLineItems.add(newFulfillmentOrderLineItem);
            } 
            }  
            String tempId='';
            //Added to create Promotional FF Items
            Boolean needPromo=false;
            
            if(itemTypes.size()==1 && (itemTypes.contains('ET') || itemTypes.contains('CH')))
            {
                if(contactCenter=='DEW SY Wilhelmshaven' || contactCenter=='EGC P&G Cairo' || contactCenter=='GBE SY Edinburgh' || contactCenter=='GBN P&G Newcastle' || contactCenter=='ITP SY Prato'
                || contactCenter=='KSJ DMS Jeddah' || contactCenter=='NLT Teleperformance Tilburg')
                needPromo=true;
            }
            List<Fulfillment_Item__c>  promoFFItemsTemp = [Select Id,Name,Type__c,Segment__c, Auto_Fulfillment_GCR_CID__c,   
                                                     Brand__c,Description__c,SKU__c,Promo_Template_Id__c,Fulfillment_Item_ID__c,Promo_Count__c,Promo_Limit__c 
                                                     from Fulfillment_Item__c WHERE Active__c = true AND Promo_Flag__c = true AND
                                                     Contact_Country__c = :country AND Contact_Language__c = :agentLanguage 
                                                     AND Bundle_Parent__c = null AND Promo_Limit__c > 0 AND (Brand__c=:brand OR Brand__c='ALL') AND
                                                     (Promo_Segment__c like :(segment+'%') OR Promo_Segment__c='ALL' OR Promo_Segment__c like :('%'+segment) OR Promo_Segment__c like :('%'+segment+'%'))];  
                                                     //AND (Promo_Quick_Code__c like :('%'+quickCode) OR Promo_Quick_Code__c like :(quickCode+'%') OR Promo_Quick_Code__c like :('%'+quickCode+'%'))]; 
            
            List<Fulfillment_Item__c>  promoFFItem = new List<Fulfillment_Item__c>();
            for(Fulfillment_Item__c tempFFItemObj : promoFFItemsTemp){
                if(String.isBlank(tempFFItemObj.Auto_Fulfillment_GCR_CID__c)) continue;
                for(String promoquickcodestr : tempFFItemObj.Auto_Fulfillment_GCR_CID__c.split(';')){
                    if(quickCode == promoquickcodestr.trim()){
                        promoFFItem.add(tempFFItemObj);
                        break;
                    }
                }
            }
            
            if(promoFFItem.size() > 0 && promoitems=='0' && needPromo==false)
            {
                //promoitems='1';
                tempId=promoFFItem[0].Promo_Template_Id__c;
                for(Integer count = 0;count<promoFFItem.size();count++)
                {
                    promocreated='1';
                    if(promoFFItem[0].Promo_Template_Id__c<>null && promoFFItem[0].Promo_Template_Id__c<>'')
                    tempId=promoFFItem[count].Promo_Template_Id__c;
                    
                    Fulfillment_Order_Line_Item__c newFulfillmentOrderLineItem = new Fulfillment_Order_Line_Item__c();
                    if(promoFFItem[count].Promo_Count__c<>null)
                    promoFFItem[count].Promo_Count__c = promoFFItem[count].Promo_Count__c + 1;
                    else
                    promoFFItem[count].Promo_Count__c = 1;
                    
                    promoFFItem[count].Promo_Limit__c = promoFFItem[count].Promo_Limit__c - 1;                    
                    newFulfillmentOrderLineItem.Fulfillment_Order__c = ffId;
                    // NOTE - commented by ljo 6/26
                    //newFulfillmentOrderLineItem.RecordTypeId = '012700000001DjI';
                    newFulfillmentOrderLineItem.Case__c = caseId;
                    newFulfillmentOrderLineItem.Fulfillment_Item__c = promoFFItem[count].Id;
                    newFulfillmentOrderLineItem.Currency__c = currencyType; 
                    // NOTE - commented by ljo 6/26    
                    //newFulfillmentOrderLineItem.CurrencyIsoCode = currencyType;
                    if(promoFFItem[count].Type__c<>null && promoFFItem[count].Type__c<>'')
                    newFulfillmentOrderLineItem.Type__c = promoFFItem[count].Type__c;
                    if(promoFFItem[count].Description__c<>null && promoFFItem[count].Description__c<>'')
                    newFulfillmentOrderLineItem.Description__c = promoFFItem[count].Description__c;
                    if(promoFFItem[count].SKU__c<>null)
                    newFulfillmentOrderLineItem.Fulfillment_SKU__c = promoFFItem[count].SKU__c;
                    if(promoFFItem[count].Fulfillment_Item_ID__c<>null)
                    newFulfillmentOrderLineItem.Fulfillment_Item_ID__c = promoFFItem[count].Fulfillment_Item_ID__c;
                    newFulfillmentOrderLineItem.Quantity__c = 1;
                    insertLineItems.add(newFulfillmentOrderLineItem);
                }                
            }
            
            if(insertLineItems.size()>0)
            {  
                insert insertLineItems;
                system.debug('!!!insertLineItems' + insertLineItems[0].Type__c);
                update promoFFItem; 
                if(promoFFItem.size() > 0 && promoitems=='0' && needPromo==false)
                {
                    Fulfillment_Order__c ff=[Select Promos_Created__c from Fulfillment_Order__c where Id=:ffId];
                    ff.Promos_Created__c=true;
                    update ff;
                }

                if(tempId<>null && tempId<>'')
                {
                    List<APXTConga4__Conga_Template__c> template = [SELECT Id,HTML_Content__c, RTL_Language__c
                            from APXTConga4__Conga_Template__c where Id=:tempId];
                    If(template.size() > 0)
                    {
                        Fulfillment_Order__c newFulfillmentOrder=[Select Conga_Merge_Template_Id__c,RTL_Language__c ,Letter_Body__c  from Fulfillment_Order__c where Id=:ffId];
                        If(template[0].Id != null)
                            newFulfillmentOrder.Conga_Merge_Template_Id__c = template[0].Id;
                        If(template[0].RTL_Language__c != null)
                            newFulfillmentOrder.RTL_Language__c = template[0].RTL_Language__c;
                       
                        If(template[0].HTML_Content__c != null)
                        {
                            newFulfillmentOrder.Letter_Body__c = template[0].HTML_Content__c;
                            String temp=template[0].HTML_Content__c;
                                for(String s:mm)
                                {
                                    if(mergemap.get(s) != null)
                                        temp = (temp).replace(s,mergemap.get(s));
                                    else
                                        temp = (temp).replace(s,'');
                                }
                            newFulfillmentOrder.Letter_Body__c = temp;
                       } 
                       update newFulfillmentOrder;  
                    } 
                }     

                return 'Success';
            }
            
            else
                return 'failure';
        }
        catch(MoreThanOneRecordsReturnedException e1)
        {
            if(fromPage=='ffSelection')//ChrisM - review this, might need to be changed now. WR256
            {
                Fulfillment_Order__c ff = [Select Id from Fulfillment_Order__c where Id = :ffId];
                delete ff;
            }
            flag = 0;
            showValidationError = true;
            showError = false;
            String msg= System.Label.Fulfillment_oneCHorET;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.ERROR, msg);
            ApexPages.addMessage(myMsg);
            return null;
        }
        catch(DmlException e)
        {
            if(fromPage=='ffSelection'&& ffId<>null)//ChrisM - review this, might need to be changed now. WR256
            {
                List<Fulfillment_Order__c> ff = [Select Id from Fulfillment_Order__c where Id = :ffId];
                if(ff.size()>0)
                    delete ff[0];
            }
            flag = 0;
            showValidationError = true;
            showError = false;            
            ApexPages.addMessages(e);
            return 'failure';
        }    

    }

    public class MoreThanOneRecordsReturnedException extends Exception{}
    public class noResultsFoundException extends Exception{}
    public class amountMandatoryException extends Exception{}
    public class userDefinedException extends Exception{}

    public PageReference redirect(){
        PageReference tempPage = new PageReference(redirectUrl);
        tempPage.setRedirect(true);
        return tempPage;
    }
}