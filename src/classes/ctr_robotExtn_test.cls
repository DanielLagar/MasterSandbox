@isTest
public class ctr_robotExtn_test {
    static String lang = 'en_US';
    Static Final String PROD_VALUE = 'Production';
    Static Final String SB_VALUE = 'Sandbox';
    Static Final String DEFAULT_VALUE = 'Disallow: / # disallow indexing of all pages.'; //This will be used if no matching records are found.

    @testSetup static void setupData(){
        //Create a number of Robot_Settings__c records
        List<Metadata_RobotTxt__c> orgType = new List<Metadata_RobotTxt__c>();
        Metadata_RobotTxt__c production = new Metadata_RobotTxt__c(
            Name = PROD_VALUE,
            Robots_txt_Value__c = PROD_VALUE
        );
        orgType.add(Production);
        
        Metadata_RobotTxt__c sandbox = new Metadata_RobotTxt__c(
            Name = SB_VALUE,
            Robots_txt_Value__c = SB_VALUE
        );
        orgType.add(sandbox);
        
        insert orgType;
	}
	
	@isTest
	static void robotTest(){
	    // Set an incorrectName so that no match can be found initially
	    List<Metadata_RobotTxt__c> robots = new List<Metadata_RobotTxt__c>();
	    Metadata_RobotTxt__c sbRobot = [select id from Metadata_RobotTxt__c where name = :SB_VALUE];
	    sbRobot.name = 'incorrectNameSB';
		Metadata_RobotTxt__c prodRobot = [select id from Metadata_RobotTxt__c where name = :PROD_VALUE];
	    prodRobot.name = 'incorrectNamePROD';
	    robots.add(sbRobot);
        robots.add(prodRobot);
	    update robots;
	    
	    PageReference pageRef = Page.RobotsTxt;
	    Test.setCurrentPage(pageRef);

        String testValue = DEFAULT_VALUE; //Set as default initially

	    ctr_robotExtn con = new ctr_robotExtn();
	    test.startTest();
	    
        //Assert page returns what you expect : This is a Robot.txt File for the Sandbox Environment
        boolean isItASandbox = [SELECT isSandbox FROM Organization LIMIT 1].isSandbox;

		system.assertEquals(testValue, con.valueToDisplay); 
        
        //Now set testValue according to environment type
		if(isItASandbox){
            testValue = SB_VALUE;
        }
        else{
            testValue = PROD_VALUE;
        }
        
        //correct value so new match can be found
        sbRobot.name = SB_VALUE;
        prodRobot.name = PROD_VALUE;

        update robots;
        
        con = new ctr_robotExtn();
        
        system.assertEquals(testValue, con.valueToDisplay);

	    test.stopTest();
	}
}