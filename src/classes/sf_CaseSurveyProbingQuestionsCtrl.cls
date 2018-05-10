/**
* @author: Oleg Rikkers
* @date: 06/02/2014
*
* @description: 
* US495:
* Based on all the product segment/comment matches, there will be potentially multiple surveys that need to be answered. 
* This page will combine all survey questions of the same Type (probing/ adhoc) into 1 page.
* AC#2: since we are combining all surveys and storing all answers on this page, 
* if they add another comment code which has additional information capture. it will just be added to the page. 
* All previously entered information should be displayed as well.
*/

public with sharing class sf_CaseSurveyProbingQuestionsCtrl {
	
	public Map <String, List <String>> uniqueFieldsSet {get; set;}
	public String lastSavedTime {get; set;}

	public String caseId {get; private set;}
	public List <Survey__c> surveys {get; set;}

	public sf_CaseSurveyProbingQuestionsCtrl(ApexPages.StandardController sc) {
		lastSavedTime = '';
		try {
			surveys = new List <Survey__c> ();
			caseId = sc.getId();
			
			List <Survey__c> slist = [SELECT Id, Survey_Fieldset__c, Has_Data__c, Survey_Type__c FROM Survey__c WHERE Case__c =:caseId];
			
			
			uniqueFieldsSet = new Map <String, List <String>> ();

			for (Survey__c s: slist) {

		    	for (String fString: s.Survey_Fieldset__c.split('\\|')) {
		    		Schema.FieldSet fs = getFieldSetMap().get(fString);   

					if (fs != null) {
						for( Schema.FieldSetMember fsm : fs.getFields() ) {

							if (uniqueFieldsSet.get(s.Survey_Type__c) == null) {
								uniqueFieldsSet.put (s.Survey_Type__c, new List <String> {fsm.getFieldPath()});
							} else {
								//add set for field names to avoid dupe questions
								Set <String> tempSet = new Set <String> ();
								tempSet.addAll(uniqueFieldsSet.get(s.Survey_Type__c));
								tempSet.add(fsm.getFieldPath());
								List <String> tempList = new List <String> (tempSet);
								tempList.sort();
								uniqueFieldsSet.put(s.Survey_Type__c, tempList);
							}  
			        	}
					}
		    	}
		    }

		    //need to query all fields in the dataset so that we can get values
		    String q = 'SELECT Id,';
		    Set <String> allFieldsSet = new Set <String> ();

		    for (List <String> fieldSet : uniqueFieldsSet.values()) {
		    	allFieldsSet.addAll (fieldSet);
		    }


		    //additional fields needed for code
		    allFieldsSet.add ('Survey_Type__c');
		    allFieldsSet.add ('Has_Data__c');
		    allFieldsSet.add ('Survey_Fieldset__c');

			for (String s: allFieldsSet) {
	    		q+= s+ ',';
	    	}


		    q = q.removeEnd(',');
		    q+= ' FROM Survey__c WHERE Case__c =:caseId';

		    sList = Database.query (q);


		    //let's figure out unique survey types needed
			Map <String, Survey__c> surveyTypeMap = new Map <String, Survey__c> ();

		    for (Survey__c s: slist) {
		    	if (surveyTypeMap.get(s.Survey_Type__c) == null
					|| !surveyTypeMap.get(s.Survey_Type__c).Has_Data__c ) {
					surveyTypeMap.put (s.Survey_Type__c, s);	
				}
		    }

		    //flag those surveys as have data
		    for (Survey__c s: surveyTypeMap.values()) {
		    	s.Has_Data__c = true;
		    }

		    surveys.addAll (surveyTypeMap.values());
		    
	    } catch (Exception e) {
	    	ApexPages.addMessages (e);
	    }
	}

	public PageReference saveQuestions () {
		
		
		//ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.WARNING, 'This is a warning.'));
		//ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, 'Something bad happened. This is an error!'));
		
		try {

			for (Survey__c sur: surveys) {
				sur.Status__c = 'Complete';
			}

			update surveys;
			
			DateTime lastSaved = System.now();
    		TimeZone tz = UserInfo.getTimeZone();
			//lastSaved = lastSaved.AddSeconds(tz.getOffset(lastSaved)/1000);
    		lastSavedTime = lastSaved.format('h:mm:ss a');
			
			//ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.INFO, 'Surveys Saved.'));
		} catch (Exception e) {
			ApexPages.addMessages (e);
		}
		return null;
	}

    //get the fields set map  
    public Map <String, Schema.FieldSet> getFieldSetMap () {
    	Map <String, Schema.FieldSet> fsMap = Schema.getGlobalDescribe().get('Survey__c').getDescribe().fieldSets.getMap();
    	System.debug(LoggingLevel.INFO, 'fsMap \n' + fsMap);
    	return fsMap;
    }

}