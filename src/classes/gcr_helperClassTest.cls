/*
* @author:       Accenture
* @date:         30/08/2016
* @description:  Test class for general care hub testing
* CHANGE LOG
* DATE          NAME                CHANGE DESCRIPTION
* 01/09/2016    Accenture           Initial Draft
*/
@isTest(SeeAllData = false)
global class gcr_helperClassTest {
    
	/*
     * @author: 		Accenture
	 * @date: 		 	30/08/2016
	 * @description:  	TEST SETUP METHOD TO SETUP TEST DATA
     */
    @testSetup
    static void setupTestData() {
        gcr_TestUtility.createCustomSettings();
        String brandConLangId = gcr_TestUtility.createContactUsObjectData();
        sObject careHub = gcr_TestUtility.getCareHubData(brandConLangId);
        Database.insert(careHub, true);
        List<sObject> lCareHubChannels = gcr_TestUtility.getCareHubChannels(careHub.Id);
        Database.insert(lCareHubChannels, true);
    }
    
    /*
    * @author:       Accenture
    * @date:         01/09/2016
    * @description:  test method for product list controller
    */
    static testmethod void productListControllerTest() {
		gcr_productListController prdListController = new gcr_productListController();
        prdListController.strSobject = 'Local_Product__c';
        prdListController.strFieldSet = 'ProductSearchResults';
        prdListController.strActionJs = 'action js';
        prdListController.desiredResultCount = 10;
        prdListController.iconAddRemove = 'add';
        List<sObject> lProd = prdListController.lProduct;
        List<Schema.FieldSetMember> fsMember = prdListController.lFieldSetMember;
        gcr_helperClass.getFieldSetFieldsForQuery('Local_Product__c', 'ProductSearchResults');
        SYSTEM.assert(fsMember != null && !fsMember.isEmpty());
    }
    
    /*
    * @author:       Accenture
    * @date:         01/09/2016
    * @description:  test method of child subquery of a specific object
    */
    static testmethod void childQueryForSpecificObjectTest() {
        String strSubQuery = gcr_helperClass.getChildQueryString('GCRCareHub__c', new Set<String>{'GCRChannelContent__r'});
        String strQuery = 'SELECT Id, ' + strSubQuery + ' FROM GCRCareHub__c';
        try {
        	Database.query(strQuery);
            SYSTEM.assert(true);
        } catch (Exception caughtException) {
            SYSTEM.assert(false);
        }
    }
    
    /*
    * @author:       Accenture
    * @date:         01/09/2016
    * @description:  test method of child subquery for all child objects
    * TODO: PUT IN ASSESRTIONS FOR THIS TO WORK
    */
    static testmethod void childQueryForAllObjectTest() {
        String strSubQuery = gcr_helperClass.getChildQueryString('GCRCareHub__c', null);
        String strQuery = 'SELECT Id, ' + strSubQuery + ' FROM GCRCareHub__c';
        //Database.query(strQuery);
    }
    
    /*
    * @author:       Accenture
    * @date:         01/09/2016
    * @description:  test method of child subquery for all child objects
    */
    static testmethod void chatButtonAvailabilityTest() {
        Test.setMock(HttpCalloutMock.class, new gcr_mockApiClass.gcr_liveAgentButton());
        GCRChannelContent__c content = [ SELECT Id FROM GCRChannelContent__c WHERE RecordType.Name = 'chat' ];
        Test.startTest();
        Boolean isButtonAvailable = gcr_helperClass.ischatBtnAvailable(content.Id);
        Test.stopTest();
        SYSTEM.assert(isButtonAvailable);
    }
    
    /*
    * @author:       Accenture
    * @date:         01/09/2016
    * @description:  test method of child subquery for all child objects
    */
    static testmethod void upsertAttachmentTest() {
        List<GCRCareHub__c> lCareHub = [ SELECT Id FROM GCRCareHub__c LIMIT 1 ];
        Attachment created = gcr_helperClass.upsertAttachment(''
                                                            , 'attachmentName'
                                                            , 'text'
                                                            , lCareHub.get(0).Id, Blob.valueOf('TEST DATA FOR ATTACHMENT'));
        List<Attachment> lAttachment = [ SELECT Id, Body FROM Attachment WHERE ParentId = :lCareHub.get(0).Id ];
		SYSTEM.assert(lAttachment != null && !lAttachment.isEmpty()
                   && lAttachment.get(0).Body.toString().equalsIgnoreCase('TEST DATA FOR ATTACHMENT'));
        created = gcr_helperClass.upsertAttachment(created.Id
                                                 , 'attachmentName'
                                                 , 'text'
                                                 , lCareHub.get(0).Id
                                                 , Blob.valueOf('NEW DATA'));
        lAttachment = [ SELECT Id, Body FROM Attachment WHERE ParentId = :lCareHub.get(0).Id ];
        SYSTEM.assert(lAttachment != null && !lAttachment.isEmpty()
                   && lAttachment.get(0).Body.toString().equalsIgnoreCase('NEW DATA'));
        gcr_helperClass.manageAttachment(created.Id, lCareHub.get(0).Id, true);
    }
}