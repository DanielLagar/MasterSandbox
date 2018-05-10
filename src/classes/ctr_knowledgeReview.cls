/**
*@author: Christopher.macduff@accenture.com
*@date: 15/02/2016
*@description: Controller for page knowledgeReview which allows searching and cloning of Knowledge Articles
*@WR: 109 Article Cloning
**/  
public with sharing class ctr_knowledgeReview {
    public String searchString {get;set;}
    public String searchCat;
    public String searchLang {get;set;}
    public String searchStatus {get;set;}

	public String reviewArticleId {get;set;} //Stores ArticleNumber of Article to review
    public String cloneArticleNumber {get;set;} //Stores ArticleNumber of Article to Clone
    public String iframeURL {get;set;} //iframe url

    public List<KnowledgeArticleVersion> resultKAVs {get;set;} //Search results list to show
    //Selected Data Category picklist valuess
    public String brandCat {get;set;}
    public String prodCat {get;set;}
    public String regCat {get;set;}
    public String promCat {get;set;}

    //Controller init
	public ctr_knowledgeReview(){
        searchLang='en_US'; //set initial value on page load
        searchStatus='Online'; //set initial value on page load
            
        searchString = '';
       	searchCat = '';
        resultKAVs = new List<KnowledgeArticleVersion>();
    }
    
 	//Generate list of languages in org
	public list<SelectOption> Languages{
	get{
		if (Languages == null){
			Languages = new List<SelectOption>();
            Schema.DescribeFieldResult field = KnowledgeArticleVersion.Language.getDescribe();

			for(Schema.PicklistEntry f : field.getPicklistValues()){
				Languages.add(new SelectOption(f.getValue(),f.getLabel()));
			}
		}
			return Languages;
        }
        set;
    }
    
    //Generate list of publication statuses
    public list<SelectOption> pubStatuses{
        get{
            if(pubStatuses == null){
                pubStatuses = new List<SelectOption>();
                Schema.DescribeFieldResult field = KnowledgeArticleVersion.PublishStatus.getDescribe();
                
                for(Schema.PicklistEntry f : field.getPicklistValues()){
                    pubStatuses.add(new SelectOption(f.getValue(),f.getLabel()));
                }
            }
            return pubStatuses;
        }
        set;
    }
    
    /****************************
	* Search button method		*
	****************************/
    public void executeSearch(){
        //Format category...
		searchCat = ''; //clear in case of previous search
        reviewArticleId = ''; //clear in case of previous search
        
        Map<String, String> catMap = new Map<String, String>();
        catMap.put(brandCat, 'Brand__c ABOVE_OR_BELOW ');
        catMap.put(prodCat, 'Product__c ABOVE_OR_BELOW ');
        catMap.put(regCat, 'Region__c ABOVE_OR_BELOW ');
        catMap.put(promCat, 'Promotion__c ABOVE_OR_BELOW ');
        
        String[] catFilters = new String[]{brandCat, prodCat, regCat, promCat};
            
		For(String s : catFilters){
            If(!String.isBlank(s)){
                searchCat += catMap.get(s)+s+'__c';
                searchCat += ' AND ';
            }       
		}
        searchCat = searchCat.removeEnd(' AND ');
        system.debug('>>> searchCat after construction: '+searchCat);

        //Build SOSL Query
        /*Example SOSL - Note can't use OR, only AND on DATA CATEGORY
        FIND {tide} IN ALL FIELDS RETURNING KnowledgeArticleVersion
		(Id, Title, ArticleNumber, ArticleType, PublishStatus  WHERE PublishStatus = 'Online' AND Language = 'en_US')
		WITH DATA CATEGORY Brand__c ABOVE_OR_BELOW Tide__c AND Region__c ABOVE_OR_BELOW United_States__c
		*/
        String soslQuery = 'FIND \''+String.escapeSingleQuotes(searchString)+'\' IN ALL FIELDS RETURNING KnowledgeArticleVersion';
        soslQuery += ' (Id, Title, ArticleNumber, ArticleType, PublishStatus, CreatedBy.Name WHERE PublishStatus = \''+searchStatus+'\'';
        soslQuery += ' AND Language = \''+searchLang+'\')';
        if(!String.isBlank(searchCat)){
            soslQuery += ' WITH DATA CATEGORY ';
            soslQuery += searchCat;
        }
        soslQuery += ' LIMIT 500'; //VF collection limit is 1000
            
        system.debug('>>> soslQuery: '+soslQuery);
        
        if(searchString.length() > 1){
            List<List<SObject>>searchList = new List<List<SObject>>();
            try{
                searchList = search.query(soslQuery);
            }
			catch(Exception e){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, e.getMessage()));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Query: '+soslQuery));
			}

            resultKAVs = (List<KnowledgeArticleVersion>)searchList[0];
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, 'Please enter at least 2 characters before starting search'));
        }
    }  

    /****************************
	* Article Cloning Method	*
	****************************/

    public pagereference cloneArticle(){
        Id clonedKAVId; //For redirect
        
        //Knowledge user check: UserPermissionsKnowledgeUser
       	boolean knowledgeUser = false;
        knowledgeUser = [SELECT UserPermissionsKnowledgeUser FROM User WHERE Id = : UserInfo.getUserId()].UserPermissionsKnowledgeUser;
        
		if(cloneArticleNumber == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No ArticleNumber Passed'));
            return null;
		}
        else if(!knowledgeUser){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You are not a knowledge user and cannot create/clone an Article'));
            return null;            
        }
        else{
                
			String kaQuery = '';
			kaQuery += 'SELECT Id, ArticleType, Title, Summary, urlName, Language FROM KnowledgeArticleVersion';
			
            kaQuery += ' WHERE ArticleNumber = :cloneArticleNumber AND Language = :searchLang AND PublishStatus = :searchStatus AND IsLatestVersion = TRUE LIMIT 1';
			system.debug('>>> KnowledgeArticle query: '+kaQuery);
                
			KnowledgeArticleVersion kavToClone = database.query(kaQuery);
            
            /********************************
             * Generic field query method	*
             *******************************/
            Set<String> fieldNames = new Set<String>();
            Set<String> queryFields = new Set<String>{'Title','Summary','articleType','urlName','Language', 'IsVisibleInPrm', 'IsVisibleInPkb', 'IsVisibleInCsp', 'IsVisibleInApp'}; 
			Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            
            Map <String, Schema.SObjectField> fieldMap = schemaMap.get(kavToClone.ArticleType).getDescribe().fields.getMap();
            
            for(Schema.SObjectField sfield : fieldMap.Values()){
                schema.describefieldresult dfield = sfield.getDescribe();
                //Only add custom fields. NOTE file field type ends with __s
                String f = dfield.getname();
                if(f.endsWith('__c')){
					queryFields.add(f); 
                }
            }
            
            //Now construct field names for query
            String fieldsToQuery = '';
            for(String s : queryFields){
                fieldsToQuery += s +', ';
            }
            //Remove last comma
            fieldsToQuery = fieldsToQuery.removeEnd(', ');
            
            system.debug('>>> fieldsToQuery: '+fieldsToQuery);
            
            String kavQuery = '';
            kavQuery += 'SELECT '+fieldsToQuery;
            kavQuery += ' FROM '+kavToClone.ArticleType;
            kavQuery += ' WHERE Id = \''+kavToClone.Id+'\'';
            
            system.debug('>>> KavQuery: '+kavQuery);

            //May need this for DC setup
			Schema.SObjectType t = Schema.getGlobalDescribe().get(kavToClone.ArticleType);

            sObject toClone = database.query(kavQuery);
            
            //Clone: preserveId, isDeepClone, preserveReadonlyTimestamps, preserveAutonumber
            sObject newKAV = toClone.clone(false,false,false,false);

            //Make urlName unique by getting latest ArticleNumber, incrementing and appending to existing urlname
            Integer urlNo = Integer.valueOf([SELECT ArticleNumber FROM KnowledgeArticle ORDER BY ArticleNumber DESC LIMIT 1].ArticleNumber);
            urlNo ++;
            String newUrlName = toClone.get('urlName')+'-'+urlNo;
            
            //To set fields for sObjects need to use put
            newKAV.put('urlName', newUrlName);
            //Publishstatus should default to 'Draft'

            insert newKAV;
            
            clonedKAVId = newKAV.Id;

            /****************************
             * Data Category cloning	*
             ***************************/
            String dcName = ''; //Holds DataCategorySelection name
            
            Schema.DescribeSObjectResult dor = t.getDescribe();
            
			List<Schema.ChildRelationship> crs = dor.getChildRelationships();
            for(Schema.ChildRelationship cr : crs){
                Schema.sObjectType temp = cr.getChildSObject();
                Schema.DescribeSObjectResult tempD = temp.getDescribe();
                dcName = tempD.getName();
                if(dcName.endsWith('__DataCategorySelection')){
                    break; //Should only be one so stop processing on first match
                }
            }
            
            String dcQuery = '';
            dcQuery += 'SELECT Id, DataCategoryGroupName, DataCategoryName FROM ';
            dcQuery += dcName +' WHERE ParentId = \''+kavToClone.Id+'\'';
            
            system.debug('>>> for loop query: '+dcQuery);
            
            List<sObject> dcsToInsert = new List<sObject>();
            
            for(sObject x : database.query(dcQuery)){
                sObject dc = x.clone(false,false,false,false);
                dc.put('ParentId', clonedKAVId);
                dcsToInsert.add(dc);
            }
            
            try{
                insert dcsToInsert;
            }
            catch(exception e){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }

			//TODO: Attachments - Field based? Can only have one attachment per 'file' field type
			//TODO: Promoted Search Terms?

			//Redirect to new record - this is generic to ArticleType
			PageReference reRend = new PageReference('/'+clonedKAVId);
			reRend.setRedirect(true);
			return reRend;
        }
    }
    /****************************
	* Article View Method		*
	****************************/
	public void reviewArticle(){
        
		if(reviewArticleId == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No ArticleNumber Passed'));
		}
        else{
			//Iframing article as this is the easiest (laziest) way to handle different ArticleTypes
			//'?isdtp=mn' - hides side bar and header
			iframeURL = '/'+reviewArticleId+'?isdtp=mn';    
		}
    }
}