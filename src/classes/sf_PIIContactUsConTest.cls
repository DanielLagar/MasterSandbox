/*
* @author: Archana Sethuraman
* @date: 08/19/2014
* @description: Test class for sf_PIIContactUsCon. 
  Class migrated from Prod org
*/
@isTest
private class sf_PIIContactUsConTest
{
    public static testmethod void testPIIContactUsCon(){
      PIISitespageSettings__c piiobject = insertData('FirstName; LastName; Email; AddressLine1; AddressLine2; City; State; Country; Postal/ZipCode; Telephone',false);
      
      piiobject = [ 
      	select 
      		PII_URL__c 
      	from 
      		PIISitespageSettings__c 
      	where 
      		Id=:piiobject.Id][0];
      PageReference rf2 = new PageReference(piiobject.PII_URL__c);
      test.setCurrentPage(rf2);
	  rf2.getParameters().put('withDPR', 'False');
      sf_PIIContactUsCon piicon=new sf_PIIContactUsCon();
      piicon.personYear = '1900';
      piicon.salutation = 'Mr';
      piicon.piisettingsobj.conWrapper.firstName = 'Test';
      piicon.piisettingsobj.conWrapper.lastName = 'Test';
      piicon.piisettingsobj.conWrapper.email = 'Test@pg.com';
      piicon.piisettingsobj.conWrapper.address1 = 'Test';
      piicon.piisettingsobj.conWrapper.address2 = 'Test';
      piicon.piisettingsobj.conWrapper.city = 'Test'; 
      piicon.piisettingsobj.conWrapper.state = 'Test';
      piicon.piisettingsobj.conWrapper.postalcode = 'Test';
      piicon.piisettingsobj.conWrapper.country = 'United States of America';  //required due to custom settings list
      piicon.piisettingsobj.conWrapper.phone = 'Test';
      piicon.isActive=true;
      Boolean activeparam = piicon.isActive;
      
      PageReference save = piicon.submit();
      System.assertNotEquals(save,null);
      
      PageReference nextPage = Page.sf_PIIThankyou;
      nextPage.getParameters().put('cn',piicon.piisettingsobj.newCase.CaseNumber);
        nextPage.getParameters().put('lang',piicon.piisettingsobj.language);
      System.debug(save.getUrl());
      //System.assertEquals(save.getUrl(),nextPage.getUrl());
      
      List<SelectOption> yearList = piicon.getYearList();
      Integer currentYear = Date.today().year();
      Integer totalNoOfYears = currentYEar-sf_Constants.BEGINNING_YEAR;
      System.assertEquals(yearList.size(),totalNoOfYears+1);
      
      List<SelectOption> countries = piicon.getCountries();
      System.assertNotEquals(countries,null);
    }
    
    public static testmethod void testPIIContactUsCon2(){
      PIISitespageSettings__c piiobject = insertData('LastName',true);
      
      piiobject = [
      	select 
      		PII_URL__c 
      	from 
      		PIISitespageSettings__c 
      	where 
      		Id =: piiobject.Id][0];
      PageReference rf2 = new PageReference(piiobject.PII_URL__c);
      test.setCurrentPage(rf2);
	  rf2.getParameters().put('withDPR', 'False');
      sf_PIIContactUsCon piicon = new sf_PIIContactUsCon();
      piicon.personYear = '1900';
      piicon.salutation = 'Mr';
      piicon.piisettingsobj.conWrapper.firstName = 'Test';
      piicon.piisettingsobj.conWrapper.lastName = 'Test';
      piicon.piisettingsobj.conWrapper.email = 'Test@pg.com';
      piicon.piisettingsobj.conWrapper.Title = 'test';
      piicon.piisettingsobj.conWrapper.address1 = 'Test';
      piicon.piisettingsobj.conWrapper.address2 = 'Test';
      piicon.piisettingsobj.conWrapper.city = 'Test';
      piicon.piisettingsobj.conWrapper.state = 'Test';
      piicon.piisettingsobj.conWrapper.postalcode = 'Test';
      piicon.piisettingsobj.conWrapper.country = 'United States of America'; //required due to custom settings list
      piicon.piisettingsobj.conWrapper.phone = 'Test';
      Boolean activeparam = piicon.isActive;
      System.assert(activeParam);
      System.assert(piicon.piisettingsobj.isContactExisted);
      piicon.submit();
    }
    
    public static testmethod void testPIIContactUsCon3(){
      PIISitespageSettings__c piiobject=insertData('FirstName; LastName; Title;Email; AddressLine1; AddressLine2; City; State; Country; Postal/ZipCode; Telephone',false);
      
      piiobject = [
      	select 
      		PII_URL__c 
      	from 
      		PIISitespageSettings__c 
      	where 
      		Id =: piiobject.Id][0];
      PageReference rf2 = new PageReference(piiobject.PII_URL__c);
      test.setCurrentPage(rf2);
      rf2.getParameters().put('withDPR', 'False');
      sf_PIIContactUsCon piicon = new sf_PIIContactUsCon();
      piicon.personYear = '1900';
      piicon.piisettingsobj.conWrapper.firstName = 'Test';
      piicon.piisettingsobj.conWrapper.lastName = 'Test';
      piicon.piisettingsobj.conWrapper.email = 'Test@pg.com';
      piicon.piisettingsobj.conWrapper.Title = 'test';
      piicon.piisettingsobj.conWrapper.address1 = 'Test';
      piicon.piisettingsobj.conWrapper.address2 = 'Test';
      piicon.piisettingsobj.conWrapper.city = 'Test';
      piicon.piisettingsobj.conWrapper.state = 'Test';
      piicon.piisettingsobj.conWrapper.postalcode = 'Test';
      piicon.piisettingsobj.conWrapper.country = 'United States of America'; //required due to custom settings list
      piicon.piisettingsobj.conWrapper.phone = 'Test';
      System.assertNotEquals(piicon.piisettingsobj.isContactExisted,true);
      PageReference nextpge = piicon.submit();
      System.assertNotEquals(nextpge,null);
      Case[] c = [
        SELECT contactId
      	FROM Case
      	WHERE CaseNumber =: nextpge.getParameters().get('cn')];
      System.assertNotEquals(c,null);
      //System.assertNotEquals(c.contactId,null);
    }
    
    public static testmethod void testPIIContactUsCon4(){
      PIISitespageSettings__c piiobject=insertData('FirstName; LastName; Email; AddressLine1; AddressLine2; City; State; Country; Postal/ZipCode; Telephone',false);
      
      piiobject.isActive__c = false;
      update piiobject;
      
      piiobject = [ 
      	select 
      		PII_URL__c 
      	from 
      		PIISitespageSettings__c 
      	where 
      		Id =: piiobject.Id][0];
      PageReference rf2 = new PageReference(piiobject.PII_URL__c);
      test.setCurrentPage(rf2);
      rf2.getParameters().put('withDPR', 'False');
      sf_PIIContactUsCon piicon = new sf_PIIContactUsCon();
      System.assertEquals(ApexPages.getMessages().size(),1);
      piicon.submit();
    }

    public static testmethod void testPIIContactUsCon5(){
      PIISitespageSettings__c piiobject = insertData('LastName',true);
      
      piiobject = [
        select 
          PII_URL__c 
        from 
          PIISitespageSettings__c 
        where 
          Id =: piiobject.Id][0];
      PageReference rf2 = new PageReference(piiobject.PII_URL__c);
      test.setCurrentPage(rf2);
      rf2.getParameters().put('withDPR', 'False');
      sf_PIIContactUsCon piicon = new sf_PIIContactUsCon();
      piicon.personYear = '1900';
      piicon.salutation = 'Mr';
      piicon.piisettingsobj.conWrapper.firstName = 'Test';
      piicon.piisettingsobj.conWrapper.lastName = 'Test';
      piicon.piisettingsobj.conWrapper.email = 'Test@pg.com';
      piicon.piisettingsobj.conWrapper.Title = 'test';
      piicon.piisettingsobj.conWrapper.address1 = 'Test';
      piicon.piisettingsobj.conWrapper.address2 = 'Test';
      piicon.piisettingsobj.conWrapper.city = 'Test';
      piicon.piisettingsobj.conWrapper.state = '';
      piicon.piisettingsobj.conWrapper.postalcode = '';
      piicon.piisettingsobj.conWrapper.country = 'Canada'; //required due to custom settings list
      piicon.piisettingsobj.conWrapper.phone = 'Test';
      Boolean activeparam = piicon.isActive;
      System.assert(activeParam);
      System.assert(piicon.piisettingsobj.isContactExisted);
      piicon.submit();
    }
    
    //WR120
    public static testmethod void testPIIContactUsCon6(){
		Country_Region_SMO__c smo = new Country_Region_SMO__c();
        smo.Name = 'UNITED STATES OF AMERICA';
        smo.Currency_Name__c = 'USD';
        smo.Region__c = 'TestRegion';
        smo.SMO__c = 'TestSMO';
        insert smo;

		Case caseobj = new Case();
		caseobj.Country__c = 'United States of America';
		caseObj.Language__c = 'English-US';
		caseObj.Brand__c = 'Tide';
		caseObj.Segment__c = 'Unknown';
		insert caseObj;

		PIISitespageSettings__c piiobject = new PIISitespageSettings__c();
		piiobject.IsActive__c = true;
		piiobject.Case_Id__c = caseobj.Id;
		piiobject.Fields__c = 'FirstName; LastName; Email; AddressLine1; AddressLine2; City; State; Country; Postal/ZipCode; Telephone';
		insert piiobject;
        
		piiobject = [SELECT PII_URL__c FROM PIISitespageSettings__c WHERE Id =: piiobject.Id];
        PageReference rf2 = new PageReference(piiobject.PII_URL__c);
        test.setCurrentPage(rf2);
        rf2.getParameters().put('withDPR', 'False');
        
        test.startTest();
            sf_PIIContactUsCon ctr = new sf_PIIContactUsCon();
        	ctr.submit();
            ctr.save();       
        test.stopTest(); 
    }
    
	//No sid param passed
    public static testmethod void noSIDTest(){
         test.startTest();
            sf_PIIContactUsCon ctr = new sf_PIIContactUsCon();
        	System.assertEquals(ApexPages.getMessages().size(),1);
        test.stopTest();       
    }
    
    //ICCS R2 coverage
    public static testmethod void existingConSaveTest(){
        String conFirstName = 'Leisure Suit';
        String conLastName = 'Larry';
        String conEmail = 'piiexistingcon@larry.net';
        Contact con = new Contact(
            firstName = conFirstName,
            lastName = conLastName,
            email = conEmail
        );
        insert con;
        
		Country_Region_SMO__c smo = new Country_Region_SMO__c();
        smo.Name = 'UNITED STATES OF AMERICA';
        smo.Currency_Name__c = 'USD';
        smo.Region__c = 'TestRegion';
        smo.SMO__c = 'TestSMO';
        insert smo;

		Case caseobj = new Case();
		caseobj.Country__c = 'United States of America';
		caseObj.Language__c = 'English-US';
		caseObj.Brand__c = 'Tide';
		caseObj.Segment__c = 'Unknown';
		insert caseObj;

		PIISitespageSettings__c piiobject = new PIISitespageSettings__c();
		piiobject.IsActive__c = true;
		piiobject.Case_Id__c = caseobj.Id;
		piiobject.Fields__c = 'FirstName; LastName; Email; AddressLine1; AddressLine2; City; State; Country; Postal/ZipCode; Telephone';
		insert piiobject;
        
		piiobject = [SELECT PII_URL__c FROM PIISitespageSettings__c WHERE Id =: piiobject.Id];
        PageReference rf2 = new PageReference(piiobject.PII_URL__c);
        test.setCurrentPage(rf2);
        rf2.getParameters().put('withDPR', 'False');
        
        test.startTest();
			sf_PIIContactUsCon ctr = new sf_PIIContactUsCon();
            /*
			con = util.getContactByFNameLNameEmail(piisettingsobj.conWrapper.contactObject.firstName, 
			piisettingsobj.conWrapper.contactObject.lastName, piisettingsobj.conWrapper.contactObject.Email);
            */
        	//Set Contact fields to matching existing
        	ctr.piisettingsobj.conWrapper.contactObject.firstName = conFirstName;
        	ctr.piisettingsobj.conWrapper.contactObject.lastName = conLastName;
        	ctr.piisettingsobj.conWrapper.contactObject.Email = conEmail;
        	//Submit+save
        	ctr.submit();
            ctr.save(); 
        test.stopTest();
        //Assert Case has been updated to use the existing ConId.
        caseobj = [SELECT Id, ContactId FROM Case WHERE Id = :caseobj.Id];
        system.assertEquals(Con.Id, caseobj.ContactId);
    }    
    
    //CR16
    public static testmethod void dprPIITest(){
		//Create Case/Product data
		checkrecursive.toggleAllTriggers(false);
        AutoComRuleHelper_datasetup_Test.dataSetup();
        checkrecursive.toggleAllTriggers(true);
        
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Digital'];
        Case_Product__c testCP = [SELECT Id, Digital_Return_Id__c FROM Case_Product__c  WHERE Case__c = :testCase.Id];
        
		PIISitespageSettings__c piiobject = new PIISitespageSettings__c();
		piiobject.IsActive__c = true;
		piiobject.Case_Id__c = testCase.Id;
		piiobject.Fields__c = 'FirstName; LastName; Email; AddressLine1; AddressLine2; City; State; Country; Postal/ZipCode; Telephone';
		piiobject.Include_DPR_Form__c = True;
        piiobject.DPR_UID__c = testCP.Digital_Return_Id__c;
		insert piiobject;
        
        piiobject = [SELECT Id, PII_URL__c, DPR_UID__c FROM PIISitespageSettings__c WHERE Id =:piiobject.Id];
        system.assertEquals(testCP.Digital_Return_Id__c, piiobject.DPR_UID__c);
        
		PageReference rf2 = new PageReference(piiobject.PII_URL__c);
        test.setCurrentPage(rf2);
		rf2.getParameters().put('withDPR', 'True');
        
        test.startTest();
        	sf_PIIContactUsCon ctr = new sf_PIIContactUsCon();
        
              ctr.personYear = '1900';
              ctr.salutation = 'Mr';
              ctr.piisettingsobj.conWrapper.firstName = 'Test';
              ctr.piisettingsobj.conWrapper.lastName = 'Test';
              ctr.piisettingsobj.conWrapper.email = 'Test@pg.com';
              ctr.piisettingsobj.conWrapper.address1 = 'Test';
              ctr.piisettingsobj.conWrapper.address2 = 'Test';
              ctr.piisettingsobj.conWrapper.city = 'Test'; 
              ctr.piisettingsobj.conWrapper.state = 'Test';
              ctr.piisettingsobj.conWrapper.postalcode = 'Test';
              ctr.piisettingsobj.conWrapper.country = 'United States of America';  //required due to custom settings list
              ctr.piisettingsobj.conWrapper.phone = 'Test';
        
			system.assertEquals(True, ctr.isDPRVisible); 
        	system.assertEquals(testCP.Digital_Return_Id__c, ctr.dprUID);
        
        	ctr.Submit();
        	testCase = [SELECT Id, Product_Return_Status__c FROM Case WHERE Id = :testCase.Id];
			testCP = [SELECT Id, Status__c FROM Case_Product__c  WHERE Id = :testCP.Id];
        	system.assertEquals('Photo Received', testCase.Product_Return_Status__c);
			system.assertEquals('Photo Received', testCP.Status__c);
        	
			ctr.partialUploadErr();
        test.stopTest();     
    }
    
    public static PIISitespageSettings__c insertData(string piifields, boolean createContact){
      Contact con;
      if ( createContact ){
        con = new Contact();
        con.Firstname = 'Test';
        con.LastName = 'Test';
        con.Email = 'Test@pg.com';
        insert con;
      }
      
      Case caseobj = new Case();
      caseobj.Country__c = 'United States of America';
      caseObj.Language__c = 'English-US';
      caseObj.Brand__c = 'Tide';
      caseObj.Segment__c = 'Unknown';
      if ( createContact )
      	caseObj.contactID = con.Id;
      insert caseObj;
      
      PIISitespageSettings__c piiobject = new PIISitespageSettings__c();
      piiobject.IsActive__c = true;
      piiobject.Case_Id__c = caseobj.Id;
      piiobject.Fields__c = piifields;
      insert piiobject;
      
      return piiobject;
    }
    
}