/*
  * @author: Oleg Rikkers
  * @date: 05/19/2014

  * @description: test class for sf_StrikeIronValidateEmail 
  * 
  */


@isTest
private class sf_StrikeIronValidateEmailTest {
	
	@isTest static void testEmailValidate() {
		
		Test.setMock(HttpCalloutMock.class, new sf_MockStrikeIronEmailValidationImpl());
		sf_StrikeIronValidateEmailResponseBean bean;
		String email = 'test@test.com';


		Test.startTest();

		sf_StrikeIronService service = sf_StrikeIronServiceFactory.getStrikeIronService();
        bean = service.validateEmailAddress (email);

        Test.stopTest();

        System.assertEquals(email, bean.email, 'email did not match.');
        System.assertEquals('300', bean.statusNbr, 'status did not match.');
	}
	
}