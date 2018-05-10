/*
* @author: Accenture - CD
* @date: 23/06/2017
* @description: Test Class for MSTCount
*/
@isTest
private class MSTCountTest {
	public static testmethod void MSTCountTest() {
	
		Metadata_Survey_Trigger__c mst = new Metadata_Survey_Trigger__c();
		insert mst;

		MST_Action_Count__c mac1 = new MST_Action_Count__c();
		mac1.date_triggered__c = date.Today()-30;
		mac1.Metadata_Survey_Trigger__c = mst.id;
		insert mac1;

		MST_Action_Count__c mac2 = new MST_Action_Count__c();
		mac2.date_triggered__c = date.Today()-60;
		mac2.Metadata_Survey_Trigger__c = mst.id;
		insert mac2;


		system.debug('mac2.date_triggered__c***'+mac2.date_triggered__c);

		Test.startTest();

			MSTCount batch = new MSTCount();
			Database.executeBatch(batch, 1);

		Test.stopTest();

		Metadata_Survey_Trigger__c mst_new = [SELECT Last_90_Day_Count__c, Last_60_Day_Count__c, Last_30_Day_Count__c FROM Metadata_Survey_Trigger__c where id =: mst.id ];

		system.assertEquals(2, mst_new.Last_90_Day_Count__c);
		system.assertEquals(2, mst_new.Last_60_Day_Count__c);
		system.assertEquals(1, mst_new.Last_30_Day_Count__c);

	}

}