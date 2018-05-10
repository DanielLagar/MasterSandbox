/**
* @author: Oleg Rikkers
* @date: 06/02/2014
*
* @description: creates test data for test classes
*
*/

public with sharing class sf_TestDataUtility {
	
	//create global and local products
	public static void setupProducts (Integer size) {
		List <Global_Product__c> gpList = new List <Global_Product__c> ();
		List <Local_Product__c> lpList = new List <Local_Product__c> ();

		for (Integer i = 0; i<size; i++) {
			Global_Product__c gp = new Global_Product__c ();
			gp.Path__c = 'Gp/test/test/test';

			gpList.add (gp);
		}

		if (Test.isRunningTest())
			insert gpList;

		for (Global_Product__c gp: gpList) {
			for (Integer i=0; i<5; i++) {
				Local_Product__c lp = new Local_Product__c ();
				lp.Global_Product__c = gp.Id;
				lp.Country__c = 'United States of America';
				lp.Translated_Path__c = 'Test/Test/Test/Test/' + gp.Id;
				lp.Consumer_Facing__c = true;
				lp.Consumer_Facing_Name__c = 'Test consumer name ' + gp.Id;


				lpList.add(lp);	
			}
		}

		insert lpList;
	}

	public static void setupComments (Integer size) {
		List <Global_Comment_Code__c> gccList = new List <Global_Comment_Code__c> ();
		List <Local_Comment_Code__c> lccList = new List <Local_Comment_Code__c> ();

		for (Integer i = 0; i<size; i++) {
			Global_Comment_Code__c gcc = new Global_Comment_Code__c ();
			gcc.Level_1__c = 'test';
			gcc.Level_2__c = 'test';
			gcc.Level_3__c = 'test';
			
			gccList.add (gcc);
		}

		if (Test.isRunningTest())
			insert gccList;

		for (Global_Comment_Code__c gcc: gccList) {
			for (Integer i=0; i<5; i++) {
				Local_Comment_Code__c lcc = new Local_Comment_Code__c ();
				//lcc.Country__c = 'United States of America';
				lcc.Global_Comment_Code__c = gcc.Id;
				lcc.Translated_Language__c = 'English-US';
				lcc.Criticality__c = 'Super';


				lccList.add(lcc);	
			}
		}

		insert lccList;

	}

	//create user
	public static User createUser (String profileName, String lastName) {
		User user = new User ();
		user.Username = lastName + 'newuser@example.com';
		User.ProfileId = [SELECT ID FROM Profile WHERE Name = :profileName].ID;
		user.LastName = LastName;
		user.Alias = 'nus010';
		user.Email = lastName + '@example.com';
		user.CompanyName = 'TestCompany001001';
		user.EmailEncodingKey = 'ISO-8859-1';
		user.LanguageLocaleKey = 'en_US';
		user.TimeZoneSidKey = 'America/Indiana/Indianapolis';
		user.LocaleSidKey = 'en_US';
		user.Country = 'United States';
		user.IsActive = true;
		return user;

	}

	//create case
	public static Case createCase () {
		Case c = new Case ();
		c.Subject = 'Test subject';
		insert c;
		return c;
	}
   
   public static Contact createContact () {
		Contact con = new Contact();
		con.LastName = 'TestLastName';
		con.FirstName = 'TestFirstName';
		return con;
	}
	
	 public static Attachment createAttachment (Id parentId) {
		Attachment att = new Attachment ();
		att.ParentId = parentId; 
		att.Name = 'skjenkjfnejnfsjkennskjeskjenkjfnejnfsjkennskjeskjenkjfnejnfsjkennskjenkjfnejnfsjkenfjkekjenkjfnejnfsjknfjksenfkjsenfjksenf.pdf';
		att.Body = Blob.valueOf(att.Name);
		return att;
	}
	
	public static Task createTask (Id parentId,Id recTypeId) {
		Task tsk = new Task ();
		tsk.WhatId = parentId; 
		tsk.RecordTypeId = recTypeId;
		tsk.Priority = sf_Constants.PRIORITY_LOW;
		tsk.Subject = 'Test';
		tsk.Status = 'In Progress';
		return tsk;
	}
	
	public static Fulfillment_Order__c createFFOrder(Id caseId){
      Fulfillment_Order__c ffoObj = new Fulfillment_Order__c();
      ffoObj.Case__c = caseId;
      return ffoObj;
   }
   
   public static Fulfillment_Order_Line_Item__c createFFOrderLineItem(Id ffoObjId){
      Fulfillment_Order_Line_Item__c fforderlineItem = new Fulfillment_Order_Line_Item__c();
      fforderlineItem.fulfillment_Order__c = ffoObjId;
      return fforderlineItem;
   }
}