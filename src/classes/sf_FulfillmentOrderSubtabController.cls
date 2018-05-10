/**
* @author: asethuraman@salesforce.com
* @date: 09/11/2014
* @description:  Class to display fulfillment orders and order line items related list and a create new fulfillment 
* order button
*/

global class sf_FulfillmentOrderSubtabController {
	
	public  Case caseRecord { get; set; }
	public static final String CONTACT_ERROR 	= 'You must have a Primary Contact to send Fulfillment';
	public static final String COUNTRY_ERROR 	= 'Case Country and Primary Account Country must match to create a fulfillment order';
	public static final String ADDRESS_ERROR 	= 'Contact Name, Address Line 1 and City are required to create a Fulfillment Order';
	public static final String CASE_COMMENTS_ERROR 	= 'Case Product/Case Comments are required  to create a Fulfillment Order';
	public static final String FULFILLMENT_CLOSED_ERROR = 'The Fulfillment Order you are trying to access is closed. Please select another';
	public sf_FulfillmentOrderSubtabController(ApexPages.StandardController sc) {
		
	   caseRecord = (Case)sc.getRecord();
	   System.debug(caseRecord);
	}
	
   /**
	* @author: asethuraman@salesforce.com
   * @date: 09/11/2014
	* @description: Redirects to sf_SelectFulfillmentItems page if there are no errors, else returns an error msg
	* @return: PageReference - Ref to sf_SelectFulfillmentItems page if successful, else null
	*/
	@RemoteAction
   global static ReturnResults createNewFulfillmentOrder(Id caseRecId) {
   	ReturnResults rResults = new ReturnResults();
    	ApexPages.Message tContactError = 
			Label.Fulfillment_ContactError != ''
			    ? new ApexPages.Message(ApexPages.Severity.ERROR,Label.Fulfillment_ContactError)
			    : new ApexPages.Message(ApexPages.Severity.ERROR,CONTACT_ERROR); 
		ApexPages.Message tCountryError = 
			Label.Fulfillment_CountryError != '' 
			 ? new ApexPages.Message(ApexPages.Severity.ERROR,Label.Fulfillment_CountryError )
			 : new ApexPages.Message(ApexPages.Severity.ERROR,COUNTRY_ERROR) ; 
		ApexPages.Message tAddressMissing = 
			Label.Fulfillment_AddressMissing != '' 
			 ? new ApexPages.Message(ApexPages.Severity.ERROR,Label.Fulfillment_AddressMissing) 
			 : new ApexPages.Message(ApexPages.Severity.ERROR,ADDRESS_ERROR); 
      ApexPages.Message tCaseCommentsError = new ApexPages.Message(ApexPages.Severity.ERROR,CASE_COMMENTS_ERROR); 
    	try {
	    	Id userId = userInfo.getUserId();
	    	Integer flag = 0; 
			Id caseId = caseRecId; 
			String addressline = ''; 
			String city = ''; 
			String country = ''; 
			String lastname = ''; 
			Boolean isPersonAccount = false;
			 
			Case caseRec = [
		      Select 
			    	ContactId,Country__c,Id, Contact_Center__c 
			    from 
			    	Case 
			    where 
			    	Id =:caseId
			    LIMIT 1
			];
			 
			Id caseContact = caseRec.ContactId; 
			String consumerCountry = caseRec.Country__c; 
			String ccenter = caseRec.Contact_Center__c; 
			if ( consumerCountry != null) { 
				 
		   	if (	consumerCountry.indexOf('-PGP') != -1) 
					consumerCountry = consumerCountry.replace('-PGP',''); 
            else if (consumerCountry.indexOf('-JV') != -1){ 
					consumerCountry = consumerCountry.replace('-JV',''); 
			   } 
		   }
		    
		   if ( caseContact== null ) { 
				
				flag=1; 
				rResults.errorMessage = tContactError.getDetail();
			} else { 
				
				List<Contact> caseContactList = [
			    	 Select 
			    	 	Primary_Address_Line_1__c, Primary_City__c, 
			    	 	LastName, Primary_Country__c 
			    	 from 
			    	 	Contact 
			    	 where 
			    	 	Id =: caseContact
			   ];
			   if (caseContactList.size() > 0) { 
				 	System.debug(caseContactList[0]);
					addressline = caseContactList[0].Primary_Address_Line_1__c; 
					city = caseContactList[0].Primary_City__c; 
					lastname = caseContactList[0].LastName; 
					country = caseContactList[0].Primary_Country__c; 
				} 
				if ( ccenter != 'Taiwan' && ccenter != 'Hong Kong' && ccenter != 'China P&G' 
				 	&& ccenter != 'China Sykes' && ccenter!='Japan' && ccenter!='Manila' 
				 	&& ccenter!='Korea' && ccenter!='China TCI') { 
					
					if ( caseContact != null && (addressline ==null || city == null 
						|| lastname == null || addressline =='' || city == '' || lastname =='')) { 
							
						if ( !(consumerCountry == 'China' || consumerCountry == 'Hong Kong' 
							|| consumerCountry == 'Taiwan')) {
							   
							flag=2; 
							rResults.errorMessage = tAddressMissing.getDetail();
								
						} 
					} 
				} 
			} 
			if (flag == 0 ) { 
				if ( consumerCountry != country && (ccenter!='Taiwan' && ccenter!='Hong Kong' && 
					ccenter!='SPG - Salon Professional Germany')) { 
					flag=3; 
					ApexPages.addMessage(tCountryError); 
					rResults.errorMessage = tCountryError.getDetail();
				} 
			}  
			
			if (!( flag == 1 || flag == 2 || flag==3 ))/* {
				 return null;
				 /*PageReference casePage = new ApexPages.StandardController(caseRec).view();
		       casePage.setRedirect(true);
		       return casePage;
			}
			else */
			{ 
				List<Case_Product__c> productResult = [
					Select 
						Id 
					from 
						Case_Product__c 
					where 
						Case__c=:caseId ]; 
				
				List<Case_Comment_Code__c> comments = [
					Select 
						Id 
					from 
						Case_Comment_Code__c 
					where 
						Case__c=:caseId ]; 
				
				PageReference selectFulfillmentItems = Page.sf_SelectFulfillmentItems;
				selectFulfillmentItems.setRedirect(true);
				
				if ( comments.size() == 1 ) { 
					selectFulfillmentItems.getParameters().put('id',caseId);
					selectFulfillmentItems.getParameters().put('fromPage','oneTopic');
					selectFulfillmentItems.getParameters().put('comment',comments[0].Id);

				} else { 
					selectFulfillmentItems = Page.sf_CreateFulfillmentOrder;
					selectFulfillmentItems.setRedirect(true);
					selectFulfillmentItems.getParameters().put('id',caseId);
                    //selectFulfillmentItems.getParameters().put('fromPage','ffSelection');//Changed from ffSelection to sf_selectfulfillmentitems as below
                    selectFulfillmentItems.getParameters().put('fromPage','sf_selectfulfillmentitems');//CMD WR259 fixing multiple case comment code issue
                    
				} 
				rResults.returnURL = selectFulfillmentItems.getUrl();
			} 
				
		 } catch (Exception e) {
    	 	 System.debug(e);
    	 	 System.debug(e.getStackTraceString());
    	 	 rResults.errorMessage = e.getMessage(); 
    	 }
    	 
    	 return rResults;
    }
    
   /**
	* @author: asethuraman@salesforce.com
   * @date: 09/11/2014
	* @description: returns a list of fulfilment orders related to case
	* @return: List<Fulfillment_Order__c> - a list of fulfilment orders related to case
	*/
    public List<Fulfillment_Order__c> getFulfillmentOrders() {
    	 System.debug(caseRecord);
    	 List<Fulfillment_Order__c> fOrders = [
    	 	 select
    	 	 	Name,Contact__c,contact__r.name,Status__c,
    	 	 	PDF_Generated__c,Date_Created__c
    	 	 from
    	 	 	Fulfillment_Order__c
    	 	 where
    	 	 	Case__c =: caseRecord.Id
    	 	 	
    	 ];
    	 return fOrders;
    } 
    
   /**
	* @author: asethuraman@salesforce.com
   * @date: 09/11/2014
	* @description: returns a list of fulfilment order line items related to case
	* @return: List<Fulfillment_Order__c> - a list of fulfilment order line items related to case
	*/
   public List<Fulfillment_Order_Line_Item__c> getFulfillmentOrderLineItems() {
    	System.debug(caseRecord);
    	List<Fulfillment_Order_Line_Item__c> fOrderLineItems = [
    	 	select
    	 	 	Name,Fulfillment_Order__r.Name,Fulfillment_Order__c,
    	 	 	CreatedDate,Amount_Currency__c,Quantity__c,Fulfillment_Item__c,
    	 	 	Fulfillment_Item__r.Name,Description__c
    	 	from
    	 	 	Fulfillment_Order_Line_Item__c
    	 	where
    	 	 	Fulfillment_Order__r.Case__c =: caseRecord.Id
    	 	 	
    	];
    	return fOrderLineItems;
   } 
   
   /**
	* @author: asethuraman@salesforce.com
   * @date: 09/11/2014
	* @description: creates a new subtab with seleted fulfillment order
	* @return: PageReference - Ref to sf_SelectFulfillmentItems page if successful, else null
	*/ 
   public PageReference emptyRefresh() {
   	
		return null;
   } 
   
   /**
	* @author: asethuraman@salesforce.com
   * @date: 09/11/2014
	* @description: Redirects to sf_SelectFulfillmentItems page if there are no errors to create new fulfillment line items
	* for the selected order, else returns an error msg
	* @return: PageReference - Ref to sf_SelectFulfillmentItems page if successful, else null
	*/
	@RemoteAction
   global static ReturnResults addFulfillmentLineItem( Id fulfilmentOrderRecId ) {
   	ApexPages.Message tFulfillmentOrderClosedMessage = Label.Fulfillment_FulfillmentOrderClosedMessage != '' ? 
			new ApexPages.Message(ApexPages.Severity.ERROR,Label.Fulfillment_FulfillmentOrderClosedMessage) 
			: new ApexPages.Message(ApexPages.Severity.ERROR,FULFILLMENT_CLOSED_ERROR);
		//fulfillmentOrderRecId = Apexpages.currentpage().getparameters().get('fOrder');
		ReturnResults rResults = new ReturnResults();
		try {
			
			if (fulfilmentOrderRecId == null) {
				rResults.errorMessage = 'Please select a fulfillment Order to add Lines';
			} else {
			
			Fulfillment_Order__c fOrder = [
				Select 
					Case_Comment_Code__c,Status__c,Promos_Created__c,case__c 
				from 
					Fulfillment_Order__c 
				where 
					Id =: fulfilmentOrderRecId ];


			 String caseCommentCode = fOrder.Case_Comment_Code__c; 
			 String status = fOrder.Status__c; 
			 Boolean promo = fOrder.Promos_Created__c; 
			 if ( status != sf_Constants.STATUS_CLOSED) { 
				
				PageReference selectFulfillmentItems = Page.sf_SelectFulfillmentItems;
				selectFulfillmentItems.getParameters().put('id',fOrder.case__c);
				selectFulfillmentItems.getParameters().put('fromPage','Additems');
				selectFulfillmentItems.getParameters().put('comment',caseCommentCode);
				selectFulfillmentItems.getParameters().put('ffOrderid',fulfilmentOrderRecId);
				selectFulfillmentItems.getParameters().put('pro',String.valueOf(promo));
				selectFulfillmentItems.setRedirect(true);
				//return selectFulfillmentItems.getUrl();
				rResults.returnURL = selectFulfillmentItems.getUrl();
			 } else { 
				//return tFulfillmentOrderClosedMessage.getDetail(); 
				rResults.errorMessage = tFulfillmentOrderClosedMessage.getDetail(); 
			 } 
			}
		} catch(Exception e) {
			System.debug(e);
    	 	System.debug(e.getStackTraceString());
    	 	rResults.errorMessage = e.getMessage(); 
    	 	//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
		}
		
		return rResults;
   }  
   
   global class ReturnResults {
   	public String returnURL { get; set; }
   	public String errorMessage { get; set; }
   	public ReturnResults () {
   		
   		this.returnURL = null;
   		this.errorMessage = null;
   	}
   	public ReturnResults (String returnURL,List<String> errorMessages) {
   		
   		this.returnURL = returnURL;
   		this.errorMessage = null;
   	}
   	
   }
}