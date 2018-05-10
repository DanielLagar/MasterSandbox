trigger OneStopTrigger on One_Stop__c (before insert,before update) {

    Map<String, OneStopSettings__c> allsettings = OneStopSettings__c.getAll();
    boolean matchFound = false;
    Id needsApprovalQueue;
    User user;
    String profId;
    String profId15Char;
    OneStopQueues__c onestopQueue;
    
    user = [select id, X1STOP_Approver__c, ProfileId from User where id = :Userinfo.getUserId()]; 
    profId=user.ProfileId;
    //lookup custom seeting with the 18 char profile id.
    onestopQueue = OneStopQueues__c.getValues(profId);
    if(onestopQueue == null){
        //if it does not find, use 15 char profile id to get the record
        profId15Char=(profId.length()==18)?profId.substring(0,15):profId;
        onestopQueue = OneStopQueues__c.getValues(profId15Char);
    }  
    //if no record found, then use default queue (1STOP Needs Approval)  
    if(onestopQueue == null) needsApprovalQueue=[select Id from Group where Name = '1STOP Needs Approval' and Type = 'Queue'].Id;
    else needsApprovalQueue=onestopQueue.Queue_Id__c;    
    Id approvedQueue=[select Id from Group where Name = '1STOP Approved' and Type = 'Queue'].Id;
    
    for(One_Stop__c onestop : Trigger.new){
        
        matchFound = false;
        for(OneStopSettings__c setting : allsettings.values()){
            if(onestop.Request_Category__c==setting.Category__c && onestop.Request_Subcategory__c==setting.Sub_Category__c){
                if(Trigger.isInsert && setting.Approval_Needed__c && !user.X1STOP_Approver__c){
                    onestop.ownerId=needsApprovalQueue;
                    onestop.status__c='Open';
                    onestop.Priority__c=setting.Priority__c;
                    if(onestop.Requested_Due_Date__c!=null)
                        onestop.Actual_Expected_Due_Date__c=onestop.Requested_Due_Date__c;                    
                }
                else if(Trigger.isInsert && setting.Approval_Needed__c==false){
                    System.debug('######## In the condition');
                    onestop.ownerId=approvedQueue;
                    //NOTE: do not change the name 'System'. This is being used in workflows and in the same trigger.
                    onestop.Approver_Name__c='System';
                    onestop.Approval_Date__c=datetime.now();                    
                    onestop.X1STOP_Approval__c = 'Approved';
                    onestop.Priority__c=setting.Priority__c;
                    onestop.status__c='Open';
                    if(setting.SLA__c!=null){
                        if(onestop.Requested_Due_Date__c==null)
                            onestop.Actual_Expected_Due_Date__c=datetime.now().addHours(Integer.valueOf(setting.SLA__c));
                        else if(onestop.Requested_Due_Date__c<datetime.now().addHours(Integer.valueOf(setting.SLA__c)))
                            onestop.Actual_Expected_Due_Date__c=datetime.now().addHours(Integer.valueOf(setting.SLA__c));
                        else if(onestop.Requested_Due_Date__c>datetime.now().addHours(Integer.valueOf(setting.SLA__c)))
                            onestop.Actual_Expected_Due_Date__c=onestop.Requested_Due_Date__c;
                    }
                }
                
                else if(trigger.isInsert && setting.Approval_Needed__c && user.X1STOP_Approver__c){                
                    onestop.ownerId=approvedQueue;
                    onestop.status__c='Open';
                    onestop.Approver_Name__c=UserInfo.getName();
                    onestop.Approved_By__c=UserInfo.getUserId();
                    onestop.Approver_Email__c=UserInfo.getUserEmail();
                    onestop.Approval_Date__c=datetime.now();
                    onestop.X1STOP_Approval__c ='Approved';
                    onestop.Sub_Status__c = 'Return to 1STOP';
                    //onestop.Send_Email__c = true;
                    if(setting.SLA__c!=null){
                        if(onestop.Requested_Due_Date__c==null)
                            onestop.Actual_Expected_Due_Date__c=datetime.now().addHours(Integer.valueOf(setting.SLA__c));
                        else if(onestop.Requested_Due_Date__c<datetime.now().addHours(Integer.valueOf(setting.SLA__c)))
                            onestop.Actual_Expected_Due_Date__c=datetime.now().addHours(Integer.valueOf(setting.SLA__c));
                        else if(onestop.Requested_Due_Date__c>datetime.now().addHours(Integer.valueOf(setting.SLA__c)))
                            onestop.Actual_Expected_Due_Date__c=onestop.Requested_Due_Date__c;
                    }
                    if( Trigger.isInsert && setting.Approval_Needed__c && user.X1STOP_Approver__c)
                        onestop.Priority__c=setting.Priority__c;
                }
                 else if((setting.Approval_Needed__c && user.X1STOP_Approver__c) && (Trigger.isUpdate && trigger.oldMap.get(onestop.Id).X1STOP_Approval__c != 'Approved' && Trigger.newMap.get(onestop.Id).X1STOP_Approval__c == 'Approved')){                
                    onestop.ownerId=approvedQueue;
                    onestop.status__c='Open';
                    onestop.Approver_Name__c=UserInfo.getName();
                    onestop.Approved_By__c=UserInfo.getUserId();
                    onestop.Approver_Email__c=UserInfo.getUserEmail();
                    onestop.Approval_Date__c=datetime.now();
                    onestop.X1STOP_Approval__c ='Approved';
                    onestop.Sub_Status__c = 'Return to 1STOP';
                    //onestop.Send_Email__c = true;
                    if(setting.SLA__c!=null){
                        if(onestop.Requested_Due_Date__c==null)
                            onestop.Actual_Expected_Due_Date__c=datetime.now().addHours(Integer.valueOf(setting.SLA__c));
                        else if(onestop.Requested_Due_Date__c<datetime.now().addHours(Integer.valueOf(setting.SLA__c)))
                            onestop.Actual_Expected_Due_Date__c=datetime.now().addHours(Integer.valueOf(setting.SLA__c));
                        else if(onestop.Requested_Due_Date__c>datetime.now().addHours(Integer.valueOf(setting.SLA__c)))
                            onestop.Actual_Expected_Due_Date__c=onestop.Requested_Due_Date__c;
                    }
                    if( Trigger.isInsert && setting.Approval_Needed__c && user.X1STOP_Approver__c)
                        onestop.Priority__c=setting.Priority__c;
                }
                
                else if((setting.Approval_Needed__c && user.X1STOP_Approver__c) &&
                        (trigger.isUpdate && Trigger.oldMap.get(onestop.Id).X1STOP_Approval__c != 'Admin Handled' && Trigger.newMap.get(onestop.Id).X1STOP_Approval__c == 'Admin Handled')){             
                  
                    onestop.OwnerId = userinfo.getUserId();
                    onestop.Status__c = 'Closed';
                    onestop.Request_Closed_Date__c = datetime.now();
                    onestop.Approver_Name__c=UserInfo.getName();
                    onestop.Approval_Date__c=datetime.now();
                    onestop.Approver_Email__c=UserInfo.getUserEmail();
                    onestop.Approval_Date__c=datetime.now();
                    //onestop.Send_Email__c = true;
                    return;
                    }
                else if((setting.Approval_Needed__c && user.X1STOP_Approver__c) && 
                    (trigger.isUpdate && Trigger.oldMap.get(onestop.Id).X1STOP_Approval__c != 'Rejected' && Trigger.newMap.get(onestop.Id).X1STOP_Approval__c == 'Rejected')){                
                    
                    onestop.OwnerId = userinfo.getUserId();
                    onestop.Status__c = 'Closed';
                    onestop.Approver_Name__c=UserInfo.getName();
                    onestop.Approval_Date__c=datetime.now();
                    onestop.Approver_Email__c=UserInfo.getUserEmail();
                    onestop.Request_Closed_Date__c = datetime.now();
                    //onestop.Send_Email__c = true;                          
                    return;
                    }
              
                onestop.SLA__c=setting.SLA__c;   
                matchFound = true;          
                }
        }   
        
        //if matchFound is false that indicates that there is no SLA defined in the custom setting.
        if(!matchFound){
            onestop.addError('SLA is not defined for this Category and Subcategory. Please contact your System Admin.');
        }
        
    }
    
    for(One_Stop__c onestop : Trigger.new){
        if(Trigger.isUpdate && onestop.Send_Email__c == true && onestop.Approver_Name__c!='System' && UserInfo.getUserEmail().contains('infosys.com') && onestop.status__c!='Closed'){
            onestop.addError('You can only send notification to everyone if the request is approved by the System.');
        }
        if(Trigger.isUpdate && onestop.OwnerId!=Trigger.oldMap.get(onestop.Id).ownerId){
            onestop.Status__c = 'Working'; 
        }
    }
    

}