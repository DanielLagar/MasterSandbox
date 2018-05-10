/**
* @author: Ashok Bommali
* @date: 08/22/2014
* @description: Code coverage class
*/
@isTest
private class sf_FulfillmentUtilityTest {

    public static testMethod void myTest1(){
        //TODO: move any test records creation code to a utility for testMethods
        //Create a user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User userObj = new User(Alias = 'Test', Email='test+' + System.Math.random()  + '@salesforce.com', 
      		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      		LocaleSidKey='en_US', ProfileId = p.Id, 
      		TimeZoneSidKey='America/Los_Angeles', UserName='test' + System.Math.random() + '@salesforce.com');
        insert userObj;
        
        System.runAs(userObj) {
            CustomSettingDataFactory.countryRegionSetup();
        	Case c = createCase('Gillette', 'United States of America', 'English-US', 'Shaver', 'NA', 'Open');
        	Fulfillment_Order__c ffoObj = createFFOrder(c);
            APXTConga4__Conga_Template__c tempObj = createCongaTemplate('Test', 'United States of America', 'NA', 'English-US', 'Gillette', 'Shaver');
			Fulfillment_Order_Line_Item__c fforderlineItem = createFFOrderLineItem(ffoObj);
            Fulfillment_Type_Exclusion__c fftypeExObj = createFFtypeExclusion('CR;CP;CH;PP', 'NA');           
            sf_FulfillmentUtility.checkForLetterGeneration(ffoObj.Id,'NA');
            
            //code coverage for getCasesForFollowups
            Map<Id,case> mapCaseObjs = new Map<Id,case>();
            mapCaseObjs.put(c.Id, c);
            sf_FulfillmentUtility.getCasesForFollowups(mapCaseObjs);
            
            //code coverage for getOrgWideEmails
            Map<String,Id> orgwideAdds=sf_FulfillmentUtility.getOrgWideEmails();
            
            //code coverage for sendemailmessage
            sf_FulfillmentUtility.sendemailmessage('test@salesforce.com', null, 'subject', 'plaintext', 'htmlbody');
        
            //code coverage for PopulateMidnightLocalTime
            Map<Id, Fulfillment_Order__c> oldFulfillmentOrderMap =new Map<Id, Fulfillment_Order__c>();
            oldFulfillmentOrderMap.put(ffoObj.Id, ffoObj);
            Map<Id, Fulfillment_Order__c> newFulfillmentOrderMap=new Map<Id, Fulfillment_Order__c>();
            newFulfillmentOrderMap.put(ffoObj.Id, ffoObj);
            sf_FulfillmentUtility.PopulateMidnightLocalTime(oldFulfillmentOrderMap, newFulfillmentOrderMap);
            
            //code coverage for CheckFulfillmentOrderLock //WR422
            /*Map<Id, Fulfillment_Order_Line_Item__c> oldFulfillmentOrderLineItemMap=new Map<Id, Fulfillment_Order_Line_Item__c>();
            oldFulfillmentOrderLineItemMap.put(fforderlineItem.Id, fforderlineItem);
            Map<Id, Fulfillment_Order_Line_Item__c> newFulfillmentOrderLineItemMap=new Map<Id, Fulfillment_Order_Line_Item__c>();
            newFulfillmentOrderLineItemMap.put(fforderlineItem.Id, fforderlineItem);
            sf_FulfillmentUtility.CheckFulfillmentOrderLock(oldFulfillmentOrderLineItemMap, newFulfillmentOrderLineItemMap);*/
            
        }   
    }
    
    public static testMethod void myTest2(){
        Boolean isSuccess=false;
        Database.SaveResult srList;
        
        Global_Product__c gpObj = createGlobalProduct('Gillette');            
        Local_Product__c lcObj = createLocalProduct('Gillette', 'United States of America', gpObj);
        
        srList=insertFulfillmentTestRecord('CO', 'Shaver', 'United States of America', 'NA', null, null,
    	null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
        system.assertEquals(srList.isSuccess(), false);
        
        srList=insertFulfillmentTestRecord('CO', 'Shaver', 'United States of America', 'NA', 'Gillette', null,
    	null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
        system.assertEquals(srList.isSuccess(), false);
        
        srList=insertFulfillmentTestRecord('CO', 'Shaver', 'United States of America', 'NA', 'Gillette', 'CP',
    	null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
        system.assertEquals(srList.isSuccess(), false);
        
        srList=insertFulfillmentTestRecord('CO', 'Shaver', 'United States of America', 'NA', 'Gillette', 'CP',
    	'123', null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
        system.assertEquals(srList.isSuccess(), false);
        
        srList=insertFulfillmentTestRecord('CO', 'Shaver', 'United States of America', 'NA', 'Gillette', 'CP',
    	'123', '12345', null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
        system.assertEquals(srList.isSuccess(), false);
        
        srList=insertFulfillmentTestRecord('CO', 'Shaver', 'United States of America', 'NA', 'Gillette', 'CP',
    	'123', '12345', '12345', null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
        system.assertEquals(srList.isSuccess(), false);
        
        srList=insertFulfillmentTestRecord('CO', 'Shaver', 'United States of America', 'NA', 'Gillette', 'CP',
    	'123', '12345', '12345', 'Test Test', null, null, null, null, null, null, null, null, null, null, null, null, null, null);
        system.assertEquals(srList.isSuccess(), false);
        
        srList=insertFulfillmentTestRecord('CO', 'Shaver', 'United States of America', 'NA', 'Gillette', 'CP',
    	'123', '12345', '12345', 'Test Test', System.now(), null, null, null, null, null, null, null, null, null, null, null, null, null);
        system.assertEquals(srList.isSuccess(), false);
        
        srList=insertFulfillmentTestRecord('CO', 'Shaver', 'United States of America', 'NA', 'Gillette', 'CP',
    	'123', '12345', '12345', 'Test Test', System.now(), '8110', null, null, null, null, null, null, null, null, null, null, null, null);
        system.assertEquals(srList.isSuccess(), false);
        
        srList=insertFulfillmentTestRecord('CO', 'Shaver', 'United States of America', 'NA', 'Gillette', 'CP',
    	'123', '12345', '12345', 'Test Test', System.now(), '8110', '1234567', null, null, null, null, null, null, null, null, null, null, null);
        system.assertEquals(srList.isSuccess(), false);
        
        srList=insertFulfillmentTestRecord('CO', 'Shaver', 'United States of America', 'NA', 'Gillette', 'CP',
    	'123', '12345', '12345', 'Test Test', System.now(), '8110', '1234567', '1', null, null, null, null, null, null, null, null, null, null);
        system.assertEquals(srList.isSuccess(), false);
        
        srList=insertFulfillmentTestRecord('CO', 'Shaver', 'United States of America', 'NA', 'Gillette', 'CP',
    	'123', '12345', '12345', 'Test Test', System.now(), '8110', '1234567', '8', null, null, null, null, null, null, null, null, null, null);
        system.assertEquals(srList.isSuccess(), false);
        
        srList=insertFulfillmentTestRecord('CO', 'Shaver', 'United States of America', 'NA', 'Gillette', 'CP',
    	'123', '12345', '12345', 'Test Test', System.now(), '8110', '1234567', '1', 'Test', null, null, null, null, null, null, null, null, null);
        system.assertEquals(srList.isSuccess(), false);
        
        srList=insertFulfillmentTestRecord('CO', 'Shaver', 'United States of America', 'NA', 'Gillette', 'CP',
    	'123', '12345', '12345', 'Test Test', System.now(), '8110', '1234567', '1', 'Test', '4', null, null, null, null, null, null, null, null);
        system.assertEquals(srList.isSuccess(), false);
        
        srList=insertFulfillmentTestRecord('CO', 'Shaver', 'United States of America', 'NA', 'Gillette', 'CP',
    	'123', '12345', '12345', 'Test Test', System.now(), '8110', '1234567', '1', 'Test', '8', null, null, null, null, null, null, null, null);
        system.assertEquals(srList.isSuccess(), false);
        
        srList=insertFulfillmentTestRecord('CO', 'Shaver', 'United States of America', 'NA', 'Gillette', 'CP',
    	'123', '12345', '12345', 'Test Test', System.now(), '8110', '1234567', '1', 'Test', '4', '12', null, null, null, null, null, null, null);
        system.assertEquals(srList.isSuccess(), false);
        
        srList=insertFulfillmentTestRecord('CO', 'Shaver', 'United States of America', 'NA', 'Gillette', 'CP',
    	'123', '12345', '12345', 'Test Test', System.now(), '8110', '1234567', '1', 'Test', '4', '12', '2', null, null, null, null, null, null);
        system.assertEquals(srList.isSuccess(), false);
        
        srList=insertFulfillmentTestRecord('CO', 'Shaver', 'United States of America', 'NA', 'Gillette', 'CP',
    	'123', '12345', '12345', 'Test Test', System.now(), '8110', '1234567', '1', 'Test', '4', '12', '8', null, null, null, null, null, null);
        system.assertEquals(srList.isSuccess(), false);
        
        srList=insertFulfillmentTestRecord('CO', 'Shaver', 'United States of America', 'NA', 'Gillette', 'CP',
    	'123', '12345', '12345', 'Test Test', System.now(), '8110', '1234567', '1', 'Test', '4', '12', '2', '9', null, null, null, null, null);
        system.assertEquals(srList.isSuccess(), false);
        
        srList=insertFulfillmentTestRecord('CO', 'Shaver', 'United States of America', 'NA', 'Gillette', 'CP',
    	'123', '12345', '12345', 'Test Test', System.now(), '8110', '1234567', '1', 'Test', '4', '12', '2', '1', null, null, null, null, '12');
        system.assertEquals(srList.isSuccess(), false);
        
        srList=insertFulfillmentTestRecord('CO', 'Shaver', 'United States of America', 'NA', 'Gillette', 'CP',
    	'123', '12345', '12345', 'Test Test', System.now(), '8110', '1234567', '1', 'Test', '4', '12', '2', '1', '2', null, null, null, '12');
        system.assertEquals(srList.isSuccess(), false);
        
        srList=insertFulfillmentTestRecord('CO', 'Shaver', 'United States of America', 'NA', 'Gillette', 'CP',
    	'123', '12345', '12345', 'Test Test', System.now(), '8110', '1234567', '1', 'Test', '4', '12', '2', '9', '1', null, null, null, null);
        system.assertEquals(srList.isSuccess(), false);
        
        srList=insertFulfillmentTestRecord('CO', 'Shaver', 'United States of America', 'NA', 'Gillette', 'CP',
    	'123', '12345', '12345', 'Test Test', System.now(), '8110', '1234567', '1', 'Test', '4', '12', '2', '9', '8', null, null, null, '12');
        system.assertEquals(srList.isSuccess(), false);
        
        srList=insertFulfillmentTestRecord('CO', 'Shaver', 'United States of America', 'NA', 'Gillette', 'CP',
    	'123', '12345', '12345', 'Test Test', System.now(), '8110', '1234567', '1', 'Test', '4', '12', '2', '9', '1', '0', null, null, null);
        system.assertEquals(srList.isSuccess(), false);
        
        srList=insertFulfillmentTestRecord('CO', 'Shaver', 'United States of America', 'NA', 'Gillette', 'CP',
    	'123', '12345', '12345', 'Test Test', System.now(), '8110', '1234567', '1', 'Test', '4', '12', '2', '9', '1', '0', '0', null, null);
        system.assertEquals(srList.isSuccess(), false);
        
        srList=insertFulfillmentTestRecord('CO', 'Shaver', 'United States of America', 'NA', 'Gillette', 'CP',
    	'123', '12345', '12345', 'Test Test', System.now(), '8110', '1234567', '1', 'Test', '4', '12', '2', '9', '1', '0', '0', '0', null);
        system.assertEquals(srList.isSuccess(), false);
        
        srList=insertFulfillmentTestRecord('CO', 'Shaver', 'United States of America', 'NA', 'Gillette', 'CP',
    	'123', '12345', '12345', 'Test Test', System.now(), '8110', '1234567', '1', 'Test', '4', '12', '2', '9', '1', '0', '0', '3', null);
        system.assertEquals(srList.isSuccess(), false);
        
        srList=insertFulfillmentTestRecord('CO', 'Shaver', 'United States of America', 'NA', 'Gillette', 'CP',
    	'123', '12345', '12345', 'Test Test', System.now(), '8110', '1234567', '1', 'Test', '4', '12', '2', '9', '1', '0', '0', '0', '12');
        system.assertEquals(srList.isSuccess(), true);
                

    }
    
    public static Case createCase(string brand, string country, string lang, string segment, string contactcenter, string status){
        Case c = new Case();
        c.Status = status;
        c.country__c = country;
        c.Language__c = lang;
        //c.Amer_Brand__c = brand;
        //c.Amer_Segment__c = segment;
        c.Contact_Center__c = contactcenter;
        insert c;
        return c;
    }
    
    public static Fulfillment_Order__c createFFOrder(Case c){
        Fulfillment_Order__c ffoObj=new Fulfillment_Order__c();
        ffoObj.Case__c = c.Id;
        insert ffoObj;
        return ffoObj;
    }
    
    public static APXTConga4__Conga_Template__c createCongaTemplate(string name, string country, string ccenter, string language, string brand, string segment){
        //Create a APXTConga4__Conga_Template__c
        APXTConga4__Conga_Template__c tempObj = new APXTConga4__Conga_Template__c();
        tempObj.APXTConga4__Name__c=name;
        tempObj.country__c=country;
        tempObj.contact_center__c=ccenter;
        tempObj.language__c=language;
        tempObj.brand__C=brand;
        tempObj.segment__c=segment;
        insert tempObj;
        return tempObj;
    }
    
    public static Fulfillment_Order_Line_Item__c createFFOrderLineItem(fulfillment_Order__c ffoObj){
        Fulfillment_Order_Line_Item__c fforderlineItem = new Fulfillment_Order_Line_Item__c();
        fforderlineItem.fulfillment_Order__c=ffoObj.Id;
        insert fforderlineItem;
        return fforderlineItem;
    }
    
    public static Fulfillment_Type_Exclusion__c createFFtypeExclusion(string type, string name){
        Fulfillment_Type_Exclusion__c fftypeExObj=new Fulfillment_Type_Exclusion__c();
        fftypeExObj.Fulfillment_Item_Type__c = type;
        fftypeExObj.Name=name;
        insert fftypeExObj;
        return fftypeExObj;
    }
    
    public static Global_Product__c createGlobalProduct(string brand){
        //insert a record in Global_Product__r
        Global_Product__c gpObj=new Global_Product__c();
        gpObj.Inactive__c=false;
        gpObj.Path__c=brand;
        insert gpObj;
        return gpObj;
    }
    
    public static Local_Product__c createLocalProduct(string brand, string country, Global_Product__c gpObj){
        //insert a record in Local_Product__c
        Local_Product__c lcObj=new Local_Product__c();
        lcObj.Brand__c=brand;
        lcObj.Country__c=country;
        lcObj.Inactive__c=false;
        lcObj.Global_Product__c=gpObj.Id;
        lcObj.name = 'Gillette';
        insert lcObj;
        return lcObj;
    }
    
    public static Database.SaveResult insertFulfillmentTestRecord(
    string fftype, string segment, string country, string ccenter, string brand, string coupontype,
    string familycode, string Manufacturer_ID, string formId, string couponDesc, Datetime Expiration_Date,
    string APPLICATION_IDENTIFIER, string COMPANY_PREFIX, string COMPANY_PREFIX_VLI, string SAVE_VALUE,
    string SAVE_VALUE_VLI, string PRIMARY_PURCHASE_REQ, string PRIMARY_PURCHASE_REQ_VLI, string MISC_ELEMENTS,
    string SAVE_VALUE_CODE, string SAVE_VALUES_APPLIES_TO, string Store_Coupon, string DO_NOT_MULTIPLY,
    string PRIMARY_PURCHASE_REQ_CODE){
        //insert a Fulfillment_Item__c
        Fulfillment_Item__c ffItem=new Fulfillment_Item__c();
        if(string.isNotBlank(fftype))ffItem.Type__c=fftype;        
        if(string.isNotBlank(segment))ffItem.Segment__c=segment;
        if(string.isNotBlank(country))ffItem.Contact_Country__c=country;
        if(string.isNotBlank(ccenter))ffItem.Contact_Center__c=ccenter;        
        if(string.isNotBlank(brand))ffItem.Brand__c=brand;        
        if(string.isNotBlank(coupontype))ffItem.Coupon_Type__c=coupontype;        
        if(string.isNotBlank(familycode))ffItem.Family_Code__c=familycode;        
        if(string.isNotBlank(Manufacturer_ID))ffItem.Manufacturer_ID__c=Manufacturer_ID;        
        if(string.isNotBlank(formId))ffItem.Form_ID__c=formId;        
        if(string.isNotBlank(couponDesc))ffItem.Coupon_Description__c=couponDesc;        
        if(Expiration_Date!=null)ffItem.Expiration_Date__c=Expiration_Date;        
        if(string.isNotBlank(APPLICATION_IDENTIFIER))ffItem.APPLICATION_IDENTIFIER__c=APPLICATION_IDENTIFIER;        
        if(string.isNotBlank(COMPANY_PREFIX))ffItem.COMPANY_PREFIX__c=COMPANY_PREFIX;        
        if(string.isNotBlank(COMPANY_PREFIX_VLI))ffItem.COMPANY_PREFIX_VLI__c=COMPANY_PREFIX_VLI;        
        if(string.isNotBlank(SAVE_VALUE))ffItem.SAVE_VALUE__c=SAVE_VALUE;        
        if(string.isNotBlank(SAVE_VALUE_VLI))ffItem.SAVE_VALUE_VLI__c=SAVE_VALUE_VLI;        
        if(string.isNotBlank(PRIMARY_PURCHASE_REQ))ffItem.PRIMARY_PURCHASE_REQ__c=PRIMARY_PURCHASE_REQ;        
        if(string.isNotBlank(PRIMARY_PURCHASE_REQ_VLI))ffItem.PRIMARY_PURCHASE_REQ_VLI__c=PRIMARY_PURCHASE_REQ_VLI;         
        if(string.isNotBlank(MISC_ELEMENTS))ffItem.MISC_ELEMENTS__c=MISC_ELEMENTS;        
        if(string.isNotBlank(SAVE_VALUE_CODE))ffItem.SAVE_VALUE_CODE__c=SAVE_VALUE_CODE;        
        if(string.isNotBlank(SAVE_VALUES_APPLIES_TO))ffItem.SAVE_VALUES_APPLIES_TO__c=SAVE_VALUES_APPLIES_TO;        
        if(string.isNotBlank(Store_Coupon))ffItem.Store_Coupon__c=Store_Coupon;        
        if(string.isNotBlank(DO_NOT_MULTIPLY))ffItem.DO_NOT_MULTIPLY__c=DO_NOT_MULTIPLY;        
        if(string.isNotBlank(PRIMARY_PURCHASE_REQ_CODE))ffItem.PRIMARY_PURCHASE_REQ_CODE__c=PRIMARY_PURCHASE_REQ_CODE;
        Database.SaveResult srList=Database.insert(ffItem,false);
        
        return srList;
    }
}