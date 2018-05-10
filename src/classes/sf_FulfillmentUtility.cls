/*
* @author: Laure OMeara
* @date: 07/20/2014

* @description: 
* US496:
* This is the utility class for fulfillment from the old org
*/

global class sf_FulfillmentUtility {

    webservice static String checkForLetterGeneration(String forderId,String contactCenter){
        Set<String> itemTypes=new Set<String>();
        try{
            Fulfillment_Type_Exclusion__c cs=Fulfillment_Type_Exclusion__c.getValues(contactCenter);
            if(cs!=null){
                String[] types=cs.Fulfillment_Item_Type__c.split(';');
                
                for(String s:types)
                    itemTypes.add(s);

                System.debug('checkForLetterGeneration itemTypes \n' + itemTypes);
                
                List<Fulfillment_Order_Line_Item__c> ffItems=[Select Id from Fulfillment_Order_Line_Item__c 
                                                              where Fulfillment_Order__c=: forderId and Type__c not in : itemTypes];
                

                System.debug('checkForLetterGeneration ffItems \n' + ffItems);
                
                if(ffItems.size()>0)
                    return '1';
                else
                    return '0';
              
            }
            else
                return '0';
        }
        catch(Exception e){
            System.debug(e);
            return '0';
        }
    }
    
   
    public static Map<Id,case> getCasesForFollowups(Map<Id,case> mapallcases){
        Map<Id,case> mapcaseforfollowups=new Map<Id,case>();        
        date createddate = system.today();
        Set<Id> caseids=new Set<Id>();        
        For(EmailMessage em : [select Id,ParentId from EmailMessage where ParentId IN :mapallcases.keySet() AND createddate=TODAY ]){
            if(string.isNotBlank(em.ParentId))caseids.add(em.ParentId);
        } 

        for(Case c : mapallcases.values()){
            if(!caseids.contains(c.Id))mapcaseforfollowups.put(c.Id,c);
        }
 
        return mapcaseforfollowups;
    }
    
    public static Map<String,Id> getOrgWideEmails(){
        Map<String,Id> mapOrgWideEmailAddress = new Map<String,Id>();
        for(OrgWideEmailAddress owa : [select id, Address from OrgWideEmailAddress]) {
            mapOrgWideEmailAddress.put(owa.Address,owa.Id); 
        }
        return mapOrgWideEmailAddress;
    }
    
    public static Messaging.SingleEmailMessage sendemailmessage(string toaddress, ID fromAddress, string subject, 
        string plaintext, string htmlbody){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {toaddress};
        mail.setToAddresses(toAddresses);
        mail.setOrgWideEmailAddressId(fromAddress);
        mail.setSubject(subject);
        mail.setHtmlBody(htmlbody);
        return mail;
    }


    /********
    Fulfillment Order Trigger Functions 
    **********/    
    public static void PopulateMidnightLocalTime(Map<Id, Fulfillment_Order__c> oldFulfillmentOrderMap, Map<Id, Fulfillment_Order__c> newFulfillmentOrderMap)
    {
        try 
        {
            Set<String> PGPcountryList=new Set<String>();
            PGPcountryList.add('Austria-PGP');
            PGPcountryList.add('Belgium-PGP');
            PGPcountryList.add('France-PGP');
            PGPcountryList.add('Germany-PGP');
            PGPcountryList.add('Italy-PGP');
            PGPcountryList.add('Greece-PGP');
            PGPcountryList.add('Netherlands-PGP');
            PGPcountryList.add('Portugal-PGP');
            PGPcountryList.add('Spain-PGP');
            PGPcountryList.add('Ireland-PGP');
            PGPcountryList.add('Switzerland-PGP');
            PGPcountryList.add('United Kingdom-PGP');
            // New code - A&A project
            Set<String> JVcountryList=new Set<String>();
            JVcountryList.add('Spain-JV');
            JVcountryList.add('Portugal-JV');
            if(newFulfillmentOrderMap != null) // update
            {
                for(Fulfillment_Order__c ff:newFulfillmentOrderMap.values()){
                    if(ff.Locked_From_Editing__c==false && ff.Midnight_Local_Time__c==null && (ff.Status__c=='Open' || ff.Status__c=='Closed') && (ff.PDF_generated__c== true || ff.No_Letter_Needed__c==true || ff.Hermes_Country__c== 'Brazil' || ff.Contact_Center__c=='AMR LA SY' || JVcountryList.contains(ff.Case_Country__c)))
                    {
                         DateTime dt=ff.LastModifiedDate;
                         DateTime midnightLocalTime = DateTime.newInstance(dt.year(), dt.month(), dt.day());
                         midnightLocalTime = midnightLocalTime.addDays(1).addMinutes(-1);
                        //System.debug('**** Midnight: ' + midnightLocalTime);
                         ff.Midnight_Local_Time__c = midnightLocalTime;
                    }
                    if(ff.Midnight_Local_Time__c!=null && (ff.Status__c =='Draft' || (ff.no_letter_needed__c==false && ff.Hermes_Country__c!= 'Brazil' && ff.Contact_Center__c!='AMR LA SY' && ff.PDF_generated__c==false &&  !(JVcountryList.contains(ff.Case_Country__c)))))
                    {
                        ff.Midnight_Local_Time__c = null;
                    }
                    
                }
            } else // delete
            {
                String errMessageDel = Label.Fulfillment_FulfillmentOrderDeleteError;
                
                for(Fulfillment_Order__c o: oldFulfillmentOrderMap.values()){
                    if (o.Locked_from_Editing__c == true) {
                        o.addError(errMessageDel);
                    }
                }
            }
        } // end of try
        catch(System.Exception e)
        {
            System.Debug(e);
        }
    }
    
    /********
    Fulfillment Order Line Item Trigger Functions 
    **********/
    //Deprecated Mar 2017 WR422
    //Ported from legacy - hard coded Ids are from Legacy - this code has never worked in Kardia
    /*public static void CheckFulfillmentOrderLock(Map<Id, Fulfillment_Order_Line_Item__c> oldFulfillmentOrderLineItemMap, Map<Id, Fulfillment_Order_Line_Item__c> newFulfillmentOrderLineItemMap)    
    {
        try
        {
            String LineItem_Del_Message = Label.Fulfillment_FulfillmentOrderLineItemDeleteError;
            
            Set<ID> FFOrder = new Set<ID>();
            for(Fulfillment_Order_Line_Item__c t: oldFulfillmentOrderLineItemMap.values())
                FFOrder.add(t.fulfillment_Order__c);
            Set<ID> closedFFOrder = new Set<Id>();
            for(Fulfillment_Order__c fo: [select id from Fulfillment_Order__c where Status__c = 'Closed' AND Id in :FFOrder])
                closedFFOrder.add(fo.Id);
            
            for(Fulfillment_Order_Line_Item__c t: oldFulfillmentOrderLineItemMap.values())
            {
                String pid = (String.valueOf(user.profileId)).substring(0,15);
                System.debug(t.Fulfillment_Order__c);
                system.debug(pid);
                if(closedFFOrder.contains(t.Fulfillment_Order__c) && pid <> '00e700000012lb5'&& pid<>'00e700000013gTi' && pid<>'00e700000013gTg' && pid<>'00e700000013gTk' && pid<>'' && pid<>'00e700000013W5m' && pid<>'00e700000013gTt' && pid<>'00e700000013gTv' && pid<>'00e700000013gTw'&& pid<>'00e700000013gTx' )
                {
                    System.debug('testing');
                    t.addError(LineItem_Del_Message );
                }
            }
        }
        catch(System.Exception e)
          {System.Debug(e);}
    }*/
    
    
    
    /********
    Fulfillment Item Trigger Functions 
    **********/
        
    public static void FulfillmentItemValidation(List<Fulfillment_Item__c> newFulfillmentItems)    
    {   
        Set<String> b=new Set<String>();
        String len='';
        String len2='';
        String len3='';
        String len4='';
        Set<Id> fIds = new Set<Id>();
        
        for (Fulfillment_Item__c fi2: newFulfillmentItems)
        {
            if(fi2.Type__c=='CO' && fi2.Contact_Country__c=='United States of America' && fi2.Preprinted__c==false)
                fIds.add(fi2.Id);
        }        
        if(fIds.size() > 0)
        {   
            for (AggregateResult lp :[select Name from Local_Product__c where
                  path_level__c = 'BRAND' AND
                  Country__c = 'United States of America' AND Inactive__c=false AND
                  Name != null
                  GROUP BY Name
                  ORDER BY Name])
            {
                b.add(String.valueOf(lp.get('Name')));
            }
        
            for(Fulfillment_Item__c fi2: newFulfillmentItems){
                if(fIds.contains(fi2.Id)) {
                    if(fi2.COMPANY_PREFIX__c!=null && fi2.COMPANY_PREFIX__c!='')
                        len = String.valueOf(fi2.COMPANY_PREFIX__c.length()-6);
                    
                    if(fi2.SAVE_VALUE__c!=null && fi2.SAVE_VALUE__c!='')
                        len2 = String.valueOf(fi2.SAVE_VALUE__c.length());
                    
                    if(fi2.PRIMARY_PURCHASE_REQ__c!=null && fi2.PRIMARY_PURCHASE_REQ__c!='')
                        len3= String.valueOf(fi2.PRIMARY_PURCHASE_REQ__c.length());
                    
                    if(fi2.Coupon_Type__c==null || fi2.Coupon_Type__c=='' || fi2.Coupon_Type__c.length()!=2)
                        fi2.addError('Please enter Coupon type');
                    
                    else if(fi2.Family_Code__c==null || fi2.Family_Code__c=='' || fi2.Family_Code__c.length()!=3)
                        fi2.addError('Please enter  3 digit Family Code');
                    
                    else if(fi2.Brand__c==null || fi2.Brand__c=='')
                        fi2.addError('Please enter Brand');
                    
                    else if(fi2.Brand__c!=null && fi2.Brand__c!='' && (!(b.contains(fi2.Brand__c))))
                        fi2.addError('Please enter a Valid Brand');
                    
                    else if(fi2.Manufacturer_ID__c==null || fi2.Manufacturer_ID__c=='' || fi2.Manufacturer_ID__c.length()!=5)
                        fi2.addError('Please enter  5 digit Manufacture ID');
                    
                    else if(fi2.Form_ID__c==null || fi2.Form_ID__c=='' || fi2.Form_ID__c.length()> 6)
                        fi2.addError('Please enter a numeric Form ID with maximum of 6 digits');
                    
                    else if(fi2.Coupon_Description__c==null || fi2.Coupon_Description__c=='' || fi2.Coupon_Description__c.length()>80)
                        fi2.addError('Please enter Coupon Description with maximum of 80 characters');
                    
                    else if(fi2.Expiration_Date__c==null) 
                        fi2.addError('Please enter Expiration Date');
                    
                    else if(fi2.APPLICATION_IDENTIFIER__c==null || fi2.APPLICATION_IDENTIFIER__c=='' || fi2.APPLICATION_IDENTIFIER__c!='8110')
                        fi2.addError('Please Enter APPLICATION IDENTIFIER as 8110');
                    
                    else if(fi2.COMPANY_PREFIX__c==null || fi2.COMPANY_PREFIX__c=='' || fi2.COMPANY_PREFIX__c.length()>12 )
                        fi2.addError('Please enter a numeric COMPANY PREFIX with maximum of 12 digits');
                    
                    else if(fi2.COMPANY_PREFIX_VLI__c==null || fi2.COMPANY_PREFIX_VLI__c=='')
                        fi2.addError('Please enter COMPANY PREFIX VLI');  
                                 
                    else if(fi2.COMPANY_PREFIX_VLI__c !=null && fi2.COMPANY_PREFIX_VLI__c !='' && fi2.COMPANY_PREFIX_VLI__c!=len)
                        fi2.addError('COMPANY PREFIX VLI should be '+(fi2.COMPANY_PREFIX__c.length()-6));
                    
                    else if(fi2.SAVE_VALUE__c==null || fi2.SAVE_VALUE__c=='')
                        fi2.addError('Please enter SAVE VALUE');
                          
                    else if(fi2.SAVE_VALUE_VLI__c==null || fi2.SAVE_VALUE_VLI__c=='')
                        fi2.addError('Please enter SAVE VALUE VLI');
                    
                    else if(fi2.SAVE_VALUE_VLI__c!=null && fi2.SAVE_VALUE_VLI__c!=''  && fi2.SAVE_VALUE_VLI__c != len2 )
                        fi2.addError('SAVE VALUE VLI must be '+len2);
                    
                    else if(fi2.PRIMARY_PURCHASE_REQ__c==null || fi2.PRIMARY_PURCHASE_REQ__c=='')
                        fi2.addError('Please enter PRIMARY PURCHASE REQ VALUE');
                    
                    else if(fi2.PRIMARY_PURCHASE_REQ_VLI__c==null || fi2.PRIMARY_PURCHASE_REQ_VLI__c=='')
                        fi2.addError('Please enter PRIMARY PURCHASE REQ VLI');
                    
                    else if(fi2.PRIMARY_PURCHASE_REQ_VLI__c !=null &&  fi2.PRIMARY_PURCHASE_REQ_VLI__c !='' && fi2.PRIMARY_PURCHASE_REQ_VLI__c != len3)
                        fi2.addError('PRIMARY PURCHASE REQ VLI must be '+len3);
                    
                    else if(fi2.PRIMARY_PURCHASE_REQ_CODE__c==null || fi2.PRIMARY_PURCHASE_REQ_CODE__c=='')
                        fi2.addError('Please enter PRIMARY PURCHASE REQ CODE');
                    
                    else if( fi2.MISC_ELEMENTS__c !='9'&& fi2.MISC_ELEMENTS__c != null)
                        fi2.addError('MISC ELEMENTS should have 9 for Free Coupon or no value');
                                    
                    else if(fi2.MISC_ELEMENTS__c=='9' && fi2.SAVE_VALUE_CODE__c!='1')
                        fi2.addError('SAVE VALUE CODE should be 1');
                    
                    else if(fi2.MISC_ELEMENTS__c != '9' && fi2.SAVE_VALUE_CODE__c!=null)
                        fi2.addError('SAVE VALUE CODE should be null');
                    
                    else if(fi2.MISC_ELEMENTS__c=='9' && fi2.SAVE_VALUES_APPLIES_TO__c!='0')
                        fi2.addError('SAVE VALUES APPLIES TO should be 0'); 
    
                    else if(fi2.MISC_ELEMENTS__c!='9'  && fi2.SAVE_VALUES_APPLIES_TO__c!= NULL)
                        fi2.addError('SAVE VALUES APPLIES TO should be null');
                    else if(fi2.MISC_ELEMENTS__c=='9'&& fi2.Store_Coupon__c!='0')
                        fi2.addError('Store Coupon should be 0');
    
                    else if(fi2.MISC_ELEMENTS__c!='9' && fi2.Store_Coupon__c!=NULL)
                        fi2.addError('Store Coupon should be null');
    
                    else if(fi2.MISC_ELEMENTS__c=='9'  && fi2.DO_NOT_MULTIPLY__c!='0')
                        fi2.addError('DO NOT MULTIPLY should be 0');
    
                    else if(fi2.MISC_ELEMENTS__c!='9' && fi2.DO_NOT_MULTIPLY__c!= null)
                        fi2.addError('DO NOT MULTIPLY should be null');
        
                }
            }
        }
        for (Fulfillment_Item__c fi2: newFulfillmentItems){
            String checkDigit = '5';
        
            if (fi2.Type__c == 'CO' && (fi2.Contact_Country__c=='United States of America' || fi2.Contact_Country__c=='Canada'))
                fi2.Check_Digit__c = checkDigit;
        }   
    }
    
    public static void getPrefixTitle(List<Case> triggerNew, Map<ID,Case> oldCases, Boolean isInsert, Boolean isUpdate){
        Set<ID> contactIds = new Set<ID>();
        Set<ID> caseIds = new Set<ID>();
        Set<String> countries = new Set<String>();
        Set<String> languages = new Set<String>();
        Set<String> salutations = new Set<String>();
        List<Metadata_Title_Prefix__c> salutationList = new List<Metadata_Title_Prefix__c>();
        Map<ID, Contact> contactMap = new Map<ID, Contact>();
        String translatedSalutation;
      
      for(Case cObj: triggerNew){
          If(isInsert || (IsUpdate && oldCases.get(cObj.ID).contactId != cObj.contactId)){   
              if(String.isNotBlank(cObj.Country__c)) countries.add(cObj.Country__c);
              if(String.isNotBlank(cObj.Language__c)) languages.add(cObj.Language__c);
              if(String.isNotBlank(cObj.contactId)) contactIds.add(cObj.contactId);
              caseIds.add(cObj.Id);
          }
      }
      //checks if any FO exists satisfying above criteria
      If(contactIds.size() != 0){ 
        contactMap = new Map<ID, Contact>([select Id, Salutation from Contact where Id in :ContactIds and Salutation!=null]);    
        for(ID c: contactMap.keySet())
            salutations.add(contactMap.get(c).Salutation);
        salutationList = [select ID, Country__c, Language__c, Prefix__c, Full_Title__c from Metadata_Title_Prefix__c where Language__c in :languages AND Country__c in :countries AND Prefix__c in :salutations]; 
      }//end IF
       
      for(Case cObj : triggerNew){ 
          translatedSalutation = ''; 
          if(!caseIds.contains(cObj.Id)) continue;  
          for(Metadata_Title_Prefix__c mtpObj : salutationList){
              if(cObj.ContactId!=null && cObj.Country__c == mtpObj.Country__c && cObj.Language__c == mtpObj.Language__c && contactMap.get(cObj.ContactId).Salutation == mtpObj.Prefix__c){
                  translatedSalutation = mtpObj.Full_Title__c;
              }
          }
          cObj.Prefix_Title__c = translatedSalutation;   
      } 
          
    }
    
    /*
    Author: Chris Doyle
    Date: 31/10/2016
    Desc: there are 4 workflow rules that reference the Monetary_Threshold__c field 
    */
    public static void SetCorrectMonetaryThreshold(List <Fulfillment_Order__c> newFulfillmentOrderList){ 

        Map<String,String> m1; 
        string fieldToQuery;

        system.debug('CDOY Entered newFulfillmentOrderList ' +newFulfillmentOrderList );

        list<fulfillment_Order__c> foListWONulls = new list<fulfillment_Order__c>();

        //loop through newFulfillmentOrderList and only add ff orders greater than zero to the new list
        for(fulfillment_Order__c fo : newFulfillmentOrderList){
            if(fo.Total_Monetary_Value__c > 0){
                foListWONulls.add(fo);
            }
        }

        //line below if new list is not empty
        if(!foListWONulls.isEmpty()){
            
            //create a map of the users currenuty() where the key is the currency (left three (USD)) 
            //and the value is the field name USD_MOnetary Threshold

            Map<string, string> UserCurrencyFields = new Map<string, String>();

            string fieldsToQuery;
            List<Schema.SObjectType> objects = new List<Schema.SObjectType>{User.SObjectType};
            for(Schema.SObjectType objType: objects){
                for(Schema.SObjectField fld: objType.getDescribe().fields.getMap().values()){
                    if(fld.getDescribe().getName().contains('_Monetary_Threshold__c')){
                        UserCurrencyFields.put(fld.getDescribe().getName().left(3) , fld.getDescribe().getName());

                        if(fieldsToQuery == null){
                            fieldsToQuery = fld.getDescribe().getName();
                        }
                        else {
                            fieldsToQuery += ', ' + fld.getDescribe().getName();
                        }
                    }
                }
            }   

            //WR450 - New field created in the global org setting to store the Conga Merge running user.
            Global_Org_Settings__c gos = Global_Org_Settings__c.getInstance();
            string congaUserId = gos.Conga_Running_User_ID__c;

            String userID = UserInfo.getUserId();
            String userCurrencyMonetaryThreshold = 'SELECT ' + fieldsToQuery + ' FROM User WHERE id =: userID AND id != :congaUserID LIMIT 1';

            //CDOY WR450 -
            //String userCurrencyMonetaryThreshold = 'SELECT ' + fieldsToQuery + ' FROM User WHERE id =: userID LIMIT 1';

            //For loop to go throigh the FF orders to get their currencys and replace list of currecnys in field to query
            // Query the user then for loop through again to go through the logic below

            List<User> results = Database.query(userCurrencyMonetaryThreshold);
            //To Do Automated USer Check
            //Add if statement round this
            if(!results.isEmpty()){
                user u = results[0];
                Map<String, Object> fieldsToValue = u.getPopulatedFieldsAsMap();

                for(fulfillment_Order__c ffOrder : foListWONulls){
                    string currencyOfCase = ffOrder.Case_Currency__c;

                    double userThreshold = 0;

                    //userThreshold = (double)u.get(UserCurrencyFields.get(currencyOfCase));
                    userThreshold = double.valueOf(u.get(UserCurrencyFields.get(currencyOfCase)));

                    /*
                    This IF statement replaces the 'Fulfillment Threshold Exceeded' Workflow Rule
                    Rule Criteria - Fullfillment_Amount_Roll_Up__c > CreatedBy.Monetary_Threshold__c
                    */
                    if(ffOrder.Fullfillment_Amount_Roll_Up__c > userThreshold){
                        ffOrder.status__c = 'Draft';  
                        ffOrder.Above_Monetary_Threshold__c = TRUE;
                    }

                    /*
                    This IF statement replaces the 'Fulfillment Threshold Exceeded (Inverse)' Workflow Rule
                    Rule Criteria - AND ( Above_Monetary_Threshold__c ,(Fullfillment_Amount_Roll_Up__c < CreatedBy.Monetary_Threshold__c ),ISPICKVAL(Status__c,"Draft"))
                    */
                    if(ffOrder.Above_Monetary_Threshold__c == TRUE 
                    && ffOrder.Fullfillment_Amount_Roll_Up__c < userThreshold
                    && ffOrder.status__c == 'Draft'
                    && ffOrder.Approve_Amount__c != TRUE){
                        
                        ffOrder.Above_Monetary_Threshold__c = FALSE;
                        ffOrder.status__c = 'Open';
                    }
                    
                    /*
                    This IF statement replaces the 'Monetary Approval' Workflow Rule
                    Rule Criteria   AND ( Above_Monetary_Threshold__c,(Fullfillment_Amount_Roll_Up__c < $User.Monetary_Threshold__c) , ISPICKVAL(Status__c,"Draft"), Approve_Amount__c = TRUE)
                    */
                    if(ffOrder.Above_Monetary_Threshold__c == TRUE 
                    && ffOrder.Fullfillment_Amount_Roll_Up__c < userThreshold
                    && ffOrder.status__c == 'Draft'
                    && ffOrder.Approve_Amount__c == TRUE){
                        
                        ffOrder.Above_Monetary_Threshold__c = FALSE;
                        ffOrder.status__c = 'Open';
                    }
                } 
            }
        }
    } 
}