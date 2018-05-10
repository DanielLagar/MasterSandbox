/*
  * @author: Oleg Rikkers
  * @date: 05/19/2014

  * @description: test class for sf_StrikeIronConfigurationUtil class
  * 
*/

@isTest
private class sf_StrikeIronConfigurationUtilTest {
	
	@isTest static void testNoConfig() {
		Test.startTest();

		sf_StrikeIronConfigurationUtil util = sf_StrikeIronConfigurationUtil.getInstance();

		System.assertEquals('', util.getUsername());
		System.assertEquals('', util.getPassword());
		System.assertEquals('', util.getZipCodeLookupUrl());
		System.assertEquals('', util.getGlobalCodeLookupUrl());
		System.assertEquals('', util.getValidateEmailUrl());
		System.assertEquals('', util.getValidateAddressUrl());
		System.assertEquals('', util.getValidateEmailTimeoutSeconds());

		Test.stopTest();
	}
	

	@isTest static void testConfigFound() {
		
		sf_StrikeIronConfigurationUtil.initSettings();

		Test.startTest();

		sf_StrikeIronConfigurationUtil util = sf_StrikeIronConfigurationUtil.getInstance();

		System.assertNotEquals('', util.getUsername());
		System.assertNotEquals('', util.getPassword());
		System.assertNotEquals('', util.getZipCodeLookupUrl());
		System.assertNotEquals('', util.getGlobalCodeLookupUrl());
		System.assertNotEquals('', util.getValidateEmailUrl());
		System.assertNotEquals('', util.getValidateAddressUrl());
		System.assertNotEquals('', util.getValidateEmailTimeoutSeconds());

		Test.stopTest();
	}
}