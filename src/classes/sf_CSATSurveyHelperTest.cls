/**
* @author: salesforce.com, inc.
* @date: 02/05/2015
*
* @description: test class
*/

@isTest
private class sf_CSATSurveyHelperTest {
    
    @isTest static void testCSATSurvey() {
        //create a contact 
        Contact c = new Contact ();
        c.LastName = 'test';
        c.Email = 'test@test12312312312.com';
        insert c;

        Case ca = new Case ();
        ca.Status = 'New';
        ca.ContactId = c.Id;
        insert ca;

        ca.Status = 'Closed';
        update ca;
        
        List<CSAT_Survey__c> csat = [SELECT Id FROM CSAT_Survey__c WHERE Case__c = :ca.Id];
        csat[0].Status__c = 'Submitted';
        update csat;

        System.assertEquals(1, csat.size());
    }
    
}