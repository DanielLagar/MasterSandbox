public with sharing class sf_InternalActivityTriggerHandler {

	public void onBeforeUpdate(List<Internal_Activity__c> newInternalActivities, List<Internal_Activity__c> oldInternalActivities, Map<Id, Internal_Activity__c> newMap, Map<Id, Internal_Activity__c> oldMap){
	
		changeAssignedTo(newInternalActivities, oldInternalActivities, newMap, oldMap);
		
	}
	
	public void onAfterInsert(List<Internal_Activity__c> newInternalActivities){
	
		createReminder(newInternalActivities);
	
	}
	
	public void changeAssignedTo(List<Internal_Activity__c> newInternalActivities, List<Internal_Activity__c> oldInternalActivities, Map<Id, Internal_Activity__c> newMap, Map<Id, Internal_Activity__c> oldMap){
		
		for(Internal_Activity__c ia: newInternalActivities){
			if((ia.Type__c == sf_Constants.INTERNAL_ACTIVITY_TYPE_KNOWLEDGE_MISSING_INCOMPLETE_KNOWLEDGE 
	        	|| ia.Type__c== sf_Constants.INTERNAL_ACTIVITY_TYPE_KNOWLEDGE_INCREASE_IN_TRENDS
	        	|| ia.Type__c== sf_Constants.INTERNAL_ACTIVITY_TYPE_KNOWLEDGE_SERVICES) 
	        	&& ia.Assessment_Close_Date__c != null &&  ia.Assessment_Open_Date__c != null){
	        	
	            if((ia.Assessment_Close_Date__c.getTime() - ia.Assessment_Open_Date__c.getTime()) <7*24*60*60*1000){
	                ia.Assessment_SLA_Flag__c = sf_Constants.INTERNAL_ACTIVITY_SLA_FLAG_GREEN;
	            } else {
	            	ia.Assessment_SLA_Flag__c = sf_Constants.INTERNAL_ACTIVITY_SLA_FLAG_RED;
	            }     
	            	
	            
	            if(ia.Type__c == sf_Constants.INTERNAL_ACTIVITY_TYPE_KNOWLEDGE_MISSING_INCOMPLETE_KNOWLEDGE 
	            	&& oldMap.get(ia.Id).Assessment_Close_Date__c != newMap.get(ia.Id).Assessment_Close_Date__c){
	                	Internal_Activity__c temp=[Select createdbyid from internal_Activity__c where id=:ia.Id];
	                	ia.ownerid = temp.createdbyid;
	                	List<User> u = [select id, name from User where Id = :temp.createdbyid];
	                	if(u.size() > 0) ia.Assigned_To__c = u[0].name;
	            }
	        }
	    }
	}
	
	public void createReminder(List<Internal_Activity__c> newInternalActivities){
	
		List<Task> taskList=new List<Task>();
	    for(Internal_Activity__c ia: newInternalActivities)
	    {
	        if(ia.Reminder__c == true && ia.Reminder_Date__c != null)
	        {
	            Task task = new Task();
	            task.whatId = ia.Id;
	            task.subject = ia.subject__c;
	            task.ActivityDate = date.valueOf(ia.Due_date__c);
	            task.ReminderDateTime = ia.Reminder_Date__c;
	            task.IsReminderSet = true;
	            taskList.add(task);
	        }
	    }
	    
	    if(taskList.size()>0)
	    insert taskList;
	
	}
}