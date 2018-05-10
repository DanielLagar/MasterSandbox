trigger OneStopSummaryFieldUpdate on OneSTOPComment__c (before insert, before update) {
    
    
    list<id> oneStopid = new list<id>();
    
    for(OneSTOPComment__c childObj : trigger.New){
        oneStopid.add(childObj.X1STOP__c);
    }
    
    list<One_Stop__c> oneStopUpdate = new list<One_Stop__c>([select id, Comment_Summary__c, Status__c
                                                            from one_stop__C where id IN : oneStopid]);
    
    for(OneSTOPComment__c oneStopComme : trigger.new){
       
       for(integer i =0; i<oneStopUpdate.size(); i++){            
           if(oneStopUpdate[i].Comment_Summary__c != null){
               oneStopUpdate[i].Comment_Summary__c = 'CommentBy: '+ 
                                     oneStopComme.name__c + 
                                     '\n'+
                                     '\n'+
                                     oneStopComme.Comment1__c + 
                                     '\n' +
                                     '___________________________________________________________________________'+
                                     '\n'+
                                     oneStopUpdate[i].Comment_Summary__c;
               }
           else{
               oneStopUpdate[i].Comment_Summary__c = 'CommentBy: '+ 
                                    oneStopComme.name__c + 
                                    '\n'+
                                    '\n'+
                                    oneStopComme.Comment1__c + 
                                    '\n' +
                                    '____________________________________________________________________________';
        }
       }
    }
   
    update oneStopUpdate;    
}