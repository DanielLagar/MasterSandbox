@isTest
public class CustomSettingDataFactory {
    
    //TODO: Check this is used/required?
    public static void triggerToggleSetup(){
        TriggerToggle__c tt = new TriggerToggle__c(
			AccountTrigger__c = True,
            CaseTrigger__c = True,
			ContactTrigger__c = True,
			FulfillmentOrder__c = True,
			FulfillmentOrderLineItem__c = True,
            SafetyAssessmentSurvey__c = True,
			sf_EmailMessage__c = True,
			sf_TaskTrigger__c = True
        );
        insert tt;
    }
    
    public static void repeaterThresholdSetup(){
        List<Repeater_Threshold__c> rtsToInsert = new List<Repeater_Threshold__c>();
        Repeater_Threshold__c rt = new Repeater_Threshold__c(
            name='United States of America',
            Threshold_Period__c=30,
            Case_Count_Threshold__c=5,
            Reimbursement_Value_Threshold__c=50.00
        );
        rtsToInsert.add(rt);
        insert rtsToInsert;
    }

    public static void countryRegionSetup(){

        List<Country_Region_SMO__c> countriesToInsert = new List<Country_Region_SMO__c>();
        
        //Add United States of America
        Country_Region_SMO__c USA = new Country_Region_SMO__c(
            name = 'UNITED STATES OF AMERICA',
            Currency_ISO_Code__c = 'USD',
            Currency_Name__c = 'United States dollar',
        	DisplayLabel__c = 'United States dollar',
            DistanceUnit__c = 'miles',
        	WTB_Enabled__c = FALSE
        );
        countriesToInsert.add(USA);
        
        //Add China
        Country_Region_SMO__c China = new Country_Region_SMO__c(
            name = 'CHINA',
            Currency_ISO_Code__c = 'CNY',
            Currency_Name__c = 'Chinese yuan',
        	DisplayLabel__c = 'Chinese yuan',
            DistanceUnit__c = 'miles',
        	WTB_Enabled__c = FALSE,
            Alternative_Contact_Info_Layout__c = TRUE
        );
        countriesToInsert.add(China);
        
        //Add Greece
        Country_Region_SMO__c Greece = new Country_Region_SMO__c(
            name = 'GREECE',
            Currency_ISO_Code__c = 'EUR',
            Currency_Name__c = 'Euro',
        	DisplayLabel__c = 'Euro',
            DistanceUnit__c = 'miles',
        	WTB_Enabled__c = FALSE
        );
        countriesToInsert.add(Greece);
        
        //Add Greece
        Country_Region_SMO__c Brazil = new Country_Region_SMO__c(
            name = 'Brazil',
            Currency_ISO_Code__c = 'BRL',
            Currency_Name__c = 'Brazilian real',
        	DisplayLabel__c = 'Brazilian real',
            DistanceUnit__c = 'miles',
        	WTB_Enabled__c = FALSE
        );
        countriesToInsert.add(Brazil);
        
        insert CountriesToInsert;
    
	}

}