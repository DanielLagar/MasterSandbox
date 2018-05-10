/**
* @author: salesforce.com, inc.
* @date: 02/01/2015
*
* @description: page extension for CSAT survey
* 
*/


public without sharing class sf_CSATSurveyExt {

    
    public CSAT_Survey__c csat {get; set;}
    public Task inboundTask {get;set;}//WR212 holds recontact information
    public String taskDescription {get;set;}//WR212 holds task description
    public Boolean showThankYou {get; set;}
    public Boolean hasErrors {
        get {
            return ApexPages.hasMessages(ApexPages.Severity.ERROR);
        }
        private set;
    }
    public String replyReceived {get; set;} //WR212 Stores value for use in rerenders
    public String needMoreHelp {get;set;}//WR212 Need any more help?
    //WR212 Gets last response by GCR
    public String lastResponse { 
        get{
            if(lastResponse == null){
                //Get textBody of last outbound email
                try{
                    lastResponse = [SELECT textBody FROM EmailMessage WHERE Incoming = False AND ParentId = :csat.Case__c ORDER BY CreatedDate DESC LIMIT 1].textBody;
                }
                catch(queryException qe){
                    lastResponse = 'Sorry something went wrong, no message was found';
                }
                
            }
            
            return lastResponse;
        }
        set;
    } 

    public sf_ContactUsTemplateController mainCtrl;

    /** language helper */
    public sf_ContactUsLanguageController langCon {get; set;}

    /** page variables */
    public String brand { get; set; }
    public String language { get; set; }
    public String template_country { get; set; }

    public sf_CSATSurveyExt (sf_ContactUsTemplateController mainCtrl) {
        try {
            langCon = sf_ContactUsLanguageController.instance;
            this.mainCtrl = mainCtrl;
            language = sf_ContactUsHelperCtrl.getLanguage();
            template_country = sf_ContactUsHelperCtrl.getCountry();
            brand = sf_ContactUsHelperCtrl.getBrand();
            system.debug(logginglevel.WARN,'***** language  '+language+ ' template_country '+ template_country + ' brand ' + brand + ' surveryId '+ ApexPages.currentPage().getParameters().get('surveyid'));
            csat = getSurveyRecordBySurveyId (ApexPages.currentPage().getParameters().get('surveyid'));
            //CDOY WR404 Fix            
            if(csat.Case_Origin__c == 'Email'){
                replyReceived = '';
            } else {
                replyReceived = 'Yes';
            }
            taskDescription = '';//WR212
        } catch (System.QueryException qe) {
            ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, langCon.language_config.CSAT_Survey_Not_Found_Message__c));
            System.debug(qe);
        
        } catch (Exception e) {
            ApexPages.addMessages(e);
            System.debug(e);
        }
    }

    public CSAT_Survey__c getSurveyRecordBySurveyId (String surveyId) {
        String sObjectApiName = 'CSAT_Survey__c';
        String queryString = 'SELECT ';
        for(Schema.SObjectField s : Schema.getGlobalDescribe().get(sObjectApiName).getDescribe().fields.getMap().values()) {
           String fieldName = s.getDescribe().getName();
        
           // Continue building your dynamic query string
           queryString += fieldName + ',';
        }
 
        // Trim last comma
        queryString = queryString.removeEnd(',');
 
        // Finalize query string
        queryString += ' FROM ' + sObjectApiName;
        queryString += ' WHERE Survey_Id__c = \'' + String.escapeSingleQuotes(surveyId) + '\' AND Status__c = \'Created\' LIMIT 1';

        return Database.query(queryString);
    }

    //WR212 CMD Start
    public List <SelectOption> ReplyOptions{
        get{
            if (ReplyOptions == null){
                ReplyOptions = new List<SelectOption>();
                //Below all pulled from language object - value in English for VF rerenders not stored on any record
                ReplyOptions.add(new SelectOption('',langCon.language_config.Brand_Please_Select__c));
                ReplyOptions.add(new SelectOption('Yes',langCon.language_config.Helpful_Yes__c));
                ReplyOptions.add(new SelectOption('No',langCon.language_config.Helpful_No__c));

            }
                return ReplyOptions;
            }
            set;
    }

    public PageReference saveTask() {
        inboundTask = new Task();
        inboundTask.Description = taskDescription;
        inboundTask.WhoId = csat.Contact__c;
        inboundTask.WhatId = csat.Case__c;
        inboundTask.ActivityDate = Date.today()+5;
        inboundTask.Direction__c = 'Inbound';
        inboundTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(sf_Constants.TASK_CUSTOMER_ACTIVITY_RECORDTYPENAME).getRecordTypeId();
        inboundTask.Contact_Method__c = 'Other';
        inboundTask.Follow_Up_Category__c = '';
        inboundTask.Subject = Label.CX_Recontact_Task_Subject;
        //inboundTask.OwnerId =  //TODO: How to set..
        try{
            insert inboundTask;    
        }
        catch(dmlexception e){
            ApexPages.addMessages(e);
            system.debug('>>> exception on task creation: '+e);
        }
        //Update Case
        try{
            Case caseToOpen = [SELECT Id FROM Case WHERE Id = :csat.Case__c LIMIT 1]; 
            caseToOpen.Status = 'Reopened by Consumer';
            caseToOpen.Reassign_Case__c = True;
            caseToOpen.CX_Did_not_receive_response__c = True;
            update caseToOpen;
        }
        catch(queryException qe){
            ApexPages.addMessages(qe);
            system.debug('>>> exception on case query: '+qe);              
        }
        catch(dmlexception de){
            ApexPages.addMessages(de);
            system.debug('>>> exception on case update: '+de);           
        }
        //Now delete CSAT so that the link will no longer work and so 
        //that it will be regenerated and sent next time the Case is closed
        try{
            delete csat;
        }
        catch(dmlexception de){
            ApexPages.addMessages(de);
            system.debug('>>> exception on CSAT delete: '+de);              
        }

        showThankYou = true;
        return null;
    }
    //WR212 CMD Fin
    
    public List <SelectOption> getRadioButtonOptions () {
        List <SelectOption> radioButtons = new List <SelectOption> ();

        for (Integer i=10; i<=50; i+=10) {
            radioButtons.add(new SelectOption (String.valueOf(i), ''));
        }

        return radioButtons;
    }

    public List <SelectOption> getRadioButtonTenOptions () {
        List <SelectOption> radioButtons = new List <SelectOption> ();

        for (Integer i=0; i<=10; i++) {
            radioButtons.add(new SelectOption (String.valueOf(i), String.valueOf(i)));
        }

        return radioButtons;
    }

    public List<selectoption> getBrandYouCanTrustOptions() {           
        List <SelectOption> options = new List <SelectOption>();                     
          
            Schema.DescribeFieldResult fieldResult = CSAT_Survey__c.Q_IsThisBrandYouCanTrust__c.getDescribe();

            List <Schema.Picklistentry> values = fieldResult.getPickListValues();               
            for (Schema.PicklistEntry a : values) {                  
                options.add(new SelectOption(a.getValue(), a.getLabel()));
            }           
          
        return options; 
    }

    public List<selectoption> getBrandYouWillBuyOptions() {           
        List <SelectOption> options = new List <SelectOption>();            
            
            Schema.DescribeFieldResult fieldResult = CSAT_Survey__c.Q_LikelyToBuyBrand__c.getDescribe();

            List <Schema.Picklistentry> values = fieldResult.getPickListValues();               
            for (Schema.PicklistEntry a : values) {                  
                options.add(new SelectOption(a.getValue(), a.getLabel()));
            }           
        
        return options; 
    }

    public PageReference saveSurvey () {

        Csat_Survey__c csatStatusCheck = [SELECT status__c FROM CSAT_Survey__c WHERE id  =:csat.id];

        system.debug(LoggingLevel.WARN,'***CDOY csatStatusCheck.Status__c : '+csatStatusCheck.Status__c);

        if(csatStatusCheck.Status__c == 'Created'){     
            csat.Status__c = 'Submitted';
            system.debug(LoggingLevel.WARN,'***CDOY About to Update CSAT csat');
            update csat;
            showThankYou = true;
            system.debug(LoggingLevel.WARN,'***CDOY showThankYou = '+showThankYou);
            
        }
        else {
            ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, langCon.language_config.CSAT_Survey_Not_Found_Message__c));
        }
        return null;
    }
}