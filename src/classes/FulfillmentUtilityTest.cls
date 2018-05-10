/**
* @author: Chris Doyle
* @date: 02/11/2016
* @description: New code coverage class for SF_FulfillmentUtility.cls
*/
@isTest
public class FulfillmentUtilityTest {
    
    @testSetup
    Static void fulfillmentSetup() {
        Profile p = sf_FulfillmentOrderCtrlTest.createProfile();
        User userObj = sf_FulfillmentOrderCtrlTest.createUserFFUserOne(p);
        User userObjTwo = sf_FulfillmentOrderCtrlTest.createUserFFUserTwo(p);
        
        System.runAs(userObj){
            CustomSettingDataFactory.countryRegionSetup();
            Contact conObj = sf_FulfillmentOrderCtrlTest.createContact();
            Case caseObj = sf_FulfillmentOrderCtrlTest.createCase(conObj);

            //Brazil case and Contact
            Contact conObj2 = createBrazilContact();
            Case caseObj2 = createBrazilCase(conObj2);

        }
    }
    
    //Rule Criteria - Fullfillment_Amount_Roll_Up__c > CreatedBy.Monetary_Threshold__c
    static testMethod void FFUtilTest1(){

        case c = [SELECT id, ownerid FROM CASE LIMIT 1];
        user u = [SELECT id from User where UserName='Under@threshold.com' LIMIT 1];

        System.runAs(u){
            system.assertequals(u.id, c.OwnerId);
            
            test.startTest();
            sf_FulfillmentOrderCtrlTest.createTestDataCommentsProducts(c); //GP, LP, GCC, LCC, CP, PCC, CCC
            sf_FulfillmentOrderCtrlTest.createFulFillmentOrder(c); //FO, FOLI
            Fulfillment_Order_Line_Item__c foli = [SELECT id, Fulfillment_Order__c FROM Fulfillment_Order_Line_Item__c LIMIT 1];
            Fulfillment_Order__c fo = [SELECT id, status__c FROM Fulfillment_Order__c where id =: foli.Fulfillment_Order__c];
            System.assertEquals ( 'Draft', fo.Status__c); 
            
            test.stopTest();
        }
    }
    
    //Rule Criteria - AND ( Above_Monetary_Threshold__c ,(Fullfillment_Amount_Roll_Up__c < CreatedBy.Monetary_Threshold__c ),ISPICKVAL(Status__c,"Draft"))
    static testMethod void FFUtilTest2(){
        
        case c = [SELECT id, ownerid FROM CASE LIMIT 1];
        user underThreshold = [SELECT id from User where UserName='Under@threshold.com' LIMIT 1];
        test.startTest();
        
        Fulfillment_Order__c fo = new Fulfillment_Order__c();
        Fulfillment_Order_Line_Item__c foli = new Fulfillment_Order_Line_Item__c();
        System.runAs(underThreshold){
            system.assertequals(underThreshold.id, c.OwnerId);
            sf_FulfillmentOrderCtrlTest.createTestDataCommentsProducts(c); //GP, LP, GCC, LCC, CP, PCC, CCC
            sf_FulfillmentOrderCtrlTest.createFulFillmentOrder(c); //FO, FOLI
            
            foli = [SELECT id, Fulfillment_Order__c FROM Fulfillment_Order_Line_Item__c LIMIT 1];
            
            foli.Type__c = 'ET';
            foli.Quantity__c = 1;
            foli.Amount_Currency__c = 90.00;
            foli.Keep_amount__c = TRUE;
            
            update foli;
            
            fo = [SELECT id, status__c, Approve_Amount__c FROM Fulfillment_Order__c where id =: foli.Fulfillment_Order__c];

            System.assertEquals ( 'Open', fo.Status__c); 

        }
        test.stopTest();
    } 

    static testmethod void FFUtilTest3(){

        case c = [SELECT id, ownerid FROM CASE WHERE Country__c = 'United States of America' LIMIT 1];

        case c2 = [SELECT id, ownerid FROM Case WHERE Country__c = 'Brazil' LIMIT 1];

        user underThreshold = [SELECT id from User where UserName='Under@threshold.com' LIMIT 1];
        test.startTest();

        System.runAs(underThreshold){
            sf_FulfillmentOrderCtrlTest.createTestDataCommentsProducts(c); //GP, LP, GCC, LCC, CP, PCC, CCC

            list<Fulfillment_Order__c> listFO = new list<Fulfillment_Order__c>();
            Fulfillment_Order__c FF1 = new Fulfillment_Order__c(
                case__c = c.id
            );
            listFO.add(FF1);

            Fulfillment_Order__c FF2 = new Fulfillment_Order__c(
                case__c = c2.id
            );
            listFO.add(FF2);

            insert listFO;

            list<Fulfillment_Order_Line_Item__c> listLineItem = new list<Fulfillment_Order_Line_Item__c>();
            Fulfillment_Order_Line_Item__c FFLI1 = new Fulfillment_Order_Line_Item__c(
                
                fulfillment_Order__c = FF1.id,
                Case__c = c.id,
                Type__c = 'ET',
                Quantity__c = 1,
                Amount_Currency__c = 90.00,
                Keep_amount__c = TRUE

            );
            listLineItem.add(FFLI1);


            Fulfillment_Order_Line_Item__c FFLI2 = new Fulfillment_Order_Line_Item__c(
                
                fulfillment_Order__c = FF2.id,
                Case__c = c.id,
                Type__c = 'ET',
                Quantity__c = 1,
                Amount_Currency__c = 995.00,
                Keep_amount__c = TRUE

            );
            listLineItem.add(FFLI2);

            insert listLineItem;
            
            Fulfillment_Order__c fo = [SELECT id, status__c, Approve_Amount__c, Case_Country__c FROM Fulfillment_Order__c WHERE Case_Country__c = 'United States of America'];

            System.assertEquals ( 'Open', fo.Status__c); 

            Fulfillment_Order__c fo2 = [SELECT id, status__c, Approve_Amount__c, Case_Country__c FROM Fulfillment_Order__c WHERE Case_Country__c = 'Brazil'];

            System.assertEquals('Open', fo2.Status__c);
        }

        test.stopTest();

    }

    public static Case createBrazilCase(Contact conObj2){
        Case c2 = new Case();
        c2.Status = 'Open';
        c2.country__c = 'Brazil';
        c2.Language__c = 'English-US';
        c2.Contact_Center__c = 'NA';
        c2.ContactId = conObj2.Id;
        c2.Origin = 'Phone';
        c2.Brand__c='TestBrand';
        c2.Segment__c='TestSegment';
        insert c2;        
        return c2;
    }

    public static Contact createBrazilContact(){
        Contact conObj2 = new Contact();
        conObj2.FirstName='TestBrazil';
        conObj2.LastName='TestBrazil';
        conObj2.Country__c='Brazil';
        conObj2.Salutation='Mr.';
        insert conObj2;        
        return conObj2;
    }

    public static Case createChinaCase(Contact conObj3){
        Case c3 = new Case();
        c3.Status = 'Open';
        c3.country__c = 'Brazil';
        c3.Language__c = 'English-US';
        c3.Contact_Center__c = 'NA';
        c3.ContactId = conObj3.Id;
        c3.Origin = 'Phone';
        c3.Brand__c='TestBrand';
        c3.Segment__c='TestSegment';
        insert c3;        
        return c3;
    }

    public static Contact createChinaContact(){
        Contact conObj3 = new Contact();
        conObj3.FirstName='TestBrazil';
        conObj3.LastName='TestBrazil';
        conObj3.Country__c='Brazil';
        conObj3.Salutation='Mr.';
        insert conObj3;
        return conObj3;
    }
    
}