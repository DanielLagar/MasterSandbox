/**
* @author: Ian Barker
* @date: 11/10/2015
*Trigger helper Safety Assessment Survey trigger
*/

public with sharing class SafetyAssessmentSurveyHelper {

    /**
    * @author: Ian Barker
    * @date: 11/11/2015
    * Updates Case.Medical_QR_Status__r to SAS equivalent field if not already progressed to that point.
    **/
    public static void UpdateCaseToMatchSAS(Map<Id, Safety_Assessment_Survey__c> newSASMap){
        system.debug('@@@UpdateCaseToMatchSAS');
        List <Id> CasesToCall = new List <Id>();
        List <Safety_Assessment_Survey__c> SASToCompare = new List <Safety_Assessment_Survey__c>();
        List <Case> CasesToUpdate = new List <Case>();

        //iterates through given 
        for(Safety_Assessment_Survey__c s: newSASMap.values()){
            //issue: can't call case__r in a trigger, need to query
            if(s.Medical_QR_Status__c != NULL){
                CasesToCall.add(s.Case__c);
                SASToCompare.add(s);
            }
        }
        List <Case> CasesToCheck = [SELECT Id, Medical_QR_Status__c FROM Case WHERE Id in :CasesToCall];
        for(Safety_Assessment_Survey__c sas: SASToCompare){
            for(Case c: CasesToCheck){
                if(sas.Case__c == c.Id){
                    if(CaseMedStatNeedsUpdate(sas.Medical_QR_Status__c, c.Medical_QR_Status__c)){
                        c.Medical_QR_Status__c = sas.Medical_QR_Status__c;
                        CasesToUpdate.add(c);
                    } else {
                        continue;
                    }
                } else {
                    continue;
                }
            }
        }

        update CasesToUpdate;
    }

    /**
    * @author: Ian Barker
    * @date: 11/11/2015
    * Checks hierarchy of Medical QR Status values
    * Seperate helper method due to hierarchy is subject to changes
    * Returns TRUE when Medical QR Status is out of date, FALSE when up to date
    **/

    /**
    * Lowest to highest priority:
    *1. Questionnaire Requested - Attempt 1
    *2. Questionnaire Requested - Attempt 2
    *3. Questionnaire Requested - Attempt 3
    *4. Unwilling to Complete
    *5. Sent by consumer but not received
    *6. Unable to Re-contact Consumer
    *7. Questionnaire Received
    **/

    private static Boolean CaseMedStatNeedsUpdate(String SASField, String CaseField){
        Boolean answer = FALSE;
        Map<String, Integer> StatusOrder = new Map<String, Integer>();
        StatusOrder.put('', 0);
        StatusOrder.put('Questionnaire Requested - Attempt 1', 1);
        StatusOrder.put('Questionnaire Requested - Attempt 2', 2);
        StatusOrder.put('Questionnaire Requested - Attempt 3', 3);
        StatusOrder.put('Unwilling to Complete', 4);
        StatusOrder.put('Sent by consumer but not received', 5);
        StatusOrder.put('Unable to Re-contact Consumer', 6);
        StatusOrder.put('Questionnaire Received', 7);


        if(SASField == NULL){
            answer = FALSE;
        } else if (CaseField == NULL){
            answer = TRUE;
        } else if (StatusOrder.get(SASField) > StatusOrder.get(CaseField)){
            answer = TRUE;
        } else {
            answer = FALSE;
        }
        return answer;
    }
}