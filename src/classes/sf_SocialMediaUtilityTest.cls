/*
* @author: original PG class
* @date: 08/19/2014
* @description: Test class for SocialMediaUtility. 
  Class migrated from Temp org
*/
@isTest
private class sf_SocialMediaUtilityTest
{
    public static testmethod void testsocialMediaUtility(){
       
      
      Case caseobj = new Case();
      caseobj.Country__c='United States of America';
      caseObj.Language__c='English-US';
      caseObj.Brand__c='Tide';
      caseObj.Segment__c='Unknown';
      insert caseObj;
      
      Contact con=new Contact();
      con.Firstname='Test';
      con.LastName='Test';
      con.Email='Test@pg.com';
      insert con;
      
      SocialMediaEmailAddresses__c metadata=new SocialMediaEmailAddresses__c();
      metadata.isExternal__c=false;
      metadata.name='bommali.a@pg.com';     
      insert metadata;
      
        
      sf_SocialMediaUtility util=new sf_SocialMediaUtility();
      util.createTask('Description: Test', 'subject: Test', 'Social Meda', 'Not Started', 'Low', caseObj.Id, sf_GlobalUtilityClass.TASK_CONSUMER_ACTIVITY_RT_ID, con.Id, null);
      util.handleException('exception:Test', 'subject:Test', 'moreinfo: Test', false);
    }
}