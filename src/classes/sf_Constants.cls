/**
      * @author: Stevie Ella
      * @date: 08/11/2014
      * @description: Contains the definition of different constants used in other classes
    */
public class sf_Constants {

    public static final Schema.DescribeSObjectResult accountSObjectResult = Account.SObjectType.getDescribe();

    public static final String CONTACT_SHIPPING_ADDRESS_PRIMARY_ADDRESS     = 'Primary Address';
    public static final String CONTACT_SHIPPING_ADDRESS_OTHER_ADDRESS   = 'Other Address';

    public static final String COUNTRY_UNITED_STATES_AMERICA = 'United States of America';
    public static final String COUNTRY_UNITED_STATES = 'United States';
    public static final String COUNTRY_CANADA = 'Canada';
    
    public static final String STRIKE_IRON_MESSAGE_MATCHED_WITH_ERROR = 'matched with errors';
    public static final String STRIKE_IRON_MESSAGE_MATCHED_WITHOUT_ERROR = 'matched without errors';
    
    public static final String STRIKE_IRON_MESSAGE_CHECKED_AND_CORRECTED = 'checked and corrected (changed or inserted)';
    public static final String STRIKE_IRON_MESSAGE_VALIDATED_AND_UNCHANGED = 'validated and unchanged';
    public static final String STRIKE_IRON_MESSAGE_VALIDATED_BUT_CHANGED = 'validated but changed (synonyms - old names)';
    public static final String STRIKE_IRON_MESSAGE_VALIDATED_BUT_STANDARDIZED = 'validated but standardized';
    public static final String STRIKE_IRON_MESSAGE_EMPTY = 'empty';
    
    public static final String ADDRESS_AMPERSAND = '&';
    public static final String ADDRESS_AND = ' AND ';
    
    public static final Integer DUPLICATECHECK_CONTACT_THRESHOLD = 40;
    public static final String DUPLICATECHECK_CONTACT_METHOD = 'dedup50';

    // Account RecordType Id
    //public static final  Id SF_ACCOUNT_BUSINESS_RECORD_TYPE = accountSObjectResult.getRecordTypeInfosByName().get('Business').getRecordTypeId();

    //Internal Activity Constants
    //Type
    public static final String INTERNAL_ACTIVITY_TYPE_KNOWLEDGE_MISSING_INCOMPLETE_KNOWLEDGE = 'Knowledge - Missing, Incomplete Knowledge';
    public static final String INTERNAL_ACTIVITY_TYPE_KNOWLEDGE_INCREASE_IN_TRENDS = 'Knowledge - Increase in Trends';
    public static final String INTERNAL_ACTIVITY_TYPE_KNOWLEDGE_SERVICES = 'Knowledge - Services';
    
    // Assessment SLA Flag
    public static final String INTERNAL_ACTIVITY_SLA_FLAG_YELLOW = 'Yellow';
    public static final String INTERNAL_ACTIVITY_SLA_FLAG_GREEN = 'Green';
    public static final String INTERNAL_ACTIVITY_SLA_FLAG_RED = 'Red';
    
    //SocialMedia Constants
    public static final String ORIGIN_SOCIAL_MEDIA = 'Social Media';
    public static final Integer BEGINNING_YEAR = 1900;
    public static final String STRING_UNKNOWN = 'Unknown'; 
    public static final String DEFAULT_SOCIAL_MEDIA_PRIORITY = '2';
    public static final String DEFAULT_SOCIAL_MEDIA_TASK_SUBJECT = 'Social conversation';
    public static final String STATUS_COMPLETED = 'Completed';
    public static final String STATUS_OPEN = 'Open';
    public static final String PRIORITY_LOW = 'Low';
    public static final String DEFAULT_QUEUE_NAME = 'Default_Queue';
    public static final String SOBJECTTYPE_CASE = 'Case';

    //Email Us Contants
    public static final String EMAILUS_DEFAULT_STATUS = 'Open';
    public static final String EMAILUS_CASE_ORIGIN = 'Email';
    public static final String TASK_CUSTOMER_ACTIVITY_RECORDTYPENAME = 'Consumer Activity';
    public static final String TASK_INTERNAL_ACTIVITY_RECORDTYPENAME = 'Internal Activity';

   // case Status
   public static final String CASE_STATUS_REOPENED_BY_CCM = 'Reopened by CCM';
   public static final String CASE_STATUS_REOPENED_BY_CCM_SUPERVISOR = 'Reopened by CCM - Supervisor';
   public static final String STATUS_LOCKED = 'Locked';
   public static final String STATUS_CLOSED = 'Closed';
   
   // case default Brand, set on Product Search/Contact Us when the Local Product does not have a Consumer_Facing_Brand__c specified
   public static final String DEFAULT_CUSTOMER_FACING_BRAND = 'P&G';

   //profiles
   public static final String INTEGRATION_USER_PROFILE_NAME = 'Integration User';
    
   //Task
   public static final String TASK_SUBJECT_INTAKE = 'Intake Agent Request';//ChrisM
   public static final String TASK_SUBJECT_PRODUCT_RETRIEVAL = 'Product Retrieval Request';//ChrisM
   public static final String TASK_TYPE_CCM_ACTIVITY = 'CCM Activity';
   public static final String TASK_FOLLOWUP_REASON_AUDIO_LOG_REQUEST = 'Audio Log Request';
   public static final Schema.DescribeSObjectResult taskSObjectResult = Task.SObjectType.getDescribe();
   public static final String TASK_CONSUMER_ACTIVITY_RECTYPE_ID = ( taskSObjectResult != null 
    && taskSObjectResult.getRecordTypeInfosByName() != null 
    && taskSObjectResult.getRecordTypeInfosByName().get(TASK_CUSTOMER_ACTIVITY_RECORDTYPENAME) != null)?
    taskSObjectResult.getRecordTypeInfosByName().get(TASK_CUSTOMER_ACTIVITY_RECORDTYPENAME).getRecordTypeId():null;

  //Comment Codes
  public static final String COMMENT_CODE_TYPE_AE = 'Adverse Event';
  public static final String COMMENT_CODE_TYPE_PQC = 'Product Quality Complaint';
}