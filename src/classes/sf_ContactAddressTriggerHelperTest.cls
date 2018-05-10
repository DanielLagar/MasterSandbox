/*
* @author: Oleg Rikkers
* @date: 05/13/2014
* @description: test class for sf_ContactAddressTriggerHelper.class
*  

*/


@isTest
private class sf_ContactAddressTriggerHelperTest {
	
	public static final map<string,Schema.RecordTypeInfo> AccountRecordTypeInfoByNameMap = Account.sObjectType.getDescribe().getRecordTypeInfosByName(); 
	public static final map<string,Schema.RecordTypeInfo> ContactRecordTypeInfoByNameMap = Contact.sObjectType.getDescribe().getRecordTypeInfosByName(); 
	
	@isTest static void testNewContactNewAccount() {
		Test.startTest();

		Contact c = new Contact ();
		c.LastName = 'test';
		c.Primary_Address_Line_1__c = 'test';
		c.Primary_City__c = 'test';
		c.Primary_Postal_Code__c = 'test';
		c.Primary_State_Province__c = 'test';
		c.RecordTypeId = ContactRecordTypeInfoByNameMap.get('Consumer').getRecordTypeId();

		insert c;

		System.assertEquals(1, [SELECT Id FROM Contact].size(), 'Contact was not created');
		System.assertEquals([SELECT Id FROM Account LIMIT 1].Id, [SELECT Id, AccountId FROM Contact].AccountId, 'Contact was not attached to account');
		System.assertEquals([SELECT Id, Complete_Address__c FROM Account LIMIT 1].Complete_Address__c, [SELECT Id, Complete_Address__c FROM Contact].Complete_Address__c, 'Contact was not attached to a correct account');

		Test.stopTest();
	}
	
	@isTest static void testExistingContactNewAccount() {
		
		Contact c = new Contact ();
		c.LastName = 'test';
		c.Primary_Address_Line_1__c = 'test';
		c.Primary_City__c = 'test';
		c.Primary_Postal_Code__c = 'test';
		c.Primary_State_Province__c = 'test';
		c.RecordTypeId = ContactRecordTypeInfoByNameMap.get('Consumer').getRecordTypeId();

		insert c;

		Test.startTest();

		c.AccountId = null;
		update c;

		

		c.Primary_Address_Line_1__c = 'test1';
		update c;
		

		Test.stopTest();

		//System.assertEquals([SELECT Id FROM Account WHERE Complete_Address__c = 'test1test'].Id, [SELECT Id, AccountId FROM Contact].AccountId, 'Contact was not attached to account');
		
		//should be two accounts now
		System.assertEquals(2, [SELECT Id FROM Account].size(), 'Should be 2 accounts now.');
	}
	
}