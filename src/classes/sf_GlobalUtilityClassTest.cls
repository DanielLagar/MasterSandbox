@isTest
private class sf_GlobalUtilityClassTest {
	
	static testMethod void test_method_one() {
		sf_GlobalUtilityClass util = new sf_GlobalUtilityClass ();
		sf_GlobalUtilityClass.getSystemEmailAddress();

		System.assertNotEquals(null, sf_GlobalUtilityClass.TASK_CONSUMER_ACTIVITY_RT_ID);
		System.assertNotEquals(null, sf_GlobalUtilityClass.TASK_INTERNAL_ACTIVITY_RT_ID);
	}
    
    static testMethod void recordTypeMapTest(){
        String testRecordTypeId = sf_GlobalUtilityClass.recordTypeMap.get('NA');
        
        system.assertNotEquals(null, testRecordTypeId);

    }
    
    static testMethod void orgEmailMapTest(){
        OrgWideEmailAddress emailTest = sf_GlobalUtilityClass.orgEmailMap.get('consumercare.im@pg.com');
        
        system.assertNotEquals(null, emailTest);
    }
    
}