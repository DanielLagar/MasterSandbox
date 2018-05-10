/*
* @author: orikkers@salesforce.com  
* @date: 06/30/2014
* @description:  controller extension for sf_OverrideMSTView page. 
*/



public with sharing class sf_OverrideMSTViewExt {
    
    private static final Integer DEFAULT_PAGE_SIZE = 10;
    private static final Integer LIMIT_QUERY_ROW = Limits.getLimitQueryRows();
    private static final String SPLIT_DELIMITER = '\\|';

    public Metadata_Survey_Trigger__c msTrigger {get; set;}

    public List <String> selectedFieldSets;
    public List <String> selectedCountries;
    public List <String> selectedLanguages;
    public List <String> selectedContactMethods;
    public List <String> selectedDirections;
    public List <String> selectedSegments;
    public List <String> selectedBrands;
    public List <String> selectedL1;
    public List <String> selectedL2;
    public List <String> selectedL3;

    
    public List <Local_Comment_Code__c> commentList {get; private set;}
    
    public Integer last30DaysCount {get; private set;}
    public Integer last60DaysCount {get; private set;}
    public Integer last90DaysCount {get; private set;}

    
    public sf_OverrideMSTViewExt(ApexPages.StandardController sc) {

        msTrigger = (Metadata_Survey_Trigger__c) sc.getRecord();
        if (msTrigger.Id != null) {
            last30DaysCount = 0;
            last60DaysCount = 0;
            last90DaysCount = 0;
            /*
            last30DaysCount = [SELECT count() FROM MST_Action_Count__c WHERE Date_Triggered__c = LAST_N_DAYS:30 AND Metadata_Survey_Trigger__c = :msTrigger.Id LIMIT :LIMIT_QUERY_ROW];
            last60DaysCount = [SELECT count() FROM MST_Action_Count__c WHERE Date_Triggered__c = LAST_N_DAYS:60 AND Metadata_Survey_Trigger__c = :msTrigger.Id LIMIT :LIMIT_QUERY_ROW];
            last90DaysCount = [SELECT count() FROM MST_Action_Count__c WHERE Date_Triggered__c = LAST_N_DAYS:90 AND Metadata_Survey_Trigger__c = :msTrigger.Id LIMIT :LIMIT_QUERY_ROW];
            */
        }
        
    }
    

    /* +++++++ SELECTED FIELDSETS ++++++++++++++*/
    public List <String> getSelectedFieldSets () {
        if (selectedFieldSets == null) {
            selectedFieldSets = new List <String> ();
            if (msTrigger.Survey_Fieldset__c != null)
            selectedFieldSets.addAll (msTrigger.Survey_Fieldset__c.split(SPLIT_DELIMITER));
        }
        return selectedFieldSets;
    }

    /* +++++++ SELECTED COUNTRIES ++++++++++++++*/
    public List <String> getSelectedCountries () {
        if (selectedCountries == null) {
            selectedCountries = new List <String> ();
            if (msTrigger.Country__c != null)
            selectedCountries.addAll (msTrigger.Country__c.split(SPLIT_DELIMITER));
        }
        return selectedCountries;
    }

    /* +++++++ SELECTED LANGUAGES ++++++++++++++*/

    public List <String> getSelectedLanguages () {
        if (selectedLanguages == null) {
            selectedLanguages = new List <String> ();
            if (msTrigger.Language__c != null)
            selectedLanguages.addAll (msTrigger.Language__c.split(SPLIT_DELIMITER));
        }
        return selectedLanguages;
    }

    /* +++++++ SELECTED CONTACT METHODS ++++++++++++++*/

    public List <String> getSelectedContactMethods () {
        if (selectedContactMethods == null) {
            selectedContactMethods = new List <String> ();
            if (msTrigger.Contact_Method__c != null)
            selectedContactMethods.addAll (msTrigger.Contact_Method__c.split(SPLIT_DELIMITER));
        }
        return selectedContactMethods;
    }

    /* +++++++ SELECTED DIRECTIONS ++++++++++++++*/

    public List <String> getSelectedDirections () {
        if (selectedDirections == null) {
            selectedDirections = new List <String> ();
            if (msTrigger.Direction__c != null)
            selectedDirections.addAll (msTrigger.Direction__c.split(SPLIT_DELIMITER));
        }
        return selectedDirections;
    }

     /* +++++++ SELECTED SEGMENTS ++++++++++++++*/

    public List <String> getSelectedSegments () {
        if (selectedSegments == null) {
            selectedSegments = new List <String> ();
            if (msTrigger.Segment__c != null)
            selectedSegments.addAll (msTrigger.Segment__c.split(SPLIT_DELIMITER));
        }
        return selectedSegments;
    }



    /* +++++++ SELECTED BRANDS ++++++++++++++*/

    public List <String> getSelectedBrands () {
        if (selectedBrands == null) {
            selectedBrands = new List <String> ();
            if (msTrigger.Brand__c != null)
            selectedBrands.addAll (msTrigger.Brand__c.split(SPLIT_DELIMITER));
        }
        return selectedBrands;
    }



    /* +++++++ SELECTED L1 ++++++++++++++*/

    public List <String> getSelectedL1 () {
        if (selectedL1 == null) {
            selectedL1 = new List <String> ();
            if (msTrigger.Comment_Code_L1__c != null)
            selectedL1.addAll (msTrigger.Comment_Code_L1__c.split(SPLIT_DELIMITER));
        }
        return selectedL1;
    }



    /* +++++++ SELECTED L2 ++++++++++++++*/

    public List <String> getSelectedL2 () {
        if (selectedL2 == null) {
            selectedL2 = new List <String> ();
            if (msTrigger.Comment_Code_L2__c != null)
            selectedL2.addAll (msTrigger.Comment_Code_L2__c.split(SPLIT_DELIMITER));
        }
        return selectedL2;
    }

   

    /* +++++++ SELECTED L3 ++++++++++++++*/

    public List <String> getSelectedL3 () {
        if (selectedL3 == null) {
            selectedL3 = new List <String> ();
            if (msTrigger.Comment_Code_L3__c != null)
            selectedL3.addAll (msTrigger.Comment_Code_L3__c.split(SPLIT_DELIMITER));
        }
        return selectedL3;
    }

    public List <Local_Product__c> getProducts () {
        String q = '';
        Set <String> countrySet = new Set <String> ();
        Set <String> brandSet = new Set <String> ();
        Set <String> segmentSet = new Set <String> ();
        
        
        String likeProductPath = '';
        
        q += 'SELECT Id, Name, Translated_Path__c, Global_Product__r.Path__c, Global_Product__r.Brand__c, Global_Product__r.Segment__c, Country__c FROM Local_Product__c WHERE Id != null ';

        if (msTrigger.Trigger_Type__c == 'Level') {
            
            if (!msTrigger.Country__c.contains('*') && !getSelectedCountries().isEmpty()) {
               
                q += ' AND Country__c IN (';
                
                for (String s: getSelectedCountries()) {
                    q += '\'' + s + '\',';
                }
                
                q = q.removeEnd(',');
                q += ') ';
            }
            
            if (!msTrigger.Brand__c.contains('*') && !getSelectedBrands().isEmpty()) {
               
                q += ' AND Global_Product__r.Brand__c IN (';
                
                for (String s: getSelectedBrands()) {
                    q += '\'' + s + '\',';
                }
                
                q = q.removeEnd(',');
                q += ') ';
            }

            if (!msTrigger.Segment__c.contains('*') && !getSelectedSegments().isEmpty()) {
               
                q += ' AND Global_Product__r.Segment__c IN (';
                
                for (String s: getSelectedSegments()) {
                    q += '\'' + s + '\',';
                }
                q = q.removeEnd(',');
                q += ') ';
            }
            
        } else if (msTrigger.Trigger_Type__c == 'Path') {
            likeProductPath = msTrigger.Product_Path__c + '%';

            q += ' AND Global_Product__r.Path__c LIKE :likeProductPath';
        }

        q += ' LIMIT 1000';

        System.debug(LoggingLevel.INFO, '##### Product query \n' + q);

        return (List <Local_Product__c>) Database.query(q);
    }
   
    public List <Local_Comment_Code__c> getComments () {
        String q = '';
        String likeCommentPath = '';
        q += 'SELECT Id, Global_Comment_Code__r.Full_Comment_Path__c, Name, Translated_Language__c, Level_1__c, Level_2__c, Level_3__c FROM Local_Comment_Code__c WHERE Id != null ';

        if (msTrigger.Trigger_Type__c == 'Level') {
            if (!msTrigger.Comment_Code_L1__c.contains('*') && !getSelectedL1().isEmpty()) {
               
                q += ' AND Global_Comment_Code__r.Level_1__c IN (';
                
                for (String s: getSelectedL1()) {
                    q += '\'' + s + '\',';
                }
                q = q.removeEnd(',');
                q += ') ';
            }

            if (!msTrigger.Comment_Code_L2__c.contains('*') && !getSelectedL2().isEmpty()) {
               
                q += ' AND Global_Comment_Code__r.Level_2__c IN (';
                
                for (String s: getSelectedL2()) {
                    q += '\'' + s + '\',';
                }
                q = q.removeEnd(',');
                q += ') ';
            }

            if (!msTrigger.Comment_Code_L3__c.contains('*') && !getSelectedL3().isEmpty()) {
               
                q += ' AND Global_Comment_Code__r.Level_3__c IN (';
                
                for (String s: getSelectedL3()) {
                    q += '\'' + s + '\',';
                }
                q = q.removeEnd(',');
                q += ') ';
            }

            if (!msTrigger.Language__c.contains('*') && !getSelectedLanguages().isEmpty()) {
                q += ' AND Translated_Language__c IN (';
                for (String s: getSelectedLanguages()) {
                     q += '\'' + s + '\',';
                }
                q = q.removeEnd(',');
                q += ') ';
            }

        } else if (msTrigger.Trigger_Type__c == 'Path') {
            likeCommentPath = msTrigger.Comment_Code_Path__c  + '%';
            q += ' AND Global_Comment_Code__r.Full_Comment_Path__c LIKE ' + '\'' + likeCommentPath + '\'';   
        }
        q += ' LIMIT 1000';
        System.debug(LoggingLevel.INFO, '##### Comment query \n' + q);

        return (List <Local_Comment_Code__c>)Database.query(q);
    }
}