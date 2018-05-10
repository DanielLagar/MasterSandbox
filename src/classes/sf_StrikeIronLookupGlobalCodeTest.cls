/*
  * @author: Oleg Rikkers
  * @date: 05/19/2014

  * @description: test class for sf_StrikeIronValidateEmail 
  * 
  */


@isTest
private class sf_StrikeIronLookupGlobalCodeTest {
	
	@isTest static void testEmailValidate() {
		
		Test.setMock(HttpCalloutMock.class, new sf_MockStrikeIronGblCodeValidationImpl());
		sf_StrikeIronGblCodeLookupResponseBean bean;
		String zip = '55555';
		String country = 'test';

		Test.startTest();

		sf_StrikeIronService service = sf_StrikeIronServiceFactory.getStrikeIronService();
        bean = service.lookupGlobalPostalCode(zip, country);

        Test.stopTest();

        System.assertNotEquals(null, bean.city);
        
	}
	
}