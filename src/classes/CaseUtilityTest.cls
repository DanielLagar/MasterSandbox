/**
* @author: Salesforce.com
* @date: 10/21/2014
* @description: 
*	Test class for CaseUtility
* @changes:
* 21-10-2015
* Removing meta site/auto response functionality
* as converting to standard auto response rules
* christopher.macduff@accenture.com
*/

@isTest
private class CaseUtilityTest {
    
	static testMethod void makeMeCaseOwnerTest(){
		Case ca = new Case (
            Status = 'New',
            Origin = 'Email'
        );
    	insert ca;
        test.startTest();
        CaseUtility.makeMeCaseOwner(ca.Id);        
        test.stopTest();
    }
    
    static testmethod void getAttachmentTest(){
		Case ca = new Case ();
    	ca.Status = 'New';
    	insert ca;
        
        test.startTest();
        CaseUtility util = new CaseUtility ();
        Blob b = Blob.valueOf('some content here for attachment');
		Attachment att = new Attachment(
		ParentId = ca.Id,
		Body = b,
        Name = 'Attachment name',
        Description = 'Attachment description'
        );
        
        util.insertAttachment(att);
        
        test.stopTest();
    }

	static testmethod void getPriorityTest() {

		Test.startTest();
		CaseUtility util = new CaseUtility ();
		System.assertEquals ( '5', util.getPriority('test', 'us'));

		Metadata_priority__c mp = new Metadata_priority__c ();
		mp.Country__c = 'US';
		mp.Keywords__c = 'test';
		mp.Priority__c = '1';

		insert mp;

		System.assertEquals ( '1', util.getPriority('test', 'us'));
		Test.stopTest();
	}

	static testmethod void getContactByLastNameTest() {
		Test.startTest();
    	
    	CaseUtility util = new CaseUtility ();
    	util.getContactByFNameLNameEmail('test', 'test', 'test');

		Test.stopTest();
	}

	static testmethod void updateContactTest() {
		Test.startTest();
    	
    	CaseUtility util = new CaseUtility ();
    	
    	//should throw exception
    	try {
    		util.updateContact(null, null, null, null,null,null, null,null,null, null,null,null);
    	} catch (Exception e){
    		System.assert(true);
    	}

    	//create a contact 
    	Contact c = new Contact ();
    	c.LastName = 'test';

    	insert c;

    	util.updateContact(c.Id, 'test', null, null,'test','test', 'test','test',null, null,false,null);
    	util.updateContact(c);
		Test.stopTest();
	}

	static testmethod void attachFileToCaseTest() {
		Test.startTest();
    	
    	CaseUtility util = new CaseUtility ();
    	
    	//should throw exception
    	try {
    		util.attachFileToCase(null);
    	} catch (Exception e){
    		System.assert(true);
    	}

		Test.stopTest();
	}

	static testmethod void isContactNeededTest() {
		Test.startTest();
    	
    	CaseUtility util = new CaseUtility ();
    	
    	util.isContactNeeded('test');
		Test.stopTest();
	}

    /*christopher.macduff@accenture.com - no longer required
	static testmethod void sendEmailToCustomerTest() {
		Test.startTest();
    	
    	CaseUtility util = new CaseUtility ();

    	Case ca = new Case ();
    	ca.Status = 'New';
    	insert ca;

    	//create a contact 
    	Contact c = new Contact ();
    	c.LastName = 'test';

    	insert c;

    	try {
    		util.sendEmailToCustomer(c.Id, ca.Id, null, 'test@test.com', 'test@test.com', 'test@test.com', 'test@test.com');
    	} catch (Exception e){
    		System.assert(true);
    	}
    
		Test.stopTest();
	}

	static testmethod void sendEmailToThirdPartyTest() {
		Test.startTest();
    	
    	CaseUtility util = new CaseUtility ();

    	try {
    		util.sendEmailToThirdParty(null, null, 'test@test.com', null, null, null, null);
    	} catch (Exception e){
    		System.assert(true);
    	}

    	Case ca = new Case ();
    	ca.Status = 'New';
    	insert ca;

    	//create a contact 
    	Contact c = new Contact ();
    	c.LastName = 'test';

    	insert c;

    	try {
    		util.sendEmailToThirdParty(c.Id, ca, 'test@test.com', 'test@test.com', 'test@test.com', 'test@test.com', 'test@test.com');
    	} catch (Exception e){
    		System.assert(true);
    	}

		Test.stopTest();
	}*/

	static testmethod void createTaskTest() {
		Test.startTest();
    	
    	CaseUtility util = new CaseUtility ();

    	Case ca = new Case ();
    	ca.Status = 'New';
    	insert ca;

    	//create a contact 
    	Contact c = new Contact ();
    	c.LastName = 'test';

    	insert c;

    	try {
    		util.createTask(c.Id, ca.Id, 'test', 'test', 'test', 'test', 'test', 'test', 'test');
    	} catch (Exception e){
    		System.assert(true);
    	}

		Test.stopTest();
	}

	static testmethod void createEmailMessageTest() {
		Test.startTest();
    	
    	CaseUtility util = new CaseUtility ();

    	try {
    		util.createEmailMessage(null, null, 'test', 'test@test.com', 'test');
    	} catch (Exception e){
    		System.assert(true);
    	}

		Test.stopTest();
	}

	static testmethod void createCreateContactTest() {
		Test.startTest();
    	
    	CaseUtility util = new CaseUtility ();

    	try {
    		util.createContact(null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null );
    	} catch (Exception e){
    		System.assert(true);
    	}

		Test.stopTest();
	}

	static testmethod void createInsertNewCase() {
		Test.startTest();
    	
    	CaseUtility util = new CaseUtility ();
    	util.insertNewCase(new Case());

		Test.stopTest();
	}

	static testmethod void getQueueRTTest() {
		Test.startTest();
    	CaseUtility util = new CaseUtility ();
    	util.getQueueRecordType('default');

		Test.stopTest();
	}
	
}