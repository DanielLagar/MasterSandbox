/*
  * @author: Oleg Rikkers
  * @date: 05/19/2014

  * @description: test class for StrikeIronZipCodeLookup class
  * 
  */


@isTest
private class sf_StrikeIronZipCodeLookupTest {
	
	@isTest static void testUSZipValidate() {
		
		Test.setMock(HttpCalloutMock.class, new sf_MockStrikeIronZipCodeLookupImpl());
		sf_StrikeIronZIPCodeLookupResponseBean bean;
		String zipCode = '30906-9295';


		Test.startTest();

		sf_StrikeIronService service = sf_StrikeIronServiceFactory.getStrikeIronService();
        bean = service.lookupZIPCodeInfo (zipCode);

        Test.stopTest();

        System.assertEquals(zipCode, bean.formattedZIPOrPostalCode, 'Zip codes did not match.');
	
	}
	
}