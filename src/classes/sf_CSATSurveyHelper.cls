/**
* @author: salesforce.com, inc.
* @date: 02/05/2015
*
* @description: helper class for CSAT survey trigger
* 
*/

public without sharing class sf_CSATSurveyHelper {

    /**
    * @description Creates a unique ID which will be used in the URL to direct the user to the appropriate CSAT record.
    */
    public static void updateCSATId (List<CSAT_Survey__c> triggerNew) {
        for (CSAT_Survey__c csat : triggerNew) {
            String stringToHash = String.valueOf(csat.Case__c) + String.valueOf(csat.Contact__c);
            Blob b = Crypto.generateDigest('SHA-256', Blob.valueOf(stringToHash));
            csat.Survey_Id__c = EncodingUtil.convertToHex(b);

            csat.Brand_Page_Parameters__c = '&brand='+ EncodingUtil.urlEncode(csat.Case_Brand__c == null ? 'P&G' : csat.Case_Brand__c, 'UTF-8');//CDOY WR403 B

            csat.Page_Parameters__c = '?surveyid='+ csat.Survey_Id__c; 
            //CDOY WR403 csat.Page_Parameters__c += '&brand='+ EncodingUtil.urlEncode(csat.Case_Brand__c == null ? 'P&G' : csat.Case_Brand__c, 'UTF-8');
            csat.Page_Parameters__c += '&country='+ EncodingUtil.urlEncode(csat.Case_Country__c, 'UTF-8');
            csat.Page_Parameters__c += '&language='+ EncodingUtil.urlEncode(csat.Case_Language__c, 'UTF-8');
            csat.Page_Parameters__c += '&lang='+ EncodingUtil.urlEncode(csat.Case_Language_Code__c, 'UTF-8');
        }
    }

    /**
    * @description Creates a CSAT Survey record when a Case is closed.
    */
    public static void createCSATForClosedCases (List<Case> closedCases) {
        List <CSAT_Survey__c> csatToInsert = new List <CSAT_Survey__c> ();
        
        for (Case c: closedCases) {
            
            boolean createCSATforAll = false;
            //WR316 and updated for WR347 by ChrisM
            //Updated by ChrisD to include Hong Kong and Taiwan
            if(c.country__c == 'China' || c.country__c == 'Japan' || c.country__c == 'Korea' || c.country__c == 'Australia'
               || c.country__c == 'Indonesia' || c.country__c == 'Philippines' || c.Country__c == 'India' 
               || c.Country__c == 'Hong Kong' || c.Country__c == 'Taiwan' ){
            
                 createCSATforAll = True;
            }
                   
            if ((true == createCSATforAll
            || c.Contact_Email__c != null)
            && !c.Do_not_send_survey__c
            && c.Not_Handled_Reason__c == null
            && c.Repeater_Case__c == null){
 
                
                CSAT_Survey__c csat = new CSAT_Survey__c ();
                csat.Case__c = c.Id;
                csat.Contact__c = c.ContactId;

                csatToInsert.add(csat);
            }
        }

        Database.insert (csatToInsert, false); //some will fail if csat already exists
    }
    
    /**
    * @description Updates the Case's version of the CSAT fields when status = 'Submitted' for reporting purposes
    */
    public static void updateCaseCSATFields(Map<Id,CSAT_Survey__c> csatsOldMap, List<CSAT_Survey__c> csatsNew) {
        List<CSAT_Survey__c> csats = new List<CSAT_Survey__c> ();
        List<Id> caseIds = new List<Id>();
        Map<Id,Case> caseMap = new Map<Id,Case>();
        List<Case> cases = new List<Case>();
        
        for(CSAT_Survey__c csat : csatsNew) {
            if(csatsOldMap.get(csat.Id).Status__c != 'Submitted' && csat.Status__c == 'Submitted') {
                caseIds.add(csat.Case__c);
            }

        }
        if(caseIds.size() > 0) { 
            for (Case cs : [SELECT Id, CX_Friendly_Welcoming_Score_Q1__c, CX_UnderstandsNeeds_Score_Q2__c, CX_MetNeeds_Score_Q3__c, CX_EasySimple_Score_Q4__c, CX_FeelValued_Score_Q5__c,
                             CX_Service_Comments_Q6__c, CX_Trust_Score_Q7__c, CX_Repurchase_Score_Q8__c, CX_Net_Promoter_Score_Q9__c, CX_Advocacy_Comments_Q10__c,
                             CX_Agent_Score_Q1_2__c, CX_Overall_Score_Q1_5__c, CX_Last_Modified_Date__c, CX_Created_By_Name__c, CX_Created_By_Location__c
                             FROM Case
                             WHERE Id in :caseIds]) {
                caseMap.put(cs.Id, cs);
            }
                        
            for(CSAT_Survey__c csat : csatsNew) {
                system.debug('@@@csat.LastModifiedDate: ' + csat.LastModifiedDate);
                system.debug('@@@csat.Created_By_Name__c: ' + csat.Created_By_Name__c);
            
                Case csatCase = caseMap.get(csat.Case__c);
                csatCase.CX_Friendly_Welcoming_Score_Q1__c = csat.CX_Friendly_Welcoming_Score_Q1__c;
                csatCase.CX_UnderstandsNeeds_Score_Q2__c = csat.CX_UnderstandsNeeds_Score_Q2__c;
                csatCase.CX_MetNeeds_Score_Q3__c = csat.CX_MetNeeds_Score_Q3__c;
                csatCase.CX_EasySimple_Score_Q4__c = csat.CX_EasySimple_Score_Q4__c;
                csatCase.CX_FeelValued_Score_Q5__c = csat.CX_FeelValued_Score_Q5__c;
                csatCase.CX_Service_Comments_Q6__c = csat.Q_ConsumerCareTeamFeedback__c;
                csatCase.CX_Trust_Score_Q7__c = csat.CX_Trust_Score_Q7__c;
                csatCase.CX_Repurchase_Score_Q8__c = csat.CX_Repurchase_Score_Q8__c;
                csatCase.CX_Net_Promoter_Score_Q9__c = csat.CX_Net_Promoter_Score_Q9__c;
                csatCase.CX_Advocacy_Comments_Q10__c = csat.Q_ExplainReasonForScore__c;
                csatCase.CX_Agent_Score_Q1_2__c = csat.CX_Agent_Score_Q1_2__c;
                csatCase.CX_Overall_Score_Q1_5__c = csat.CX_Overall_Score_Q1_5__c;
                csatCase.CX_Last_Modified_Date__c = csat.LastModifiedDate;
                csatCase.CX_Created_By_Name__c = csat.Created_By_Name__c;
                csatCase.CX_Created_By_Location__c = csat.Created_By_Location__c;
                cases.add(csatCase);
            }

            if(cases.size() > 0) {
                update cases;
            }
        }
    }
    
}