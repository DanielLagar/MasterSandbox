@isTest
private class sf_LiveChatTranscriptTriggerTest {
	
	@isTest static void testNewChat() {
		Case c = new Case();
        c.Status = 'Open';
        insert c;

        LiveChatVisitor lcv = new LiveChatVisitor ();
        insert lcv;

        LiveChatTranscript tran = new LiveChatTranscript ();
        tran.CaseId = c.Id;
        tran.LiveChatVisitorId = lcv.Id;
        tran.Body = 'foo';

        Test.startTest();
 		insert tran;

 		System.assertEquals('foo', [SELECT Id, Summary__c FROM Case WHERE Id = :c.Id].Summary__c);

        Test.stopTest();

	}
	
}