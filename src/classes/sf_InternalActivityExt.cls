public class sf_InternalActivityExt{

    public Internal_Activity__c ia{get;set;}
    public Case theCase{get;set;}
    public String parentId;
    public String isReply = '0';
    public Boolean showSentBy{get;set;}
    public boolean showReminder{get;set;}
    public boolean showStandardTaskType{get;set;}
    public List<SelectOption> internalTasktypeValues{get;set;}
    private String tempCom;
    
    public Set<String> QAProfiles = new Set<String>{
            'Followup User with System Requests',
            'Followup User',
            'Followup Blades and Razors',
            'Follow up Admin',
            'Followup User Read Only'
        };
    public Set<String> GSSAProfiles = new Set<String>{
            'NAPSS user with System Requests',
            'NAPSS User'
        };
        
    public List<String> GCRPicklistItems = new List<String>{
            'Research',
            'Management Review',
            'For Information Only',
            'Recontact Consumer',
            'Other',
            'Action Needed',
            'Increase in Trends',
            'Suggestions to improve knowledge',
            'Missing, incomplete knowledge',
            'Service',
            'NA Topic Added',
            'NA A1 Topic Added-Product Available',
            'NA A1 Topic Added-Product Not Available',
            'NA Product Available',
            'NA Product Not Available',
            'NA GSSA Investigation Request-Product Available',
            'NA GSSA Investigation Request-Product Not Available',
            'NA 30 Day Reminder Sent',
            'NA 60 Day Reminder Sent'            
        };
    public List<String> GSSAPicklistItems = new List<String>{
            'FRFF',
            'FRFU',
            'FRSP',
            'FRPD',
            'GSSA Aligned with AE Change',
            'GSSA Not Aligned with AE Change',
            'GSSA Requests AE Change',
            'SAEQ1',
            'SAEQ2',
            'SAEQ3',
            'SQPR1',
            'SQPR2',
            'SQPR3',
            'SRPR1',
            'SRPR2',      
            'SRPR3'         
        };
    public List<String> QAPicklistItems = new List<String>{
            'Add Topic',
            'Add A1 Topic',
            'AE Change Made',
            'AE Investigation Complete',
            'Management Review',
            'Product Received-No Investigation Needed',
            'Request for Product Retrieval',
            'Results of Investigation',
            '30 Day Reminder',
            '60 Day Reminder',
            'Miscoded-Coaching',
            'GSSA Review AE Change',
            'Other'
        };
    
    public sf_InternalActivityExt(ApexPages.StandardController stdController) 
    {
        showStandardTaskType = true;
        showSentBy = false;
        showReminder = true;
        this.ia = (Internal_Activity__c)stdController.getRecord();
        isReply=ApexPages.currentPage().getParameters().get('reply');
        String activityId=ApexPages.currentPage().getParameters().get('id');
        
        tempCom = ia.comments__c == null ? '' : ia.comments__c;
        
        if(ia.case__c != null){
            theCase = [select summary__c, contact.name, account.name from Case where id =: ia.case__c]; // Removed region__c from queried fields
        }

        // STEVIE __ Commented until we figure out what is Investigation__c: SHould we create it or not ?
       /* if(ia.Investigation__c !=null){
            List<Investigation__c> tempInvs = [select related_Case__c,related_topic__c from Investigation__c where id =: ia.Investigation__c]; 
            if(tempInvs.size()>0) {
                this.ia.Case__c=tempInvs[0].Related_Case__c;
                theCase = [select summary__c, contact.name, account.name from Case where id =: tempInvs[0].Related_Case__c]; // Removed region__c from queried fields
                this.ia.Topic__c=tempInvs[0].Related_Topic__c;
            }
        }
        */
        
        //for activity edit page
        if(activityId != null && isreply != '1')
        {
            showSentBy = true;
            showReminder = false;
        }
        
        //for reply. clone version of activity 
        if(isreply =='1' && activityId != null)
        {            
            Internal_Activity__c temp = [Select comments__c,createdbyid from internal_Activity__c where id=:activityId];
            String comment=' \n';//Add emtpy line above
            comment += '------ Original Content ------\n';
            showReminder = false;
            ia.comments__c = comment+temp.comments__c;
            ia.ownerid = temp.createdbyid;
            ia.status__c = 'Open';
        }
        
        internalTasktypeValues = internalTypeItems();
              
    }
    
    private String ownerName(String ownerId){
        if(ownerId != null){
            //first check if its a queue
            try{
                Group g = [select id, name from Group where Id =: ownerId];
                if(g != null){
                    return g.name;
                }
            }catch(Exception e){System.debug('not a group');}
            try{
                User u = [select id, name from User where Id = :ownerId];
                if( u != null){
                    return u.name;
                }
            }catch(Exception e){System.debug('not a user');}
        }
        return '';
    }
    
    public pagereference saveAndReply(){
       save();
       Pagereference pg = new Pagereference('/apex/sf_InternalActivity?id='+ia.id+'&reply=1');
       pg.setRedirect(true);
       return pg;
    }
    
    public List<SelectOption> internalTypeItems(){ 
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('--None--','--None--'));
        List<Profile> matchedProfiles = [Select Name from Profile where Id = :UserInfo.getProfileId()];
        if(matchedProfiles.size() == 0) return options;   
        
        if(QAProfiles.contains(matchedProfiles[0].Name)){
            showStandardTaskType = false;
            for(String str:QAPicklistItems){
                options.add(new SelectOption(str,str));
            }
        }
        else if(GSSAProfiles.contains(matchedProfiles[0].Name)){
            showStandardTaskType = false;
            for(String str:GSSAPicklistItems){
                options.add(new SelectOption(str,str));
            }
        }
        else {
            showStandardTaskType = true;
            for(String str:GCRPicklistItems){
                options.add(new SelectOption(str,str));
            }
        }
        
        //add the selected item to the current picklist items
        if(String.isNotBlank(ia.Type__c)){
            options.add(new SelectOption(ia.Type__c,ia.Type__c));
        }
        
        return options;
    }
    
    public pagereference save() {
        //edit and trim comments if they've changed
       //String strSelectedTopics='';
       String comments = ia.comments__c;
       Boolean strEq = comments.replaceAll('[\r\n]', '').equals(tempCom.replaceAll('[\r\n]', ''));
 
       if(!strEq || Test.isRunningTest()){
           comments = datetime.now().format() + '\n'+ comments ;
           if(comments.length() > 10000 || Test.isRunningTest())
               ia.comments__c = comments.abbreviate(10000);
           else
               ia.comments__c = comments;
       }
       
       if(ia.Type__c == '--None--') ia.Type__c=NULL;
       

       
       //grab owner name   
       ia.assigned_to__c = ownerName(ia.ownerid);
       
       //clone if clone, upsert if not
       if(ApexPages.currentPage().getParameters().get('clone') == '1'){
        ia = ia.clone(false);
        insert ia;
       }
       else
        upsert ia; 
       
       Pagereference pg;
       if(ApexPages.currentPage().getParameters().get('retURL') != null){
           pg = new Pagereference(ApexPages.currentPage().getParameters().get('retURL'));
       }
       //WR14 ChrisM - commenting out as part of WR14, testing on always redirecting back to IA
       /*else if(ia.case__c != null){
           pg = new Pagereference('/'+ia.case__c);
       }*/
       else pg = new Pagereference('/'+ia.id);
       
       pg.setRedirect(true);
       return pg;
    }

}