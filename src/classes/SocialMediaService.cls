/**
* @author: Archana Sethuraman
* @date: 08/12/2014
* @description:  Class to create a case from Sprinkler
*                 Class migrated from Temp org
*/

global class SocialMediaService {
 
    public class GeneralException extends Exception{}
   
    global class CaseAccountFields {
        webservice String SNConsumerID;
        webservice String SNUniqueID;
        webservice String SNMessageID;
        webservice String SNTYPE;      
        webservice String lastname;
        webservice String firstname;      
        webservice String contactWebsite;
        webservice String summary;
        webservice Date receivedDate;
        webservice String language;
        webservice Id SFCaseID;
        webservice Id SFAccountID;
        webservice Id SFContactID;
    }
   
    global class ActivityFields {
        webservice Id SFCaseID;
        webservice Id SFActivityID;
        webservice String SNMessageID;
        webservice String description;
        webservice Boolean isConsumerComment;
        webservice Date receivedDate;
    }
   
    webservice static ActivityFields createActivityMethod(ActivityFields vAF) {
      
        Id contactId;
        sf_SocialMediaUtility smUtil = new sf_SocialMediaUtility();
        
        try {
            //Valdate input
            validateInput(vAF);
       
            //retrieve contact from the case
            List<Case> caseobjs = [SELECT ContactId FROM Case WHERE  Id=:vAF.sfCaseId];
            contactId = !caseobjs.isEmpty() ? caseobjs[0].ContactId : null;
            
       
            String actRecType = vAF.isConsumerComment ? sf_GlobalUtilityClass.TASK_CONSUMER_ACTIVITY_RT_ID : sf_GlobalUtilityClass.TASK_INTERNAL_ACTIVITY_RT_ID;
            
            
            vAF.sfActivityId = smUtil.createTask(vAF.description, 
                                                    sf_Constants.DEFAULT_SOCIAL_MEDIA_TASK_SUBJECT, 
                                                    sf_Constants.ORIGIN_SOCIAL_MEDIA, 
                                                    sf_Constants.STATUS_COMPLETED, 
                                                    sf_Constants.PRIORITY_LOW, vAF.SFCaseID, 
                                                    actRecType, contactId, null);
           
            return vAF;
        
        } catch (Exception ex){
            
            String exstring='EXCEPTION: '+ex.getMessage()+'\n\nSTACK TRACE: '+ex.getStackTraceString()+'\n\nNUMBER: '+ex.getLineNumber();
            smUtil.handleException(exstring, 
                                    '[Social Media]: Exception in web service method: createActivityMethod, Web service: SocialMediaService', 
                                    'Request Parameters: '+vAF, true);
            throw ex;
        }      
    }

    webservice static CaseAccountFields createCaseServiceMethod(CaseAccountFields vCA) {
        CaseUtility util = new CaseUtility();
        sf_SocialMediaUtility smUtil = new sf_SocialMediaUtility();
        Id tskId;

        System.debug(LoggingLevel.INFO, '====== createCaseServiceMethod vCA ======== \n' + vCA);

        try{
            //Validate the input
            validateInput(vCA);
           
            //pull social media settings
            SocialMediaSettingsWrapper smobj = new SocialMediaSettingsWrapper(vCA.snType, vCA.snUniqueID, vCA.language);

            //Handling Case
            CaseWrapper caseWrap = new CaseWrapper(vCA, smobj);
            caseWrap.createCase();
           
            //Commented this code. Becuase we are not creating Account/Contact
            //create case account
            /**if(vCA.SFAccountID != null)                         
             util.createCaseAccount(caseWrap.accountObj.accountId, caseWrap.accountObj.contactId, caseWrap.caseId, caseWrap.summary,true); */
           
            //create a task
            //'012700000001Dsw' = 'Consumer Activity'
            //caseWrap.accountObj.contactId
            tskId = smUtil.createTask(caseWrap.summary, 'Initial Case Creation', caseWrap.origin, sf_Constants.STATUS_COMPLETED, sf_constants.PRIORITY_LOW, 
            caseWrap.caseId, sf_GlobalUtilityClass.TASK_CONSUMER_ACTIVITY_RT_ID, null, null, vCA.receivedDate);
            System.debug(LoggingLevel.INFO, '##### Case has been created. #### \n' + caseWrap);
            return vCA;

        } catch(Exception ex){
            string exstring='EXCEPTION: '+ex.getMessage()+'\n\nSTACK TRACE: '+ex.getStackTraceString()+'\n\nNUMBER: '+ex.getLineNumber();
            smUtil.handleException(exstring, '[Social Media]: Exception in web service method: createCaseServiceMethod, Web service: SocialMediaService', 
            'Request Parameters: '+vCA, true);
            throw ex;
        }
    }
  
    public static void validateInput(CaseAccountFields caseAccFields){      

        sf_SocialMediaUtility smUtil = new sf_SocialMediaUtility();
        String errorMessage='One or more mandatory fields are missing. List of mandatory fields: SNConsumerID,'+
          'SNUniqueID, SNMessageID, SNTYPE, lastname, firstname, contactWebsite, receivedDate, language, summary';
        
        if (String.isBlank(caseAccFields.snConsumerID)
                || String.isBlank(caseAccFields.snUniqueID)
                || String.isBlank(caseAccFields.snMessageID)
                || String.isBlank(caseAccFields.snType)
                || String.isBlank(caseAccFields.lastname)
                || String.isBlank(caseAccFields.firstname)
                || String.isBlank(caseAccFields.contactWebsite)
                || String.isBlank(caseAccFields.summary)
                || caseAccFields.receivedDate==null
                || String.isBlank(caseAccFields.language)) {
          
            smUtil.handleException (errorMessage, '[Social Media]: Mandatory fields are missing', 
                                                    '\n\nReason: Sprinklr failed to send mandatory fields.' 
                                                    +' \n\nSolution: No action from SFDC side. Sprinklr should pass all mandatory fields. \n\nRequest parameters: ' 
                                                    + caseAccFields, true);
        }
    }

    public static void validateInput(ActivityFields activityFields){
        sf_SocialMediaUtility smUtil = new sf_SocialMediaUtility();
        String errorMessage='One or more mandatory fields are missing. List of mandatory fields: SFCaseID, '+
          'SNMessageID, description, isConsumerComment, receivedDate';

        if (String.isBlank(activityFields.sfCaseId)
                || String.isBlank(activityFields.description)
                || activityFields.isConsumerComment==null
                || activityFields.receivedDate==null){

            smUtil.handleException(errorMessage, '[Social Media]: Mandatory fields are missing', 
                                            '\n\nReason: Sprinklr failed to send mandatory fields.\n\nSolution: No action from SFDC side.' 
                                            + ' Sprinklr should pass all mandatory fields.\n\nRequest parameters: '+activityFields, true);
        }
    }
  
    public class CaseWrapper {
        public Id caseId { get; set; }
        public String brand { get {return smSettings.brand;}}    
        public String segment { get {return smSettings.segment;}}
        public String country { get {return smSettings.country;}}
        public String language { get {return smSettings.language;}}
        public String queueId { get {return smSettings.queueId;}}
        public String priority { get{return String.isNotBlank(priority) ? priority : sf_constants.DEFAULT_SOCIAL_MEDIA_PRIORITY;} set; }
        public String rectypeId { get {return smSettings.caseRecTypeId;}}
        public String mdo { get {return smSettings.mdo;}}
        public String origin { get {return sf_Constants.ORIGIN_SOCIAL_MEDIA;}}
        public String region { get {return smSettings.region;}}
        public String contactWebsite { get{return cseaccfields != null ? cseaccfields.contactWebsite : '';}}
        public Date receivedDate { get{ return cseaccfields != null ? cseaccfields.receivedDate : null;}}
        public String subject { get{ return String.isNotBlank(summary) && summary.length()>255 ? summary.subString(0,254) : summary;}}
        public String status {get{ return (String.isNotBlank(status)) ? status : sf_Constants.STATUS_OPEN;} set;}
        public SocialMediaSettingsWrapper smSettings { get; set; }
        public CaseAccountFields cseaccfields { get; set; }

        public String summary { 
            get{
                if(cseaccfields != null) {
                    if(String.isNotBlank(cseaccfields.summary) && cseaccfields.summary.length()>4000)  
                        return summary.subString(0,3999);
                    else return cseaccfields.summary;
                }
                else return '';
            }
        }
        

        //CaseWrapper constructor
        public CaseWrapper (CaseAccountFields caseAccFields, SocialMediaSettingsWrapper smobj){
            smSettings = smobj;
            cseaccfields = caseAccFields;
        }
    
        public void createCase(){
            
            CaseUtility caseUtil = new CaseUtility();
            Case newCase = new Case();
            newCase.Priority = priority;
            newCase.OwnerId = queueId;
            newCase.RecordTypeId = rectypeId;
            newCase.Country__c = country;
            newCase.Language__c = language;
            newCase.MDO__c = mdo;
            newCase.Origin = origin;
            newCase.Region__c = region;
            newCase.Contact_Website__c = contactwebsite;
            newCase.Brand__c = brand;
            newCase.Segment__c = segment;
          
            if (!String.isEmpty(summary)) {
                newCase.Summary__c = summary;
          
                if (newCase.Summary__c.length()>255)
                    newCase.Subject = newCase.Summary__c.substring (0, 249);
            }
                    
            newCase = caseUtil.insertNewCase(newCase);
            System.debug(LoggingLevel.INFO, '############## newCase: '+newCase);
            caseId = newCase.Id;
            cseaccfields.sfCaseId = newCase.Id;
        }
    }
  
    public class SocialMediaSettingsWrapper {
    
        public Id queueId { 
            get {
                if(queueRecTypeSettings != null) return queueRecTypeSettings.name;
                else return '';
            }
        }
        
        public Id caseRecTypeId { 
            get {
                if(queueRecTypeSettings != null) return queueRecTypeSettings.Case_Record_Type_Id__c;
                else return '';
            }
        }

        public string country { 
             get {
                if (smSettings != null && string.isNotBlank(smSettings.Country__c)) 
                   return smSettings.Country__c;
                else 
                   return sf_Constants.STRING_UNKNOWN;
            }
        }
        
        public string language { 
            get {
                if (smSettings != null && string.isNotBlank(smSettings.Language__c)) 
                   return smSettings.Language__c;
                else 
                  return sf_Constants.STRING_UNKNOWN;
            }
        } 
        
        public string languageCode { 
            get {
                return smSettings.Language_Code__c;
            }
        }
        
        public string region { 
            get {
                if(queueRecTypeSettings != null) return queueRecTypeSettings.Region__c;
                else return '';
            }
        }
        
        public string mdo { 
            get {
                if(queueRecTypeSettings != null) return queueRecTypeSettings.MDO__c;
                else return '';
            }
        }
        
        public string snType { 
            get {
                if(smSettings != null) return smSettings.SN_Type__c;
                else return '';
            }
        }

        public string snUniqueId { 
            get {
                if(smSettings != null) return smSettings.SN_Unique_Id__c;
                else return '';
            }
        }

        public string brand { 
            get {
                if ( smSettings != null && string.isNotBlank(smSettings.Brand__c)) 
                   return smSettings.Brand__c;
                else 
                   return sf_Constants.STRING_UNKNOWN;
            }
        }
        public string segment { 
            get {
                return sf_Constants.STRING_UNKNOWN;
            }
        }

        public SocialMediaSettings__c smSettings { get; set; }
        public QueueRecordType__c queueRecTypeSettings { get; set; }
        
        public SocialMediaSettingsWrapper(String snType, String snUniqueId, String languageCode){
            System.debug(LoggingLevel.INFO, 'SocialMediaSettingsWrapper trying to find SocialMediaSettings__c for  snType: ' + snType + ' , snUniqueId: ' + snUniqueId + ', languageCode: ' + languageCode );
            
            sf_SocialMediaUtility smUtil = new sf_SocialMediaUtility();
            
            for(SocialMediaSettings__c sm : SocialMediaSettings__c.getall().values()){
                
                if(sm.SN_Type__c == null || sm.SN_Unique_Id__c == null || sm.language_code__c == null) continue;
                
                if(sm.SN_Type__c.toLowerCase() == snType.toLowerCase() && 
                    sm.SN_Unique_Id__c.toLowerCase() == snUniqueId.toLowerCase() && 
                    sm.language_code__c.toLowerCase() == languageCode.toLowerCase()){
                    smSettings = sm;
                    break;
                }//end if

            }//end for

            System.debug('########### first attempt to match SocialMediaSettings__c  smSettings =  '+smSettings);   
            
            if (smSettings == null) {
                //When metadata is not found for given sntype, snuniqueid and language, then use criteria below
                //sntype, snuniqueid and language=ALL.
                for (SocialMediaSettings__c sm : SocialMediaSettings__c.getall().values()) {
                    if (sm.SN_Type__c == null || sm.SN_Unique_Id__c == null || sm.language_code__c == null) 
                        continue;
                    if (sm.SN_Type__c.toLowerCase() == snType.toLowerCase() && 
                        sm.SN_Unique_Id__c.toLowerCase() == snUniqueId.toLowerCase() && 
                        sm.language_code__c.toLowerCase() == 'all'){
                        smSettings = sm;
                        break;
                    }//end if
                }//end for
            }

            System.debug('########### second attempt to match SocialMediaSettings__c with language = ALL.  smSettings =  '+smSettings);   



            //Handle the situation when metadata is not defined for a SN Unique Id
            if (smSettings == null) {
                
              
                smSettings = [SELECT Id, Name FROM SocialMediaSettings__c WHERE Queue_Name__c = 'Default Queue' AND Name LIKE 'Default Queue%' LIMIT 1];
                smSettings = SocialMediaSettings__c.getValues(smSettings.Name);

                smUtil.handleException('Social Media settings are not defined. Please contact your SFDC Admin.', '[Social Media]: Metadata fields are missing', 
                        'SN Type: '+snType+', SN Unique ID: '+snUniqueId+', Language Code: '+languageCode, false);

                System.debug('########### Grabbing Default settings smSettings =  '+smSettings);   

            } 
          
            queueRecTypeSettings = QueueRecordType__c.getValues(smSettings.queue_Id__c);
            
            if (queueRecTypeSettings == null){
                //throw an error as the values are not defined.
                //throw new generalException('Record types are not defined. Please contact your SFDC Admin.');

                queueRecTypeSettings = [SELECT Id, Name FROM QueueRecordType__c WHERE Queue_Name__c = 'Default Queue' LIMIT 1];
                queueRecTypeSettings = QueueRecordType__c.getValues(queueRecTypeSettings.Name);
            }

            System.debug('########### queueRecTypeSettings: '+queueRecTypeSettings); 
        } //end constructor
    } //end SocialMediaSettingsWrapper
}