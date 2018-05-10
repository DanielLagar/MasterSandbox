/**
* @author: Archana Sethuraman
* @date: 09/8/2014
* @description: 
*   Helper class for Task Trigger
*/

public class sf_TaskHelper {

    /**
    * @author: Archana Sethuraman
    * @date: 09/8/2014
    * @description: 
    *   When a task related to a case with type CCM activity gets Inserted/updated, update the Reassign Case and Status
    *   fields on case 
    */

    public static void updateCaseFields (List <Task> newTasks, Map <Id,Task> oldTasksMap) {

        Map <Id, Case> casesToUpdateMap = new Map <Id, Case> ();
        
		/*April 2016 christopher.macduff@accenture.com
		 *Need to use a try/catch and a string as occasionally this method is called by a time based
		 *Workflow rule running as the "Automated process user"
		 *This user does not have a profile and the below fails silently
		*/
        String profileName = '';
        try{
            profileName = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()].name;
        }
        catch(queryexception e){
            system.debug('!!! error on querying current user profile: '+e);
        }

        for (Task t: newTasks) {

            Case c = new Case ();

            //ALM 662
            /*christopher.macduff@accenture.com - Mar 2016
             *Ecosystem change - "intake agent request" is being depreciated
             *Added new subject line support. Need to keep "intake agent request" to support crossover period and
			 *if a historical case is updated downstream
			*/

            if((t.Subject == sf_Constants.TASK_SUBJECT_INTAKE || t.Subject == sf_Constants.TASK_SUBJECT_PRODUCT_RETRIEVAL)
               	&& (t.whatId).getSObjectType().getDescribe().getName() == sf_Constants.SOBJECTTYPE_CASE
              	){
            //if (t.Subject == 'Intake Agent Request' && (t.whatId).getSObjectType().getDescribe().getName() == sf_Constants.SOBJECTTYPE_CASE) {
                c.Id = t.WhatId;
                /*ChrisM Comment:
                 *Intake_Agent_Request__c:
                 *ALM 662 - this get's checked when task subject is Intake Agent Request. This way case product will know when to show CCM Retreival Request flag on products added page
				*/
                c.Intake_Agent_Request__c = true;
            } 

            if (t.Follow_up_category__c == sf_Constants.TASK_TYPE_CCM_ACTIVITY 
                && t.WhatId != null
                && (  oldTasksMap == null || oldTasksMap.get(t.Id).Follow_up_category__c != t.Follow_up_category__c)
                && (t.whatId).getSObjectType().getDescribe().getName() == sf_Constants.SOBJECTTYPE_CASE
               	&& t.Originating_System__c != 'SFDC') {
                    
                c.Id = t.WhatId;
                c.Reassign_Case__c = true;
                c.Child_Last_Modified_Date__c = datetime.now(); //ChrisM Ecosystem Spring CR

                system.debug('@@@c.Reassign_Case__c: ' + c.Reassign_Case__c);

                if (t.Follow_Up_Reason__c != sf_Constants.TASK_FOLLOWUP_REASON_AUDIO_LOG_REQUEST) {
                    c.Status = sf_Constants.CASE_STATUS_REOPENED_BY_CCM;
                } else {
                    c.Status = sf_Constants.CASE_STATUS_REOPENED_BY_CCM_SUPERVISOR;
                }   
            }
			
            if (c.Id != null){
                casesToUpdateMap.put(t.WhatId, c);
            }
 
            if(profileName.toLowerCase() != sf_Constants.INTEGRATION_USER_PROFILE_NAME){
                //salesforce.com fix NPE on WhatId 5/18/2015 - add && t.WhatId != null
                if (!checkRecursive.newCase && casesToUpdateMap.get(t.WhatId) == null && t.WhatId != null && (t.whatId).getSObjectType().getDescribe().getName() == sf_Constants.SOBJECTTYPE_CASE) {
                    c.Id = t.WhatId;
                    casesToUpdateMap.put(t.WhatId, c);
                }

                if (casesToUpdateMap.get(t.WhatId) != null){
                    casesToUpdateMap.get(t.WhatId).Child_Last_Modified_Date__c = datetime.now();//ChrisM Test
                }   
            }
        }
        
        if (!casesToUpdateMap.isEmpty()){
            update casesToUpdateMap.values();            
        }
    }

    public static void checkTaskBeforeDelete (List <Task> triggerOld) {
        for (Task t: triggerOld) {
            if (t.whatId.getSObjectType().getDescribe().getName() == sf_Constants.SOBJECTTYPE_CASE) {
                if (!Schema.sObjectType.Case.isDeletable()){
					t.addError ('You are not allowed to delete tasks assigned to the case');                    
                }
            }
        }
    }
}