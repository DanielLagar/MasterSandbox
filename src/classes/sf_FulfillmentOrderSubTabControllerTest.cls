/**
* @author: asethuraman@salesforce.com
* @date: 09/11/2014
* @description:  Test Class for  sf_FulfillmentOrderSubTabController
* order button
*/

@isTest
private class sf_FulfillmentOrderSubTabControllerTest {


  static testmethod void testCreateNewFulfilmentOrder() {
    
    Contact contactRec = sf_TestDatautility.createContact();
    contactRec.Primary_Address_Line_1__c = '123 Test Street';
    contactRec.Primary_City__c = 'Chicago';
    contactRec.Primary_State_Province__c = 'Illinois';
    contactRec.Primary_Postal_Code__c = '60661';
    contactRec.Primary_Country__c = sf_Constants.COUNTRY_UNITED_STATES_AMERICA;
    insert contactRec;
    Case caseRec = new Case ( contactId = contactRec.Id, Country__c = sf_Constants.COUNTRY_UNITED_STATES_AMERICA);
    insert caseRec;
    
    ApexPages.StandardController sc = new ApexPages.StandardController(caseRec);
    sf_FulfillmentOrderSubtabController fOrder = new sf_FulfillmentOrderSubtabController(sc);
    
    Test.startTest();
    sf_FulfillmentOrderSubtabController.ReturnResults nextPage = sf_FulfillmentOrderSubtabController.createNewFulfillmentOrder(caseRec.Id);
    Test.stopTest();
    
    System.assertNotEquals(nextPage.returnURL,null);
  }
  
  static testmethod void testCreateNewFulfilmentOrderWithCaseProduct() {
    
    Contact contactRec = sf_TestDatautility.createContact();
    contactRec.Primary_Address_Line_1__c = '123 Test Street';
    contactRec.Primary_City__c = 'Chicago';
    contactRec.Primary_State_Province__c = 'Illinois';
    contactRec.Primary_Postal_Code__c = '60661';
    contactRec.Primary_Country__c = sf_Constants.COUNTRY_UNITED_STATES_AMERICA;
    insert contactRec;
    
    Case caseRec = new Case ( contactId = contactRec.Id, Country__c = sf_Constants.COUNTRY_UNITED_STATES_AMERICA);
    insert caseRec;
    
    sf_TestDataUtility.setupProducts(1);
    sf_TestDataUtility.setupComments(1);
    
    Case_Product__c cp = new Case_Product__c ();
      cp.Case__c = caseRec.Id;
      cp.Local_Product__c = [SELECT Id FROM Local_Product__c LIMIT 1].Id;
      insert cp;

      Case_Comment_Code__c ccc = new Case_Comment_Code__c ();
      ccc.Case__c = caseRec.Id;
      ccc.Case_Product__c = cp.Id;
      ccc.Local_Comment_Code__c = [SELECT Id FROM Local_Comment_Code__c LIMIT 1].Id;
      insert ccc;
    
    ApexPages.StandardController sc = new ApexPages.StandardController(caseRec);
    sf_FulfillmentOrderSubtabController fOrder = new sf_FulfillmentOrderSubtabController(sc);
    
    Test.startTest();
    sf_FulfillmentOrderSubtabController.ReturnResults nextPage = sf_FulfillmentOrderSubtabController.createNewFulfillmentOrder(caseRec.Id);
    Test.stopTest();
    
    System.assertNotEquals(nextPage.returnURL,null);
  }
  
  static testmethod void testCreateNewFulfilmentOrderContactError() {
    
    
    Case caseRec = new Case ( Country__c = sf_Constants.COUNTRY_UNITED_STATES_AMERICA);
    insert caseRec;
    
    ApexPages.StandardController sc = new ApexPages.StandardController(caseRec);
    sf_FulfillmentOrderSubtabController fOrder = new sf_FulfillmentOrderSubtabController(sc);
    
    Test.startTest();
    
    Test.setCurrentPage(Page.sf_FulfillmentOrderSubtab);
    sf_FulfillmentOrderSubtabController.ReturnResults nextPage = sf_FulfillmentOrderSubtabController.createNewFulfillmentOrder(caseRec.Id);
    Test.stopTest();
    
    System.assertEquals(nextPage.returnURL,null);
    
    List<Apexpages.Message> msgs = ApexPages.getMessages();
    System.assertEquals(nextPage.errorMessage,sf_FulfillmentOrderSubtabController.CONTACT_ERROR);
  }
  
  static testmethod void testCreateNewFulfilmentOrderAddrError() {
    
    Contact contactRec = sf_TestDatautility.createContact();
    insert contactRec;
    
    Case caseRec = new Case ( contactId = contactRec.Id,Country__c = sf_Constants.COUNTRY_UNITED_STATES_AMERICA);
    insert caseRec;
    
    ApexPages.StandardController sc = new ApexPages.StandardController(caseRec);
    sf_FulfillmentOrderSubtabController fOrder = new sf_FulfillmentOrderSubtabController(sc);
    
    Test.startTest();
    
    Test.setCurrentPage(Page.sf_FulfillmentOrderSubtab);
    sf_FulfillmentOrderSubtabController.ReturnResults nextPage = sf_FulfillmentOrderSubtabController.createNewFulfillmentOrder(caseRec.Id);
    Test.stopTest();
    
    System.assertEquals(nextPage.returnURL,null);
    
    List<Apexpages.Message> msgs = ApexPages.getMessages();
    System.assertEquals(nextPage.errorMessage,sf_FulfillmentOrderSubtabController.ADDRESS_ERROR);
  }
  
  static testmethod void testCreateNewFulfilmentOrderCountryError() {
    
    Contact contactRec = sf_TestDatautility.createContact();
     contactRec.Primary_Address_Line_1__c = '123 Test Street';
    contactRec.Primary_City__c = 'Chicago';
    contactRec.Primary_State_Province__c = 'Illinois';
    contactRec.Primary_Postal_Code__c = '60661';
    contactRec.Primary_Country__c = sf_Constants.COUNTRY_UNITED_STATES_AMERICA;
    insert contactRec;
    
    Case caseRec = new Case ( contactId = contactRec.Id,Country__c = 'Greece');
    insert caseRec;
    
    ApexPages.StandardController sc = new ApexPages.StandardController(caseRec);
    sf_FulfillmentOrderSubtabController fOrder = new sf_FulfillmentOrderSubtabController(sc);
    
    Test.startTest();
    
    Test.setCurrentPage(Page.sf_FulfillmentOrderSubtab);
    sf_FulfillmentOrderSubtabController.ReturnResults nextPage = sf_FulfillmentOrderSubtabController.createNewFulfillmentOrder(caseRec.Id);
    Test.stopTest();
    
    System.assertEquals(nextPage.returnURL,null);
    
    List<Apexpages.Message> msgs = ApexPages.getMessages();
    System.assertEquals(nextPage.errorMessage,sf_FulfillmentOrderSubtabController.COUNTRY_ERROR);
  }
  
  static testmethod void testGetFulfillmentOrders() {
    
    Contact contactRec = sf_TestDatautility.createContact();
     contactRec.Primary_Address_Line_1__c = '123 Test Street';
    contactRec.Primary_City__c = 'Chicago';
    contactRec.Primary_State_Province__c = 'Illinois';
    contactRec.Primary_Postal_Code__c = '60661';
    contactRec.Primary_Country__c = sf_Constants.COUNTRY_UNITED_STATES_AMERICA;
    insert contactRec;
    
    Case caseRec = new Case ( contactId = contactRec.Id,Country__c = 'Greece');
    insert caseRec;
    
    List<Fulfillment_Order__c> fulfillmentOrders = new List<Fulfillment_Order__c>();
    for (Integer i = 0; i < 200; i++) {
      Fulfillment_Order__c fo = sf_TestDataUtility.createFFOrder(caseRec.Id);
      fulfillmentOrders.add(fo);
    }
    insert fulfillmentOrders;
     
    ApexPages.StandardController sc = new ApexPages.StandardController(caseRec);
    sf_FulfillmentOrderSubtabController fOrder = new sf_FulfillmentOrderSubtabController(sc);
    
    Test.startTest();
    
    
    List<Fulfillment_Order__c> fOrders= fOrder.getFulfillmentOrders();
    System.assertEquals(forders.size(),200);
    Test.stopTest();
    
    
  }
  
  static testmethod void testGetFulfillmentOrderLineItems() {
    
    Contact contactRec = sf_TestDatautility.createContact();
     contactRec.Primary_Address_Line_1__c = '123 Test Street';
    contactRec.Primary_City__c = 'Chicago';
    contactRec.Primary_State_Province__c = 'Illinois';
    contactRec.Primary_Postal_Code__c = '60661';
    contactRec.Primary_Country__c = sf_Constants.COUNTRY_UNITED_STATES_AMERICA;
    insert contactRec;
    
    Case caseRec = new Case ( contactId = contactRec.Id,Country__c = 'Greece');
    insert caseRec;
    
    List<Fulfillment_Order__c> fulfillmentOrders = new List<Fulfillment_Order__c>();
    for (Integer i = 0; i < 200; i++) {
      Fulfillment_Order__c fo = sf_TestDataUtility.createFFOrder(caseRec.Id);
      fulfillmentOrders.add(fo);
    }
    insert fulfillmentOrders;
     
    List<Fulfillment_Order_Line_Item__c> fOrderLineItems = new List<Fulfillment_Order_Line_Item__c>();
    for (Fulfillment_Order__c fo: fulfillmentOrders) {
      
      fOrderLineItems.add(sf_TestDataUtility.createFFOrderLineItem(fo.Id));
    }
    insert fOrderLineItems;
    ApexPages.StandardController sc = new ApexPages.StandardController(caseRec);
    sf_FulfillmentOrderSubtabController fOrder = new sf_FulfillmentOrderSubtabController(sc);
    
    Test.startTest();
    
    
    List<Fulfillment_Order_Line_Item__c> fOrderLines= fOrder.getFulfillmentOrderLineItems();
    System.assertEquals(forderLines.size(),200);
    Test.stopTest();
    
    
  }
  
  static testmethod void testAddFulfillmentOrderLineItems() {
    
    Contact contactRec = sf_TestDatautility.createContact();
     contactRec.Primary_Address_Line_1__c = '123 Test Street';
    contactRec.Primary_City__c = 'Chicago';
    contactRec.Primary_State_Province__c = 'Illinois';
    contactRec.Primary_Postal_Code__c = '60661';
    contactRec.Primary_Country__c = sf_Constants.COUNTRY_UNITED_STATES_AMERICA;
    insert contactRec;
    
    Case caseRec = new Case ( contactId = contactRec.Id,Country__c = sf_Constants.COUNTRY_UNITED_STATES_AMERICA);
    insert caseRec;
    
    Fulfillment_Order__c fo = sf_TestDataUtility.createFFOrder(caseRec.Id);
    
    insert fo;
     
    
    ApexPages.StandardController sc = new ApexPages.StandardController(caseRec);
    sf_FulfillmentOrderSubtabController fOrder = new sf_FulfillmentOrderSubtabController(sc);
    
    Test.startTest();
    Test.setCurrentPage(Page.sf_FulfillmentOrderSubtab);
    System.currentPageReference().getParameters().put('fOrder', fo.Id);
    
    sf_FulfillmentOrderSubtabController.ReturnResults nextPage = sf_FulfillmentOrderSubtabController.addFulfillmentLineItem(fo.Id);
    
    Test.stopTest();
    System.assertNotEquals(nextPage.returnURL,null);
    
  }
}