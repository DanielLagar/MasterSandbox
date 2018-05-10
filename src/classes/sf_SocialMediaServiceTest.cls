/**
* @author: Salesforce.com
* @date: 08/18/2014
* @description:  test class
*/

@isTest
private class sf_SocialMediaServiceTest{
	
	public static Id queueId { get; set; }
	public static Id getQueue() {
		 if (queueId == null) {
			Group grp = new Group(
			  Name = 'Default_Queue',
			  Type = 'Queue'
			);
			insert grp;
			System.runAs(new User(Id=UserInfo.getUserId()))
			{
				QueuesObject testQueue = new QueueSObject(QueueID = grp.id, SobjectType = 'Case');
				insert testQueue;
			}
			queueId = grp.Id;
		 }
		return queueId;
	}

    public static void insertEmailAddresses(){
        SocialMediaEmailAddresses__c metadata=new SocialMediaEmailAddresses__c();
        metadata.isExternal__c=false;
        metadata.name='bommali.a@pg.com';     
        insert metadata;
    }
    
    public static void insertSMSetting(string brand, string languagecode, string sntype, string snuid){
        SocialMediaSettings__c smset=new SocialMediaSettings__c();
        smset.name='Test';
        if(string.isNotBlank(brand))smset.Brand__c=brand;
        smset.Country__c='United States of America';
        smset.Language__c='English-US';
        smset.Language_Code__c=languagecode;
        smset.Queue_Id__c = getQueue();
        smset.SN_Type__c=sntype;
        smset.SN_Unique_Id__c=snuid;
        insert smset;
    }
    
    public static void insertQRRecord(){
    	
        QueueRecordType__c qrset = new QueueRecordType__c();
        qrset.name = getQueue();
        qrset.Country__c='United States of America';
        qrset.Language__c='English-US';
        qrset.MDO__c='AAI';
        qrset.Region__c='ASIA';
        RecordType rt = new RecordType();
        rt = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'case' LIMIT 1];
        qrset.Case_Record_Type_Id__c = rt.Id;
        qrset.Case_Record_Type_Name__c = rt.Name;
        insert qrset;
    }
    
    public static testmethod void testSocialMediaService(){
        insertEmailAddresses();
        insertSMSetting('Tide', 'en', 'Facebook', '123456789');
        insertQRRecord();      
      
        String snconsumerid='987654321';
        String snuniqueid='123456789';
        String sntype='Facebook';
        String lastname = 'Bommali';
        String firstname='Ashok';
        String summary='How are you?';
        String website = 'https://www.facebook.com/pgtest1';
        String languagecode = 'en';
        String snmessageid = '123123123';
      
        SocialMediaService.CaseAccountFields  inputobj = new SocialMediaService.CaseAccountFields();
        inputobj.SNConsumerID = snconsumerid;
        inputobj.SNUniqueID = snuniqueid;
        inputobj.SNTYPE = sntype;
        inputobj.lastname = lastname;
        inputobj.firstname = firstname;
        inputobj.summary = summary;
        inputobj.contactWebsite = website;
        inputobj.language= languagecode;
        inputobj.SNMessageID = snmessageid;
        inputobj.receivedDate = system.today();
        inputobj = SocialMediaService.createCaseServiceMethod(inputobj);
         
         
        System.assertNotEquals(inputobj.SFCaseID,null);
        //Activity call
        String sfdccaseidactivity=inputobj.SFCaseID;
        String activitydescription='Consumer comments come here...';
      
        SocialMediaService.ActivityFields inputobj2 = new SocialMediaService.ActivityFields();
        inputobj2.SFCaseID = sfdccaseidactivity;
        inputobj2.description = activitydescription;
        inputobj2.SNMessageID = snmessageid;
        inputobj2.receivedDate = system.today();
        inputobj2.isConsumerComment = true;
        inputobj2 = SocialMediaService.createActivityMethod(inputobj2);
        System.assertNotEquals(inputobj2.SFActivityID,null);
        
    }
    
    public static testmethod void testSocialMediaService2(){
        insertEmailAddresses();
        insertSMSetting('Tide', 'all', 'Facebook', '123456789');
        insertQRRecord(); 
      
        String snconsumerid='987654321';
        String snuniqueid='123456789';
        String sntype='Facebook';
        String lastname = 'Bommali';
        String firstname='Ashok';
        String summary='How are you?';
        String website = 'https://www.facebook.com/pgtest1';
        String languagecode = 'en';
        String snmessageid = '123123123';
      
        SocialMediaService.CaseAccountFields  inputobj = new SocialMediaService.CaseAccountFields();
        inputobj.SNConsumerID = snconsumerid;
        inputobj.SNUniqueID = snuniqueid;
        inputobj.SNTYPE = sntype;
        inputobj.lastname = lastname;
        inputobj.firstname = firstname;
        inputobj.summary = summary;
        inputobj.contactWebsite = website;
        inputobj.language= languagecode;
        inputobj.SNMessageID = snmessageid;
        inputobj.receivedDate = system.today();
        inputobj = SocialMediaService.createCaseServiceMethod(inputobj);
    }
    
    public static testmethod void testSocialMediaService3(){
    	  Boolean isException = false;
        try{  
            insertEmailAddresses();
            insertSMSetting('', 'all', 'Twitter', '12345678912345555');
            insertQRRecord(); 
          
            String snconsumerid='987654321';
            String snuniqueid='123456789';
            String sntype='Facebook';
            String lastname = 'Bommali';
            String firstname='Ashok';
            String summary='How are you?';
            String website = 'https://www.facebook.com/pgtest1';
            String languagecode = 'en';
            String snmessageid = '123123123';
          
            SocialMediaService.CaseAccountFields  inputobj = new SocialMediaService.CaseAccountFields();
            inputobj.SNConsumerID = snconsumerid;
            inputobj.SNUniqueID = snuniqueid;
            inputobj.SNTYPE = sntype;
            inputobj.lastname = lastname;
            inputobj.firstname = firstname;
            inputobj.summary = summary;
            inputobj.contactWebsite = website;
            inputobj.language= languagecode;
            inputobj.SNMessageID = snmessageid;
            inputobj.receivedDate = system.today();
            inputobj = SocialMediaService.createCaseServiceMethod(inputobj);
        } catch(Exception ex){
                System.debug(ex);
                System.assert(true); //we wanted exception ? 
                isException = true;
        }
        System.assert(isException);
    }
    
    public static testmethod void testSocialMediaService4(){
    	 Boolean isException = false;
        try{  
            insertEmailAddresses();
            insertSMSetting('', 'all', 'Twitter', '12345678912345555');
            insertQRRecord();
      
            String snconsumerid='987654321';
            String snuniqueid='123456789';
            String sntype='Facebook';
            String lastname = 'Bommali';
            String firstname='Ashok';
            String summary='How are you?';
            String website = 'https://www.facebook.com/pgtest1';
            String languagecode = 'en';
            String snmessageid = '123123123';
      
            SocialMediaService.CaseAccountFields  inputobj = new SocialMediaService.CaseAccountFields();
            inputobj.SNConsumerID = snconsumerid;
            inputobj.SNUniqueID = snuniqueid;
            inputobj.SNTYPE = sntype;
            //inputobj.lastname = lastname;
            //inputobj.firstname = firstname;
            inputobj.summary = summary;
            //inputobj.contactWebsite = website;
            inputobj.language= languagecode;
            inputobj.SNMessageID = snmessageid;
            inputobj.receivedDate = system.today();
            inputobj = SocialMediaService.createCaseServiceMethod(inputobj);
        } catch(Exception ex){
            System.debug(ex);
            System.assert(true); //we wanted exception ? 
            isException = true;
        }
        System.assert(isException);
    }
    
    public static testmethod void testSocialMediaService5(){
        try {
            insertEmailAddresses();
            insertSMSetting('Tide', 'en', 'Facebook', '123456789');
            insertQRRecord();  
      
            String snconsumerid='987654321';
            String snuniqueid='123456789';
            String sntype='Facebook';
            String lastname = 'Bommali';
            String firstname='Ashok';
            String summary='How are you?';
            String website = 'https://www.facebook.com/pgtest1';
            String languagecode = 'en';
            String snmessageid = '123123123';
          
            SocialMediaService.CaseAccountFields  inputobj = new SocialMediaService.CaseAccountFields();
            inputobj.SNConsumerID = snconsumerid;
            inputobj.SNUniqueID = snuniqueid;
            inputobj.SNTYPE = sntype;
            inputobj.lastname = lastname;
            inputobj.firstname = firstname;
            inputobj.summary = summary;
            inputobj.contactWebsite = website;
            inputobj.language= languagecode;
            inputobj.SNMessageID = snmessageid;
            inputobj.receivedDate = system.today();
            inputobj = SocialMediaService.createCaseServiceMethod(inputobj);
          
            //Activity call
            String sfdccaseidactivity=inputobj.SFCaseID;
            String activitydescription='internal comments come here...';
          
            SocialMediaService.ActivityFields inputobj2 = new SocialMediaService.ActivityFields();
            inputobj2.SFCaseID = sfdccaseidactivity;
            inputobj2.description = activitydescription;
            inputobj2.SNMessageID = snmessageid;
            inputobj2.receivedDate = system.today();
            inputobj2.isConsumerComment = false;
            inputobj2 = SocialMediaService.createActivityMethod(inputobj2);
            System.assertNotEquals(inputobj2.SFActivityID,null);
        } catch(Exception ex){
            System.debug(ex);
            System.assert(true); //we wanted exception ? 
        }
    } 
}