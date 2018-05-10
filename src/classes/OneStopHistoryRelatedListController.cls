public with sharing class OneStopHistoryRelatedListController {
    public One_Stop__c oneStop{get;set;}
    public Map<String, Schema.SObjectField> myObjectFieldMap;
    public ID tempId;
    
    public List<historyWrapper> getHistoryDetails()
    {
        Schema.DescribeSObjectResult objectDescription = oneStop.getSObjectType().getDescribe();
        system.debug('********** objectDescription: '+objectDescription);
        myObjectFieldMap = objectDescription.fields.getMap();
        system.debug('********** myObjectFieldMap: '+myObjectFieldMap);
        system.debug('********** objectDescription.getName(): '+objectDescription.getName());
        
        List<historyWrapper> historydetails = new List<historyWrapper>();
        For(One_Stop__History obj:[Select Field, CreatedById,CReatedby.Name, CreatedDate,Id, 
            NewValue, OldValue, ParentId from One_Stop__History where ParentId=:oneStop.Id Order by createddate desc]){
            if(String.isNotBlank(string.valueOf(obj.NewValue)) && (string.valueOf(obj.NewValue).length()==15 || string.valueOf(obj.NewValue).length()==18)){
                try{
                    tempId = string.valueOf(obj.NewValue);
                    continue;
                }
                catch(exception e){}                
            }//end if
            
            historydetails.add(new historyWrapper(obj.Field,string.valueOf(obj.OldValue),string.valueOf(obj.NewValue),obj.CReatedby.Name,obj.CreatedById,obj.CreatedDate,returnFieldLabel(obj.Field)));
        }  
        return historydetails;                                  
    }
    
    //Function to return Field Label of a object field given a Field API name
    public String returnFieldLabel(String fieldName){
        if (myObjectFieldMap.containsKey(fieldName)){
            return myObjectFieldMap.get(fieldName).getDescribe().getLabel();
        }
        else {
            return fieldName;
        }
    }
    
    public class historyWrapper{
        public string field {get;set;}
        public string fieldLabel {get;set;}
        public string oldvalue {get;set;}
        public string newvalue {get;set;}
        public string updatedby {get;set;}
        public Id updatedbyid {get;set;}
        public datetime updatedon {get;set;}
        public historyWrapper(string fld,string ovalue,string nvalue,string updatedbywho,Id updatedbywhoid,datetime updateddate,string fldlabel){
            field = fld;
            oldvalue = ovalue;
            newvalue = nvalue;
            updatedby = updatedbywho;
            updatedbyid = updatedbywhoid;
            updatedon = updateddate;
            fieldLabel = fldlabel;
        }
    }
}