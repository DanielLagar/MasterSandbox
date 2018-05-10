/*
* @author: Oleg Rikkers
* @date: 06/02/2014

* @description: 
* US495:
*Trigger helper for closed case to copy survey questions to the case field.
*/

public with sharing class sf_CaseClosedTriggerHelper {
	private static Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

	public static void processCases (Map <Id, Case> newMap, Map <Id, Case> oldMap) {
		Map <Id, Case> closedCases = new Map <Id, Case> ();
		for (Case c: newMap.values()) {

			if (c.Status == 'Closed'){
				closedCases.put (c.Id, c);
			}
		}

		//prepare list for surveys
		List <Survey__c> surveys = new List <Survey__c> ();

		//describe metadata for query
		Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Survey__c.fields.getMap();
		List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
		
		//record all fieldsets for specific case for probing questions
		Map <Id, List <String>> caseSurveyFieldsMap = new Map <Id, List <String>> ();

		Set <Id> caseKeys = closedCases.keySet();

		for (Survey__c s: [SELECT Id, Case__c, Survey_Fieldset__c FROM Survey__c WHERE Case__c IN : caseKeys]) {		
			if (!String.isEmpty(s.Survey_Fieldset__c)) {
				if (caseSurveyFieldsMap.get (s.Case__c) == null) {
					caseSurveyFieldsMap.put (s.Case__c, s.Survey_Fieldset__c.split('\\|'));
				} else {
					caseSurveyFieldsMap.get(s.Case__c).addAll(s.Survey_Fieldset__c.split('\\|'));
				}
			}
		}

		System.debug(caseSurveyFieldsMap);

		//describe survey__c
		Schema.DescribeSObjectResult objResult=globalDescribe.get('Survey__c').getDescribe();
			
		//get the fields set map  
	    Map <String, Schema.FieldSet> fieldSetMap= objResult.fieldSets.getMap(); 
	    Map <String, Schema.SObjectField> fieldDescribe = objResult.fields.getMap();

	    //fields that need to be queried
	    Set <String> uniqueFieldsSet = new Set <String> ();

	    for (List <String> sets: caseSurveyFieldsMap.values()) {
	    	for (String s: sets) {
	    		Schema.FieldSet fs = fieldSetMap.get(s);
	    		if (fs != null) {
					for( Schema.FieldSetMember fsm : fs.getFields() ) {
						//add set for field names to avoid dupe questions
						uniqueFieldsSet.add (fsm.getFieldPath());      
		        	}
				} //end if fs not null
	    	} // end for s
	    } //end for sets
	       
	    if (!uniqueFieldsSet.isEmpty()) {
		    	//build query
		    	
		    //add special fields for the code
		    uniqueFieldsSet.add ('Case__c');

			String q = 'SELECT ';

			for(String s : uniqueFieldsSet) {
				q += s + ',';
			}
			
			q = q.removeEnd(',');
			q+= ' FROM Survey__c WHERE Case__c IN :caseKeys';
			q+= ' AND Has_Data__c = true';
			q+= ' AND Survey_Type__c = \'Probing Questions\'';
			surveys = Database.query (q);
	    } else {
	    	surveys = new List <Survey__c> ();
	    }

		Map <Id, String> caseTextMap = new Map <Id, String> ();

		for (Survey__c sur: surveys) {
			String text = 'Probing questions : \n ';

			//unique fields to get
			Set <String> fset = new Set <String> ();
			 
            for (String s: caseSurveyFieldsMap.get(sur.Case__c)) {
                Schema.FieldSet fs = fieldSetMap.get(s);
                if (fs != null) {
                    for( Schema.FieldSetMember fsm : fs.getFields() ) {
                        //add set for field names to avoid dupe questions
                        fset.add (fsm.getFieldPath());      
                    }
                } //end if fs not null
            } // end for s            

			//loop through fields to see if there are values
			for(String s: fset) {
				if (sur.get(s) != null) { //field has value
					text += fielddescribe.get(s).getDescribe().getLabel();
					text += ': ' + sur.get(s);
					text += '\n';
				}	
			}

			caseTextMap.put (sur.Case__c, text);

		}

		//put text values into case
		for (Case c: newMap.values()) {
			if (caseTextMap.get(c.Id) != null) {
				System.debug(caseTextMap.get(c.Id));
				c.Probing_Questions__c = caseTextMap.get(c.Id);
			}
		}
	}
}