/*
* @author: original PG class
* @date: 08/19/2014
* @description: ContactUsController - part of PII Utility. 
  Class migrated from Prod org and updated by sfdc on 7/22/2015
*/

public class sf_PIIContactUsCon{
    //private string regexemailaddress { get { return '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';}} //WR120 No longer required?
    private string siteid { get;set; }    
    private Map<String,String> MonVals = new Map<String,String>{'Jan' => '1', 'Feb' => '2', 'Mar' => '3', 'Apr' => '4', 'May' => '5', 'Jun' => '6', 'Jul' => '7', 'Aug' => '8', 'Sep' => '9', 'Oct' => '10', 'Nov' => '11', 'Dec' => '12'};
   
    public String personYear { get; set; }      
    public String salutation { get; set; }      
    public  Boolean isActive{ 
        get{
            if (isActive == null) 
             return true;
            else 
             return isActive;
        } 
        set;  
   }        
   
   public piiSettings piisettingsobj { get; set; }
   public Contact newContact2{get;set;}

   //added 2/9/2016 by Ian Barker to make zip and state fields dynamically required on Email Us page
    public Boolean isZipRequired {
        get {
            Country_Status__c cs = Country_Status__c.getInstance(piisettingsobj.conWrapper.country);
            system.debug('!!!isZipRequired ' + ((cs != null) ? cs.Uses_Postal_Codes__c : false));
            return (cs != null) ? cs.Uses_Postal_Codes__c : false;
        }
        set;
    }
    public Boolean isStateRequired {
        get{
            Country_Status__c cs = Country_Status__c.getInstance(piisettingsobj.conWrapper.country);
            system.debug('!!!isStateRequired ' + ((cs != null) ? cs.Uses_States__c : false));
            return (cs != null) ? cs.Uses_States__c : false;
        }
        set;
    }
    
    public Id caseId {get;set;}

    public sf_PIIContactUsCon(){
        withDPR = false;//CR16
        Blob decodedSiteId;
        String encodedSiteId;
        newContact2 = new Contact();
        
        //get encoded value from the querystring
        encodedSiteId=ApexPages.currentPage().getParameters().get('sid'); 
        if (String.isBlank(encodedSiteId)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.PII_ExpiredURL));
            isActive = false;
            return; 
        } 
        decodedSiteId = EncodingUtil.base64Decode(encodedSiteId);
        siteid = decodedSiteId.tostring();
        
        List <PIISitespageSettings__c> piisettings = [SELECT Id
                                                            ,Fields__c
                                                            ,Case_Id__c
                                                            ,IsActive__c
                                                      		,Include_DPR_Form__c//CR16
                                                      		,DPR_UID__c//CR16
                                                     FROM PIISitespageSettings__c 
                                                     WHERE Id=:siteid];
          
        System.debug('########## piisettings: ' + piisettings);
        
        if (piisettings.size() > 0){
            piisettingsobj = new piiSettings(piisettings[0]);
            
            //START CR16
			caseId = piisettings[0].Case_Id__c;
            isDPRVisible = piisettings[0].Include_DPR_Form__c;
            dprUID = piisettings[0].DPR_UID__c;
            //FIN CR16
            
            if (!piisettingsobj.isActive) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.PII_ExpiredURL+piisettingsobj.newCase.CaseNumber));
                isActive = false;

                return;
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.PII_ExpiredURL));
            isActive=false;
        }       
    }

    public List<SelectOption> getYearList(){
        Integer currentYear = Date.today().year();
        String yearString;
        List <SelectOption> yearList= new List <SelectOption>();
        
        for (integer i = 1900; i <= currentYear; i++) {
            yearString = String.valueOf(i);
            yearList.add(new SelectOption(yearString, yearString));
        } 
        
        return yearList;
    }
    
    public List<selectOption> getCountries() {
        List <SelectOption> countries= new List <SelectOption> ();
        countries.add(new selectOption('--Select--','--Select--'));
        Schema.DescribeFieldResult fieldResult =
    Case.Country__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
    for ( Schema.PicklistEntry f : ple ) {
          countries.add(new SelectOption(f.getLabel(), f.getValue()));
    }       
    
        if (countries.isEmpty()) 
            countries.add (new SelectOption (sf_Constants.COUNTRY_UNITED_STATES_AMERICA,sf_Constants.COUNTRY_UNITED_STATES_AMERICA));

        return countries;
    } 
    
	//START CR16 DPR Support
	//If Include_DPR_Form__c create a string list of UIDS for Case Products
	//Use apex repeat on this list and the component and pass the UID into the component
    public Boolean isDPRVisible{get;set;}//CR16
    public String dprUID{get;set;}//CR16
    
    //Below was for multi digi CP support
    /*public List<String> getdprUIDs(){
        List<String> dprUIDs = new List<String>();
		for(Case_Product__c cp : [SELECT Id, Digital_Return_Id__c
                                  FROM Case_Product__c
                                  WHERE Case__c = :caseId AND Digital_Return_Id__c != null AND Product_available_for_return__c = 'Yes - Product is Available']){
            dprUIDs.add(cp.Digital_Return_Id__c);
        }
        
        return dprUIDs;
    }*/
	//END CR16 DPR Support
    
    public void validateInputs(){
        Cookie minAgeCookie;
        Boolean showErrorMessage = false;
         
        if (piisettingsobj.isFirstnameVisible && String.isBlank(piisettingsobj.conWrapper.contactObject.firstname) )
            showErrorMessage = true;
        
        if (piisettingsobj.isLastnameVisible && String.isBlank(piisettingsobj.conWrapper.contactObject.lastname))
            showErrorMessage = true;
          
        if (piisettingsobj.isEmailVisible && String.isBlank(piisettingsobj.conWrapper.contactObject.email))
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ContactUs_InvalidEmail));
                   
        if (piisettingsobj.isAddress1Visible && String.isBlank(piisettingsobj.conWrapper.contactObject.Primary_Address_Line_1__c) )
            showErrorMessage = true;
        
        if (piisettingsobj.isCityVisible && String.isBlank(piisettingsobj.conWrapper.contactObject.Primary_City__c) )
            showErrorMessage = true;
        
        //updated by Ian Barker to account for Postal/State requirements
        if (piisettingsobj.isStateVisible && String.isBlank(piisettingsobj.conWrapper.contactObject.Primary_State_Province__c) && isStateRequired)
            showErrorMessage = true;
          
        if(piisettingsobj.isPostalCodeVisible && String.isBlank(piisettingsobj.conWrapper.contactObject.Primary_Postal_Code__c) && isZipRequired)
            showErrorMessage = true;
          
        if (piisettingsobj.isCountryVisible && String.isBlank(piisettingsobj.conWrapper.contactObject.Primary_Country__c) )
            showErrorMessage = true;
        
        if (piisettingsobj.isTelephoneVisible && String.isBlank(piisettingsobj.conWrapper.phone) )
            showErrorMessage = true;  
        
        //check the PII page is active or inactive.
        //Reason: sometimes page is cached and user able to submit. This validation checks whether or PII form active.
      
        List <PIISitespageSettings__c> piisettingsValidate = [SELECT Id
                                                                    ,Fields__c
                                                                    ,Case_Id__c
                                                                    ,IsActive__c
                                                                
                                                                FROM PIISitespageSettings__c 

                                                                WHERE Id=:siteid LIMIT 1];
        
        if (!piisettingsValidate.isEmpty()) {
            piiSettings piiobj = new piiSettings(piisettingsValidate[0]);
        
            if ( !piiobj.isActive ) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.PII_ExpiredURL+piiobj.newCase.CaseNumber));
                isActive=false;
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.PII_ExpiredURL));
            isActive=false;
        }
        
        if (showErrorMessage)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ContactUs_RequiredFields));
    }
    
    public QueueRecordType__c getRecordType(string strcountry, string strlanguage){
      
        QueueRecordType__c queueRec;
        System.debug('############# strcountry: '+ strcountry);
        System.debug('############# strlanguage: '+ strlanguage);
        
        List <QueueRecordType__c> qrrecs = QueueRecordType__c.getall().values();
      
        for (QueueRecordType__c qr : qrrecs){
        
          if (qr.Country__c == strcountry && qr.Language__c == strlanguage) {
                 queueRec = qr;
                 break;
          }
        }      
        
        return queueRec;
    }
    
    
    //START - CR16
	/*public Pagereference SubmitWithDPR(){
		ctr_DPRUploadForm dprCtr = new ctr_DPRUploadForm();
        dprCtr.submit(dprUID);
        return submit();
    }*/
    
    private Boolean withDPR;//Does submission include DPR submit?
    
    public void submitDPR(){
		ctr_DPRUploadForm dprCtr = new ctr_DPRUploadForm();
        dprCtr.submit(dprUID);        
    }
    
    public void partialUploadErr(){
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.partialPhotoCount));
    }

    //FIN - CR16
    public Pagereference submit(){
		withDPR = Boolean.valueof(Apexpages.currentPage().getParameters().get('withDPR')); 
        system.debug(logginglevel.WARN,'^^^ withDPR value: '+withDPR);
        validateInputs();
        
        if (ApexPages.hasMessages()) 
             return null; 
        
        return save();     
    }
   
    public Pagereference save(){
        Contact con = new Contact();
        CaseUtility util = new CaseUtility();
        sf_SocialMediaUtility smUtil = new sf_SocialMediaUtility();
        
        Date birthday;  
        Id conId, accId;
        QueueRecordType__c accountQueueRecType;
        String accountRecTypeId;
      
        try {  
            if (piisettingsobj.isContactExisted) {
            
                //Just update the associated account
                System.debug('######### Account Update: '+piisettingsobj.conWrapper.contactObject);
                
                update piisettingsobj.conWrapper.contactObject;
                
                accId = piisettingsobj.newCase.AccountId;
                conId = piisettingsobj.newCase.ContactId;
            } else {
                //Id the case is not associated to an Account, then create new one

                if (String.isNotBlank(piisettingsobj.conWrapper.contactObject.firstName)  
                 && String.isNotBlank(piisettingsobj.conWrapper.contactObject.lastName) 
                   && String.isNotBlank(piisettingsobj.conWrapper.contactObject.Email) ) {
              
                    con = util.getContactByFNameLNameEmail(piisettingsobj.conWrapper.contactObject.firstName, 
                 piisettingsobj.conWrapper.contactObject.lastName, piisettingsobj.conWrapper.contactObject.Email);
                }          
          
                if (con.Id != null) {//checking if the account is already exists
                    util.updateContact(con.Id, piisettingsobj.conWrapper.contactObject.Primary_Address_Line_1__c,
                      piisettingsobj.conWrapper.contactObject.Primary_Address_Line_2__c,null, piisettingsobj.conWrapper.contactObject.Primary_City__c,
                      piisettingsobj.conWrapper.contactObject.Primary_State_Province__c, piisettingsobj.conWrapper.contactObject.Primary_Postal_Code__c,
                      piisettingsobj.conWrapper.contactObject.Primary_Country__c, null, birthday, false, piisettingsobj.conWrapper.contactObject.Phone);
              
                 conId = con.Id;
                } else {
                    accountQueueRecType = getRecordType(piisettingsobj.conWrapper.contactObject.Primary_Country__c, piisettingsobj.newCase.Language__c);

                    if (accountQueueRecType != null){
                      accountRecTypeId = accountQueueRecType.Account_Record_Type_Id__c;
                    }

                    piisettingsobj.conWrapper.contactObject = util.createContact(piisettingsobj.conWrapper.contactObject.firstName, piisettingsobj.conWrapper.contactObject.lastName, 
                      piisettingsobj.conWrapper.contactObject.Primary_Address_Line_1__c, piisettingsobj.conWrapper.contactObject.Primary_City__c,
                      null, birthday, accountRecTypeId , false, piisettingsobj.conWrapper.contactObject.Primary_Country__c,
                      piisettingsobj.conWrapper.contactObject.Email, piisettingsobj.conWrapper.contactObject.Primary_Address_Line_2__c,null, 
                      piisettingsobj.conWrapper.contactObject.Primary_State_Province__c, piisettingsobj.conWrapper.contactObject.Primary_Postal_Code__c,
                      piisettingsobj.conWrapper.contactObject.Phone);
              
                    conId = piisettingsobj.conWrapper.contactObject.Id;
                }

                if ( string.isNotBlank(conId) )
                    conId = [SELECT Id FROM Contact WHERE Id=:conId].Id;
        
                //update case
                piisettingsobj.newCase.AccountId = accId;
                piisettingsobj.newCase.ContactId = conId;
                
                update piisettingsobj.newCase;
        
          }//end if  
        
            //update case's country if consumer changes the country on the pii form.
          if ( piisettingsobj.conWrapper.contactObject.Primary_Country__c != piisettingsobj.newCase.Country__c ){
             
                 piisettingsobj.newCase.Country__c = piisettingsobj.conWrapper.contactObject.Primary_Country__c;
                 update piisettingsobj.newCase;
          }
        
            //Create a task
          Id caseownerid;
          List <Case> caseObjs = [SELECT OwnerId 
                                    FROM Case 
                                    WHERE Id = :piisettingsobj.newCase.Id 
                                  AND (Owner.Type!='Queue' AND Owner.Isactive=True) LIMIT 1];
                
        
          if (!caseObjs.isEmpty()) {
                 caseownerid = caseObjs[0].ownerId;

                //7-22-15 sfdc
                caseObjs[0].Status = 'Reopened by Social';
                caseObjs[0].Reassign_Case__c = true;
                update caseObjs[0];
            }

          smUtil.createTask('PII Utility Response', 'PII Utility Response', 'Social Media', 'Not Started', 'Low', 
                piisettingsobj.newCase.Id, sf_GlobalUtilityClass.TASK_CONSUMER_ACTIVITY_RT_ID, conId, caseownerid);
        
            //deactivate the PII form.
          piisettingsobj.piiSettingObject.IsActive__c = false;
          update piisettingsobj.piiSettingObject;


		//redirect to thank you page
          PageReference nextPage;                
          nextPage = Page.sf_PIIThankyou;
          nextPage.setRedirect(true);
          nextPage.getParameters().put('cn',piisettingsobj.newCase.CaseNumber);
          nextPage.getParameters().put('lang',piisettingsobj.language);
            
          //START CR16 - if submitted with DPR, submit DPR now. Do it now so the Case has the Contact email address available for the confirmation email
		  if(withDPR){
       		submitDPR();
    	  }
          //FIN CR
            
          return nextPage;
        } catch (Exception e){ 
            System.enqueueJob(new exceptionHelperQueable(e,'PII Error on Save. PII Object: '+String.valueOf(piisettingsobj)));             
            System.debug(e);
            String countryerrormsg = '';
            String expmsg=e.getMessage()+ '\n' + e.getCause() + '\n\n';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, expmsg));
            return ApexPages.currentPage();
        } 
    }
    
    public class PIISettings{

        public boolean isFirstnameVisible{ 
            get{ return fields.contains('FirstName');}
        }
        
        public boolean isLastnameVisible{ 
            get{ return fields.contains('LastName');}
        }
      
        //WR120 No longer required?
        /*public boolean isTitleVisible{ 
            get{ return fields.contains('Title');}
        }*/
        
        public boolean isAddress1Visible{ 
            get{ return fields.contains('AddressLine1');} 
        }

        //WR120 No longer required?
        //Breaks PII form.
        public boolean isAddress2Visible{
            get{ return fields.contains('AddressLine2');}
        }

        public boolean isCityVisible{
            get{ return fields.contains('City');}
        }
        
        public boolean isStateVisible{
            get{ return fields.contains('State');}    
        }

        public boolean isCountryVisible{ 
            get{ return fields.contains('Country');}
        }

        public boolean isPostalCodeVisible{
            get{ return fields.contains('Postal/ZipCode');} 
        }
        
        public boolean isTelephoneVisible{ 
            get{ return fields.contains('Phone');}//changed to phone post WR508
        }
        
        public boolean isEmailVisible{ 
            get{ return fields.contains('Email');}
        }
      
        public Set <String> fields { get; set; }
      
        public Boolean isContactExisted { get; set; }
        public Case newCase { get; set; }
        public PIISitespageSettings__c piiSettingObject { get;set; }
        public ContactWrapper conWrapper{ get;set; }
        
        //WR214 Is this used? If so how?
        public String language { 
            get {if(newCase != null)return newCase.Language_Code__c; else return '';}
        }
        
        public Boolean isActive{ get; set; }

        public PIISettings (PIISitespageSettings__c piiObject){
          
            Contact newContact;
          
            piiSettingObject = piiObject;
          List <String> listfields = piiObject.Fields__c.split(';');
          fields = new Set <String>();
          fields.addAll(listfields);  
          isActive = piiObject.isActive__c;
          
          newCase =  [SELECT CaseNumber
                                ,Country__c
                                ,Language__c
                                ,Language_Code__c
                                ,Brand__c
                                ,Age__c
                                ,AccountId
                                ,ContactId 
                        FROM Case  
                        WHERE Id=: piiObject.Case_Id__c LIMIT 1];
         
            //get account details if exists
          if (newCase.ContactId == null){
                newContact = new Contact();
                newContact.Primary_Country__c = newCase.Country__c;
                isContactExisted = false;
          } else {
          
          
                //get values from existed contact
                newContact = [SELECT FirstName
                                    ,LastName
                                    ,Phone
                                    ,Primary_Address_Line_1__c
                                    ,Primary_Address_Line_2__c
                                    ,Email
                                    ,Primary_City__c
                                    ,Primary_Country__c
                                    ,Primary_State_Province__c
                                    ,Primary_Postal_Code__c
                                    ,Birthdate
                                    ,Id
                                  
                            FROM Contact 
                            WHERE Id =:newCase.ContactId LIMIT 1];
                isContactExisted = true;

            }//end if
            

            //added by Ian Barker
            //causes page authentication issue
            /*
            if(isStateRequired){
                newContact.Primary_State_Province__c = 'N/A';
            }
            if(isZipRequired){
                newContact.Primary_Postal_Code__c = '00000';
            }
            */

        conWrapper = new ContactWrapper(newContact);
    }//end constructor
}//end class
     
public class ContactWrapper{
    public Country_Status__c selectedcountry {
    //added by Ian Barker
        get {return Country_Status__c.getInstance(ContactObject.Primary_Country__c);}

        set{selectedcountry = value;}
    }
    public String title{ get;set; }
    public String firstname{
        get{return firstname;}
          
        set{
            contactObject.firstName = value;
            firstname=value;
        }
    }
        
    public String lastname{ 
        get{return lastname;}
          
        set{
            contactObject.LastName = value;
            lastname=value;
        }
    }
        
    public String email{ 
        get{ return email;}
          
        set{
            contactObject.Email = value;
            email=value;
        }
    }
        
    public String dob {get;set;}
        
    public String address1{ 
        get{return address1;}
          
        set{
            contactObject.Primary_Address_Line_1__c = value;
            address1=value;
        }
    }
        
    public String address2{ 
        get{return address2;}
          
        set{
            contactObject.Primary_Address_Line_2__c = value;
            address2=value;
        }
    }
       
    public String city{ 
        get{return city;}
        set{
            contactObject.Primary_City__c = value;
            city=value;
        }
    }

    public String state{
        get{return state;}
        set{
            if(selectedCountry == null){
                state = value;
            } else {
                if(selectedCountry.Uses_States__c){
                    contactObject.Primary_State_Province__c = value;
                    state = value;
                }
            }
        }
    }

    public String country{ 
        get{return contactObject.Primary_Country__c;}
        set{
            contactObject.Primary_Country__c = value;
        }
    }

    public String postalcode{ 
        get{return postalcode;}
            
        set{
            if(selectedCountry == null){
                postalcode = value;
            } else {
                if(selectedCountry.Uses_Postal_Codes__c){
                    contactObject.Primary_Postal_Code__c = value;
                    postalcode = value;
                }
            }
        }
    }

    public String phone{ 
        get{return phone;}
        set{
            contactObject.Phone = value;
            phone = value;
        }
    }

    public Contact contactObject {get; set;}
        
    public ContactWrapper (Contact conObj){
        if (conObj != null){
            contactObject = conObj;
        }else{
            contactObject = new Contact();        
        }
    }
    }//end ContactWrapper class
}