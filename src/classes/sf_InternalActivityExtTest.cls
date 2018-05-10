@isTest
private class sf_InternalActivityExtTest {
	
	@isTest static void testInit() {
		Internal_Activity__c intAct = new Internal_Activity__c ();
        intAct.Comments__c = 'foo';
        //WR14 Test coverage improvements
        intAct.OwnerId = UserInfo.getUserId();
        
		Test.setCurrentPage(Page.sf_InternalActivity);
		ApexPages.currentPage().getParameters().put('retURL', 'www.google.com');
		ApexPages.currentPage().getParameters().put('clone', '1');


		sf_InternalActivityExt ext = new sf_InternalActivityExt (new ApexPages.StandardController (intAct));
		ext.saveAndReply();
		ext.save();
		ext.internalTypeItems();
	}

	@isTest static void testInitExisting() {

		Case c = new Case ();
    	c.Country__c = 'China';
    	c.Language__c = 'Chinese';
    	insert c;

		Internal_Activity__c intAct = new Internal_Activity__c ();
		intAct.Comments__c = 'foo';
		intAct.Case__c = c.Id;
		insert intAct;

		Test.setCurrentPage(Page.sf_InternalActivity);
		ApexPages.currentPage().getParameters().put('retURL', 'www.google.com');
        ApexPages.currentPage().getParameters().put('reply', '1');
        ApexPages.currentPage().getParameters().put('id', intAct.Id);

		sf_InternalActivityExt ext = new sf_InternalActivityExt (new ApexPages.StandardController (intAct));
		ext.save();
	}
	
}