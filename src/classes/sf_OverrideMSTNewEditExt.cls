/*
* @author: orikkers@salesforce.com  
* @date: 06/25/2014
* @description:  controller extension for sf_OverrideMSTNewEdit page. 
*/

public with sharing class sf_OverrideMSTNewEditExt {
    
    private Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    private static final Integer LIMIT_QUERY_ROW = Limits.getLimitQueryRows();
    private static final String SPLIT_DELIMITER = '\\|';
    public static final String JOIN_DELIMITER = '|';

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
    
    public Metadata_Survey_Trigger__c msTrigger {get; set;}

    public sf_OverrideMSTNewEditExt(ApexPages.StandardController sc) {
        
        try {
            msTrigger = (Metadata_Survey_Trigger__c) sc.getRecord();

            populateBrandSegment();

        } catch (Exception e){
            ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, e.getMessage() + ' - ' + e.getStackTraceString()));
        }
    }

    public List <SelectOption> objectsOptionsList {
        get {
            if (objectsOptionsList == null) {
                objectsOptionsList = new List <SelectOption> {new SelectOption ('', '-- Select Object --')};
                for (String s: gd.keySet()) {
                    if (s.containsIgnoreCase('Survey')) {
                        String label = gd.get(s).getDescribe().getLabel();
                        label += ' (';
                        label += gd.get(s).getDescribe().getName();
                        label += ')';
                        objectsOptionsList.add (new SelectOption (s,  label));
                    }
                }
            }
            return objectsOptionsList;
        } 
        set;
    }

    //ChrisM WR96 - replace the soql based approach with describe
    public List <SelectOption> countryOptionsList {
        get{
            if (countryOptionsList == null){
                countryOptionsList = new List <SelectOption> {new SelectOption ('*', 'ALL')};
                //Describe Case Country picklist as the Country field on the local product objec is a text field
				Schema.DescribeFieldResult field = Case.Country__c.getDescribe();

				for(Schema.PicklistEntry f : field.getPicklistValues()){
					countryOptionsList.add(new SelectOption(f.getValue(),f.getLabel()));
				}
			}         
            return countryOptionsList;    
        }
        set;
    }    
    //ChrisM: The below uses SOQL as the country field on the Local Product object is a text field
    //NOT a picklist
    /*public List <SelectOption> countryOptionsList {
        get {
            if (countryOptionsList == null) {
                countryOptionsList = new List <SelectOption> {new SelectOption ('*', 'ALL')};

                for (AggregateResult ar: [SELECT Country__c FROM Local_Product__c WHERE Inactive__c = false GROUP BY Country__c LIMIT :LIMIT_QUERY_ROW]){
                    if (ar.get('Country__c') != null) {
                        String label = String.valueOf(ar.get('Country__c'));
                        countryOptionsList.add (new SelectOption(label, label));
                    }
                }
            }
            return countryOptionsList;
        }

        set;
    }*/

    public List <SelectOption> languageOptionsList {
        get {
            if (languageOptionsList == null) {
                languageOptionsList = new List <SelectOption> {new SelectOption ('*', 'ALL')};

                //use case language for picklist
                Map <String, Schema.SObjectField> fieldMap = gd.get('Case').getDescribe().fields.getMap();

                // Get the list of picklist values for language field.
                List <Schema.PicklistEntry> values = fieldMap.get('Language__c').getDescribe().getPickListValues();
                
                // Add these values to the selectoption list.
                for (Schema.PicklistEntry a : values){ 
                    languageOptionsList.add(new SelectOption(a.getLabel(), a.getValue())); 
                }

            }
            return languageOptionsList;
        }
        set;
    }

    public List <SelectOption> caseDirectionOptionsList {
        get {
            if (caseDirectionOptionsList == null) {
                caseDirectionOptionsList = new List <SelectOption> {new SelectOption ('*', 'ALL')};

                //use case language for picklist
                Map <String, Schema.SObjectField> fieldMap = gd.get('Case').getDescribe().fields.getMap();

                // Get the list of picklist values for language field.
                List <Schema.PicklistEntry> values = fieldMap.get('Direction__c').getDescribe().getPickListValues();
                
                // Add these values to the selectoption list.
                for (Schema.PicklistEntry a : values){ 
                    caseDirectionOptionsList.add(new SelectOption(a.getLabel(), a.getValue())); 
                }

            }
            return caseDirectionOptionsList;
        }
        set;
    }

    public List <SelectOption> contactMethodOptionsList {
        get {
            if (contactMethodOptionsList == null) {
                contactMethodOptionsList = new List <SelectOption> {new SelectOption ('*', 'ALL')};

                //use case language for picklist
                Map <String, Schema.SObjectField> fieldMap = gd.get('Case').getDescribe().fields.getMap();

                // Get the list of picklist values for language field.
                List <Schema.PicklistEntry> values = fieldMap.get('Origin').getDescribe().getPickListValues();
                
                // Add these values to the selectoption list.
                for (Schema.PicklistEntry a : values){ 
                    contactMethodOptionsList.add(new SelectOption(a.getLabel(), a.getValue())); 
                }

            }
            return contactMethodOptionsList;
        }
        set;
    }

    public void populateBrandSegment () {

        Set <String> countrySet = new Set <String> ();
        countrySet.addAll (getSelectedCountries());

        //System.debug(LoggingLevel.INFO, countrySet);//chrisM
            
        if (!countrySet.isEmpty()) {
            brandOptionsList = null;
            segmentOptionsList = null;
            
            Set <String> brands = new Set <String> ();
            Set <String> segments = new Set <String> ();
            
            String q;
            if (!countrySet.contains('*')) {
                q = 'SELECT Global_Product__r.Path__c, Path_Level__c FROM Local_Product__c ';
                q += 'WHERE Global_Product__r.Path_Level__c = \'SEGMENT\'';
                q += ' AND Country__c IN :countrySet';
                q += ' LIMIT :LIMIT_QUERY_ROW';
                
                List <Local_Product__c> lpList = Database.query(q);

                for (Local_Product__c lp: lpList) {
                    List <String> paths = new List <String> ();
                    paths = lp.Global_Product__r.Path__c.split ('/');
    
                    //System.debug(LoggingLevel.INFO, paths);//ChrisM
                    
                    if (paths.size()>1) {
                        brands.add (paths[0]);
                        segments.add (paths[1]);
                    }
                }
                
            } else {
                q = 'SELECT Path__c FROM Global_Product__c ';
                q += 'WHERE Path_Level__c = \'SEGMENT\'';
                q += ' LIMIT :LIMIT_QUERY_ROW';
                
                List <Global_Product__c> gpList = Database.query(q);
                for (Global_Product__c gp: gpList) {
                    List <String> paths = new List <String> ();
                    paths = gp.Path__c.split ('/');
                    
                    if (paths.size()>1) {
                        brands.add (paths[0]);
                        segments.add (paths[1]);
                    }
                }
            }
            
            for (String s: brands) {
                brandOptionsList.add (new SelectOption(s,s));
            }
            
            for (String s: segments) {
                segmentOptionsList.add (new SelectOption(s,s));
            }

            brandOptionsList.sort(); 
            segmentOptionsList.sort();
        }
    }

    public List <SelectOption> segmentOptionsList {
        get {
            if (segmentOptionsList == null) {
                segmentOptionsList = new List <SelectOption> {new SelectOption ('*', 'ALL')};
            }
            return segmentOptionsList;
        }

        set;
    }

    public List <SelectOption> brandOptionsList {
        get {
            if (brandOptionsList == null) {
                brandOptionsList = new List <SelectOption> {new SelectOption ('*', 'ALL')};
            }
            return brandOptionsList;
        }

        set;
    }
    
    public List <SelectOption> l1OptionsList {
        get {
            if (l1OptionsList == null) {
                l1OptionsList = new List <SelectOption> {new SelectOption ('*', 'ALL')};

                for (AggregateResult ar: [SELECT Level_1__c FROM Global_Comment_Code__c GROUP BY Level_1__c LIMIT :LIMIT_QUERY_ROW]){
                    if (ar.get('Level_1__c') != null) {
                        String label = String.valueOf(ar.get('Level_1__c'));
                        l1OptionsList.add (new SelectOption (label, label));
                    }
                }
            }
            return l1OptionsList;
        }

        set;
    }

    public List <SelectOption> l2OptionsList {
        get {
            if (l2OptionsList == null) {
                l2OptionsList = new List <SelectOption> {new SelectOption ('*', 'ALL')};
                Set <String> l1Set = new Set <String> ();
                l1Set.addAll (selectedL1);

                if (!l1Set.isEmpty()) {

                    String q = 'SELECT Level_2__c FROM Global_Comment_Code__c';
                    if (!l1Set.contains('*')) {
                        q += ' WHERE Level_1__c IN :l1Set ';
                    }

                    q += ' GROUP BY Level_2__c LIMIT :LIMIT_QUERY_ROW';

                    List <AggregateResult> arList = Database.query(q);

                    for (AggregateResult ar: arList){
                        if (ar.get('Level_2__c') != null) {
                            String label = String.valueOf(ar.get('Level_2__c'));
                            l2OptionsList.add (new SelectOption (label, label));
                        }
                    }
                } 
            }
            return l2OptionsList;
        }

        set;
    }

    public List <SelectOption> l3OptionsList {
        get {
            if (l3OptionsList == null) {
                l3OptionsList = new List <SelectOption> {new SelectOption ('*', 'ALL')};
                Set <String> l2Set = new Set <String> ();
                l2Set.addAll (selectedL2);

                if (!l2Set.isEmpty()) {

                    String q = 'SELECT Level_3__c FROM Global_Comment_Code__c';
                    if (!l2Set.contains('*')) {
                        q += ' WHERE Level_2__c IN :l2Set ';
                    }

                    q += ' GROUP BY Level_3__c LIMIT :LIMIT_QUERY_ROW';

                    List <AggregateResult> arList = Database.query(q);

                    for (AggregateResult ar: arList){
                        if (ar.get('Level_3__c') != null) {
                            String label = String.valueOf(ar.get('Level_3__c'));
                            l3OptionsList.add (new SelectOption (label, label));
                        }
                    }
                } 
            }
            return l3OptionsList;
        }

        set;
    }

    public void populateL2Options () {
        l2OptionsList = null;
    }
    public void populateL3Options () {
        l3OptionsList = null;
    }

    public List <SelectOption> fieldSetOptionsList {
        get {
            if (fieldSetOptionsList == null) {
                fieldSetOptionsList = new List <SelectOption> ();
                if (!String.isEmpty(msTrigger.Survey_Object__c)) {
                    
                    Map <String, Schema.FieldSet> fieldSetMap= gd.get(msTrigger.Survey_Object__c).getDescribe().fieldSets.getMap();
                    if (!fieldSetMap.keySet().isEmpty()) {
                       
                        for (String s: fieldSetMap.keySet()) {
                            fieldSetOptionsList.add (new SelectOption(s, s));
                        }
                    }    
                }
            }

            return fieldSetOptionsList;
        } 
        set;
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

    public void setSelectedFieldSets (List <String> selectedFieldSets) {
        this.selectedFieldSets = selectedFieldSets;
        msTrigger.Survey_Fieldset__c = '';
        for (String s: selectedFieldSets) {
            msTrigger.Survey_Fieldset__c += s + JOIN_DELIMITER;
        }
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

    public void setSelectedCountries (List <String> selectedCountries) {
        this.selectedCountries = selectedCountries;
        msTrigger.Country__c = '';
        for (String s: selectedCountries) {
            msTrigger.Country__c += s + JOIN_DELIMITER;
        }
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

    public void setSelectedLanguages (List <String> selectedLanguages) {
        this.selectedLanguages = selectedLanguages;
        msTrigger.Language__c = '';
        for (String s: selectedLanguages) {
            msTrigger.Language__c += s + JOIN_DELIMITER;
        }
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

    public void setSelectedContactMethods (List <String> selectedContactMethods) {
        this.selectedContactMethods = selectedContactMethods;
        msTrigger.Contact_Method__c = '';
        for (String s: selectedContactMethods) {
            msTrigger.Contact_Method__c += s + JOIN_DELIMITER;
        }
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

    public void setSelectedDirections (List <String> selectedDirections) {
        this.selectedDirections = selectedDirections;
        msTrigger.Direction__c = '';
        for (String s: selectedDirections) {
            msTrigger.Direction__c += s + JOIN_DELIMITER;
        }
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

    public void setselectedSegments (List <String> selectedSegments) {
        this.selectedSegments = selectedSegments;
        msTrigger.Segment__c = '';
        for (String s: selectedSegments) {
            msTrigger.Segment__c += s + JOIN_DELIMITER;
        }
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

    public void setselectedBrands (List <String> selectedBrands) {
        this.selectedBrands = selectedBrands;
        msTrigger.Brand__c = '';
        for (String s: selectedBrands) {
            msTrigger.Brand__c += s + JOIN_DELIMITER;
        }
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

    public void setselectedL1 (List <String> selectedL1) {
        this.selectedL1 = selectedL1;
        msTrigger.Comment_Code_L1__c = '';
        for (String s: selectedL1) {
            msTrigger.Comment_Code_L1__c += s + JOIN_DELIMITER;
        }
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

    public void setselectedL2 (List <String> selectedL2) {
        this.selectedL2 = selectedL2;
        msTrigger.Comment_Code_L2__c = '';
        for (String s: selectedL2) {
            msTrigger.Comment_Code_L2__c += s + JOIN_DELIMITER;
        }
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

    public void setselectedL3 (List <String> selectedL3) {
        this.selectedL3 = selectedL3;
        msTrigger.Comment_Code_L3__c = '';
        for (String s: selectedL3) {
            msTrigger.Comment_Code_L3__c += s + JOIN_DELIMITER;
        }
    }

    public void populateFieldSetOptions () {
        //get the fields set map
        fieldSetOptionsList = null;//clear it
        selectedFieldSets = null;
        msTrigger.Survey_Fieldset__c = null;
    }

    public PageReference save () {

        if (msTrigger.Trigger_Type__c == 'Level') {
            msTrigger.Country__c = String.isEmpty(msTrigger.Country__c) ? '*|' : msTrigger.Country__c;
            msTrigger.Language__c = String.isEmpty(msTrigger.Language__c) ? '*|' : msTrigger.Language__c;
            msTrigger.Brand__c = String.isEmpty(msTrigger.Brand__c) ? '*|' : msTrigger.Brand__c;
            msTrigger.Segment__c = String.isEmpty(msTrigger.Segment__c) ? '*|' : msTrigger.Segment__c;
            msTrigger.Direction__c = String.isEmpty(msTrigger.Direction__c) ? '*|' : msTrigger.Direction__c;
            msTrigger.Contact_Method__c = String.isEmpty(msTrigger.Contact_Method__c) ? '*|' : msTrigger.Contact_Method__c;
            msTrigger.Comment_Code_L1__c = String.isEmpty(msTrigger.Comment_Code_L1__c) ? '*|' : msTrigger.Comment_Code_L1__c;
            msTrigger.Comment_Code_L2__c = String.isEmpty(msTrigger.Comment_Code_L2__c) ? '*|' : msTrigger.Comment_Code_L2__c;
            msTrigger.Comment_Code_L3__c = String.isEmpty(msTrigger.Comment_Code_L3__c) ? '*|' : msTrigger.Comment_Code_L3__c;
        }

        if (String.isEmpty(msTrigger.Survey_Fieldset__c)) {
            ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, 'Survey Fieldset is required.'));
            return null;
        }
       

        try {
            upsert msTrigger;
            return new PageReference ('/' + msTrigger.Id);
        } catch (Exception e) {
            ApexPages.addMessages (e);
            return null;
        }
    }
}