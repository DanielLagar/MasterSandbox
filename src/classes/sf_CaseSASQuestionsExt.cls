/**
* @author: Oleg Rikkers
* @date: 07/21/2014
* @description:  Case SAS questions
*/

public with sharing class sf_CaseSASQuestionsExt {

	public Map <String, List <Safety_Assessment_Survey__c>> sasMstMap {get; set;}
	public Map <String, String> sasSavedTime {get; set;}
	
	public Map <Id, List <String>> fieldSetNamesSASIdMap {get; set;}
	private Set <String> fieldSetNamesSet;

	public String sasId {get; set;} //holds SAS Id that is being cloned or created new out of
	public String mstId {get; set;}
	
	public Integer pqSize {get; set;} //Holds #of survey records to determine if we should show th SAS first

	private String caseId;

	public sf_CaseSASQuestionsExt(ApexPages.StandardController sc) {
		caseId = sc.getId();
		sasSavedTime = new Map<String, String>();
		pqSize = [SELECT Id FROM Survey__c WHERE Case__c = :caseId].size(); 
		populateSasMstMap ();
	}

	private void populateSasMstMap () {

		fieldSetNamesSet = new Set <String> ();
		fieldSetNamesSASIdMap = new Map <Id, List <String>> ();

		//get all the field sets that are being used so that we can add those to the query
		for (Safety_Assessment_Survey__c sas: [SELECT Id, Survey_Field_Set__c, Number_of_Symptoms__c FROM Safety_Assessment_Survey__c WHERE Case__c = :caseId and Metadata_Survey_Trigger__c != null]) {
			List <String> fsList = new List <String> ();
			if (sas.Survey_Field_Set__c != null) {
				fsList = sas.Survey_Field_Set__c.split('\\|');
			}
			fsList.sort();

			if (sas.Number_of_Symptoms__c == null) {
				sas.Number_of_Symptoms__c = 2;
			}
			
			fieldSetNamesSet.addAll (fsList); 
			fieldSetNamesSASIdMap.put (sas.Id, fsList);
			if(!sasSavedTime.containsKey(sas.Id)){
				sasSavedTime.put(sas.Id, 'None');
			}
		}
		System.debug('***Time: ' + sasSavedTime);


		sasMstMap = new Map <String, List <Safety_Assessment_Survey__c>> ();

		String q = '';
		Set <String> uniqueFieldsSet = new Set <String> ();
		

		for (String s: fieldSetNamesSet) {
			Schema.FieldSet fs = getFieldSetMap().get(s);
			if (fs != null) {
				for( Schema.FieldSetMember fsm : fs.getFields() ) {
					uniqueFieldsSet.add (fsm.getFieldPath()); 
	        	}
			}
		}


		//add system fields in case they were not on the fieldset
		uniqueFieldsSet.add ('Id');
		uniqueFieldsSet.add ('Case__c');
		//uniqueFieldsSet.add ('Changed_By__c');
		//uniqueFieldsSet.add ('Change_Reason__c');
		uniqueFieldsSet.add ('Status__c');
		uniqueFieldsSet.add ('Locked_by_GSSA__c');
		uniqueFieldsSet.add ('Survey_Field_Set__c');
		uniqueFieldsSet.add ('Metadata_Survey_Trigger__c');
		uniqueFieldsSet.add ('Metadata_Survey_Trigger__r.Name');
		uniqueFieldsSet.add ('CreatedDate');
		uniqueFieldsSet.add ('LastModifiedDate');

		//symptoms related 
		uniqueFieldsSet.add ('Symptom_1_Body_Part_Affected__c');
		uniqueFieldsSet.add ('Symptom_2_Body_Part_Affected__c');
		uniqueFieldsSet.add ('Symptom_3_Body_Part_Affected__c');
		uniqueFieldsSet.add ('Symptom_4_Body_Part_Affected__c');
		uniqueFieldsSet.add ('Symptom_5_Body_Part_Affected__c');
		uniqueFieldsSet.add ('Symptom_6_Body_Part_Affected__c');
		uniqueFieldsSet.add ('Symptom_7_Body_Part_Affected__c');
		uniqueFieldsSet.add ('Symptom_8_Body_Part_Affected__c');
		uniqueFieldsSet.add ('Symptom_9_Body_Part_Affected__c');
		uniqueFieldsSet.add ('Symptom_10_Body_Part_Affected__c');

		uniqueFieldsSet.add ('When_did_the_symptom_1_appear__c');
		uniqueFieldsSet.add ('When_did_the_symptom_2_appear__c');
		uniqueFieldsSet.add ('When_did_the_symptom_3_appear__c');
		uniqueFieldsSet.add ('When_did_the_symptom_4_appear__c');
		uniqueFieldsSet.add ('When_did_the_symptom_5_appear__c');
		uniqueFieldsSet.add ('When_did_the_symptom_6_appear__c');
		uniqueFieldsSet.add ('When_did_the_symptom_7_appear__c');
		uniqueFieldsSet.add ('When_did_the_symptom_8_appear__c');
		uniqueFieldsSet.add ('When_did_the_symptom_9_appear__c');
		uniqueFieldsSet.add ('When_did_the_symptom_10_appear__c');


		uniqueFieldsSet.add ('Is_Symptom_1_still_present__c');
		uniqueFieldsSet.add ('Is_Symptom_2_still_present__c');
		uniqueFieldsSet.add ('Is_Symptom_3_still_present__c');
		uniqueFieldsSet.add ('Is_Symptom_4_still_present__c');
		uniqueFieldsSet.add ('Is_Symptom_5_still_present__c');
		uniqueFieldsSet.add ('Is_Symptom_6_still_present__c');
		uniqueFieldsSet.add ('Is_Symptom_7_still_present__c');
		uniqueFieldsSet.add ('Is_Symptom_8_still_present__c');
		uniqueFieldsSet.add ('Is_Symptom_9_still_present__c');
		uniqueFieldsSet.add ('Is_Symptom_10_still_present__c');

		uniqueFieldsSet.add ('When_did_symptom_1_disappear__c');
		uniqueFieldsSet.add ('When_did_symptom_2_disappear__c');
		uniqueFieldsSet.add ('When_did_symptom_3_disappear__c');
		uniqueFieldsSet.add ('When_did_symptom_4_disappear__c');
		uniqueFieldsSet.add ('When_did_symptom_5_disappear__c');
		uniqueFieldsSet.add ('When_did_symptom_6_disappear__c');
		uniqueFieldsSet.add ('When_did_symptom_7_disappear__c');
		uniqueFieldsSet.add ('When_did_symptom_8_disappear__c');
		uniqueFieldsSet.add ('When_did_symptom_9_disappear__c');
		uniqueFieldsSet.add ('When_did_symptom_10_disappear__c');
		uniqueFieldsSet.add ('Number_of_Symptoms__c');

		uniqueFieldsSet.add ('Name');
		q += 'SELECT ';

		for (String s: uniqueFieldsSet) {
			q+= s + ',';
		}

		q = q.removeEnd(',');

		q += ' FROM Safety_Assessment_Survey__c';
		q += ' WHERE Case__c = \'' + caseId + '\' and Metadata_Survey_Trigger__c != null '; 
		q += ' ORDER BY Name';
		q += ' LIMIT 1000'; //just in case
		
		System.debug(LoggingLevel.INFO, 'query string \n' + q);

		List <Safety_Assessment_Survey__c> sasList = (List <Safety_Assessment_Survey__c>) Database.query (q);

		for (Safety_Assessment_Survey__c sas: sasList) {
			if (sasMstMap.get (sas.Metadata_Survey_Trigger__r.Name) == null) {
				sasMstMap.put (sas.Metadata_Survey_Trigger__r.Name, new List <Safety_Assessment_Survey__c> {sas});
			} else {
				sasMstMap.get (sas.Metadata_Survey_Trigger__r.Name).add (sas);
			}
		}
		
	}

	//get the fields set map  
    public Map <String, Schema.FieldSet> getFieldSetMap () {
    	Map <String, Schema.FieldSet> fsMap = Schema.getGlobalDescribe().get('Safety_Assessment_Survey__c').getDescribe().fieldSets.getMap();
    	System.debug(LoggingLevel.INFO, 'fsMap \n' + fsMap);
    	return fsMap;
    }

	private Safety_Assessment_Survey__c getCurrentSas (String mId, String sId) {
		if (sasMstMap.get(mstId) != null) {
			Map <Id, Safety_Assessment_Survey__c>  sasTempMap = new Map <Id, Safety_Assessment_Survey__c> (sasMstMap.get(mstId));
			return sasTempMap.get(sasId);
		} else {
			return new Safety_Assessment_Survey__c();
		}
		
	}


    private void cloneSCP (Id oldSasId, Id newSasId) {
    	
    	List <Survey_Comment_Product__c> scpList = new List <Survey_Comment_Product__c> ([SELECT Id
																								,Case_Product__c
																								,Safety_Assessment_Survey__c
																							FROM Survey_Comment_Product__c 
																							WHERE Safety_Assessment_Survey__c = :oldSasId]);
		if (!scpList.isEmpty()) {
			List <Survey_Comment_Product__c> scpListClone = scpList.deepClone(false, false, false);
			for (Survey_Comment_Product__c scp: scpListClone) {
				scp.Safety_Assessment_Survey__c = newSasId;
			}
			insert scpListClone;
		}
    }

    public PageReference saveAllSas () {

    	try {

    		Safety_Assessment_Survey__c sas = getCurrentSas(mstId, sasId);
    		sas.Survey_Completed__c = true; 
    		update sas;
    		
    		//ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.INFO, 'Current record has been updated!'));
    		populateSasMstMap ();
    		DateTime lastSaved = System.now();
    		TimeZone tz = UserInfo.getTimeZone();
			//lastSaved = lastSaved.AddSeconds(tz.getOffset(lastSaved)/1000);
    		sasSavedTime.put(sas.Id, lastSaved.format('h:mm:ss a'));
    		
		} catch (Exception e) {
			System.debug(e);
			ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, e.getMessage()));
		}

    	return null;
    }



    public PageReference cloneSAS (){
    	try {

    		update getCurrentSas(mstId, sasId);
    		Safety_Assessment_Survey__c sas = getCurrentSas(mstId, sasId);
    		Safety_Assessment_Survey__c newSas = sas.clone(false, true, false, false);
    		insert newSas;
    		cloneSCP(sas.Id, newSas.Id);	
    		populateSasMstMap();
    		//ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.INFO, 'Cloned!'));

		} catch (Exception e) {
			System.debug(e);
			ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, e.getMessage()));
		}
    	return null;
    }

    public PageReference deleteSAS() {
    	try {
    		delete [select id from Safety_Assessment_Survey__c WHERE id = :sasId];
    		if (sasMstMap.get(mstId) == null) sasMstMap.remove(mstId);
    		
    		populateSasMstMap();
    	} catch (Exception e) {
			System.debug(e);
			ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, e.getMessage()));
		}
    	return null;
    }
    
    public PageReference addSymptom (){
    	Safety_Assessment_Survey__c sas = getCurrentSas(mstId, sasId);
    	try {
    		if (sas.Number_of_Symptoms__c < 10) {
    			sas.Number_of_Symptoms__c++;
    		} else {
				ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, 'Maximum of 10 symptoms. Cannot add a symptom.'));
    		}
    	} catch (Exception e) {
			System.debug(e);
			ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, e.getMessage()));
		}
		return null;
    }
     public PageReference removeSymptom (){
     	Safety_Assessment_Survey__c sas = getCurrentSas(mstId, sasId);
    	try {
    		if (sas.Number_of_Symptoms__c > 2) {
    			sas.Number_of_Symptoms__c --;

    		} else {
				ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, 'Minimum of 2 symptoms. Cannot remove a symptom.'));
    		}
    	} catch (Exception e) {
			System.debug(e);
			ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, e.getMessage()));
		}
		return null;
    }   
    public PageReference createNewSas (){
    	try {

    		//update getCurrentSas(mstId, sasId);
    		Safety_Assessment_Survey__c sas = getCurrentSas(mstId, sasId);
    		Safety_Assessment_Survey__c newSas = new Safety_Assessment_Survey__c ();
    		newSas.Metadata_Survey_Trigger__c = sas.Metadata_Survey_Trigger__c;
    		newSas.Case__c = sas.Case__c;
    		insert newSas;
    		cloneSCP(sas.Id, newSas.Id);
    		populateSasMstMap();
    		//ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.INFO, 'Created New!'));

		} catch (Exception e) {
			System.debug(e);
			ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, e.getMessage()));
		}
    	return null;
    }

    public Map <String, List <Survey_Comment_Product__c>> getSurveyProducts () {
    	Map <String, List <Survey_Comment_Product__c>> surveyProductMap = new Map <String, List <Survey_Comment_Product__c>> ();

    	for (Safety_Assessment_Survey__c sas: [Select Id, 
    												(SELECT Id
    												,Safety_Assessment_Survey__c
    												,Translated_Path__c 
    												,Main_Image__c
    												,Case_Product__r.Local_Product__r.GTIN_Number__c
    												,Case_Product__r.Status__c
    												,Case_Product__r.ProductStatus__c
    											FROM Survey_Comment_Products__r)
    											FROM Safety_Assessment_Survey__c
    											WHERE Case__c = :caseId and Metadata_Survey_Trigger__c != null]) {
    		surveyProductMap.put (sas.Id, sas.Survey_Comment_Products__r);
    	}
    	return surveyProductMap;
    }
    //post go live user story to delete SCP after association
    public String scpIdToDelete {get; set;}
    public PageReference deleteScp () {
    	//ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.Info, 'scp id ' + scpIdToDelete));
    	delete [SELECT Id FROM Survey_Comment_Product__c WHERE Id = :scpIdToDelete];
    	return null;
    }

    public class SurveyProductWrapper {
    	public Case_Product__c cp {get; set;}
    	public Boolean isAssociated {get; set;}

    	public SurveyProductWrapper (Case_Product__c cp, Boolean isAssociated) {
    		this.cp = cp;
    		this.isAssociated = isAssociated;
    	}

    }
}