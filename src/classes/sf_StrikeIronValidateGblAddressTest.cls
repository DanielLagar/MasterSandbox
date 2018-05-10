/*
  * @author: Oleg Rikkers
  * @date: 05/19/2014

  * @description: test class for sf_StrikeIronValidateGblAddress class
  * 
  */


@isTest
private class sf_StrikeIronValidateGblAddressTest {
    

        /*
        CDOY START
        */
        
    @isTest static void testAddressValidate() {
        //Test.setMock(HttpCalloutMock.class, new sf_MockStrikeIronGblAddressImpl());
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('siTestAddressResponseOption3');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'text/plain');
		Test.setMock(HttpCalloutMock.class, mock);
        
        sf_StrikeIronValidateGblAddressRespBean bean;
        String street = '1 STREET';
        String cityState = 'LONDON';
        String Postcode = 'NE27 0QW';
        String country = 'UNITED KINGDOM';
        
        Test.startTest();
        sf_StrikeIronService service = sf_StrikeIronServiceFactory.getStrikeIronService();
        bean = service.validateGlobalAddress (street, cityState, country);
        bean.getFormattedAddressWithHTMLBreaks();
        sf_StrikeIronValidateGblAddressRespBean.getFormattedUserInputWithHTMLBreaks('test', 'test', 'test', 'test', 'test', 'test');
        Test.stopTest();
        
        System.assertEquals(country, bean.country, 'country did not match.');
        System.assertEquals('325', bean.statusNbr, 'status did not match.');
    } 
    
    
    
    @isTest static void testAddressValidateTwo() {
        //Test.setMock(HttpCalloutMock.class, new sf_MockStrikeIronGblAddressImpl());
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('siTestAddressResponseOption2');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'text/plain');
		Test.setMock(HttpCalloutMock.class, mock);
        
        sf_StrikeIronValidateGblAddressRespBean beanTwo;
        String streetTwo = '1 STREET';
        String cityStateTwo = 'LONDON';
        String PostcodeTwo = 'NE27 0QW';
        String countryTwo = 'Brazil';
        
        Test.startTest();
        sf_StrikeIronService service = sf_StrikeIronServiceFactory.getStrikeIronService();
        beanTwo = service.validateGlobalAddress (streetTwo, cityStateTwo, countryTwo);
        beanTwo.getFormattedAddressWithHTMLBreaksOption2();
        sf_StrikeIronValidateGblAddressRespBean.getFormattedUserInputWithHTMLBreaksOption2('test', 'test', 'test', 'test', 'test', 'test');
        Test.stopTest();
        
        //System.assertEquals(countryTwo, beanTwo.countryTwo, 'country did not match.');
        System.assertEquals('325', beanTwo.statusNbr, 'status did not match.'); 
    } 
        
        /*
        CDOY END
        */
        
    @isTest static void testAddressValidateThree() {
        
        Test.setMock(HttpCalloutMock.class, new sf_MockStrikeIronGblAddressImpl());
        sf_StrikeIronValidateGblAddressRespBean beanThree;
        String streetThree = '1 STREET';
        String cityStateThree = 'Berlin';
        String countryThree = 'GERMANY';

        Test.startTest();
        sf_StrikeIronService serviceThree = sf_StrikeIronServiceFactory.getStrikeIronService();
        beanThree = serviceThree.validateGlobalAddress (streetThree, cityStateThree, countryThree);
        beanThree.getFormattedAddressWithHTMLBreaksOption3();
        sf_StrikeIronValidateGblAddressRespBean.getFormattedUserInputWithHTMLBreaksOption3('test', 'test', 'test', 'test', 'test', 'test');
        Test.stopTest();
        
        System.assertEquals(countryThree, beanThree.country, 'country did not match.');
        System.assertEquals('325', beanThree.statusNbr, 'status did not match.');
        
    } 
    
    
    @isTest static void testAddressValidateFour() {
        
        //Test.setMock(HttpCalloutMock.class, new sf_MockStrikeIronGblAddressImpl());
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('siTestAddressResponseOption4');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'text/plain');
		Test.setMock(HttpCalloutMock.class, mock);
        
        
        sf_StrikeIronValidateGblAddressRespBean beanFour;
        String streetFour = '1 STREET';
        String cityStateFour = 'Berlin';
        String countryFour = 'China';

        Test.startTest();
        sf_StrikeIronService serviceFour = sf_StrikeIronServiceFactory.getStrikeIronService();
        beanFour = serviceFour.validateGlobalAddress (streetFour, cityStateFour, countryFour);
        beanFour.getFormattedAddressWithHTMLBreaksOption4();
        sf_StrikeIronValidateGblAddressRespBean.getFormattedUserInputWithHTMLBreaksOption4('test', 'test', 'test', 'test', 'test', 'test');
        Test.stopTest();
        
        System.assertEquals(countryFour, beanFour.country, 'country did not match.');
        System.assertEquals('325', beanFour.statusNbr, 'status did not match.');
        
    } 
    
    @isTest static void testAddressValidateFive() {
        
        //Test.setMock(HttpCalloutMock.class, new sf_MockStrikeIronGblAddressImpl());
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('siTestAddressResponseOption5');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'text/plain');
		Test.setMock(HttpCalloutMock.class, mock);
        
        sf_StrikeIronValidateGblAddressRespBean beanFive;
        String streetFive = '1 STREET';
        String cityStateFive = 'Berlin';
        String countryFive = 'Japan';

        Test.startTest();
        sf_StrikeIronService serviceFive = sf_StrikeIronServiceFactory.getStrikeIronService();
        beanFive = serviceFive.validateGlobalAddress (streetFive, cityStateFive, countryFive);
        beanFive.getFormattedAddressWithHTMLBreaksOption5();
        sf_StrikeIronValidateGblAddressRespBean.getFormattedUserInputWithHTMLBreaksOption5('test', 'test', 'test', 'test', 'test', 'test');
        Test.stopTest();
        
        System.assertEquals(countryFive, beanFive.country, 'country did not match.');
        System.assertEquals('325', beanFive.statusNbr, 'status did not match.');
        
    } 
    
    

    
    
}