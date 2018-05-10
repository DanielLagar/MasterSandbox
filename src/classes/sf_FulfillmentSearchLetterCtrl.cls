/**
* @author: Laure OMeara
* @date: 07/18/2014, 07/24/2014

* @description: 
* US496:
* This controller is used for the conga template selection dialog on fulfillment orders
*/
public with sharing class sf_FulfillmentSearchLetterCtrl {
    public string commentType = ''; 
    public string segment ='';
    public String selectedTemp { get; set; }
    public string brand = '';
    public string country = '';
    public string language ='';
    public string contactMethod ='';
    public string lastName ='';
    public string firstName ='';
    public string salutation ='';
    public string prifixSal ='';
    public string caseNumber ='';       
    public String viewDis { 
        get{
            if(string.isBlank(viewDis))
                return Label.Fulfillment_SelectTemplateAndView;
            else
                return viewDis;
        } set; 
    }
    public String viewTemplateName { get;set; }
    public string View {
        get {
            if(string.isblank(view)) return 'View';
            else return  View;
        } 
        set;
    }
    public string select1{get ; set;}
    public string Search1 {get; set;}
    public string btnCancel {get; set;}
    public string tkeyword{
        get{
            if(string.isBlank(tkeyword))
               return 'Enter a Keyword:';
            else return tkeyword;
        } 
        set;
    }
    public String searching { get; set; }   
    public list<selectoption> templeteOptions { get; set; }  
    // getting the user contact center and language    
    public list<user> uname = [select id, Contact_Center__c from user where id =: UserInfo.getUserId()];
    // Query to retrieve the fullfillment
    /*public list<Fulfillment_Order__c> lstCase = [select id, letter_body__c, conga_merge_template_id__c, RTL_language__c,
         Fulfillment_Order__c.Prefix_Sal__c, Fulfillment_Order__c.case__r.Master_Brand__c, Fulfillment_Order__c.case__r.country__c, Fulfillment_Order__c.case__r.language__c ,Fulfillment_Order__c.case__r.brand__c, Fulfillment_Order__c.case__r.segment__c,
         Fulfillment_Order__c.case__r.Amer_brand__c, Fulfillment_Order__c.case__r.Emea_brand__c ,  Fulfillment_Order__c.case__r.ceemea_brand__c,  Fulfillment_Order__c.case__r.amer_segment__c,  Fulfillment_Order__c.case__r.Emea_segment__c,  Fulfillment_Order__c.case__r.ceemea_segment__c,
         Fulfillment_Order__c.topic__r.Local_Comment__r.Major_Area__c, Fulfillment_Order__c.topic__r.Local_Comment__r.Comment_Type__c,Fulfillment_Order__c.topic__r.Local_Comment__r.Category__c ,
         Fulfillment_Order__c.account__r.FirstName, Fulfillment_Order__c.account__r.LastName,  Fulfillment_Order__c.account__r.salutation,  Fulfillment_Order__c.topic__r.Local_Comment__r.global_comment__r.quick_code__c, 
         Fulfillment_Order__c.topic__r.Local_Comment__r.Subcategory__c, Fulfillment_Order__c.topic__r.Local_Comment__r.Description__c                                               
         from Fulfillment_Order__c where id =: ApexPages.currentPage().getParameters().get('id')];
     */                  
    //constructor to show all the items at first
    public sf_FulfillmentSearchLetterCtrl(ApexPages.StandardController controller) {        
        View = Label.Fulfillment_View;
        select1 = Label.Fulfillment_Select;
        Search1 = Label.Fulfillment_Search;
        tkeyword = Label.Fulfillment_EnterAKeyword;
        btnCancel = Label.Fulfillment_Cancel;
        
        list<Fulfillment_Order__c> ffOrderObj = [select id, letter_body__c, conga_merge_template_id__c, RTL_language__c,
            case__r.Brand__c, 
            case__r.country__c, Fulfillment_Order__c.case__r.language__c,
            case__r.segment__c, 
            contact__r.FirstName, 
            contact__r.LastName, 
            contact__r.salutation,            
            Case_Comment_Code__r.Comment_Code_Type__c,
            Case_Comment_Code__r.Case_Product__r.Local_Product__r.Translated_Path__c
            from Fulfillment_Order__c where id =: ApexPages.currentPage().getParameters().get('id')];
        
        if(ffOrderObj.size()==0) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'FulfillmentOrder does not exist');
            return;
        }
        
        /** ALM 588 - Cas: instead of using brand from the case, use brand from the related comment code's product
       		if(ffOrderObj[0].case__r.brand__c !=null)
            	brand = ffOrderObj[0].case__r.brand__c; 
            
            if(ffOrderObj[0].case__r.segment__c!= null)
            	segment = ffOrderObj[0].case__r.segment__c;
        */
        String[] productLevels = ffOrderObj[0].Case_Comment_Code__r.Case_Product__r.Local_Product__r.Translated_Path__c.split('/');
        if (productLevels.size() > 0)
        	brand = productLevels[0];
        if (productLevels.size() > 1)
       		segment = productLevels[1];
        
        
        /* Old code from the previous system 
        
        else if(ffOrderObj[0].case__r.Amer_brand__c !=null)
            brand = ffOrderObj[0].case__r.Amer_brand__c;
        else if (ffOrderObj[0].case__r.Emea_brand__c != null)
            brand= ffOrderObj[0].case__r.Emea_brand__c;
        else if (ffOrderObj[0].case__r.Ceemea_brand__c!= null)
            brand = ffOrderObj[0].case__r.Ceemea_brand__c;
        else if(ffOrderObj[0].case__r.segment__c!= null)
            segment = ffOrderObj[0].case__r.Amer_segment__c ;
        else if(ffOrderObj[0].case__r.segment__c!= null)
            segment = ffOrderObj[0].case__r.Emea_segment__c;
        else if(ffOrderObj[0].case__r.segment__c!= null)
            segment = ffOrderObj[0].case__r.Ceemea_segment__c; 
           
        //majorArea     =   lstCase[0].topic__r.local_comment__r.major_area__c;
        //category     =   lstCase[0].topic__r.local_comment__r.category__c;
        //subcategory   =   lstCase[0].topic__r.local_comment__r.subcategory__c;
        //comDescription   =   lstCase[0].topic__r.local_comment__r.description__c;
        //subcategory   =   subcategory.replace(';', ':');
        //comDescription   =   comDescription.replace(';', ':');
        //category     =   category.replace(';', ':');
        //quickCode     =   lstCase[0].topic__r.local_comment__r.Global_Comment__r.Quick_Code__c;
         */ 
        
        commentType = ffOrderObj[0].Case_Comment_Code__r.Comment_Code_Type__c;
        country     =   ffOrderObj[0].case__r.country__c;
        language     =   ffOrderObj[0].case__r.language__c;
        firstName     =   ffOrderObj[0].contact__r.firstname;
        lastName     =   ffOrderObj[0].contact__r.lastname;
        salutation     =   ffOrderObj[0].contact__r.salutation;       
      system.debug('###### querying for template with country ' + ffOrderObj[0].case__r.country__c + 
                    ' contact center ' + uname[0].contact_center__c + 
                    ' language ' + ffOrderObj[0].case__r.language__c + 
                    ' brand ' + brand + 
                    ' segment ' + segment);
      templeteOptions = new list<selectoption>();       
      list<APXTConga4__Conga_Template__c> congaTemplates =[select id, APXTConga4__Name__c from APXTConga4__Conga_Template__c
              where Template_active__c = true and followup__c = false               
              and (country__c includes (:country)) 
              and (contact_center__c includes(:uname[0].contact_center__c))
              and (language__c includes(:language)) 
              and ((brand__C includes (:brand)) or brand__C = '')
              and ((segment__c includes(:segment)) or segment__c = '')              
              and (comment_type__c includes (:commentType) or comment_type__c ='')
              //and (major_area__c includes (:majorArea) or major_area__c ='' )
              //and (Category__c INCLUDES (:category) OR Category__c='')
              //and (Subcategory__c INCLUDES (:subcategory) OR Subcategory__c='') 
              //and (Com_Description__c INCLUDES (:comDescription) OR Com_Description__c='')
              //and (Quick_Code__c INCLUDES (:quickCode) OR Quick_Code__c='')
              //and type__c =null
              order by APXTConga4__Name__c];  
        for(APXTConga4__Conga_Template__c a: congaTemplates){
            templeteoptions.add(new selectoption(a.id,  a.APXTConga4__Name__c));
        }
        if(templeteoptions.size()>0)
            selectedTemp = templeteoptions[0].getvalue();
    }   
    
    // Search button 
    public PageReference search_new() {     
        if(String.isBlank(searching)) return null;
        system.debug('######## Search string: '+searching);
        //commentType   =   lstCase[0].Case_Comment_Code__r.Comment_Code_Type__c;
        //majorArea     =   lstCase[0].topic__r.local_comment__r.major_area__c;
        //category     =   lstCase[0].topic__r.local_comment__r.category__c;
        //subcategory   =   lstCase[0].topic__r.local_comment__r.subcategory__c;
        //comDescription   =   lstCase[0].topic__r.local_comment__r.description__c;
        //subcategory   =   subcategory.replace(';', ':');
        //comDescription   =   comDescription.replace(';', ':');
        //category    =  category.replace(';', ':');
        //quickCode     =   lstCase[0].topic__r.local_comment__r.Global_Comment__r.Quick_Code__c;
        if(searching.contains('*')) searching = searching.replace('*', '');    
        templeteOptions = new list<selectoption>();
            /*temp =[select id, apxt_cmtr__name__c from APXT_CMTR__Conga_Merge_Template__c 
                   where Template_active__c = true and type__c =null
                   and (country__c includes (:lstCase[0].case__r.country__c )) 
                           and (contact_center__c includes(:uname[0].contact_center__c))
                           and (language__c includes(: lstCase[0].case__r.language__c)) 
                   and ((segment__c includes(: segment)) or segment__c = '')
                           and (major_area__c includes (:majorArea) or major_area__c ='' )
                       and (comment_type__c includes (:commentType) or comment_type__c ='')
                           and (Category__c INCLUDES (:category) OR Category__c='')
                           and (Subcategory__c INCLUDES (:subcategory) OR Subcategory__c='') 
                           and (Com_Description__c INCLUDES (:comDescription) OR Com_Description__c='')
                           and (Quick_Code__c INCLUDES (:quickCode) OR Quick_Code__c='')
                           and (apxt_cmtr__name__c like :'%'+searching+'%')
                   order by apxt_cmtr__name__c];*/
        list<APXTConga4__Conga_Template__c> congaTemplates =[select id, APXTConga4__Name__c from APXTConga4__Conga_Template__c 
              where (country__c includes (:country )) 
              and (contact_center__c includes(:uname[0].contact_center__c))
              and (language__c includes(:language)) 
              and ((brand__C includes (:brand)) or brand__c = '')
              and (segment__c includes(:segment) or segment__c = '')
              //FIXME use comment type from ffOrder?
              and (comment_type__c includes (:commentType) or comment_type__c ='')
              // NOTE - ljo leaving this for reference from old org
              //and (major_area__c includes (:ffOrder[0].topic__r.Local_Comment__r.Major_Area__c) or major_area__c ='' )
              //and (comment_type__c includes (:ffOrder[0].Case_Comment_Code__r.Comment_Code_Type__c) or comment_type__c ='')
              //and (Category__c INCLUDES (:ffOrder[0].topic__r.Local_Comment__r.Category__c) OR Category__c='')
              //and (Subcategory__c INCLUDES (:ffOrder[0].topic__r.Local_Comment__r.Subcategory__c) OR Subcategory__c='') 
              and ((APXTConga4__Name__c like :'%'+searching+'%') or (Keywords__c like : '%'+searching+'%'))
              order by APXTConga4__Name__c];
        
        for(APXTConga4__Conga_Template__c a: congaTemplates){
            templeteoptions.add(new selectoption(a.id,  a.APXTConga4__Name__c));
        }
                       
        if(templeteoptions.isEmpty()){                
            templeteoptions.add(new selectoption('1', Label.Fulfillment_NoMatchingFound)); 
            selectedTemp = templeteoptions[0].getvalue();
        }
        else selectedTemp = templeteoptions[0].getvalue();  
        viewDis = '';
        viewTemplateName='';
        system.debug('######## templeteoptions: '+templeteoptions);               
        return null;  
    }  

    // Select button
    public PageReference selectBtn(){ 
        //selectedTemp=1 indicates that no results were found
        if(selectedTemp == '1') return null;
        //update the fulfillment order
        list<APXTConga4__Conga_Template__c> congaTemplates = [SELECT id, RTL_language__c,  HTML_Content__c FROM APXTConga4__Conga_Template__c where id =: selectedTemp];                
        if(congaTemplates.size()==0) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Template does not exist');
            return null;
        }
        Fulfillment_Order__c fforder = new Fulfillment_Order__c();
        fforder.id = ApexPages.currentPage().getParameters().get('Id');
        fforder.letter_body__c = replaceValues(congaTemplates[0].HTML_Content__c);
        fforder.Conga_Merge_Template_Id__c = congaTemplates[0].id;
        fforder.RTL_Language__c = congaTemplates[0].RTL_language__c;
        update fforder;
        //redirect to fulfillment order record
        PageReference pageRef = new PageReference('/'+fforder.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
        
    // View button  
    public PageReference viewbtn() {
        //rend = true;  
        //selectedTemp=1 indicates that no results were found
        if(selectedTemp == '1') return null;      
        list<APXTConga4__Conga_Template__c> congaTemplates = [SELECT id, APXTConga4__Name__c, HTML_Content__c FROM APXTConga4__Conga_Template__c where id =: selectedTemp];   
        if(congaTemplates.size()==0) return null;
        viewDis = congaTemplates[0].HTML_Content__c;
        viewTemplateName=congaTemplates[0].APXTConga4__Name__c;
        viewDis=  replaceValues(viewDis); 
        return null;       
    }
    
    //cancel button
    public PageReference cancelbtnAction(){
        PageReference pageRef = new PageReference('/'+ApexPages.currentPage().getParameters().get('Id'));
        pageRef.setRedirect(true);
        return pageRef;
    }
        
    // Replacing the maerge field values     
    public string replaceValues(string strBody)
    {
        if(strBody!=null && strBody!= ''){       
            if(strBody.contains('{Case.Brand}'))
                strBody = strBody.replace('{Case.Brand}', brand);
            if(strBody.contains('{Case.Segment}'))
                strBody= strBody.replace('{Case.Segment}', segment);
            if(strBody.contains('{Account.LastName}'))
                strBody= strBody.replace('{Account.LastName}', lastName);
            if(strBody.contains('{Account.FirstName}'))
                strBody= strBody.replace('{Account.FirstName}', FirstName);
            if(strBody.contains('{Account.Salutation}'))
                strBody= strBody.replace('{Account.Salutation}', Salutation);        
            if(strBody.contains('{Case.Country}'))
                strBody = strBody.replace('{Case.Country}', country);
            if(strBody.contains('{Case.Language}'))
                strBody = strBody.replace('{Case.Language}', Language);
        }   
        return strBody;
    }
}