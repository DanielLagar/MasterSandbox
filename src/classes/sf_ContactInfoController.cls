/**
  * @author: Stevie Ella
  * @date: 08/11/2014
  * @description: Contact Info extension
  *     Handle custom actions from the contact info vf page.  
  *
  * NOTE: Be careful when updating CurrentCase from here
  * It is manipulated in memory - CurrentCase.ContactId may
  * not be set as expected 
  */
public with sharing class sf_ContactInfoController {

    private ApexPages.StandardController standardController;
    
    //WR260 ChrisM - colour breakout points
    public decimal amber{
        get{
            if(amber==null){
                //Get value from custom setting
                Global_Org_Settings__c gos = Global_Org_Settings__c.getInstance();
                amber = gos.Amber_Threshold__c;
            }
            return amber;
        }
        set;
    }
    
    public decimal green{
        get{
            if(green==null){
                //Get value from custom setting
                Global_Org_Settings__c gos = Global_Org_Settings__c.getInstance();
                green = gos.Green_Threshold__c;
            }
            return green;
        }
        set;
    }
    
    public String faxOtherPhone {get; set;}
    public String emailAddress {get; set;}
    public boolean isPrimaryAddressShipping {get; set;}
    public boolean isOtherAddressShipping {get; set;}
    
    public String isEmailAddressValid{get; set;}
    
    public List <SelectOption> countryOptions {get; set;}
    public String defaultCountry ;

    public Map<String, boolean> addressFieldManuallyUpdatedMap{get;set;}
    public Map<String, String> mapPrimaryAddressFieldValidation{get; set;}
    public Map<String, String> mapOtherAddressFieldValidation{get; set;}

    public sf_StrikeIronZIPCodeLookupResponseBean bean {get; set;}
    public sf_StrikeIronValidateEmailResponseBean emailBean {get; set;}
    public sf_StrikeIronValidateGblAddressRespBean addressBean {get; set;}
    public sf_StrikeIronGblCodeLookupResponseBean globalCodeBean {get; set;}
    
    private static sf_StrikeIronService service = sf_StrikeIronServiceFactory.getStrikeIronService();
    
    /********************************
    * START: CR16 Digital Returns   *
    ********************************/
    public String SelectedReturnType {get;set;}
    public list <SelectOption> returnOptions{get;set;} 
    public Boolean showReturnOptions {get;set;}
    public Set<String> returnTypes = new Set<String>();

    public void checkReturnTypes(){
        //update currentCase before calling setReturnOptions
        //So that Consumer_Wants_Follow_Up__c + High_Priority__c are updated
        //Only update Case if open
		if(caseClosed){
			ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, 'Error', system.label.Case_Closed_Message));
        }
		else{
			update currentCase;
			setReturnOptions();        	
        }
    }

    public void jsSetReturnOptions(){
        currentCase = [SELECT Id, ContactId, Case_Products__c, Selected_Return_Type__c, Consumer_Wants_Follow_Up__c, High_Priority__c, Country__c, Language__c, Closed_Date__c FROM Case WHERE Id = :currentCase.Id];
        setReturnOptions();
    }
    
    public void setReturnOptions(){
        system.debug(logginglevel.WARN, '>>> in setReturnOptions currentCase: '+currentCase);
        
        //Is Current Contact a repeater?
        //Note this will only really work for Cases created via the webform/s
        Set<String> repeaterStatuses = new Set<String>();
        repeaterStatuses.add(trg_AutoComRuleHelper.CONTACT_REPEATER_STATUS_KNOWN);
        repeaterStatuses.add(trg_AutoComRuleHelper.CONTACT_REPEATER_STATUS_SUSPECTED);
        String caseContactRepeaterStatus = '';
        if(!String.IsBlank(CurrentCase.ContactId)){
            Contact caseContact = [SELECT Repeater_Status__c FROM Contact WHERE Id = :CurrentCase.ContactId];
            caseContactRepeaterStatus = caseContact.Repeater_Status__c;
        }

        returnOptions = new List<SelectOption>();
        //Clear returnTypes - prevents issues on reload after removing a Case Comment record for example:
        returnTypes = new Set<String>();

        //Check CPs available for return - any physical? More than 1 digital?
        Integer digiCPCount = 0; 
        Integer returnCPCount = 0;//CP count where available for return and with a matching ACR
        for(Case_Product__c cp : [SELECT Name, ACR_Info__c, ACR_Return_Type__c FROM Case_Product__c WHERE Case__c = :currentCase.Id AND Product_available_for_return__c = 'Yes - Product is available' AND Productstatus__c = 'Added' AND ACR_Info__c != :getProductReturnACR.NO_MATCH]){
            returnTypes.add(cp.ACR_Return_Type__c);
            if(cp.ACR_Return_Type__c == 'Digital'){
                digiCPCount ++;
            }
            if(String.isNotBlank(cp.ACR_Info__c)){
                returnCPCount ++;
            }
        }

        showReturnOptions = false;

        system.debug(logginglevel.WARN, '!!!!!! currentCase.Case_Products__c size: '+ currentCase.Case_Products__c);
        system.debug(logginglevel.WARN, '!!!!!! String.IsBlank(currentCase.Selected_Return_Type__c): '+String.IsBlank(currentCase.Selected_Return_Type__c));
        system.debug(logginglevel.WARN, '!!!!!! returnTypes.contains(Physical): '+returnTypes.contains('Physical'));
        system.debug(logginglevel.WARN, '!!!!!! currentCase.Consumer_Wants_Follow_Up__c: '+currentCase.Consumer_Wants_Follow_Up__c);
        system.debug(logginglevel.WARN, '!!!!!! currentCase.High_Priority__c: '+currentCase.High_Priority__c);
        system.debug(logginglevel.WARN, '!!!!!! returnCPCount: '+returnCPCount);
        system.debug(logginglevel.WARN, '!!!!!! digiCPCount: '+digiCPCount);
        system.debug(logginglevel.WARN, '!!!!!! returnTypes: '+returnTypes);

        //Issue: just counting active products, need to count products available for return with a marching ACR
        //Otherwise when checking followup/high priority incorrectly displays return type with physical
        if(
        returnCPCount > 0 &&
        String.IsBlank(currentCase.Selected_Return_Type__c) &&
        (returnTypes.contains('Physical') || currentCase.Consumer_Wants_Follow_Up__c || currentCase.High_Priority__c || digiCPCount > 1
        ||
        repeaterStatuses.contains(caseContactRepeaterStatus))){//If repeater force physical
            //default to physical only
            returnOptions.add(new SelectOption('Physical',System.Label.Physical));
            showReturnOptions = True;
        }
        else if(returnTypes.contains('Digital') && String.IsBlank(currentCase.Selected_Return_Type__c)){
            returnOptions.add(new SelectOption('',System.Label.Select_Return_Type));
            returnOptions.add(new SelectOption('Digital',System.Label.Digital));
            returnOptions.add(new SelectOption('Physical',System.Label.Physical));
            
            showReturnOptions = True;
        }
        /*For Digital only support - left here for future reference 10th Mar 2017
        //TODO: What to do if digital only is found?
        else if(returnTypes.contains('Digital_Only') && String.IsBlank(currentCase.Selected_Return_Type__c)){
            returnOptions.add(new SelectOption(System.Label.Digital,System.Label.Digital));//TBC if defaulting to Digital is corect behaviour
            //TODO: Do we need a declined option here?
            showReturnOptions = True;
        }*/
        else if(!String.isBlank(currentCase.Selected_Return_Type__c)){//TODO: Possibly should only do this if Case has been submitted (i.e. Initial Case Submission data has a value)
            returnOptions.add(new SelectOption(currentCase.Selected_Return_Type__c,currentCase.Selected_Return_Type__c));
            showReturnOptions = True;
        }
    }
    /********************************
    * FIN: CR16 Digital Returns     *
    ********************************/

    /************************************************
    * START: CR47 ChrisM Multiple Contact Support   *
    ************************************************/
    //Used to disable buttons/functions if Case is closed
    public boolean caseClosed{
        get{
            if(caseClosed == null){
                caseClosed = false;
                if(currentCase.Status == 'Closed'){
                    caseClosed = true;
                }
                system.debug(logginglevel.WARN, '>>> currentCase.Status: '+currentCase.Status+' caseClosed: '+caseClosed);
            }
            return caseClosed;
        }
        set;
    }

    //Controls if remove button is enabled/disabled
    //Prevents weird behaviour if used when Contact is either not created or not associated to the Case
    //Don't want to lazy load
    //Contact must have an id - i.e saved at some point in SF
    //Must have a matching Case_Contact__c record
    public boolean canRemoveContact{
        get{
            canRemoveContact = true;
            if(String.isNotBlank(contactinfo.Id)){
                Set<Id> caseConIdSet = new Set<Id>();
                for(Case_Contact__c cc : [SELECT Id, Contact__c FROM Case_Contact__c WHERE Case__c = :currentCase.Id]){
                    caseConIdSet.add(cc.Contact__c);
                }
                if(caseConIdSet.contains(currentCase.ContactId)){
                    canRemoveContact = false;
                }
            }
            return canRemoveContact;
        }
        set;
    }

    public id selectedRecordTypeId {get;set;}

    public boolean isPrimaryCheck(Id conId){
        boolean isPrimary = false;
        List<Case_Contact__c> ccList = new List<Case_Contact__c>([SELECT Id, Case_Primary_Contact__c FROM Case_Contact__c WHERE Case__c = :currentCase.Id AND Contact__c = :conId]);
        if(!ccList.isEmpty()){
            isPrimary = ccList[0].Case_Primary_Contact__c;
        }
        return isPrimary;
    }
    public boolean isPrimary {get;set;}
    public String selectedConId {get;set;}
    public list <SelectOption> contactOptions{get;set;}
    
    public void setContactOptions(){
        List<Case_Contact__c> busCCs = new List<Case_Contact__c>();
        List<Case_Contact__c> conCCs = new List<Case_Contact__c>();
        
        contactOptions = new List<SelectOption>();
        //Added selected recordType CaseContacts first
        Id tempId = null;
        for(Case_Contact__c cc : [SELECT Id, Contact__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Name, Case_Primary_Contact__c
                                      FROM Case_Contact__c
                                      WHERE Contact_Status__c = 'Active'
                                        AND Case_Contact__c.Contact__r.RecordTypeId = :selectedRecordTypeId
                                        AND Case__c = :currentCase.Id
                                        ORDER By Case_Primary_Contact__c DESC]){
            if(String.isblank(tempId)){
                tempId = cc.Contact__c;                    
            }
            contactOptions.add(new SelectOption(cc.Contact__c, cc.Contact__r.Name));
        }
        //Add any remaining
        for(Case_Contact__c cc : [SELECT Id, Contact__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Name, Case_Primary_Contact__c, Contact__r.RecordTypeId
                                      FROM Case_Contact__c
                                      WHERE Contact_Status__c = 'Active'
                                        AND Case_Contact__c.Contact__r.RecordTypeId != :selectedRecordTypeId
                                        AND Case__c = :currentCase.Id
                                        ORDER By Case_Primary_Contact__c DESC]){
            if(String.isblank(tempId)){
                tempId = cc.Contact__c;                    
            }                          
            contactOptions.add(new SelectOption(cc.Contact__c, cc.Contact__r.Name));
        }
        
        contactOptions.add(new SelectOption('newCon', label.Add_a_new_Contact));
        
        if(String.isBlank(selectedConId)){//Don't overwrite saved con, refreshes to default
            selectedConId = tempId;
        }
        
        system.debug(logginglevel.WARN,'>>> SelectConId = '+selectedConId);
        system.debug(logginglevel.WARN, '>>> pre in setContactOptions about to set ContactInfo and isPrimary: '+isPrimary+ ' currentCase: '+currentCase);

        //Prevents isPrimary being incorrectly checked when changing recordtype
		Case contactCheck = [SELECT Id, ContactId FROM Case WHERE Id = :currentCase.Id];
        system.debug(logginglevel.WARN, '>>> contactCheck Case: '+contactCheck);

        if(!String.isBlank(selectedConId) && selectedConId !='newCon'){
            ContactInfo = new Contact();
            ContactInfo = [SELECT
                                    Id,
                                    AccountId,
                                    FirstName,
                                    LastName,
                                    Salutation,
                                    Title,
                                    Email,
                                    Fax,
                                    Country__c,
                                    Facebook_Name__c,
                                    Twitter_Name__c,
                                    Phone,
                                    HomePhone,
                                    Other_Social_Media_Name__c,
                                    MobilePhone,
                                    Preferred_Contact_Method__c,
                                    Preferred_Contact_Time__c,
                                    Primary_Country__c,
                                    Primary_Address_Line_1__c,
                                    Primary_Address_Line_2__c,
                                    Primary_Address_Line_3__c,
                                    Primary_City__c,
                                    Primary_Postal_Code__c,
                                    Primary_State_Province__c,
                                    Other_Country__c,
                                    Other_Address_Line_1__c,
                                    Other_Address_Line_2__c,
                                    Other_Address_Line_3__c,
                                    Other_City__c,
                                    Other_Postal_Code__c,
                                    Other_State_Province__c,
                                    OtherPhone,
                                    Override_Primary_Address__c,
                                    Primary_Address_Validated__c,
                                    Primary_Address_Override_Reason__c,
                                    Override_Other_Address__c,
                                    Other_Address_Validated__c,
                                    Other_Address_Override_Reason__c,
                                    Purchasing_Role__c,
                                    Shipping_Address__c,
                                    Reporter_Type__c,
                                    Delete_PII__c,
                                    RecordTypeId,
                                    Is_Regulatory_Authority__c,
                                    Birthdate, //CDOY WR364
                                    gender__c, //CDOY WR364
                                    Name_Pronunciation__c //CDOY WR362
                            FROM
                                    Contact
                            WHERE
                                    Id = :selectedConId];
            isPrimary = isPrimaryCheck(selectedConId); 
        }
        //On remove Contact default isPrimary back to true if Case has no primary
        //Don't use currentCase
        else if(String.isBlank(contactCheck.ContactId)){
            system.debug(logginglevel.WARN, '>>> Setting isPrimary to true. contactCheck.ContactId: '+contactCheck.ContactId);
            isPrimary = True;
        }
        system.debug(logginglevel.WARN, '>>> post in setContactOptions about to set ContactInfo and isPrimary: '+isPrimary+' / ContactInfo: '+ContactInfo);
    }
    
    public void setContactId(){
        Map<Id, RecordType> rtMap = New Map<Id, RecordType>([SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Contact']);

        //Clear values from previous Contact record
        isEmailAddressValid = ''; //Clear Email validation
        initMapPrimaryAddressFieldValidation(); //Clear Address validation
        lastSavedTime = ''; //Clear save time
        selectedRecordTypeId = contactInfo.RecordTypeId;
        contactInfo = new Contact(); //Clear contactInfo otherwise null fields on the newly selected contact record keep value from previously displayed contact
        RecordType rt = rtMap.get(selectedRecordTypeId);
        //Clear address options - otherwise dropdowns persists on Contact change
        cityOptions = new List <SelectOption>();
        streetOptions = new List <SelectOption>();
        cityOtherOptions = new List <SelectOption>();
		streetOtherOptions = new List <SelectOption>();

        if(selectedConId != 'newCon'){
            currentCase.ContactId = selectedConId;
        }
        else{
            //If adding a new Contact on a Case with no primary default isPrimary to true
            isPrimary = String.isBlank(currentCase.ContactId);
            system.debug(logginglevel.WARN,'!!! isPrimary: '+isPrimary);
            currentCase.ContactId = null;
            if(rt.developerName == 'Business_Contact'){
                isBusinessContact = True;
            }
        }
        setContactInfoObject(true);
    }
    /************************************************
    * FIN: CR47 ChrisM Multiple Contact Support     *
    ************************************************/
    
    public List <SelectOption> cityOptions {get; set;}
    public List <SelectOption> streetOptions {get; set;}
    public List <SelectOption> cityOtherOptions {get; set;}
    public List <SelectOption> streetOtherOptions {get; set;}
    public list <Metadata_Title_Prefix__c> prefixTitle {get; set;} //CDOY WR301
    public Contact contactInfo {get; set;}
    public Case currentCase {get; set;}
    
    //WR370 CDOY
    public boolean altLayout{
        get{
            boolean altLayout = false;
            String caseCountry = currentCase.Country__c;
            if(String.isNotBlank(caseCountry)){//Sometimes Country is set incorrectly via V3 webforms e.g. 'United States of Am' or cleared when assigned to default queue
                Country_Region_SMO__c countrySetting = Country_Region_SMO__c.getValues(caseCountry.toUpperCase());
                altLayout = countrySetting.Alternative_Contact_Info_Layout__c;               
            }
            return altLayout;
        }
        set;
    }

    public String lastSavedTime {get; set;}
    private String errorMessage; //WR082 Contact/Account Inactive User - Chris Doyle (christopher.j.doyle@accenture.com)

    //orikkers - add business info to the contact
    //5/29/2015
    public Boolean isBusinessContact {get {if (isBusinessContact == null) isBusinessContact = false; return isBusinessContact;} set;}
    
    //CDOY WR089
    public Boolean isContactPopulated {get;set;} 
    
    public sf_ContactInfoController(ApexPages.StandardController sc){ 
        
        lastSavedTime = '';
        this.standardController = sc;
        currentCase = (Case)standardController.getRecord();
        init();
        setListOfCountryOptions();
        setContactInfoObject(false);//CR47 false = not changing contact
        setContactOptions();//CR47
        setReturnOptions();//CR16
       
        if(contactInfo.id == null){
            isContactPopulated = false;
        } else {
            isContactPopulated = true;
        }
        
        initializeAddressFieldsManuallyUpdated();

        checkContactType();
        if(String.isBlank(currentCase.ContactId)){
            isPrimary = True;
        }

        if(caseClosed){
        	ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.Info,'', system.label.Case_Closed_Message));
        }
    }
    
    public sf_ContactInfoController controller {get {return this;} set;}
    public sf_ContactInfoController(){    
    }
    
    //WR202 - Contact Salutation Needed for letters - christopher.j.doyle@accenture.com - START
    public list <SelectOption> Salutations {
        get{
            if (Salutations == null){
                Salutations = new List<SelectOption>();
                
                //Select the country and language from the case.
                List <Case> countryLanguage = [select id, Country__c, Language__c from case where Id = :currentCase.Id]; 
                
                string country = countryLanguage[0].Country__c;
                string language = countryLanguage[0].language__c;
                    
                //Using the Country and Language select the relevant Salutation options from the Metadata Title Prefix table.
                list <Metadata_Title_Prefix__c> salutationList = [ select id, Prefix__c, Full_Title__c from Metadata_Title_Prefix__c where Country__c =: country and Language__c =: language ORDER BY Prefix__c ASC ];
                
                //If the salutation field is already populated then display that first.
                if(contactinfo.salutation != null){ 
                    Salutations.add(new SelectOption(contactinfo.salutation, contactinfo.salutation));
                }
                else{
                    //Add a Blank Value to the top of the list of salutations
                    Salutations.add(new SelectOption('', '--None--')); 
                }
                //Loop through the titles for the language/country and add them to the picklist
                for(Metadata_Title_Prefix__c m: salutationList){
                    if(contactinfo.salutation != m.prefix__c){
                        Salutations.add(new SelectOption(m.Prefix__c, m.Prefix__c));
                    }
                }
            }
            return Salutations;
        }
        set;
    }
    //WR202 - Contact Salutation Needed for letters - christopher.j.doyle@accenture.com - END
    
   /**
      * @author: Stevie Ella
      * @description: Initialize required properties when loading Contact Info page
    */
    public void init(){
        
        currentCase = [SELECT Id, ContactId, AccountId, status, ownerId, owner.isActive, Closed_Date__c, Country__c, Selected_Return_Type__c, Consumer_Wants_Follow_Up__c, Case_Products__c, High_Priority__c 
                       FROM Case
                       WHERE Id = :currentCase.Id];
        isEmailAddressValid = '';
        cityOptions = new List <SelectOption> ();
        cityOtherOptions = new List <SelectOption> ();
        streetOptions = new List <SelectOption> ();
        streetOtherOptions = new List <SelectOption> ();
        initMapPrimaryAddressFieldValidation();
        initMapOtherAddressFieldValidation();

    }
    
     /**
      * @author: Stevie Ella
      * @description: Initialize map of validation statuses for address, city, state and zip/postal code for primary address
    */
    public void initMapPrimaryAddressFieldValidation(){
        mapPrimaryAddressFieldValidation = new Map<String, String>();
        mapPrimaryAddressFieldValidation.put('Address', '');
        mapPrimaryAddressFieldValidation.put('City', '');
        mapPrimaryAddressFieldValidation.put('State', '');
        mapPrimaryAddressFieldValidation.put('Zip_Code', '');
    }
    
     /**
      * @author: Stevie Ella
      * @description: Initialize map of validation statuses for address, city, state and zip/postal code for other address
    */
    public void initMapOtherAddressFieldValidation(){
        mapOtherAddressFieldValidation = new Map<String, String>();
        mapOtherAddressFieldValidation.put('Address', '');
        mapOtherAddressFieldValidation.put('City', '');
        mapOtherAddressFieldValidation.put('State', '');
        mapOtherAddressFieldValidation.put('Zip_Code', '');
    }
    
     /**
      * @author: Stevie Ella
      * @description: Set list of countries to be used in primary country and other country picklists
    */
    public void setListOfCountryOptions(){
        countryOptions = new List <SelectOption>();
        Schema.DescribeFieldResult countryFieldResult = Contact.Country__c.getDescribe();
        List<Schema.PicklistEntry> countryPickListEntry = countryFieldResult.getPicklistValues();
        
        countryOptions.add(new SelectOption('', '--None--'));
        
        for( Schema.PicklistEntry ple : countryPickListEntry){
            countryOptions.add(new SelectOption(ple.getValue(), ple.getLabel()));
            if(ple.isDefaultValue()){
                defaultCountry = ple.getValue();
            }
        }       

    }
    
    public void initializeAddressFieldsManuallyUpdated(){
        addressFieldManuallyUpdatedMap = new Map<String, boolean>();
        addressFieldManuallyUpdatedMap.put('Primary_Address_Valid', false);
        addressFieldManuallyUpdatedMap.put('Primary_Address_Invalid', false);
        addressFieldManuallyUpdatedMap.put('Other_Address_Valid', false);
        addressFieldManuallyUpdatedMap.put('Other_Address_Invalid', false);
    }
    
    public PageReference setUnverifiedPrimaryAddress(){
        addressFieldManuallyUpdatedMap.put('Primary_Address_Invalid', true);
        return null;
    }
    
    public PageReference setUnverifiedOtherAddress(){
        addressFieldManuallyUpdatedMap.put('Other_Address_Invalid', true);
        return null;
    }


    public void setContactInfoObject(boolean updatingContact){ //CR47 True = changing contact record
        if(!updatingContact){
            //TODO: This overwrites init() - we query the Case twice?
            currentCase = [
                    SELECT
                            Id,
                            ContactId,
                            AccountId,
                            status, //CDOY WR089
                            ownerId, //CDOY
                            owner.isActive, //CDOY
                            Closed_Date__c,
                            Country__c,
                            Selected_Return_type__C, //CR16
                            Consumer_Wants_Follow_Up__c, //CR16 
                            Case_Products__c,
                            High_Priority__c //CR16
                    FROM Case
                    WHERE Id = :currentCase.Id
                    LIMIT 1
            ];            
        }

        // If the case has already a Contact, retrieve it
        if(!String.isEmpty(String.valueOf(currentCase.ContactId))){
            isPrimary = isPrimaryCheck(currentCase.ContactId);//CR47
            Contact tempContact = new Contact ();
            tempContact = [SELECT
                                Id,
                                AccountId,
                                FirstName,
                                LastName,
                                Salutation,
                                Title,
                                Email,
                                Fax,
                                Country__c,
                                Facebook_Name__c,
                                Twitter_Name__c,
                                Phone,
                                HomePhone,
                                Other_Social_Media_Name__c,
                                MobilePhone,
                                Preferred_Contact_Method__c,
                                Preferred_Contact_Time__c,
                                Primary_Country__c,
                                Primary_Address_Line_1__c,
                                Primary_Address_Line_2__c,
                                Primary_Address_Line_3__c,
                                Primary_City__c,
                                Primary_Postal_Code__c,
                                Primary_State_Province__c,
                                Other_Country__c,
                                Other_Address_Line_1__c,
                                Other_Address_Line_2__c,
                                Other_Address_Line_3__c,
                                Other_City__c,
                                Other_Postal_Code__c,
                                Other_State_Province__c,
                                OtherPhone,
                                Override_Primary_Address__c,
                                Primary_Address_Validated__c,
                                Primary_Address_Override_Reason__c,
                                Override_Other_Address__c,
                                Other_Address_Validated__c,
                                Other_Address_Override_Reason__c,
                                Purchasing_Role__c,
                                Shipping_Address__c,
                                Reporter_Type__c,
                                Delete_PII__c,
                                RecordTypeId,
                                Is_Regulatory_Authority__c,
                                Birthdate, //CDOY WR364
                                gender__c //CDOY WR364
                        FROM Contact
                        WHERE Id = :currentCase.ContactId
                        LIMIT 1
                ];

                if (contactInfo != null) {           
                    /*
                        User Story - Contact Object in Console
                        When selecting an Existing Contact, I would like blank fields in the Existing Contact to be updated 
                        with the data entered into the Contact Tab of the console by the agent. 
                        i.e. any new data added by the agent are appended to the existing contact.
                    */

                    //5/28/2015
                    //basic info
                    tempContact.FirstName = String.isEmpty(tempContact.FirstName) ? contactInfo.FirstName : tempContact.FirstName;
                    tempContact.LastName = String.isEmpty(tempContact.LastName) ? contactInfo.LastName : tempContact.LastName;
                    tempContact.Salutation = String.isEmpty(tempContact.Salutation) ? contactInfo.Salutation : tempContact.Salutation;
                    //tempContact.Title = String.isEmpty(tempContact.Title) ? contactInfo.Title : tempContact.Title; //CDOY WR202
                    tempContact.Title = contactInfo.Salutation;
                    tempContact.Email = String.isEmpty(tempContact.Email) ? contactInfo.Email : tempContact.Email;
                    tempContact.Phone = String.isEmpty(tempContact.Phone) ? contactInfo.Phone : tempContact.Phone;
                    tempContact.MobilePhone = String.isEmpty(tempContact.MobilePhone) ? contactInfo.MobilePhone : tempContact.MobilePhone;
                    tempContact.Fax = String.isEmpty(tempContact.Fax) ? contactInfo.Fax : tempContact.Fax;

                    //primary address
                    tempContact.Primary_Address_Line_1__c = String.isEmpty(tempContact.Primary_Address_Line_1__c) ? contactInfo.Primary_Address_Line_1__c : tempContact.Primary_Address_Line_1__c;
                    tempContact.Primary_Address_Line_2__c = String.isEmpty(tempContact.Primary_Address_Line_2__c) ? contactInfo.Primary_Address_Line_2__c : tempContact.Primary_Address_Line_2__c;
                    tempContact.Primary_Address_Line_3__c = String.isEmpty(tempContact.Primary_Address_Line_3__c) ? contactInfo.Primary_Address_Line_3__c : tempContact.Primary_Address_Line_3__c;
                    tempContact.Primary_City__c = String.isEmpty(tempContact.Primary_City__c) ? contactInfo.Primary_City__c : tempContact.Primary_City__c;
                    tempContact.Primary_State_Province__c = String.isEmpty(tempContact.Primary_State_Province__c) ? contactInfo.Primary_State_Province__c : tempContact.Primary_State_Province__c;
                    tempContact.Primary_Postal_Code__c = String.isEmpty(tempContact.Primary_Postal_Code__c) ? contactInfo.Primary_Postal_Code__c : tempContact.Primary_Postal_Code__c;
                    tempContact.Primary_Country__c = String.isEmpty(tempContact.Primary_Country__c) ? contactInfo.Primary_Country__c : tempContact.Primary_Country__c;
                    
                    //other address
                    tempContact.Other_Address_Line_1__c = String.isEmpty(tempContact.Other_Address_Line_1__c) ? contactInfo.Other_Address_Line_1__c : tempContact.Other_Address_Line_1__c;
                    tempContact.Other_Address_Line_2__c = String.isEmpty(tempContact.Other_Address_Line_2__c) ? contactInfo.Other_Address_Line_2__c : tempContact.Other_Address_Line_2__c;
                    tempContact.Other_Address_Line_3__c = String.isEmpty(tempContact.Other_Address_Line_3__c) ? contactInfo.Other_Address_Line_3__c : tempContact.Other_Address_Line_3__c;
                    tempContact.Other_City__c = String.isEmpty(tempContact.Other_City__c) ? contactInfo.Other_City__c : tempContact.Other_City__c;
                    tempContact.Other_State_Province__c = String.isEmpty(tempContact.Other_State_Province__c) ? contactInfo.Other_State_Province__c : tempContact.Other_State_Province__c;
                    tempContact.Other_Postal_Code__c = String.isEmpty(tempContact.Other_Postal_Code__c) ? contactInfo.Other_Postal_Code__c : tempContact.Other_Postal_Code__c;
                    tempContact.Other_Country__c = String.isEmpty(tempContact.Other_Country__c) ? contactInfo.Other_Country__c : tempContact.Other_Country__c;

                    //do we need to reset validation?
                    tempContact.Primary_Address_Validated__c = false;
                    tempContact.Other_Address_Validated__c = false;
                }
                
                contactInfo = tempContact;
                // Set shipping address checkboxesK
                if(sf_Constants.CONTACT_SHIPPING_ADDRESS_OTHER_ADDRESS.equals(contactInfo.Shipping_Address__c)){
                    isPrimaryAddressShipping = false;
                    isOtherAddressShipping = true;
                }else if(sf_Constants.CONTACT_SHIPPING_ADDRESS_PRIMARY_ADDRESS.equals(contactInfo.Shipping_Address__c)){
                    isPrimaryAddressShipping = true;
                    isOtherAddressShipping = false;
                }
            }
            // If the case has no contact, create a new one.
            else{
                system.debug('!!! ContactInfo.ctr case has no Contact. SelectedRecordTypeId: '+selectedRecordTypeId+' isBusinessContact: '+isBusinessContact);
                contactInfo = new Contact();
                if (isBusinessContact) {
                    contactInfo.AccountId = null;
                    contactInfo.RecordTypeId = selectedRecordTypeId;
                } else {
                    contactInfo.reporter_Type__c = 'Consumer';
                }
            }
        if(String.isEmpty(contactInfo.Primary_Country__c)){
            if(!String.isEmpty(currentCase.Country__c)){
                contactInfo.Primary_Country__c = currentCase.Country__c;
            }
            else{
                contactInfo.Primary_Country__c = defaultCountry;  
            }                  
        }

        if(String.isEmpty(contactInfo.Other_Country__c)){
            if(!String.isEmpty(currentCase.Country__c)){
                contactInfo.Other_Country__c = currentCase.Country__c;
            }
            else{
                contactInfo.Other_Country__c = defaultCountry;
            }           
        }
        
        isPrimary = isPrimaryCheck(contactInfo.Id);
        //find out whether this is a business rt or not
        checkContactType();       
    }

    public PageReference checkContactType  () {
        system.debug(logginglevel.WARN,'>>> in checkContactType contactinfo: '+contactInfo);
        if (contactInfo != null && contactInfo.RecordTypeId != null) {
            Schema.DescribeSObjectResult d = Schema.SObjectType.Contact; 
            Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
            Schema.RecordTypeInfo rtByName =  rtMapByName.get('Business Contact');
            isBusinessContact = rtByName.getRecordTypeId() == contactInfo.RecordTypeId;
        }
        else {
            isBusinessContact = false;
        }
        /*if (contactInfo != null && isBusinessContact && contactInfo.Id == null && currentCase.AccountId != null){
            //contactInfo.AccountId = currentCase.AccountId;//CR47 removing
        }
        else */if(contactInfo != null && isBusinessContact && contactInfo.AccountId != null){
            currentCase.AccountId = contactInfo.AccountId;
        } 
        return null;
    }


    //ChrisM - pre CR47 Multi Contact changes 
    public PageReference onContactTypeChange  () {
    	if(caseClosed){
    		ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, 'Error', system.label.Case_Closed_Message));
    	}
    	else{
	        selectedRecordTypeId = contactInfo.RecordTypeId;//CR47
	        
	        checkContactType  ();
	        contactInfo.reporter_Type__c = !isBusinessContact ? 'Consumer' : '';
	        setContactOptions();
    	}
        return null;
    }
    
    public void saveContact(){
        //START - CR16 Digi returns validations
        /****************************************************
         * CR16 Digi returns validations Seperate           *
         * method to prevent further unnecessary processing *
        ****************************************************/
        //Using checklist instead
        /*if(returnOptions.size() > 1 && String.isBlank(SelectedReturnType)){
            ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, 'Error', System.Label.Please_Select_a_Return_Type));
        }*/
        if(SelectedReturnType == System.Label.Digital && String.IsBlank(contactInfo.Email) && isPrimary){//Only Primary Contact email is required
            ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, 'Error', System.label.Digi_Email_Required));
        }
        else{
            currentCase.Selected_Return_Type__c = SelectedReturnType;
        } 

        boolean process = true;
        system.debug(logginglevel.WARN,'!!! in saveContact. has messages? '+ApexPages.hasMessages());//Will always have one because of the successful save message
        Set<ApexPages.Message> msgs = new Set<ApexPages.Message>(ApexPages.getMessages());
        for(ApexPages.Message msg : msgs){
            if(msg.getSeverity() == ApexPages.Severity.ERROR || msg.getSeverity() == ApexPages.Severity.FATAL) {
                process = false;
                break;
            }
        }
        //Prevent further processing regardless of message
        if(process){
            //Now update CP's?
            List<Case_Product__c> cpsToUpdate = new List<Case_Product__c>();
            for(Case_Product__c cp : [SELECT Id, ACR_Return_Type__c, Digital_Return_Id__c FROM Case_Product__c WHERE Case__C = :currentCase.Id]){
                //Don't overwrite with null, this can happen depending on the order the advisor completes the subtabs
                if(String.isNotBlank(currentCase.Selected_Return_Type__c) && cp.ACR_Return_Type__c != currentCase.Selected_Return_Type__c){ 
                    cp.ACR_Return_Type__c = currentCase.Selected_Return_Type__c;
                    if(String.isBlank(cp.Digital_Return_Id__c)){
                        cp.Digital_Return_Id__c = getProductReturnACR.setDigitalReturnId(cp.Id);
                    }
                    cpsToUpdate.add(cp);
                } 
            }
            try{
                update cpsToUpdate;
            }
            catch(dmlException de){
                ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, 'Error', 'Problem on updating CaseProducts: '+de.getMessage()));
            }
            nowSave();
        }
    }
    
    public void nowSave(){
        system.debug('!!! ContactInfo.ctr in saveContact');
        Case_Contact__c tempCC = new Case_Contact__c();
        Map<Id, Case_Contact__c> casConMap = new Map<Id, Case_Contact__c>();
        List<Case_Contact__c> casConList = new List<Case_Contact__c>();
        List<Case_Contact__c> caseConsToUpsert = new List<Case_Contact__c>();
        Set<Id> primaryCaseCons = new Set <Id>();
        boolean process = true; //throwing exceptions without page messages are not user friendly - page messages on their own don't stop code flow
        
        if(contactOptions.size() > 1){//Will always be one "Add a new Contact"
            for(Case_Contact__c cc : [SELECT Id, Case__c, Contact__c, Case_Primary_Contact__c FROM Case_Contact__c WHERE Case__c = :currentCase.Id]){
                casConMap.put(cc.Contact__c, cc);
                casConList.add(cc);
                if(cc.Case_Primary_Contact__c){
                    primaryCaseCons.add(cc.Id);
                }
            }
        }
        
        system.debug(logginglevel.WARN,'!!! ContactInfo.ctr casConMap: '+casConMap);
        system.debug(logginglevel.WARN,'!!! ContactInfo.ctr Pre saveContact. isPrimary: '+isPrimary);
        /********************************
         * Adding a  primary contact    *
        ********************************/
        if(isPrimary){//CR47 set as primary
            //Update/insert Contact
            checkContactType(); //this will do the magic with the account id on the case and contact
            contactInfo.OwnerId = UserInfo.getUserId();
            //TODO: Check here for multiple primary?
            try{
                system.debug(logginglevel.WARN,'!!! ContactInfo.ctr saveContact, 1st upsert contactInfo');
                upsert contactInfo; //Need the ContactId for the Case_Contact__c record
                //Attach the contact to the current case
                currentCase.ContactId = contactInfo.Id;
            }
            catch(Exception e){
            	process = false;
				System.enqueueJob(new exceptionHelperQueable(e,'ContactInfo - error on Primary Contact upsert. Case: '+String.ValueOf(currentCase)+' contact: '+String.ValueOf(contactinfo)));
				ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, 'Error', 'Error on upsert contactInfo. Details: '+e.getMessage()));
            }

            //Only process if contactInfo update was a success
            if(process){
	            if(casConMap.containsKey(currentCase.ContactId)){
	                tempCC = casConMap.get(currentCase.ContactId);
	                tempCC.Contact_Status__c = 'Active';
	                tempCC.Case_Primary_Contact__c = isPrimary;
	                caseConsToUpsert.add(tempCC);
	            }
	            else{
	                tempCC = caseContactHelper.createNewCC(currentCase.Id, ContactInfo.Id, isPrimary, false);
	                caseConsToUpsert.add(tempCC);             
	            }
	            
	            //Prevent multiple primary Case Contacts
	            system.debug(logginglevel.WARN,'!!! ContactInfo.ctr saveContact currentCase.contactId: '+currentCase.contactId);
	            system.debug(logginglevel.WARN,'!!! ContactInfo.ctr saveContact tempCC.Contact__c: '+tempCC.Contact__c);
	            for(Case_Contact__c ccx :casConList){
	                if(ccx.contact__c != tempCC.Contact__c && ccx.Case_Primary_Contact__c == True){
	                    ccx.Case_Primary_Contact__c = False;
	                    caseConsToUpsert.add(ccx);
	                }
	            }
	            //TODO: try description here
	            try{
	                system.debug(logginglevel.WARN,'!!! ContactInfo.ctr saveContact, upsert caseConsToUpsert '+casConList);
                    //Bypass caseConTrigger, allowing multiple primary initially
                    checkRecursive.doNotByPass = false;
	                upsert caseConsToUpsert;
	            }
	            catch(dmlException e){
	                System.enqueueJob(new exceptionHelperQueable(e,'ContactInfo - error on upsert caseConsToUpsert Case: '+String.ValueOf(currentCase)+' contact: '+String.ValueOf(caseConsToUpsert)));
	                system.debug(logginglevel.WARN,'!!! ContactInfo.ctr caseConsToUpsert exception: '+e.getMessage());
	                ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, 'Error', 'Error on upsert caseConsToUpsert. Details: '+e.getMessage()));
	            }
	            //TODO: try description here
		        try{
		            // Attach the contact to the current case
		            //currentCase.ContactId = contactInfo.Id; //Already done earlier
		            
		            //Attach the contact's account to the current case
		            system.debug(logginglevel.WARN,'!!! ContactInfo.ctr post upsert saveContact. isPrimary: '+isPrimary);
		                
		            //Attach the contact's account to the current case
		            Contact con = [SELECT Id, AccountId, Salutation FROM Contact WHERE Id = :contactInfo.Id]; //Title Added CDOY - WR202

		            if(!isBusinessContact){
		                currentCase.AccountId = con.AccountId;
		            }       
		            update currentCase;

		            Case thisCase = [SELECT Id, Prefix_Title__c, country__c, language__c, Closed_Date__c FROM Case WHERE Id = :currentcase.Id LIMIT 1];
		                    
		            if(con.salutation != null){
		                //CDOY WR301 Changed prefix title to a list
		                list<Metadata_Title_Prefix__c> prefixTitle = [ SELECT id, Prefix__c, Full_Title__c, Country__c, Language__c FROM Metadata_Title_Prefix__c WHERE Prefix__c =: con.Salutation AND Country__c =: thisCase.country__c and Language__c =: thisCase.Language__c LIMIT 1]; //CDOY WR202
		                
		                String fullTitle = '';
		                if(!prefixTitle.isEmpty()){
		                    fullTitle = prefixTitle[0].full_Title__c;
		                    thisCase.Prefix_Title__c = fullTitle; 
		                    update thisCase;
		                }
		                else{                                    
		                    thisCase.Prefix_Title__c = '';        
		                    update thisCase;
		                }
		            }
		            else{
		                thisCase.Prefix_Title__c = '';   
		                update thisCase;
		            }

		            tagCases(contactinfo.Id);//asynch

		            DateTime lastSaved = System.now();
		            TimeZone tz = UserInfo.getTimeZone();
		            //lastSaved = lastSaved.AddSeconds(tz.getOffset(lastSaved)/1000);
		            lastSavedTime = lastSaved.format('h:mm:ss a');
		            isContactPopulated = true;//CDOY WR089           
		            selectedConId = contactInfo.Id;
		            ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.CONFIRM, Label.Contact_Info_Contact_Saved, ''));
				}
				catch(Exception e){
					System.enqueueJob(new exceptionHelperQueable(e,'ContactInfo - error on primary contact save: '+String.ValueOf(currentCase)));
					errorMessage = e.getMessage(); //WR082 Contact/Account Inactive User - Chris Doyle (christopher.j.doyle@accenture.com) START 
					if(!e.getMessage().contains('INVALID_EMAIL_ADDRESS') && !e.getMessage().contains('Email')){
						if(errorMessage.contains('CANNOT_REPARENT_RECORD')) {
							ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, 'Error', label.AgentConsole_Cannot_Reparent_Record));
						} 
						else{ 
							ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, 'Error', e.getMessage()));
						}  
					}
				}
            }
        }//CR47 if is primary end
        
        /********************************
         * Adding a non primary contact *
        ********************************/
        else if(!isPrimary){

            contactInfo.OwnerId = UserInfo.getUserId();
            system.debug(logginglevel.WARN,'!!! ContactInfo.ctr upserting non primary Contact. CurrentCase.ContactId: '+currentCase.ContactId);
            try{
                upsert contactInfo;
            }
            catch(exception e){
            	process = false;
				System.enqueueJob(new exceptionHelperQueable(e,'ContactInfo - error on non-Primary Contact upsert. Case: '+String.ValueOf(currentCase)+' contact: '+String.ValueOf(contactinfo)));
				ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, 'Error', e.getMessage()));
            }

            if(process){
	            if(casConMap.containsKey(ContactInfo.Id)){
	                tempCC = casConMap.get(ContactInfo.Id);
	                tempCC.Contact_Status__c = 'Active';
	                tempCC.Case_Primary_Contact__c = isPrimary;
	            }
	            else{
	                tempCC = caseContactHelper.createNewCC(currentCase.Id, ContactInfo.Id, isPrimary, false);
	            }

	            if(primaryCaseCons.contains(tempCC.Id)){
	                System.debug(logginglevel.WARN,'!!! ContactInfo.ctr adding error message. PrimaryCaseCons: '+primaryCaseCons+' +tempCC.Id: '+tempCC.Id);
	                ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, System.label.Select_a_new_Primary_Contact, ''));

	            }
	            else{
	                try{
	                    upsert tempCC;
	                    
	                    //Update lastmodified on currentCase for Tibco to repull
	                    //Only update if Case has been previously submitted?

                        /****************************************************************************************
                        Causing non-primary to get set as primary when Case is closed. is this required now     *
                        if the ContactInfo buttons are disabled and the advisor has to open the Case            *
                        ****************************************************************************************/
	                    if(!String.isBlank(String.valueOf(currentCase.Closed_Date__c))){
                            //So we ONLY update Child_Last_Modified_Date__c
                            case updateCase = new Case();
                            updateCase.Id = currentCase.Id;
                            updateCase.Child_Last_Modified_Date__c = datetime.now();
                            update updateCase;
	                    }

	                    tagCases(ContactInfo.Id);

	                    //Display save confirmation to advisor
	                    ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.CONFIRM, System.label.Contact_Info_Contact_Saved, ''));
	                    DateTime lastSaved = System.now();
	                    TimeZone tz = UserInfo.getTimeZone();
	                    lastSavedTime = lastSaved.format('h:mm:ss a');
	                }
	                catch(dmlexception e){
	                    System.enqueueJob(new exceptionHelperQueable(e,'ContactInfo - error on non primary contact save: '+String.ValueOf(currentCase)+ ' CaseContact: '+tempCC));
	                    ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, e.getMessage(),''));
	                }
	            }
	            selectedConId = tempCC.Contact__c;
            }
        }//!isPrimary end
        System.debug('^^^ end of save, selectedconId: '+selectedConId);
        setContactOptions();//CR47
        setReturnOptions();//CR16
    }

    /************************************************
    * START: CR47 Remove/Delete Contact Support     *
    *   +Cannot delete if submitted/synced          *
    ************************************************/
    public void removeCaseContact(){
        List<Fulfillment_Order__c> currentCaseFOs = new List<Fulfillment_Order__c>();
        List<Fulfillment_Order__c> otherRelatedFOs = new List<Fulfillment_Order__c>();
        List<Task> currentCaseTasks = new List<Task>();
        List<Task> otherRelatedTasks = new List<Task>();

        system.debug(logginglevel.WARN, '^^^ removeCaseContact contactinfo.Id: '+contactinfo.Id+' currentcase.ContactId: '+currentcase.ContactId+' CurrentCase: '+CurrentCase);
        try{
            /***********************************************
             Case has NOT been previously submitted logic  *
            ***********************************************/ 
            if(String.isBlank(String.valueOf(currentcase.Closed_Date__c))){
                for(Fulfillment_Order__c fo : [SELECT Id, Case__c FROM Fulfillment_Order__c WHERE Contact__c = :ContactInfo.Id] ){
                    if(fo.Case__C == currentCase.Id){
                        currentCaseFOs.add(fo);//Prevent Case_Contact__c delete if > 0
                    }
                    else{
                        otherRelatedFOs.add(fo); //Prevent Contact delete if > 0
                    }
                }
                if(currentCaseFOs.isEmpty()){
                    system.debug(logginglevel.WARN, '^^^ removeCaseContact task check WhatId: '+currentCase.Id+' whoid: '+ContactInfo.Id);
                    for(Task t : [SELECT Id, WhatId FROM Task WHERE WhoId = :ContactInfo.Id]){
                        if(t.WhatId == currentCase.Id){
                            currentCaseTasks.add(t);//Prevent Case_Contact__c delete if > 0
                        }
                        else{
                            otherRelatedTasks.add(t); //Prevent Contact delete if > 0
                        }
                    }
                    if(currentCaseTasks.isEmpty()){
                        Case_Contact__c caseCon = [SELECT Id, Case_Primary_Contact__c, Contact__c FROM Case_Contact__c WHERE Case__c = :currentCase.Id AND Contact__c = :ContactInfo.Id LIMIT 1];
                        List<Case_Contact__c> ccList = new List<Case_Contact__c>([SELECT Id FROM Case_Contact__c WHERE Case__c != :currentCase.Id AND Contact__c = :caseCon.Contact__c]);
                        Id caseConId = [SELECT ContactId FROM Case WHERE Id = :currentCase.Id].contactId;
                        system.debug(logginglevel.WARN,'^^^ removeCaseContact ccList: '+ccList+' ContactInfo.Id: '+ContactInfo.Id);
                        //Do this regardless of previous Cases or not
                        if(contactinfo.Id == caseConId){
                                currentCase.AccountId = null;
                                currentCase.ContactId = null;
                                currentCase.Selected_Return_Type__c = null;
                                SelectedReturnType = null;
                                update currentCase;                            
                            }
                        if(ccList.isEmpty() && otherRelatedFOs.isEmpty() && otherRelatedTasks.isEmpty()){
                            Contact conToDelete = [SELECT Id FROM Contact WHERE Id = :caseCon.Contact__c];
                            delete conToDelete;//Only do this if no FOs, no Tasks, no Cases 
                        }
                        else{//Use else as will be cascade deleted if Con is deleted in line above
                            delete caseCon; //Do this regardless of previous Cases or not
                        }
                    }
                    else{
                        ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, system.label.Cannot_Remove_Task_Contact, ''));
                    }
                }
                else{
                    ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, system.label.Cannot_Remove_FO_Contact, ''));
                }
            }
            /***********************************************
             Case HAS been previously submitted logic      *
            ***********************************************/ 
            else{
                system.debug(logginglevel.WARN, '^^^ Case has been previosuly submitted');
                Case_Contact__c caseCon = [SELECT Id, Case_Primary_Contact__c FROM Case_Contact__c WHERE Case__c = :currentCase.Id AND Contact__c = :ContactInfo.Id LIMIT 1];
                if(caseCon.Case_Primary_Contact__c){
                    ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, System.Label.Cannot_Remove_Primary_Contact, ''));  
                }
                else{
                    system.debug(logginglevel.WARN, '^^^ Non Primary Removal');
                    List<Fulfillment_Order__c> foList = new List<Fulfillment_Order__c>([SELECT Id FROM Fulfillment_Order__c WHERE Case__c = :currentCase.Id AND Contact__c = :ContactInfo.Id]);
                    List<Task> taskList = new List<Task>([SELECT Id FROM Task WHERE WhatId = :currentCase.Id AND WhoId = :ContactInfo.Id]);
                    if(foList.isEmpty() && taskList.isEmpty()){
                        caseCon.Contact_Status__c = 'Cancelled';
                        update caseCon;
                        //Now update Case so Tibco knows to repull
                        Case touchCase = new Case();//need to do this otherwise update Case.ContactId with ContactInfo.Id - the Contact we are removing
                        touchCase.Id = currentCase.Id;
                        touchCase.Child_Last_Modified_Date__c = datetime.now();
                        update touchCase;
                    }
                    else{
                        //String errorMessage = foList.isEmpty() ? system.label.Cannot_Remove_Task_Contact : system.label.Cannot_Remove_FO_Contact;
                        ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR,errorMessage = foList.isEmpty() ? system.label.Cannot_Remove_Task_Contact : system.label.Cannot_Remove_FO_Contact, ''));               
                    }
                }
            }
            system.debug(logginglevel.WARN, '^^^ removeCaseContact pre Contact removed contact - resetting form. ContactInfo: '+ContactInfo);
            selectedConId = null;
            init();
            setListOfCountryOptions();
            setContactInfoObject(false);
            setContactOptions();//CR47
            setReturnOptions();//CR16
        }
        catch(exception e){
            ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, 'Error: ', e.getMessage() + ' / '+ e.getStackTraceString()));
            System.enqueueJob(new exceptionHelperQueable(e,'ContactInfo - error on removing Contact. Case: '+String.valueOf(currentCase)+' ***Contact: '+String.valueOf(ContactInfo)));
        }
    }

    // 'touch' all cases created in the last 90 days where this contact is related.
    @future
    public static void tagCases(String conId){
    	List<Case> tagCases = new List<Case>();
		//Make days config
		//Exception handling/notification
		Global_Org_Settings__c gos = Global_Org_Settings__c.getInstance();
		Integer days = 90; //Default to 90 days if no value found
		if(gos.Tag_Case_Days__c != null){
			days = integer.valueof(gos.Tag_Case_Days__c);
		}
		//Get list of Case_Contact__c records associated to ContactId
		List<Case_Contact__c> relatedCaseContacts = new List<Case_Contact__c>([SELECT  Id, Contact__c, Case__c FROM Case_Contact__c WHERE Contact__c = :conId]);
		//Get set of Ids associated to Case_Contact__c.Id
		Set<Id> caseIds = new Set<Id>();
		for(Case_Contact__c cc :relatedCaseContacts){
			caseIds.add(cc.Case__c);
		}
		String caseQuery = 'SELECT Id, CaseNumber FROM Case WHERE ContactID = :conId AND Id In :caseIds AND CreatedDate =  LAST_N_DAYS: '+days;
		tagCases = database.query(caseQuery);

		//Update list of Cases
		//String caseQuery = 'SELECT Id, CaseNumber FROM Case WHERE ContactID = :conId AND CreatedDate =  LAST_N_DAYS: '+days;
		//tagCases = database.query(caseQuery);
		for(Case c: tagCases){
			c.Child_Last_Modified_Date__c = datetime.now();
		}
		//WR434 Prevent ACR firing on historical records
		checkrecursive.ACREnabled = false;	
		Database.SaveResult[] srList = Database.update(tagCases, false);
		System.enqueueJob(new exceptionHelperQueable(srList,'ContactInfo Ctr - updating tag Cases. Tag Case list: '+tagCases));
		checkrecursive.ACREnabled = true;
	}

    /************************************************
    * FIN: CR47 Remove/Delete Contact Support       *
    *   +Cannot delete if submitted/synced          *
    ************************************************/

    public PageReference setPrimaryAsShippingAddress(){
        contactInfo.Shipping_Address__c = sf_Constants.CONTACT_SHIPPING_ADDRESS_PRIMARY_ADDRESS;
        isOtherAddressShipping = false;
        return null;
    }

    public PageReference setOtherAsShippingAddress(){

        contactInfo.Shipping_Address__c = sf_Constants.CONTACT_SHIPPING_ADDRESS_OTHER_ADDRESS;
        isPrimaryAddressShipping = false;
        return null;
    }
    
    public PageReference setPrimaryAddressCountryOnContact(){
        contactInfo.Primary_Country__c = contactInfo.Country__c;
        return null;
    }
    
    public PageReference setOtherAddressCountryOnContact(){
        contactInfo.Other_Country__c = contactInfo.Country__c;
        return null;
    }
    
    public PageReference overridePrimaryAddress () {   
        
        if (contactInfo.Override_Primary_Address__c) {
            contactInfo.Primary_Address_Validated__c = false;
            addressFieldManuallyUpdatedMap.put('Primary_Address_Valid', false);
            addressFieldManuallyUpdatedMap.put('Primary_Address_Invalid', false);
        } 

        contactInfo.Primary_Address_Override_Reason__c = null;

        return null;
    }
    
    public PageReference overrideOtherAddress () {   
        
        if (contactInfo.Override_Other_Address__c) {
            contactInfo.Other_Address_Validated__c = false;
            contactInfo.Other_Address_Override_Reason__c = null;
            
            addressFieldManuallyUpdatedMap.put('Other_Address_Valid', false);
            addressFieldManuallyUpdatedMap.put('Other_Address_Invalid', false);
        } 

        contactInfo.Other_Address_Override_Reason__c = null;
        return null;
    }
    
    public PageReference lookUpPrimaryPostalCode () {
        try {   
            initMapPrimaryAddressFieldValidation();
            if (String.isEmpty(contactInfo.Primary_Country__c)) {
                ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, 'Error',  'Please select country.'));
     
            } else {
                if (contactInfo.Primary_Country__c.equalsIgnoreCase (sf_Constants.COUNTRY_UNITED_STATES_AMERICA)) {
                    validatePrimaryZip (contactInfo);
                } else {
                    AddressWrapper aw = validateGlobalCode (contactInfo.Primary_Postal_Code__c, contactInfo.Primary_Country__c);
                    
                    if (!String.isEmpty(aw.address1))
                        contactInfo.Primary_Address_Line_1__c = aw.address1;

                    contactInfo.Primary_City__c = aw.city;
                    contactInfo.Primary_State_Province__c = aw.state;
                    contactInfo.Primary_Postal_Code__c = aw.zip;
                    if(sf_Constants.COUNTRY_UNITED_STATES.equalsIgnoreCase(aw.country)){
                        contactInfo.Primary_Country__c = sf_Constants.COUNTRY_UNITED_STATES_AMERICA;
                    }
                    if (globalCodeBean != null){
                        ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.INFO,  'Code: ' + globalCodeBean.statusNbr, globalCodeBean.statusDescription));
                    } 
                }
            }
        } catch (Exception e) {
            ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, 'Error', 'Error occurred. Please check settings. ' + e.getMessage() + ' ' + e.getStackTraceString()));
        }
        return null;
    }
   
    public PageReference lookUpOtherPostalCode () {
        try {  
            initMapOtherAddressFieldValidation(); 
            if (String.isEmpty(contactInfo.Other_Country__c)) {
                ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, 'Error',  'Please select country.'));

            } else {
                if (contactInfo.Other_Country__c.equalsIgnoreCase (sf_Constants.COUNTRY_UNITED_STATES_AMERICA) 
                    || contactInfo.Other_Country__c.equalsIgnoreCase (sf_Constants.COUNTRY_CANADA)) {
                    validateOtherZip(contactInfo);
                } else {
                    AddressWrapper aw = validateGlobalCode (contactInfo.Other_Postal_Code__c, contactInfo.Other_Country__c);
                    
                    if (!String.isEmpty(aw.address1))
                        contactInfo.Other_Address_Line_1__c = aw.address1;
                    
                    contactInfo.Other_City__c = aw.city;
                    contactInfo.Other_State_Province__c = aw.state;
                    contactInfo.Other_Postal_Code__c = aw.zip;
                    if(sf_Constants.COUNTRY_UNITED_STATES.equalsIgnoreCase(aw.country)){
                        contactInfo.Other_Country__c = sf_Constants.COUNTRY_UNITED_STATES_AMERICA;
                    }
                    if (globalCodeBean != null){
                        ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.INFO,  '', globalCodeBean.statusDescription));

                    } 
                }
            }
        } catch (Exception e) {
            ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, 'Error', 'Error occurred. Please check settings. ' + e.getMessage() + ' ' + e.getStackTraceString()));
        }

        return null;
    }
    
    public PageReference validateEmailAddress(){
        try {
            if (String.isEmpty(contactInfo.Email)) {
                contactInfo.Email_Validation_Status__c = '';
                isEmailAddressValid = '';
            } else {
                emailBean = service.validateEmailAddress(contactInfo.Email);
                contactInfo.Email_Validation_Status__c = emailBean.validationStatusForUser;
                contactInfo.StrikeIron_Status__c = emailBean.statusNbr + ' - ' + emailBean.statusDescription;
                if (contactInfo.Email_Validation_Status__c.equalsIgnoreCase('Valid')) {
                    isEmailAddressValid = 'Valid';
                }else{
                    isEmailAddressValid = 'Invalid';
                }
                System.debug('Controller_validateEmailAddress isEmailAddressValid = ' + isEmailAddressValid + '; contactInfo.Email_Validation_Status__c = ' + contactInfo.Email_Validation_Status__c);
                
            }
        } catch (Exception e) {
            ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, e.getMessage() + ' - ' + e.getStackTraceString(), ''));
        }

        return null;
    }
    
    public PageReference validatePrimaryAddress () {
        try{
            if (contactInfo.Primary_Country__c.equalsIgnoreCase(sf_Constants.COUNTRY_UNITED_STATES_AMERICA) 
                //check if user enters canadian address with country set as USA.
                &&  !contactInfo.Primary_Postal_Code__c.remove('-').isNumeric()) {

                contactInfo.Primary_Postal_Code__c.addError('Invalid Postal Code');
                return null;

            }else {

                initMapPrimaryAddressFieldValidation();
                AddressWrapper aw = new AddressWrapper ();
                aw = validateAddress (
                    contactInfo.Primary_Address_Line_1__c,
                    contactInfo.Primary_Address_Line_2__c,
                    contactInfo.Primary_Address_Line_3__c,
                    contactInfo.Primary_City__c,
                    contactInfo.Primary_State_Province__c,
                    contactInfo.Primary_Postal_Code__c,
                    contactInfo.Primary_Country__c
                );
                
                //WR200 ChrisM
                system.debug(logginglevel.WARN,'!!! ContactInfo.ctr AddressBean: '+addressBean);
                                
                if(addressBean != null){
                    mapPrimaryAddressFieldValidation = validationResultsAddressVerification(addressBean);
                    
                    if(mapPrimaryAddressFieldValidation.get('Address') != 'false'){
                        contactInfo.Primary_Address_Line_1__c = aw.address1;
                        contactInfo.Primary_Address_Line_2__c = aw.address2;
                        contactInfo.Primary_Address_Line_3__c = aw.address3;
                    }
                    
                    if(mapPrimaryAddressFieldValidation.get('City') != 'false')
                        contactInfo.Primary_City__c = aw.city;
                    if(mapPrimaryAddressFieldValidation.get('State') != 'false')
                        contactInfo.Primary_State_Province__c = aw.state;
                    if(mapPrimaryAddressFieldValidation.get('Zip_Code') != 'false')
                        contactInfo.Primary_Postal_Code__c = aw.zip;
                        
                    if(aw.country.equalsIgnoreCase('United States'))
                        contactInfo.Primary_Country__c = sf_Constants.COUNTRY_UNITED_STATES_AMERICA;
                    
                    System.debug(logginglevel.WARN,'CONTROLLER_validatePrimaryAddress addressBean.buildingNumberMessage = ' + addressBean.buildingNumberMessage
                        + '; addressBean.streetMessage = ' + addressBean.streetMessage + ' and streetName = ' + addressBean.streetName
                        + '; addressBean.cityMessage = ' + addressBean.cityMessage + ' and province = ' + addressBean.streetName
                        + '; addressBean.stateMessage = ' + addressBean.stateMessage + ' and country = ' + addressBean.country
                        + '; addressBean.zipMessage = ' + addressBean.zipMessage
                        + '; addressBean.buildingMessage = ' + addressBean.buildingMessage
                        + '; addressBean.orgMessage = ' + addressBean.orgMessage
                    );
                    if (addressBean.statusNbr == '221' || addressBean.statusNbr == '222') { //either valid or corrected
                        contactInfo.Primary_Address_Validated__c = true;
                        contactInfo.Override_Primary_Address__c = false;
                        
                        addressFieldManuallyUpdatedMap.put('Primary_Address_Valid', true);
                        addressFieldManuallyUpdatedMap.put('Primary_Address_Invalid', false);
                    } else {
                        contactInfo.Primary_Address_Validated__c = false;
                        //contactInfo.Override_Primary_Address__c = true;
                        
                        addressFieldManuallyUpdatedMap.put('Primary_Address_Valid', false);
                        addressFieldManuallyUpdatedMap.put('Primary_Address_Invalid', true);
                    }
                }
            } //end if valid zip for USA
        } catch (Exception e) {
            ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, 'Error occurred', 'Please check settings. ' + e.getMessage() + ' ' + e.getStackTraceString()));
        }
        return null;
    }
    
    public PageReference validateOtherAddress () {

        if (contactInfo.Other_Country__c.equalsIgnoreCase(sf_Constants.COUNTRY_UNITED_STATES_AMERICA) 
                //check if user enters canadian address with country set as USA.
            &&  !contactInfo.Other_Postal_Code__c.remove('-').isNumeric()) {

            contactInfo.Other_Postal_Code__c.addError('Invalid Postal Code');
            return null;

        } else {
            
            try{
                initMapOtherAddressFieldValidation();
                AddressWrapper aw = new AddressWrapper ();
                aw = validateAddress (
                    contactInfo.Other_Address_Line_1__c,
                    contactInfo.Other_Address_Line_2__c,
                    contactInfo.Other_Address_Line_3__c,
                    contactInfo.Other_City__c,
                    contactInfo.Other_State_Province__c,
                    contactInfo.Other_Postal_Code__c,
                    contactInfo.Other_Country__c
                );
     
                if(addressBean != null){
                    mapOtherAddressFieldValidation = validationResultsAddressVerification(addressBean);
                    
                    if(mapOtherAddressFieldValidation.get('Address') != 'false'){
                        contactInfo.Other_Address_Line_1__c = aw.address1;
                        contactInfo.Other_Address_Line_2__c = aw.address2;
                        contactInfo.Other_Address_Line_3__c = aw.address3;
                    }
                    
                    if(mapOtherAddressFieldValidation.get('City') != 'false')
                        contactInfo.Other_City__c = aw.city;
                    
                    if(mapOtherAddressFieldValidation.get('State') != 'false')
                        contactInfo.Other_State_Province__c = aw.state;
                        
                    if(mapOtherAddressFieldValidation.get('Zip_Code') != 'false')   
                        contactInfo.Other_Postal_Code__c = aw.zip;
                        
                    if(aw.country.equalsIgnoreCase('United States'))
                        contactInfo.Other_Country__c = sf_Constants.COUNTRY_UNITED_STATES_AMERICA;
                
                    if (addressBean.statusNbr == '221' || addressBean.statusNbr == '222') { //either valid or corrected
                        contactInfo.Other_Address_Validated__c = true;
                        contactInfo.Override_Other_Address__c = false;
                        addressFieldManuallyUpdatedMap.put('Other_Address_Valid', true);
                        addressFieldManuallyUpdatedMap.put('Other_Address_Invalid', false);

                    } else {
                        contactInfo.Other_Address_Validated__c = false;

                        addressFieldManuallyUpdatedMap.put('Other_Address_Valid', false);
                        addressFieldManuallyUpdatedMap.put('Other_Address_Invalid', true);
                    }
                }

            } catch (Exception e) {
                ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, 'Error occurred', 'Please check settings. ' + e.getMessage() + ' ' + e.getStackTraceString()));
            }
            return null;
        }
    }
     
    private AddressWrapper validateAddress (String address1, String address2, String address3, String city, String state, String zip, String country) {
        addressBean = null;
        AddressWrapper aw = new AddressWrapper ();

        String street = '';
        if (!String.isEmpty(address1)) street += address1 + ' ';
        if (!String.isEmpty(address2)) street += address2 + ' ';
        if (!String.isEmpty(address3)) street += address3 + ' ';
        street = street.replaceAll('(\\s+)', ' ');

        String cityStateZip = '';
        if(!String.isEmpty(city)) cityStateZip += city.replace('.', ' ') + ' ';
        cityStateZip += String.isEmpty(state) ?'' : state + ' ';
        cityStateZip += zip + ' ';

        System.debug(logginglevel.WARN,'CONTROLLER_validateAddress address1 = ' + address1 + '; city = ' + city + '; state = ' + state + '; zip = ' + zip + '; country = ' + country);
        if (String.isEmpty(address1) || String.isEmpty(country) 
            || String.isEmpty(city) || String.isEmpty(zip)) {
            ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, '', Label.Contact_Info_Missing_Fields));
            
        } else {
            addressBean = service.validateGlobalAddress(street, cityStateZip, country);
        }

        //ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.INFO, 'Bean.xmlString: ', addressBean.xmlString));

        if (addressBean != null) {
            if (addressBean.formattedAddress != null) {
                
                List<String> listOfAddressLineResults = new List<String>();
                
                if(!String.isEmpty(addressBean.contact))
                    listOfAddressLineResults.add(addressBean.contact);
                    
                if(!String.isEmpty(addressBean.poBox))
                    listOfAddressLineResults.add(addressBean.poBox);
                    
                String completeStreet = addressBean.streetNumber + ' ' + addressBean.streetName + ' ' + addressBean.buildingName;
                if(!String.isEmpty(completeStreet.trim()))
                    listOfAddressLineResults.add(completeStreet.trim());
                    
                Integer addressLength = listOfAddressLineResults.size();
                
                // Set appropriate values in address line 1, 2 and 3 if applicable
                if(addressLength > 0)
                    aw.address1 = listOfAddressLineResults.get(0).toUpperCase();
                if(addressLength > 1)
                    aw.address2 = listOfAddressLineResults.get(1).toUpperCase();
                if(addressLength > 2)
                    aw.address3 = listOfAddressLineResults.get(2).toUpperCase();

                aw.city = !String.isEmpty(addressBean.locality) ? addressBean.locality : city;
                if (!String.isEmpty(aw.city)) aw.city = aw.city.toUpperCase();

                aw.state = !String.isEmpty(addressBean.province) ? addressBean.province : state;
                if (!String.isEmpty(aw.state)) aw.state = aw.state.toUpperCase();

                aw.zip = !String.isEmpty(addressBean.postalCode) ? addressBean.postalCode : zip;
                if (!String.isEmpty(aw.zip)) aw.zip = aw.zip.toUpperCase();

                aw.country = !String.isEmpty(addressBean.country) ? addressBean.country : country;
                if (!String.isEmpty(aw.country)) aw.country  = aw.country .toUpperCase();
            }


            if (addressBean.statusNbr == '221') {
                ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.INFO, '', addressBean.statusDescription));
                    
            } else if (addressBean.statusNbr == '222') {
                ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.WARNING, '', addressBean.statusDescription));

            } else {
                ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, '', addressBean.statusDescription));
            }

        }

        return aw;
    }
     
    private AddressWrapper validateGlobalCode (String zipOrPostalCode, String country) {
        AddressWrapper aw = new AddressWrapper ();
        cityOptions = new List <SelectOption> ();
        globalCodeBean = null;

        if (String.isEmpty(zipOrPostalCode) || String.isEmpty(country)) {            
            ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, 'Error', 'Postal code and country are required.'));
        } else {
            globalCodeBean = service.lookupGlobalPostalCode (zipOrPostalCode, country);
            
            if(globalCodeBean != null){
                aw.address1 = !String.isEmpty(globalCodeBean.streetName) ? globalCodeBean.streetName : '';
                aw.city = !String.isEmpty(globalCodeBean.city) ? globalCodeBean.city : '';
                aw.state = !String.isEmpty(globalCodeBean.stateOrProvince) ? globalCodeBean.stateOrProvince : '';
                aw.zip = !String.isEmpty(globalCodeBean.postalOrZIPCode) ? globalCodeBean.postalOrZIPCode : zipOrPostalCode;
            }
        }

        return aw;

    }

   public PageReference validatePrimaryZip (Contact con) {
        cityOptions = new List <SelectOption> ();
        streetOptions = new List <SelectOption> ();

        try {
            
            bean = service.lookupZIPCodeInfo (con.Primary_Postal_Code__c);
            
            if (bean != null) {

                System.debug('!!! ContactInfo.ctr validatePrimaryZip');
                for (sf_StrikeIronZIPCodeLookupResponseBean.AliasInfo al: bean.aliases) {
                    System.debug('!!! ContactInfo.ctr validatePrimaryZip aliasCityName = ' + al.aliasCityName);
                    cityOptions.add (new SelectOption (al.aliasCityName, al.aliasCityName));
                }

                for (sf_StrikeIronZIPCodeLookupResponseBean.StreetInfo si: bean.streets) {
                    String s = si.StreetNumberLow + '-' + si.StreetNumberHigh;
                    streetOptions.add (new SelectOption (s, s));
                    System.debug('!!! ContactInfo.ctr validatePrimaryZip Street (Low - High) = ' + s);
                }

               con.Primary_State_Province__c = bean.stateOrProvinceCode;
               con.Primary_Postal_Code__c = bean.formattedZIPOrPostalCode;
               con.Primary_City__c = bean.city;
               if(sf_Constants.COUNTRY_UNITED_STATES.equalsIgnoreCase(bean.countryName)){
                    con.Primary_Country__c = sf_Constants.COUNTRY_UNITED_STATES_AMERICA;
               }

                System.debug('!!! ContactInfo.ctr validatePrimaryZip streetOptions.size = ' + streetOptions.size());
                if (streetOptions.size() > 0) { // only one city
                    String primaryAddressLine1 = bean.streets[0].StreetNumberLow + ' ' + bean.streets[0].StreetNumberHigh + ' ';
                    primaryAddressLine1 += bean.streets[0].streetPreDirection + ' ';
                    primaryAddressLine1 += bean.streets[0].streetName + ' ';
                    primaryAddressLine1 += bean.streets[0].streetSuffix + ' ';
                    primaryAddressLine1 += bean.streets[0].streetPostDirection + ' ';
                    primaryAddressLine1 = primaryAddressLine1.replaceAll('(\\s+)', ' '); //get rid of extra spaces
                    System.debug('!!! ContactInfo.ctr validatePrimaryZip primaryAddressLine1 = ' + primaryAddressLine1);
                    if(!String.isEmpty(primaryAddressLine1.trim())){
                        con.Primary_Address_Line_1__c = primaryAddressLine1;
                    }  
                }

                con.StrikeIron_Status__c = 'Code ' + bean.statusNbr + ' - ' + bean.statusDescription;

                if (bean.statusNbr.contains('201') || bean.statusNbr.contains('202') || bean.statusNbr.contains('203')) {
                    ApexPages.addMessage (new ApexPages.Message (sf_StrikeIronZIPCodeLookupHelper.getMessageSeverityFromCode(bean.statusNbr),'Code ' + bean.statusNbr, bean.statusDescription));
                } else {
                    con.Primary_Postal_Code__c.addError(con.StrikeIron_Status__c); 
                }
            }
        } catch (Exception e) {
            System.debug(e);
            ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, e.getMessage() + ' - ' + e.getStackTraceString(), ''));
        }
        
        return null;
    }

    public PageReference validateOtherZip (Contact con) {
        cityOtherOptions = new List <SelectOption> ();
        streetOtherOptions = new List <SelectOption> ();

        try {
            
            bean = service.lookupZIPCodeInfo (con.Other_Postal_Code__c);
            
            if (bean != null) {

                for (sf_StrikeIronZIPCodeLookupResponseBean.AliasInfo al: bean.aliases) {
                    cityOtherOptions.add (new SelectOption (al.aliasCityName, al.aliasCityName));
                }

                for (sf_StrikeIronZIPCodeLookupResponseBean.StreetInfo si: bean.streets) {
                    String s = si.StreetNumberLow + '-' + si.StreetNumberHigh;
                    streetOtherOptions.add (new SelectOption (s, s));
                }

               con.Other_State_Province__c = bean.stateOrProvinceCode;
               con.Other_Postal_Code__c = bean.formattedZIPOrPostalCode;
               con.Other_City__c = bean.city;
                if(sf_Constants.COUNTRY_UNITED_STATES.equalsIgnoreCase(bean.countryName)){
                    con.Other_Country__c = sf_Constants.COUNTRY_UNITED_STATES_AMERICA;

                }

                if (streetOtherOptions.size() > 0) { // only one city
                    
                    String otherAddressLine1 = bean.streets[0].StreetNumberLow + ' ' + bean.streets[0].StreetNumberHigh + ' ';
                    otherAddressLine1 += bean.streets[0].streetPreDirection + ' ';
                    otherAddressLine1 += bean.streets[0].streetName + ' ';
                    otherAddressLine1 += bean.streets[0].streetSuffix + ' ';
                    otherAddressLine1 += bean.streets[0].streetPostDirection + ' ';
                    otherAddressLine1 = otherAddressLine1.replaceAll('(\\s+)', ' '); //get rid of extra spaces

                    if(!String.isEmpty(otherAddressLine1.trim())){
                        con.Other_Address_Line_1__c = otherAddressLine1;
                    }
                        
                }

                con.StrikeIron_Status__c = 'Code ' + bean.statusNbr + ' - ' + bean.statusDescription;

                if (bean.statusNbr.contains('201') || bean.statusNbr.contains('202') || bean.statusNbr.contains('203')) {
                    ApexPages.addMessage (new ApexPages.Message (sf_StrikeIronZIPCodeLookupHelper.getMessageSeverityFromCode(bean.statusNbr),'Code ' + bean.statusNbr, bean.statusDescription));
                } else {
                    con.Other_Postal_Code__c.addError(con.StrikeIron_Status__c); 
                } 
            }
            
        } catch (Exception e) {
            System.debug(e);
            ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, e.getMessage() + ' - ' + e.getStackTraceString(), ''));
        }
        
        return null;
    }
    
    public Map<String, String> validationResultsAddressVerification(sf_StrikeIronValidateGblAddressRespBean addresseValidationBean){
        
        Map<String, String> mapAddressVerificationResults = new Map<String, String>();
        if(
            (sf_Constants.STRIKE_IRON_MESSAGE_MATCHED_WITH_ERROR.equalsIgnoreCase(addresseValidationBean.buildingNumberMessage)
            && !sf_Constants.STRIKE_IRON_MESSAGE_CHECKED_AND_CORRECTED.equalsIgnoreCase(addresseValidationBean.buildingNumberResult)
            && !sf_Constants.STRIKE_IRON_MESSAGE_VALIDATED_BUT_CHANGED.equalsIgnoreCase(addresseValidationBean.buildingNumberResult)
            && !sf_Constants.STRIKE_IRON_MESSAGE_VALIDATED_BUT_STANDARDIZED.equalsIgnoreCase(addresseValidationBean.buildingNumberResult)
            )
            || (sf_Constants.STRIKE_IRON_MESSAGE_MATCHED_WITH_ERROR.equalsIgnoreCase(addresseValidationBean.buildingMessage)
            && !sf_Constants.STRIKE_IRON_MESSAGE_CHECKED_AND_CORRECTED.equalsIgnoreCase(addresseValidationBean.buildingResult)
            && !sf_Constants.STRIKE_IRON_MESSAGE_VALIDATED_BUT_CHANGED.equalsIgnoreCase(addresseValidationBean.buildingResult)
            && !sf_Constants.STRIKE_IRON_MESSAGE_VALIDATED_BUT_STANDARDIZED.equalsIgnoreCase(addresseValidationBean.buildingResult)
            )
            || (sf_Constants.STRIKE_IRON_MESSAGE_MATCHED_WITH_ERROR.equalsIgnoreCase(addresseValidationBean.streetMessage)
            && !sf_Constants.STRIKE_IRON_MESSAGE_CHECKED_AND_CORRECTED.equalsIgnoreCase(addresseValidationBean.streetResult)
            && !sf_Constants.STRIKE_IRON_MESSAGE_VALIDATED_BUT_CHANGED.equalsIgnoreCase(addresseValidationBean.streetResult)
            && !sf_Constants.STRIKE_IRON_MESSAGE_VALIDATED_BUT_STANDARDIZED.equalsIgnoreCase(addresseValidationBean.streetResult)
            )
            || (sf_Constants.STRIKE_IRON_MESSAGE_MATCHED_WITH_ERROR.equalsIgnoreCase(addresseValidationBean.poBoxMessage)
            && !sf_Constants.STRIKE_IRON_MESSAGE_CHECKED_AND_CORRECTED.equalsIgnoreCase(addresseValidationBean.poBoxResult)
            && !sf_Constants.STRIKE_IRON_MESSAGE_VALIDATED_BUT_CHANGED.equalsIgnoreCase(addresseValidationBean.poBoxResult)
            && !sf_Constants.STRIKE_IRON_MESSAGE_VALIDATED_BUT_STANDARDIZED.equalsIgnoreCase(addresseValidationBean.poBoxResult)
            )
        )
            mapAddressVerificationResults.put('Address', 'false');
        else if(
                (sf_Constants.STRIKE_IRON_MESSAGE_MATCHED_WITHOUT_ERROR.equalsIgnoreCase(addresseValidationBean.buildingNumberMessage)
                || sf_Constants.STRIKE_IRON_MESSAGE_CHECKED_AND_CORRECTED.equalsIgnoreCase(addresseValidationBean.buildingNumberResult)
                || sf_Constants.STRIKE_IRON_MESSAGE_VALIDATED_BUT_CHANGED.equalsIgnoreCase(addresseValidationBean.buildingNumberResult)
                || sf_Constants.STRIKE_IRON_MESSAGE_VALIDATED_BUT_STANDARDIZED.equalsIgnoreCase(addresseValidationBean.buildingNumberResult)
                || String.isBlank(addresseValidationBean.buildingNumberMessage)
                )
            && (sf_Constants.STRIKE_IRON_MESSAGE_MATCHED_WITHOUT_ERROR.equalsIgnoreCase(addresseValidationBean.buildingMessage)
                || sf_Constants.STRIKE_IRON_MESSAGE_CHECKED_AND_CORRECTED.equalsIgnoreCase(addresseValidationBean.buildingResult)
                || sf_Constants.STRIKE_IRON_MESSAGE_VALIDATED_BUT_CHANGED.equalsIgnoreCase(addresseValidationBean.buildingResult)
                || sf_Constants.STRIKE_IRON_MESSAGE_VALIDATED_BUT_STANDARDIZED.equalsIgnoreCase(addresseValidationBean.buildingResult)
                || String.isBlank(addresseValidationBean.buildingMessage)
            )
            && (sf_Constants.STRIKE_IRON_MESSAGE_MATCHED_WITHOUT_ERROR.equalsIgnoreCase(addresseValidationBean.streetMessage)
                || sf_Constants.STRIKE_IRON_MESSAGE_CHECKED_AND_CORRECTED.equalsIgnoreCase(addresseValidationBean.streetResult)
                || sf_Constants.STRIKE_IRON_MESSAGE_VALIDATED_BUT_CHANGED.equalsIgnoreCase(addresseValidationBean.streetResult)
                || sf_Constants.STRIKE_IRON_MESSAGE_VALIDATED_BUT_STANDARDIZED.equalsIgnoreCase(addresseValidationBean.streetResult)
                || String.isBlank(addresseValidationBean.streetMessage)
            )
            && (sf_Constants.STRIKE_IRON_MESSAGE_MATCHED_WITHOUT_ERROR.equalsIgnoreCase(addresseValidationBean.poBoxMessage)
                || sf_Constants.STRIKE_IRON_MESSAGE_CHECKED_AND_CORRECTED.equalsIgnoreCase(addresseValidationBean.poBoxResult)
                || sf_Constants.STRIKE_IRON_MESSAGE_VALIDATED_BUT_CHANGED.equalsIgnoreCase(addresseValidationBean.poBoxResult)
                || sf_Constants.STRIKE_IRON_MESSAGE_VALIDATED_BUT_STANDARDIZED.equalsIgnoreCase(addresseValidationBean.poBoxResult)
                || String.isBlank(addresseValidationBean.poBoxMessage)
            )
        ){
            //If all not fields are empty, set address status = true
            if(
                String.isBlank(addresseValidationBean.buildingNumberMessage) 
                && String.isBlank(addresseValidationBean.buildingMessage)
                && String.isBlank(addresseValidationBean.streetMessage)
                && String.isBlank(addresseValidationBean.poBoxMessage)
            )
                mapAddressVerificationResults.put('Address', '');

            else{
                mapAddressVerificationResults.put('Address', 'true');
            }
                
        }

        else{
            mapAddressVerificationResults.put('Address', '');
        }

        if(sf_Constants.STRIKE_IRON_MESSAGE_MATCHED_WITH_ERROR.equalsIgnoreCase(addresseValidationBean.cityMessage)
            && !sf_Constants.STRIKE_IRON_MESSAGE_CHECKED_AND_CORRECTED.equalsIgnoreCase(addresseValidationBean.cityResult)
            && !sf_Constants.STRIKE_IRON_MESSAGE_VALIDATED_BUT_CHANGED.equalsIgnoreCase(addresseValidationBean.cityResult)
            && !sf_Constants.STRIKE_IRON_MESSAGE_VALIDATED_BUT_STANDARDIZED.equalsIgnoreCase(addresseValidationBean.cityResult)
        )
            mapAddressVerificationResults.put('City', 'false');
        else if(sf_Constants.STRIKE_IRON_MESSAGE_MATCHED_WITHOUT_ERROR.equalsIgnoreCase(addresseValidationBean.cityMessage)
            || sf_Constants.STRIKE_IRON_MESSAGE_CHECKED_AND_CORRECTED.equalsIgnoreCase(addresseValidationBean.cityResult)
            || sf_Constants.STRIKE_IRON_MESSAGE_VALIDATED_BUT_CHANGED.equalsIgnoreCase(addresseValidationBean.cityResult)
            || sf_Constants.STRIKE_IRON_MESSAGE_VALIDATED_BUT_STANDARDIZED.equalsIgnoreCase(addresseValidationBean.cityResult)
        )
            mapAddressVerificationResults.put('City', 'true');

        else{
            mapAddressVerificationResults.put('City', '');
        }
            
        if(sf_Constants.STRIKE_IRON_MESSAGE_MATCHED_WITH_ERROR.equalsIgnoreCase(addresseValidationBean.stateMessage)
            && !sf_Constants.STRIKE_IRON_MESSAGE_CHECKED_AND_CORRECTED.equalsIgnoreCase(addresseValidationBean.stateResult)
            && !sf_Constants.STRIKE_IRON_MESSAGE_VALIDATED_BUT_CHANGED.equalsIgnoreCase(addresseValidationBean.stateResult)
            && !sf_Constants.STRIKE_IRON_MESSAGE_VALIDATED_BUT_STANDARDIZED.equalsIgnoreCase(addresseValidationBean.stateResult)
        )
            mapAddressVerificationResults.put('State', 'false');
        else if(sf_Constants.STRIKE_IRON_MESSAGE_MATCHED_WITHOUT_ERROR.equalsIgnoreCase(addresseValidationBean.stateMessage)
            || sf_Constants.STRIKE_IRON_MESSAGE_CHECKED_AND_CORRECTED.equalsIgnoreCase(addresseValidationBean.stateResult)
            || sf_Constants.STRIKE_IRON_MESSAGE_VALIDATED_BUT_CHANGED.equalsIgnoreCase(addresseValidationBean.stateResult)
            || sf_Constants.STRIKE_IRON_MESSAGE_VALIDATED_BUT_STANDARDIZED.equalsIgnoreCase(addresseValidationBean.stateResult)
        )
            mapAddressVerificationResults.put('State', 'true');

        else{
            mapAddressVerificationResults.put('State', '');

        }
        if(sf_Constants.STRIKE_IRON_MESSAGE_MATCHED_WITH_ERROR.equalsIgnoreCase(addresseValidationBean.zipMessage)
            && !sf_Constants.STRIKE_IRON_MESSAGE_CHECKED_AND_CORRECTED.equalsIgnoreCase(addresseValidationBean.zipResult)
            && !sf_Constants.STRIKE_IRON_MESSAGE_VALIDATED_BUT_CHANGED.equalsIgnoreCase(addresseValidationBean.zipResult)
            && !sf_Constants.STRIKE_IRON_MESSAGE_VALIDATED_BUT_STANDARDIZED.equalsIgnoreCase(addresseValidationBean.zipResult)
        )
            mapAddressVerificationResults.put('Zip_Code', 'false');
        else if(sf_Constants.STRIKE_IRON_MESSAGE_MATCHED_WITHOUT_ERROR.equalsIgnoreCase(addresseValidationBean.zipMessage)
            || sf_Constants.STRIKE_IRON_MESSAGE_CHECKED_AND_CORRECTED.equalsIgnoreCase(addresseValidationBean.zipResult)
            || sf_Constants.STRIKE_IRON_MESSAGE_VALIDATED_BUT_CHANGED.equalsIgnoreCase(addresseValidationBean.zipResult)
            || sf_Constants.STRIKE_IRON_MESSAGE_VALIDATED_BUT_STANDARDIZED.equalsIgnoreCase(addresseValidationBean.zipResult)

        ){
            mapAddressVerificationResults.put('Zip_Code', 'true');

        }
        else{
            mapAddressVerificationResults.put('Zip_Code', '');
        }

        return mapAddressVerificationResults;
            
    }
    public class AddressWrapper {
        public String address1 = '';
        public String address2 = '';
        public String address3 = '';
        public String city = '';
        public String state = '';
        public String zip = '';
        public String country = '';

        public AddressWrapper (String address1, String address2, String address3, String city, String state, String zip, String country) {
            this.address1 = address1;
            this.address2 = address2;
            this.address3 = address3;
            this.city = city;
            this.state = state;
            this.zip = zip;
            this.country = country;
        }

        public AddressWrapper () {}
    }
    
 public List<dupcheck.dc3SearchResult> existingContactList {get; set;}
    public pageReference checkExistingContact() {
        
        cleanExistingContactList(); 
        dupcheck.dc3Api dcApi = new dupcheck.dc3Api(); 
    
        Map<String, List<dupcheck.dc3SearchResult>> searchResult = dcApi.doSearch(this.contactInfo); 

        if (searchResult == null || !searchResult.containsKey('003') || searchResult.get('003').isEmpty()) {
            this.existingContactList = new List<dupcheck.dc3SearchResult>();
            return null;
        }
        
        Set<Id> foundContacts = new Set<Id>();
        for (dupcheck.dc3SearchResult resultItem : searchResult.get('003')) {
            foundContacts.add(resultItem.objectData.Id);
        }
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, AccountId, Reporter_Type__c, LastName, FirstName, Name, Email, Phone, Primary_City__c, Primary_State_Province__c, Primary_Country__c, Primary_Postal_Code__c, Primary_Address_Line_1__c, Primary_Address_Line_2__c, Primary_Address_Line_3__c FROM Contact WHERE Id IN :foundContacts ]);
        for (dupcheck.dc3SearchResult resultItem : searchResult.get('003')) {
            resultItem.objectData = contactMap.get(resultItem.objectData.Id);
        }
        this.existingContactList = searchResult.get('003');
        
        return null;
    }
    
    private void cleanExistingContactList() {
        this.existingContactList = null;
    }
    
    public Id selectedExistingContact {get; set;}
    
    public pageReference selectExistingContact() {
        if (String.isBlank(this.selectedExistingContact)) {
            ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, 'Error', 'No existing contact selected.'));
            return null;
        }
        
        try {

            Case tempCase = [SELECT Id, ContactId FROM Case WHERE Id = :currentCase.Id];
            system.debug('!!! ContactInfo.ctr in selectExistingContact selectedRecordTypeId: '+selectedRecordTypeId);
            system.debug('!!! ContactInfo.ctr in selectExistingContact currentCase.ContactId: '+currentCase.ContactId);
            system.debug('!!! ContactInfo.ctr pre selectExistingContact: '+selectedExistingContact);
            system.debug('!!! ContactInfo.ctr pre tempCase: '+tempCase);
            
            // Attach the selected contact to the current case

            currentCase.ContactId = this.selectedExistingContact;//Always want to do this

            if(String.isBlank(tempCase.ContactId)){
                system.debug('+++ ContactInfo.ctr in selectExistingContact adding first Contact: '+selectedExistingContact);
                update currentCase;
                checkContactType();
                // reload contact info information
                setContactInfoObject(false);//CR47 Adding first Contact
                setContactOptions();
                setReturnOptions();
                this.cleanExistingContactList();
                isEmailAddressValid = '';
            }
            else{
                system.debug('--- ContactInfo.ctr in selectExistingContact adding second Contact: '+selectedExistingContact);
                setContactInfoObject(true);//CR47 False - Adding second Contact
                this.cleanExistingContactList();
            }
        } catch (Exception e) {            //WR082 Contact/Account Inactive User - Chris Doyle (christopher.j.doyle@accenture.com) START
            System.enqueueJob(new exceptionHelperQueable(e,'ContactInfo - error on selectExistingContact Case: '+String.valueOf(currentCase)));
            errorMessage = e.getMessage(); 
            
            if (errorMessage.contains('CANNOT_REPARENT_RECORD')) {
                ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, 'Error', label.AgentConsole_Cannot_Reparent_Record));
            }
            else { 
                ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, 'Error', errorMessage));
            } 
        }
        return null;
    } 
    
    public class contactInfoException extends Exception {}
}