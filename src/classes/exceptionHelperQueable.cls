/*
 * 
 * Example usage:
 * Standard exception:
 * System.enqueueJob(new exceptionHelperQueable(e,''));
 * Database class:
 * System.enqueueJob(new exceptionHelperQueable(results));
 * 
 */

public class exceptionHelperQueable implements Queueable{
    private Exception theException {get;Set;}
    private List <Database.SaveResult> results {get;set;}
    private static List<Exception__c> exceptionsToInsert = new List<Exception__c>(); //Records to create
    private String jsonString {get;set;}
    private String optMessage {get;set;}
    private Boolean databaseException {get;set;}//flag for when database class has been used - used to prevent empty exception records when result list is empty

    /****************************************
    * Constructor for standard exception    *
    ****************************************/
    public exceptionHelperQueable(Exception theException, String optMessage){
        this.theException = theException;
        this.optMessage = optMessage;
    }

    public exceptionHelperQueable(String optMessage){
        this.theException = null;
        this.optMessage = optMessage;
    }
    
    /****************************************
    *Constructor for database.SaveResult    *
    ****************************************/
    public exceptionHelperQueable(List<Database.SaveResult> results, String optMessage){
        jsonString = JSON.serialize(results);//Need to do this as passing SaveResult with errors 
        this.optMessage = optMessage;
        this.databaseException = true;//prevents emtpy exceptions being created when result list is empty
        //this.results = results;// causes GACK
    }
    
    /****************************************
    *Constructor for database.DeleteResult  *
    ****************************************/
    public exceptionHelperQueable(List<Database.DeleteResult> results, String optMessage){
        jsonString = JSON.serialize(results);//Need to do this as passing DeleteResult with errors 
        this.optMessage = optMessage;
        this.databaseException = true;
        //this.results = results;// causes GACK
    }

    /****************************************
    * Constructor for emailResults          *
    ****************************************/    
    //TODO: Platform bug preventing implementation

    /****************************************
    * Execute method                        *
    ****************************************/  
    public void execute(QueueableContext SC) {
        if(String.isNotBlank(jsonString)){
            results = (Database.SaveResult[])JSON.deserialize(jsonString, Database.SaveResult[].class);//To avoid GACK
        }

        /****************************************
        * Handle SendEmailResult                *
        ****************************************/
        //TODO: Platform bug preventing implementation

        /****************************************
        * Handle database.saveresult            *
        ****************************************/
        if(results != null && !results.isEmpty()){
            //Any failures?
            for (Database.SaveResult sr : results) {
                if(sr.isSuccess()){
                    //Do nothing
                }
                else{
                    //If an error occurred, returns an array of one or more database error objects providing
                    //the error code and description. If no error occurred, returns an empty set.
                    for(Database.Error err : sr.getErrors()){
                        exceptionsToInsert.add(createException(err, optMessage));
                    }
                }
            }           
        }
        
        /****************************************
        * Handle standard exceptions            *
        ****************************************/
        else if(databaseException==null || !databaseException){
            exceptionsToInsert.add(createException(theException, optMessage));
        }
        
        insert exceptionsToInsert;//Testing DML in controller
    }
    
    /****************************************
     * Creates exception record for         * 
     * SendEmailError, methods:             *
     * getFields()                          *
     * getMessage()                         *
     * getStatusCode()                      *
     * getTargetObjectId()                  *
     ***************************************/
    //TODO: Platform bug preventing implementation
    /*private static Exception__c createException(Messaging.SendEmailError theEmailError){
        Schema.DescribeFieldResult fieldsDFR = Exception__c.Fields__c.getDescribe();
        Schema.DescribeFieldResult messageDFR = Exception__c.Message__c.getDescribe();
        Schema.DescribeFieldResult stackDFR = Exception__c.Stack_Trace__c.getDescribe();
        Schema.DescribeFieldResult recordDFR = Exception__c.Related_Record__c.getDescribe();
 
        Exception__c ex = new Exception__c(
            Line_Number__c = 'N/A',
            Cause__c = 'N/A',
            Stack_Trace__c = theEmailError.getStatusCode() != null ? String.ValueOf(theEmailError.getStatusCode()).left(stackDFR.getLength()): '',
            Message__c = theEmailError.getMessage() != null ? theEmailError.getMessage().left(messageDFR.getLength()) : '',
            Fields__c = theEmailError.getFields() != null ? String.ValueOf(theEmailError.getFields()).left(fieldsDFR.getLength()) : '',
            Related_Record__c = theEmailError.getTargetObjectId() != null ? theEmailError.getTargetObjectId().left(recordDFR.getLength()) : '',
            Type__c = 'Email Error'
        );
        return ex;
    }*/
    
    /****************************************
     * Creates exception record when        * 
     * database.error is used.              *
     * database.error methods:              *
     * getStatusCode()                      *
     * getMessage()                         *
     * getFields()                          *
     ***************************************/
    private static Exception__c createException(Database.Error theError, String optMessage){
        Schema.DescribeFieldResult fieldsDFR = Exception__c.Fields__c.getDescribe();
        Schema.DescribeFieldResult messageDFR = Exception__c.Message__c.getDescribe();
        Schema.DescribeFieldResult stackDFR = Exception__c.Stack_Trace__c.getDescribe();
        Schema.DescribeFieldResult detailsDFR = Exception__c.Further_Details__c.getDescribe();
 
        Exception__c ex = new Exception__c(
            Line_Number__c = 'N/A',
            Cause__c = 'N/A',
            Stack_Trace__c = theError.getStatusCode() != null ? String.ValueOf(theError.getStatusCode()).left(stackDFR.getLength()): '',
            Message__c = theError.getMessage() != null ? theError.getMessage().left(messageDFR.getLength()) : '',
            Fields__c = theError.getFields() != null ? String.ValueOf(theError.getFields()).left(fieldsDFR.getLength()) : '',
            Type__c = 'Database class',
            Further_Details__c = String.isNotBlank(optMessage) ? optMessage.left(detailsDFR.getLength()) : ''
            //Further_Details__c = String.isNotBlank(optMessage) ? optMessage : ''
        );
        return ex;
    }
    
    /***************************************
     * Creates exception record supports    *
     * general use, not database class      *
     **************************************/
    private static Exception__c createException (Exception theException, String optMessage){
        Schema.DescribeFieldResult fieldsDFR = Exception__c.Fields__c.getDescribe();
        Schema.DescribeFieldResult typeDFR = Exception__c.Type__c.getDescribe();
        Schema.DescribeFieldResult messageDFR = Exception__c.Message__c.getDescribe();
        Schema.DescribeFieldResult lineNoDFR = Exception__c.Line_Number__c.getDescribe();
        Schema.DescribeFieldResult stackDFR = Exception__c.Stack_Trace__c.getDescribe();
        Schema.DescribeFieldResult causeDFR = Exception__c.Cause__c.getDescribe();
        Schema.DescribeFieldResult recordDFR = Exception__c.Related_Record__c.getDescribe();
        Schema.DescribeFieldResult detailsDFR = Exception__c.Further_Details__c.getDescribe();

        Exception__c ex = new Exception__c();

        if(theException != null){//Allows creating an exception record with only a message
            ex.Line_Number__c = theException.getLineNumber() != null ? String.ValueOf(theException.getLineNumber()).left(lineNoDFR.getLength()): '';
            ex.Cause__c = theException.getCause() != null ? String.ValueOf(theException.getCause()).left(causeDFR.getLength()) : '';
            ex.Stack_Trace__c = theException.getStackTraceString() != null ? theException.getStackTraceString().left(stackDFR.getLength()): '';
            ex.Message__c = theException.getMessage() != null ? theException.getMessage().left(messageDFR.getLength()) : '';
            ex.Type__c = theException.getTypeName() != null ? theException.getTypeName().left(typeDFR.getLength()) : '';
        }
        ex.Further_Details__c = String.isNotBlank(optMessage) ? optMessage.left(detailsDFR.getLength()) : '';
        //ex.Further_Details__c = String.isNotBlank(optMessage) ? optMessage : '';
        return ex;
    }
    
    /************************
     * Field Describes      *
     * TODO: Returning null *
     ***********************/
    /*public static Schema.DescribeFieldResult fieldsDFR {
        get{
            if(fieldsDFR == null){
                Schema.DescribeFieldResult fieldsDFR = Exception__c.Fields__c.getDescribe();
            }
            return fieldsDFR;
        }
        set;
    }

    public static Schema.DescribeFieldResult typeDFR {
        get{
            if(typeDFR == null){
                Schema.DescribeFieldResult typeDFR = Exception__c.Type__c.getDescribe();
            }
            return typeDFR;
        }
        set;
    }
    
    
    public static Schema.DescribeFieldResult messageDFR{
        get{
            if(messageDFR == null){
                Schema.DescribeFieldResult messageDFR = Exception__c.Message__c.getDescribe();
            }
            return messageDFR;
        }
        set;
    }
    
    public static Schema.DescribeFieldResult lineNoDFR {
        get{
            if(lineNoDFR == null){
                Schema.DescribeFieldResult lineNoDFR = Exception__c.Line_Number__c.getDescribe();
            }
            return lineNoDFR;
        }
        set;
    }
    
    public static Schema.DescribeFieldResult stackDFR {
        get{
            if(stackDFR == null){
                Schema.DescribeFieldResult stackDFR = Exception__c.Stack_Trace__c.getDescribe();
            }
            return stackDFR;
        }
        set;
    }
    
    public static Schema.DescribeFieldResult causeDFR {
        get{
            if(causeDFR == null){
                Schema.DescribeFieldResult causeDFR = Exception__c.Cause__c.getDescribe();
            }
            return causeDFR;
        }
        set;
    }*/
    
}