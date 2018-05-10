/**
* @author: Ashok Bommali
* @date: SEP-2014
* @description: 
* This controller is used for the conga template edit on fulfillment orders
*/
public class sf_FulfillmentOrderLetterEdit {
    public string editBox {get; set;}
    list<Fulfillment_Order__c> query;

    public sf_FulfillmentOrderLetterEdit(ApexPages.StandardController controller) {
        query =[select id ,Letter_Body__c from Fulfillment_Order__c where id =: ApexPages.currentPage().getParameters().get('id')];
        editBox = query[0].letter_body__c;
    }  
     
    public PageReference save1(){
        Fulfillment_Order__c fo = new Fulfillment_Order__c();
        fo.id = ApexPages.currentPage().getParameters().get('Id');
        fo.Letter_Body__c = editbox;
        update fo;
        
        PageReference pageRef = new PageReference('/'+ApexPages.currentPage().getParameters().get('Id'));
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference cancelBtn(){
        PageReference pageRef = new PageReference('/'+ApexPages.currentPage().getParameters().get('Id'));
        pageRef.setRedirect(true);
        return pageRef;
    }
}