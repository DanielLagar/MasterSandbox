/*
* @author: John Casimiro
* @date: 08/15/2014
* @description: After insert after update trigger.
* US607
* @Updates:
    Updated to include before 15-12-2015 christopher.macduff@accenture.com


*/
trigger User on User (before insert, before update, after insert, after update) {
    
    if (Trigger.isBefore){        
        sf_UserTriggerHelper.setMonetaryThreshold(Trigger.new, Trigger.oldMap);
    }
    
    if (Trigger.isAfter){
        
        sf_UserTriggerHelper.relatePublicGroups(Trigger.new);
        
        if (Trigger.isUpdate){            
            sf_UserTriggerHelper.removePublicGroups(Trigger.old, Trigger.new);
        }       
    }
}