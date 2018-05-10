@istest
public class contactValidation_Test {
    Static boolean expectedExceptionThrown = false;

    
    @testSetup static void setupData(){
        //Setup custom setting records here
        TriggerSwitch__c validationSwitch = new TriggerSwitch__c(
            Name = 'conValidation',
            TriggerOn__c = True
        );
        insert validationSwitch;
        
        List<Country_Status__c> countrySettings = new List<Country_Status__c>();
        
        Country_Status__c bothRequired = new Country_Status__c(
            Name = 'United States of America',
            Uses_States__c = True,
            Uses_Postal_Codes__c = True
        );
        countrySettings.add(bothRequired);
        
		Country_Status__c postCodeRequired = new Country_Status__c(
			Name = 'Canada',
            Uses_States__c = False,
            Uses_Postal_Codes__c = True
        );
        countrySettings.add(postCodeRequired);
        
		Country_Status__c stateRequired = new Country_Status__c(
			Name = 'Scotland', // :)
            Uses_States__c = True,
            Uses_Postal_Codes__c = False
        );
        countrySettings.add(stateRequired);
        
		Country_Status__c neitherRequired = new Country_Status__c(
			Name = 'Venezuela',
            Uses_States__c = False,
            Uses_Postal_Codes__c = False
        );
        countrySettings.add(neitherRequired);
        insert countrySettings; 
    }
    
	@isTest
    static void addressValidationPositiveTest(){
		Contact usCon = new Contact(
            LastName = 'PositiveContact',
            Primary_Country__c = 'United States of Kingdom',
            Primary_Address_Line_1__c = 'St Margs',
            Primary_City__c = 'London',
            Primary_State_Province__c = 'London',
			Primary_Postal_Code__c = 'TW1 1PT'
        );
        test.startTest();
            try{
                insert usCon;
                Database.SaveResult sr = Database.insert(usCon);
				system.assertEquals(True, sr.isSuccess());
            }
            catch(exception e){
				System.AssertEquals(expectedExceptionThrown, False);
            }
        test.stopTest();
    }
    
	@isTest
    static void addressValidationDefaultTest(){
		Contact usCon = new Contact(
            LastName = 'welshContact',
            Primary_Country__c = 'Wales',
            Primary_Address_Line_1__c = 'Welsh Address Line 1'
        );
        test.startTest();
            try{
                insert usCon;
            }
            catch(exception e){
                system.debug('>>> e: '+e.getMessage());
                expectedExceptionThrown =  e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);
            }
        test.stopTest();
    }
    
    @isTest
    static void addressValidationPostcodeStateTest(){
		Contact usCon = new Contact(
            LastName = 'USContact',
            Primary_Country__c = 'United States of America',
            Primary_Address_Line_1__c = 'US Address Line 1'
        );
        test.startTest();
            try{
                insert usCon;
            }
            catch(exception e){
                expectedExceptionThrown =  e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);
            }
        test.stopTest();
    }
    
    @isTest
    static void addressValidationPostcodeTest(){
		Contact caCon = new Contact(
            LastName = 'CAContact',
            Primary_Country__c = 'Canada',
            Primary_Address_Line_1__c = 'CA Address Line 1'
        );
        test.startTest();
            try{
                insert caCon;
            }
            catch(exception e){
                expectedExceptionThrown =  e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);
            }
        test.stopTest();
    }
    
    @isTest
    static void addressValidationStateTest(){
		Contact scoCon = new Contact(
            LastName = 'scoContact',
            Primary_Country__c = 'Scotland',
            Primary_Address_Line_1__c = 'SCO Address Line 1'
        );
        test.startTest();
            try{
                insert scoCon;
            }
            catch(exception e){
                expectedExceptionThrown =  e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);
            }
        test.stopTest();
    }

    @isTest
    static void addressValidationNeitherTest(){
 		Contact veCon = new Contact(
            LastName = 'veContact',
            Primary_Country__c = 'Venezuela',
            Primary_Address_Line_1__c = 'VE Address Line 1'
        );
        test.startTest();
            try{
                insert veCon;
            }
            catch(exception e){
                expectedExceptionThrown =  e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);
            }
        test.stopTest();
    }
}