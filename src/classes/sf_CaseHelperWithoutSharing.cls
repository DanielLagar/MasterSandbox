/*Without sharing to allow Guest site users
 *to create tasks against Cases they don't own/see
 *christopher.macduff@accenture.com 19th Nov 2015
*/
public without sharing class sf_CaseHelperWithoutSharing {
    /**
    * @author: Ian Barker
    * @date: 9/18/2015
    *
    * @description: Creates activity record to record the transfer of ownership on a case between users and/or groups. Integration Users are ignored.
    *
    * @changes:
    * Moved to sf_CaseHelperWITHOUT to use without sharing - christopher.macduff@accenture.com 19th Nov 2015
    **/
    public static void CreateTransferActivityForCase(List<Case> newCases, Map<Id, Case> OldCases){
        List<TaskWrapper> wrappers = new List<TaskWrapper>();
        List<Id> userIds = new List<Id>();
        List<Id> groupIds = new List<Id>();

        system.debug('@@@OldOwnerId: ' + OldCases.get(newCases[0].id).ownerid);
        system.debug('@@@NewOwnerId: ' + newCases[0].ownerid);
        

        //loop through cases to populate wrapper & id lists
        for(Case c: newCases){
            system.debug('@@@case ' + c);
            Case oldCase = OldCases.get(c.id);
            boolean isNewOwnerGroup;
            boolean isOldOwnerGroup;

            //validate case owner has changed
            if(c.status == 'Closed' || oldCase.status == 'Closed'){
                continue;
            } else{
                if(c.ownerId != oldCase.ownerId){

                    //determine new case owner type
                    //'00g' is group, '005' is user
                    if(String.valueOf(c.ownerid).startsWith('00G')){
                        isNewOwnerGroup = true;
                        groupIds.add(c.ownerid);
                    }else{
                        isNewOwnerGroup = false;
                        userIds.add(c.ownerid);
                    }
                    //determine old case owner type
                    if(String.valueOf(oldCase.ownerid).startsWith('00G')){
                       isOldOwnerGroup = true;
                       groupIds.add(oldCase.ownerid);
                    }else{
                        isOldOwnerGroup = false;
                        userIds.add(oldCase.ownerid);
                    }
                    system.debug('@@@c.Id: ' + c.Id);
                    wrappers.add(new TaskWrapper(c.Id, oldCase.ownerid, c.ownerid, isOldOwnerGroup, isNewOwnerGroup));
                } else {
                    continue;
                }
            }

        }

        //query user & group to get details (Name, Location)
        List<User> users = [SELECT Id, Name, Location__c FROM User WHERE ID in :userIds];
        Map<ID, User> userMap = new Map<Id, User>(users);
        List<Group> groups = [SELECT Id, Name FROM Group WHERE ID in :groupIds];
        Map<ID, Group> groupMap = new Map<Id, Group>(groups);
        
        //this part populates tasks from the info on the wrapper, userMap, and groupMap and adds the tasks to a list before inserting them
        List<Task> tasks = new List<Task>();
        String rectypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Transfer Activity').getRecordTypeId();
        for (TaskWrapper w : wrappers) {
            system.debug('@@@userMap ' + userMap);
            system.debug('@@@groupMap' + groupMap);
            //populate Wrapper Task details
            //Catch Integration users here
            
            system.debug('@@@w1: ' + w);
            if(userMap.isEmpty() && groupMap.isEmpty()) {
                continue;
            }else{
                if(!w.isOldOwnerGroup && !w.isNewOwnerGroup){
                    if(userMap.get(w.oldOwner).Name.contains('Integration') && userMap.get(w.newOwner).Name.contains('Integration')){
                        continue;
                        //skip transfers involving integration users
                    }
                } 
                w.task.RecordTypeId = rectypeId;
                //check if new owner is group or user
                if(w.isNewOwnerGroup){
                    w.task.New_Owner__c = groupMap.get(w.newOwner).Name;
                    w.task.New_Owner_ID__c = w.newOwner;
                } else {
                    w.task.New_Owner__c = userMap.get(w.newOwner).Name;
                    w.task.New_Owner_ID__c = w.newOwner;
                    w.task.New_Owner_Location__c = userMap.get(w.newOwner).Location__c;
                }
                if(w.isOldOwnerGroup){
                    w.task.Old_Owner__c = groupMap.get(w.oldOwner).Name;
                    w.task.Old_Owner_ID__c = w.oldOwner;
                } else {
                    w.task.Old_Owner__c = userMap.get(w.oldOwner).Name;
                    w.task.Old_Owner_ID__c = w.oldOwner;
                    w.task.Old_Owner_Location__c = userMap.get(w.oldOwner).Location__c;
                }
                tasks.add(w.task);
            }
        }
        insert tasks;
    }
    
    //This wrapper holds new and old case info along with a new task so that non-conforming case scenarios can be discarded without having to worry about ordered pair nonsense.
    private class TaskWrapper{
        public Id caseId;
        public Id oldOwner;
        public Id newOwner;
        public Boolean isOldOwnerGroup;
        public Boolean isNewOwnerGroup;
        public Task task;

        public TaskWrapper(Id caseId, Id oldOwnerID, Id newOwnerId, boolean oldOwnerGroup, boolean newOwnerGroup) {
            caseId  = caseId;
            oldOwner = oldOwnerId;
            newOwner = newOwnerId;
            isOldOwnerGroup = oldOwnerGroup;
            isNewOwnerGroup = newOwnerGroup;
            task = new Task(Subject='Case Transferred', Status='Completed', WhatId=caseId);
        }
    }

}