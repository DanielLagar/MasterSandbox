/*=====================================================================
* Get Next Case Offering
* Version         1.0
* Author          Trevor Scott <tscott@salesforce.com>
*                 Ryan Mccullough <rmccullough@salesforce.com>
*                 Hao Dong <hdong@salesforce.com>
*                 Derek Anderson <derek.anderson@salesforce.com>
*
* Usage           The Get Next Case offering allows agents to click a button on the console component and pull the next
*                 case from queues they are assigned to
*                  - One click custom footer component
*                  - Two levels of queue/group hierarchy
*                  - Case priority is determined by case.SFPS_GNC_PriorityDate__c that defaults to case creation date
*                  - Allows declartive configuration on overwrite priority data field
*
* Component       SFPS_GNC_GetNextCase.cls - Actions related to Get Next Case
*                 SFPS_GNC_GetNextCaseTest.cls - Test class for Get Next Case actions
*                 SFPS_GNC_GetNextCase.page - Visualforce Page for Custom Console Component
*                 SFPS_GNC_CSS.resource - stylesheets
*                 SFPS_GNC_GetNextCase.customApplicationComponent - Custom Console Component
*                 SFPS_GNC_[...] Custom Labels - Various custom labels
*
* Change Log      v0.1 Trevor Scott - "Next In Queue" demo component (https://org62.my.salesforce.com/a2x30000002eB16)
*                 v0.9 Ryan Mccullough - Initial Version
*                 v1.0 Hao Dong, Derek Anderson
*                      Various UI update
*                      Support console toolkit API v34.0
*                      Support case open as sub tab defined in app setting
*                      Add Priority Date custom field on Case to support declarative configuration on routing priority
*
* Last Modified   07/15/2015
=====================================================================*/
public class SFPS_GNC_GetNextCase {
    
    public Boolean NoSearches { get; set; }
    public String CaseIdAssigned { get; set; }
    public String CaseNumberAssigned { get; set; }
    public String CasePreviousQueue { get; set; }
    public String ErrorMessage { get; set; }
    public Integer AutoCloseDelay { get; set; }

    public SFPS_GNC_GetNextCase() {
        System.debug('SFPS_GNC - SFPS_GNC_GetNextCase() entered');
        this.NoSearches = true;
        this.AutoCloseDelay = 5;
    }

    public void AssignNextRecord() {
        try {
            
            System.debug('SFPS_GNC - Retrieving Group Memberships of type \'Queue\' for User Id: ' + UserInfo.getUserId());

            // flip the "No Searches" flag
            this.NoSearches = false;

            // clear the assigned vals
            this.CaseIdAssigned = null;
            this.CaseNumberAssigned = null;
            this.CasePreviousQueue = null;
            this.ErrorMessage = null;

            // Get the public groups to which the current user is part of
            Set<Id> PublicGroups = new Set<Id>();
            
            for (GroupMember mem : [SELECT GroupId FROM GroupMember WHERE Group.Type = 'Regular' AND UserOrGroupId =:UserInfo.getUserId()]) {
                PublicGroups.add(mem.GroupId);
            }

            // Pick the queues that are associated with the public groups and for ones where the user is a direct queue member
            List<GroupMember> GroupMemberships = [SELECT GroupId, Group.Name 
                                                    FROM GroupMember
                                                    WHERE Group.Type = 'Queue' 
                                                    AND (UserOrGroupId = :UserInfo.getUserId() OR UserOrGroupId IN :PublicGroups )];

            System.debug('User (' + UserInfo.getUserId() + ') Is a Member of these groups: ' + GroupMemberships);

            // put the group memberships into a map where the Key is the Group Id
            Map<Id, GroupMember> GroupIdToMember = new Map<Id, GroupMember>();
            
            for (GroupMember GroupMembership : GroupMemberships) {
                GroupIdToMember.put(GroupMembership.GroupId, GroupMembership);
            }
            
            System.debug('SFPS_GNC - Group Memberships: ' + GroupIdToMember.keySet());

            // default next case to null
            Case NextCase = null;

            // get the next case for those queues sorted by SFPS_GNC_PriorityDate__c
            // The system will pick a bucket of cases (say 5) and attempt to lock one by one and
            // whichever is successful will be returned to the front end
            for (Case c : [SELECT Id, OwnerId, CaseNumber, Owner.Name, Origin
                            FROM Case
                            WHERE OwnerId IN :GroupIdToMember.keySet() 
                            AND IsClosed = false
                            ORDER BY Priority_Date__c ASC LIMIT 2]) {
                System.debug('SFPS_GNC - Attemping to lock Case Number: ' + c.CaseNumber + ', Id: ' + c.Id);
                // Attempt to lock the case
                try {
                    
                    // Confirm that the case is still in the queue and Lock it
                    NextCase = [SELECT Id, OwnerId, CaseNumber, Owner.Name, Origin FROM Case WHERE Id =: c.Id AND OwnerId =: c.OwnerId FOR UPDATE];
                    
                    System.debug('SFPS_GNC - Case should be locked here.');
                    
                    String sQueueName = NextCase.Owner.Name;

                    NextCase.OwnerId = UserInfo.getUserId();
                    
                    update NextCase;

                    //check tasks
                    if (c.Origin == 'Email') {
                        User u = [SELECT Department, Contact_Center__c, Username FROM User WHERE Id = :UserInfo.getUserId()];
                        List <Task> tasks = new List <Task> ([SELECT Id, User_Department__c, User_Contact_Center__c FROM Task WHERE WhatId = :c.Id AND Status = 'Completed' AND (User_Department__c = null OR User_Contact_Center__c = null)]);

                        if (!tasks.isEmpty()) {
                            for (Task t: tasks) {
                                t.User_Department__c =  u.Department;
                                t.User_Contact_Center__c = u.Contact_Center__c;
                                t.Username__c = u.Username;
                            }

                            update tasks;
                        }
                    }


                    
                    System.debug('SFPS_GNC - Case has been updated.');

                    // Fetch again to make sure one, that you are still the owner and second, the previous queue information
                    //NextCase = [SELECT Id, OwnerId, CaseNumber, Last_Assigned_Queue__c FROM Case WHERE Id =: c.Id AND OwnerId =: UserInfo.getUserId()];
                    NextCase = [SELECT Id, OwnerId, CaseNumber FROM Case WHERE Id =: c.Id AND OwnerId =: UserInfo.getUserId()];
                    
                    System.debug('Updated case owner: ' + NextCase.OwnerId + ', current user Id: ' + UserInfo.getUserId());

                    // assign next case to current user and store some info about the case in public vars for the page
                    this.CasePreviousQueue = sQueueName;
                    this.CaseNumberAssigned = NextCase.CaseNumber;
                    this.CaseIdAssigned = NextCase.Id;

                    // exit the for loop if we re-assigned the case
                    break;
                } catch (Exception e) {
                    this.ErrorMessage = e.getMessage();
                    System.debug(LoggingLevel.ERROR, 'SFPS_GNC - Could not re-assign case. Exception: ' + e);
                    // Any exceptions including Lock, Dont do anything and just move to the record case record.
                    NextCase = null;
                } // end TRY/CATCH REASSIGN
            
            } //end FOR CASES IN QUEUE
            
            System.debug('SFPS_GNC - Next Case: ' + NextCase);
        

        } catch (Exception e) {
            this.ErrorMessage = e.getMessage() + ' ' + e.getLineNumber();
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
    }
}