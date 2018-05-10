/*
* @author: John Casimiro
* @date: 08/15/2014
* @description: 
    Helper class for User trigger
US607

@todo - compare trigger.old with trigger.new to find any region language values that were removed.
*/
public with sharing class sf_UserTriggerHelper {
    
    /*
    * @description On trigger insert and update, this method looks at the region language fields and creates group memberships to Public Groups
    *   with the same name.
    */
    public static void relatePublicGroups (List <User> newList) {
        List<GroupMember> gms = new List<GroupMember>();
        //List<GroupMember> deleteGms = new List<GroupMember>();
        Map<Id, set<Id>> userIdToSetOfGms = new Map<id, set<Id>>();
        
        List<Group> groups = [select id, name from group where Type = 'Regular'];
        
        //create map of Group Name to Group Id
        map<String, Id> groupNameToGroupId = new map<String,Id>();
        for(Group g : groups){
            groupNameToGroupId.put(g.Name, g.Id);
        }
        
        // get all group memberships for the current batch of users
        List<GroupMember> currentGroups = [select id, groupId, UserOrGroupId from GroupMember where UserOrGroupId IN :newList];
        
        // create map of User Id to a set of Groups
        for (GroupMember gm : currentGroups){
            if(userIdToSetOfGms.containsKey(gm.UserOrGroupId)){
                set<id> tempGms = userIdToSetOfGms.get(gm.UserOrGroupId);
                tempGms.add(gm.groupId);
                
                userIdToSetOfGms.put(gm.UserOrGroupId, tempGms);
            } else {
                userIdToSetOfGms.put(gm.UserOrGroupId, new Set<Id>{gm.groupId});
            }
        }
        
        system.debug('*** User GMs' + userIdToSetOfGms);
        
        for (User u: newList) {
            //build list of group ID from group names on the user record
            if(u.Region_Language__c != null){
                List<string> groupNames = u.Region_Language__c.split(';');
                set<Id> groupIds = new set<Id>();
                for (string gn : groupNames){
                    if(groupNameToGroupId.containsKey(gn))
                        groupIds.add(groupNameToGroupId.get(gn));
                }
                system.debug('*** Group names'+ groupNames);
                system.debug('*** Group Ids'+ groupIds);
                 
                //remove current memberships from list of group from user record
                if(userIdToSetOfGms.containsKey(u.Id)){
                    for(Id currentGroup : userIdToSetOfGms.get(u.Id)){
                        if (groupIds.contains(currentGroup)){
                            groupIds.remove(currentGroup);
                        } else {
                            //GroupMember gm = new GroupMember();
                            //gm.id = currentGroup;
                            //deleteGms.add(gm);
                        }
                    }
                    
                } 
                system.debug('***final list of group Ids'+ groupIds);
                
                //add what is left to gms to be inserted
                for(id gId : groupIds){
                    GroupMember gm = new GroupMember();
                    gm.GroupId = gId;
                    gm.UserOrGroupId = u.Id;
                    gms.add(gm);                
                }
                
                if (gms.size() > 0){
                    system.debug('*** insert gms =' + gms);
                    insert gms;
                }
                
            }
        }
    }
    
    
    /*
    * @description On trigger update, this methode removes all Public Groups if the user is deactivated. If the user is still active, it removes any Public Groups
    *   that were removed from the Region Language picklist.
    */
    public static void removePublicGroups(List <User> oldList, List <User> newList){
        List<User> deactivatedUsers = new List<User>();
        List<GroupMember> deleteGms = new List<GroupMember>();
        
        List<Group> groups = [select id, name from group where Type = 'Regular'];
        
        //create map of Group Name to Group Id
        map<String, Id> groupNameToGroupId = new map<String,Id>();
        for(Group g : groups){
            groupNameToGroupId.put(g.Name, g.Id);
        }
        
        // get all group memberships for the current batch of users
        List<GroupMember> currentGroups = [select id, groupId, UserOrGroupId from GroupMember where UserOrGroupId IN :newList];
        
        for (User u: newList) {
            if (u.isActive == false){
                deactivatedUsers.add(u);
            } else {
                for (User oldU: oldList) {
                    if (oldU.id == u.Id && oldU.Region_Language__c != null) {
                        List<string> newGroupNames = u.Region_Language__c.split(';');
                        List<string> oldGroupNames = oldU.Region_Language__c.split(';');
                        Boolean isFound = false;
                        for (String oldName : oldGroupNames){
                            for (String newName : newGroupNames){
                                system.debug('*** old = ' + oldName + '*** new = ' + newName);
                                if (oldName == newName){
                                    isFound = true;
                                    break; // match found. no need to continue
                                } else {
                                    isFound = false;
                                }
                                system.debug('*** is found = '  + isFound);
                            }
                            if (isFound == false){
                                system.debug('*** ' + oldName + ' NOT FOUND');
                                //get group id
                                string tempGroupId = groupNameToGroupId.get(oldName);
                                
                                //cycle through current groups to get a group member id for the group that was removed
                                for (GroupMember gm : currentGroups){
                                    if(gm.GroupId == tempGroupId && gm.UserOrGroupId == u.Id){
                                        deleteGms.add(gm);
                                    }
                                }
                                
                            }
                        }
                    }
                }
                
            }
        }
        
        if (deactivatedUsers.size() > 0)
            deleteGms.addAll([select groupId, UserOrGroupId from GroupMember where UserOrGroupId IN :deactivatedUsers]);
        
        if (deleteGms.size() > 0){
            system.debug('*** delete gms =' + deleteGms);
            delete deleteGms;
        }
    }
    
	/*
    * @description On trigger before insert and update, this method looks at the specific currency threshold fields and sets
    *   the generic monetary threshold to the highests specific currency value.
    *   christopher.macduff@accenture.com
    */
    public static void setMonetaryThreshold(List <User> newList, Map<Id, User> oldMap){
        
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('User').getDescribe().fields.getMap();
        
        List<String> doubles = new List<String>(); //Container for fields with data type doubles
        List<Schema.SObjectField> fieldsToLoop = new List<Schema.SObjectField>();
        
        for(String s : objectFields.keySet()) {
            
            Schema.DisplayType fielddataType = objectFields.get(s).getDescribe().getType();
            //Only include fields with data type double and threshold fields
            If(fielddataType == Schema.DisplayType.Double && s.endsWithIgnoreCase('_Monetary_Threshold__c')){ 
                doubles.add(s);
                fieldsToLoop.add(objectFields.get(s));
            }
        }
        
        For(User u : newList){
            
            Set<Double> uThresholds = new Set<Double>();
            
            //Go through fields adding value to Set
            For(Schema.SObjectField f : fieldsToLoop){ 
                uThresholds.add(Double.valueOf(u.get(f))); //Get value of field and convert to double data type
            }
            
            List<Double> utValues = new List<Double>(uThresholds);
            utValues.sort(); //Defaults to asc so get the last value
            Double highestValue = utValues.get(utValues.size()-1);
            
            u.Monetary_Threshold__c = highestValue;
        }
    }
}