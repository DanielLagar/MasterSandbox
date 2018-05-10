@isTest
private class sf_CaseHelperWithoutSharingTest {

    @isTest //
    public static void testTransferActivityTaskUserToUser() {
        sf_TestDataUtility tdu = new sf_TestDataUtility();
        User olduser = sf_TestDataUtility.createUser('System Administrator', 'alpha');
        User newuser = sf_TestDataUtility.createUser('System Administrator', 'omega');

        olduser.location__c = 'US';
        newuser.location__c = 'CA';

        insert oldUser;
        insert newUser;

        Case c = new Case();
        c.ownerid = oldUser.id;
        insert c;
        c.ownerid = newuser.id;

        test.startTest();
        update c;
        test.stopTest();

        List<Task> taskResults = [SELECT id, subject, status, New_Owner__c, New_Owner_Location__c, New_Owner_Id__c, Old_Owner__c, Old_Owner_Location__c, Old_Owner_Id__c FROM Task WHERE Recordtype.name = 'Transfer Activity'];
        
        system.debug('@@@taskResults: ' + taskResults);
        system.debug('@@@taskResults[0]: ' + taskResults[0]);
        
        system.assertEquals(1, taskResults.size());
        system.assertEquals('CA', taskResults[0].New_Owner_Location__c);
        system.assertEquals('US', taskResults[0].Old_Owner_Location__c);

    }
}