/**

Test class for SafetyAssessmentSurveyHelper.cls
@author     Ian Barker
@date       11/10/2015

*/
@isTest
private class SafetyAssessmentSurveyHelperTest {

    @isTest
    public static void updateCasefromSAS(){
    	Case c = new Case();
    	c.Subject = 'updateCasefromSAS';
    	c.status = 'open';
    	//c.Medical_QR_Status__c = 'Questionnaire Requested - Attempt 1';
    	insert c;
    	system.assertEquals('open', c.status);
    	//system.assertEquals('Questionnaire Requested - Attempt 1', c.Medical_QR_Status__c);

    	Safety_Assessment_Survey__c sas = new Safety_Assessment_Survey__c();
    	sas.Case__r = c;
    	sas.Case__c = c.id;
    	sas.Status__c = 'Active';

    	//Safety_Assessment_Survey__c sas = [select Status__c, Medical_QR_Status__c, Case__r.Medical_QR_Status__c from Safety_Assessment_Survey__c where Id = :presas.Id];
    	insert sas;

    	//system.assertEquals(null, sas.Medical_QR_Status__c);

    	sas.Medical_QR_Status__c = 'Questionnaire Requested - Attempt 2';

    	system.assertEquals('Questionnaire Requested - Attempt 2', sas.Medical_QR_Status__c);

    	Test.startTest();
    	update sas;
    	system.debug('@@@Case Status ' + sas.case__r.status);
    	Test.stopTest();

    	system.assertEquals('Questionnaire Requested - Attempt 2', sas.Medical_QR_Status__c);

    	List <Case> caseResults = [SELECT Id, Medical_QR_Status__c, Subject FROM Case WHERE Subject = 'updateCasefromSAS'];

    	system.assertEquals('updateCasefromSAS', caseResults[0].Subject);
    	system.assertEquals(1, caseResults.size());
    	system.assertEquals('Questionnaire Requested - Attempt 2', caseResults[0].Medical_QR_Status__c);
    }

        @isTest
    public static void notupdateCasefromSAS(){
        Case c = new Case();
        c.Subject = 'notupdateCasefromSAS';
        c.status = 'open';
        c.Medical_QR_Status__c = 'Questionnaire Requested - Attempt 2';
        insert c;
        system.assertEquals('open', c.status);
        system.assertEquals('Questionnaire Requested - Attempt 2', c.Medical_QR_Status__c);

        Safety_Assessment_Survey__c sas = new Safety_Assessment_Survey__c();
        sas.Case__c = c.id;
        sas.Status__c = 'Active';
        insert sas;

        //check 

        sas.Medical_QR_Status__c = 'Questionnaire Requested - Attempt 1';

        Test.startTest();
        update sas;
        Test.stopTest();

        List <Case> caseResults = [SELECT Id, Medical_QR_Status__c, Subject FROM Case WHERE Subject = 'notupdateCasefromSAS'];

        system.assertEquals('notupdateCasefromSAS', caseResults[0].Subject);
        system.assertEquals(1, caseResults.size());
        system.assertEquals('Questionnaire Requested - Attempt 2', caseResults[0].Medical_QR_Status__c);
    }

}