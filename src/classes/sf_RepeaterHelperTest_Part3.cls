@isTest
public class sf_RepeaterHelperTest_Part3 {
    private static String SUSPECTED = 'Suspected Repeater';
    private static String FRAUDULENT = 'Fraudulent Case';
    private static String USA = 'United States of America';
    private static String CLOSED = 'Closed';
    private static String AE = 'Adverse Event';
    private static String line1 = '1a First Street';
    
    public static Id lpId;
    public static Id lcId;
	
    @testSetup static void setupData(){
        List<Account> accsToInsert = new List<Account>();
        List<Contact> consToInsert = new List<Contact>();
        List<Case> casesToInsert = new List<Case>();
        
        List<Global_Product__c> gpsToInsert = new List<Global_Product__c>();
        List<Local_Product__c> lpsToInsert = new List<Local_Product__c>();
        List<Case_Product__c> cpsToInsert = new List<Case_Product__c>();
        
        List<Global_Comment_Code__c> gccsToInsert = new List<Global_Comment_Code__c>();
        List<Local_Comment_Code__c> lccsToInsert = new List<Local_Comment_Code__c>();
        List<Case_Comment_Code__c> cccsToInsert = new List<Case_Comment_Code__c>();
        
        Repeater_Threshold__c rt = new Repeater_Threshold__c(
            name=USA,
            Threshold_Period__c=30,
            Case_Count_Threshold__c=4,
            Reimbursement_Value_Threshold__c=50.00
        );
        insert rt;
        
        Global_Comment_Code__c utGCC = new Global_Comment_Code__c(
            Level_1__c = AE
        );
        gccsToInsert.add(utGCC);
        insert utGCC;
        
        Local_Comment_Code__c utLCC = new Local_Comment_Code__c(
            Criticality__c = 'AE',
            Level_1__c = AE,
            Level_2__c = AE,
            Level_3__c = 'Accidental ingestion or exposure to product by child',
			Global_Comment_Code__c = utGCC.Id
        );
        lccsToInsert.add(utLCC);
        insert utLCC;
        
        lcId = utLCC.Id;
 
		Global_Product__c utGP = new Global_Product__c(
            Consumer_Facing_Brand__c = 'UT GP Brand',
            Consumer_Facing_Name__c = 'UT GP Brand'
        );
        gpsToInsert.add(utGP);
        insert gpsToInsert;
        
        Local_Product__c utLP = new Local_Product__c(
            Global_Product__c = utGP.Id,
            Brand__c = 'UT Brand',
            Consumer_Facing_Brand__c = '',
			Country__c = USA
        );
        lpsToInsert.add(utLP);
        insert lpsToInsert;
        
        lpId = utLP.Id;

		Account utAccount = New Account(
			name = 'UnitTest Account', 
			Address_Line_1__c = line1,
			City__c = 'City',
			State_Province__c = 'XX',
			Postal_Code__c = '11111', 
			Country__c = USA
        );
        accsToInsert.add(utAccount);
        Insert accsToInsert;
        
        Contact utContact = new Contact(
            FirstName = 'ConFirstName',
            LastName = 'ConLastName',
            AccountId = utAccount.Id,
			Primary_Address_Line_1__c = line1,
			Primary_City__c = 'City',
			Primary_State_Province__c = 'XX',
			Primary_Postal_Code__c = '11111', 
			Primary_Country__c = USA            
        );
        consToInsert.add(utContact);
        Insert consToInsert;
        
        //////////////////
        //Case/s setup	//
        //////////////////

        //Create 4 AE Cases initially
		for(integer i=0; i<4; i++){
            casesToInsert.add(new Case(ContactId = utContact.Id, Subject = 'UT Test Case'+i));
        }
		insert casesToInsert;
            
        for(Case c : casesToInsert){
            cpsToInsert.add(new Case_Product__c(Case__c = c.Id,Local_Product__c = utLP.Id));
        }
		insert cpsToInsert;

        for(Case_Product__c cp : cpsToInsert){
            cccsToInsert.add(new Case_Comment_Code__c(Case__c = cp.Case__c,Case_Product__c = cp.Id,Comment_Code_Type__c = 'Adverse Event', Status__c = 'Active', Local_Comment_Code__c = utLCC.Id));
        }
        insert cccsToInsert;
    }
    
	@isTest
    static void setSuspectedTest(){
        Contact repeaterCon = [SELECT Id, AccountId, Repeater_Status__c FROM Contact LIMIT 1];
        
        Integer caseCount = [SELECT Count() FROM Case WHERE ContactId = :repeaterCon.Id];
        Case fourthCase = [SELECT Id, AccountId,Repeater_Case__c FROM Case WHERE ContactId = :repeaterCon.Id AND Status = 'Open' LIMIT 1];
        Account repeaterAcc = [SELECT Id, Repeater_Status__c FROM Account WHERE Id = :repeaterCon.AccountId];
        List<Case> casesToClose = [SELECT Id FROM Case WHERE ContactId = :repeaterCon.Id];
        
        //Assert repeater status values have not been set yet
        system.assertEquals(4, caseCount);
        system.assertEquals(null, fourthCase.Repeater_Case__c);
		system.assertEquals(null, repeaterAcc.repeater_Status__c);
		system.assertEquals(null, repeaterCon.repeater_Status__c);
        
		test.startTest();

            for(Case c : casesToClose){
            	c.status = 'Closed'; 
            }
        	update casesToClose;
        
        	repeaterAcc = [SELECT Id, Repeater_Status__c FROM Account WHERE Id = :repeaterAcc.Id];
        	system.assertEquals(SUSPECTED, repeaterAcc.repeater_Status__c);
        
        	repeaterCon = [SELECT Id, Repeater_Status__c FROM Contact WHERE Id = :repeaterCon.Id];
        	system.assertEquals(SUSPECTED, repeaterCon.repeater_Status__c);
        
        test.stopTest();
    }
}