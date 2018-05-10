@isTest
public class checkRecursive_Test {
    
    @testSetup
    static void dataSetup(){
        CustomSettingDataFactory.triggerToggleSetup();
    }
    
    @isTest
    static void triggerToggleAllTest(){
        //Check all supported triggers are enabled first
		system.assertEquals(True, checkRecursive.triggerStatus('AccountTrigger__c'));
		system.assertEquals(True, checkRecursive.triggerStatus('CaseCommentCodeTrigger__c'));
		system.assertEquals(True, checkRecursive.triggerStatus('CaseContactTrigger__c'));
		system.assertEquals(True, checkRecursive.triggerStatus('CaseTrigger__c'));
		system.assertEquals(True, checkRecursive.triggerStatus('ContactTrigger__c'));
		system.assertEquals(True, checkRecursive.triggerStatus('FulfillmentOrder__c'));
		system.assertEquals(True, checkRecursive.triggerStatus('FulfillmentOrderLineItem__c'));
		system.assertEquals(True, checkRecursive.triggerStatus('SafetyAssessmentSurvey__c'));
 		system.assertEquals(True, checkRecursive.triggerStatus('sf_EmailMessage__c'));
		system.assertEquals(True, checkRecursive.triggerStatus('sf_TaskTrigger__c'));
		
		test.startTest();
        	//Toggle all supported triggers off
			checkRecursive.toggleAllTriggers(False);
            system.assertEquals(False, checkRecursive.triggerStatus('AccountTrigger__c'));
            system.assertEquals(False, checkRecursive.triggerStatus('CaseCommentCodeTrigger__c'));
            system.assertEquals(False, checkRecursive.triggerStatus('CaseContactTrigger__c'));
            system.assertEquals(False, checkRecursive.triggerStatus('CaseTrigger__c'));
            system.assertEquals(False, checkRecursive.triggerStatus('ContactTrigger__c'));
            system.assertEquals(False, checkRecursive.triggerStatus('FulfillmentOrder__c'));
            system.assertEquals(False, checkRecursive.triggerStatus('FulfillmentOrderLineItem__c'));
            system.assertEquals(False, checkRecursive.triggerStatus('SafetyAssessmentSurvey__c'));
            system.assertEquals(False, checkRecursive.triggerStatus('sf_EmailMessage__c'));
            system.assertEquals(False, checkRecursive.triggerStatus('sf_TaskTrigger__c'));
        	
        	//Toggle all supported triggers back on
        	checkRecursive.toggleAllTriggers(True);
            system.assertEquals(True, checkRecursive.triggerStatus('AccountTrigger__c'));
            system.assertEquals(True, checkRecursive.triggerStatus('CaseCommentCodeTrigger__c'));
            system.assertEquals(True, checkRecursive.triggerStatus('CaseContactTrigger__c'));
            system.assertEquals(True, checkRecursive.triggerStatus('CaseTrigger__c'));
            system.assertEquals(True, checkRecursive.triggerStatus('ContactTrigger__c'));
            system.assertEquals(True, checkRecursive.triggerStatus('FulfillmentOrder__c'));
            system.assertEquals(True, checkRecursive.triggerStatus('FulfillmentOrderLineItem__c'));
            system.assertEquals(True, checkRecursive.triggerStatus('SafetyAssessmentSurvey__c'));
            system.assertEquals(True, checkRecursive.triggerStatus('sf_EmailMessage__c'));
            system.assertEquals(True, checkRecursive.triggerStatus('sf_TaskTrigger__c'));        
		test.stopTest();      
    }
    
    @isTest
    static void triggerStatusEnabled_Test(){
        test.startTest();
        	system.assertEquals(True, checkRecursive.triggerStatus('caseTrigger__c'));
        test.stopTest();
    }
    
	@isTest
    static void triggerStatusDisabled_Test(){
        TriggerToggle__c tt = TriggerToggle__c.getInstance();
        tt.caseTrigger__c = false;
        upsert tt;
        
        test.startTest();
        	system.assertEquals(False, checkRecursive.triggerStatus('caseTrigger__c'));
        test.stopTest();
    }
    
    @isTest
    static void checkRecursive_isCaseInsert_Test(){
        Case testCase = new Case(
            Country__c = 'United States of America'
        );
        test.startTest();
        	insert testCase;
            system.assertEquals(True, checkRecursive.newCase);
        test.stopTest();
    }

}