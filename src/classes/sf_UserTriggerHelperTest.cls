/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class sf_UserTriggerHelperTest {

    static testMethod void test() {
        //create test data
        Profile admin = [select id from profile where name='System Administrator'];
        
        // create a couple of test groups
        Group g = new Group();
        g.Name = 'Test Group 1';
        g.Type = 'Regular';
        insert g;
        
        Group g1 = new Group();
        g1.Name = 'Test Group 2';
        g1.Type = 'Regular';
        insert g1;
        //end create test data

   	
        
        //TEST CASE 1: test creating an user and adding region_language. verify that public groups are added.
        User testUser = new User(alias = 'u1', email='u1@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = admin.Id,  country='United States', CommunityNickname = 'u1',
            timezonesidkey='America/Los_Angeles', username='testuser@pg.com.gcrdev1', Region_Language__c='Test Group 1;Test Group 2');
        insert testUser;
        
        // check for group membership
        List<GroupMember> gm = [select id from GroupMember where GroupId =:g.id AND UserOrGroupId =:testUser.id];
        system.assertEquals(1, gm.size());    
        //END TEST CASE 1
        
         
        //TEST CASE 2: test removing a region_language. Verify that matching public group is removed and other public groups remain.
        testUser.Region_Language__c = 'Test Group 2';
        update testUser;
        
         // check for group membership has been deleted and other remains
        gm = [select id from GroupMember where GroupId =:g.id AND UserOrGroupId =:testUser.id];
        system.assertEquals(0, gm.size());
        gm = [select id from GroupMember where GroupId =:g1.id AND UserOrGroupId =:testUser.id];
        system.assertEquals(1, gm.size());   
        
        //TEST CASE 3: test deactivating a user. verify that all public groups are removed.
        testUser.isActive=false;
        update testUser;
        
        //check for any public groups
        gm = [select id from GroupMember where UserOrGroupId =:testUser.id];
        system.assertEquals(0, gm.size());
        
    }
}