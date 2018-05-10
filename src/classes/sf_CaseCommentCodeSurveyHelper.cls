/*
* @author: Oleg Rikkers
* @date: 06/26/2014

* @description: 
* As a user enters comment codes, system checks for MST and creates survey.
* 
*  Upon deleting a comment code, since the survey is already created and there is no code to delete it when the related comment is deleted. 
*  It will remain attached to the case.
*/



public with sharing class sf_CaseCommentCodeSurveyHelper {
 

//sfdc 08/11/15 - looks like the class is no longer used and can be deleted

   

/*    public static void processNewCaseCommentCodes (Map <Id, Case_Comment_Code__c> triggerNewMap) {
        
        //map contains MST records for every CCC
        Map <Id, List<Metadata_Survey_Trigger__c>> cccMstListMap = new Map <Id, List<Metadata_Survey_Trigger__c>> ();
        
        //ok this is potentially an exception, but for now that is the only way I see it happens. Up to 100 CCC per transaction
        for (Case_Comment_Code__c ccc: triggerNewMap.values()) {
            String q = '';
            String likeDirection = '%' + ccc.Case_Direction__c + '%';
            String likeContactMethod =  '%' + ccc.Case_Contact_Method__c + '%';
            String likeCountry =  '%' + ccc.Product_Country__c + '%';
            String likeLanguage =  '%' + ccc.Comment_Language__c + '%';
            String likeSegment =  '%' + ccc.Global_Product_Segment__c + '%';
            String likeBrand =  '%' + ccc.Product_Brand__c + '%';
            String likeL1 =  '%' + ccc.GCC_Level_1__c + '%';
            String likeL2 =  '%' + ccc.GCC_Level_2__c + '%';
            String likeL3 =  '%' + ccc.GCC_Level_3__c + '%';


            q += 'SELECT Id, Survey_Object__c, Type__c FROM Metadata_Survey_Trigger__c ';
            q += ' WHERE (Direction__c LIKE :likeDirection OR Direction__c = \'*|\')';
             q += 'AND (Contact_Method__c LIKE :likeContactMethod OR Contact_Method__c = \'*|\')';
            
            q += ' AND (';

            //level trigger type
            q += ' (Trigger_Type__c = \'Level\' ';
                q += ' AND ( ';
           
                q += ' (Country__c LIKE :likeCountry OR Country__c = \'*|\')';
                q += ' AND ';
                q += ' (Language__c LIKE :likeLanguage OR Language__c = \'*|\')';
                q += ' AND ';
                q += ' (Segment__c LIKE :likeSegment OR Segment__c = \'*|\')';
                q += ' AND ';
                q += ' (Brand__c LIKE :likeBrand OR Brand__c = \'*|\')';
                q += ' AND ';
                q += ' (Comment_Code_L1__c LIKE :likeL1 OR Comment_Code_L1__c = \'*|\')';
                q += ' AND ';
                q += ' (Comment_Code_L2__c LIKE :likeL2 OR Comment_Code_L2__c = \'*|\')';
                q += ' AND ';
                q += ' (Comment_Code_L3__c LIKE :likeL3 OR Comment_Code_L3__c = \'*|\')';

                q += ' ) '; // end level type

            q += ') OR (';

            //path level
            q += ' Trigger_Type__c = \'Path\' AND (';

            List <String> productPathList = new List <String> ();
            
            if (ccc.Global_Product_Path__c != null) productPathList = ccc.Global_Product_Path__c.split('/');

            Integer i = 0;
            
            q += '(';
            String prodPath = '';
            for (String s: productPathList) {
                
                if (i==0) {
                    prodPath += s;
                } else {
                    prodPath += '/' + s;
                }

                if (i+1 != productPathList.size()) {
                    q += ' Product_Path__c =  \'' + prodPath + '\' OR ';
                } else {
                    q += ' Product_Path__c =  \'' + prodPath + '\'';
                }
                
                i++;
            }
            
            q+= ') ';

            List <String> commentCodePathList = new List <String> ();
            
            if (ccc.Global_Comment_Path__c != null) commentCodePathList = ccc.Global_Comment_Path__c.split('/');
            Integer n = 0;
            
            q+= ' AND (';
            String comPath = '';
            for (String s: commentCodePathList) {
                
                if (n==0) {
                    comPath += s;
                } else {
                    comPath += '/' + s;
                }

                if (n+1 != commentCodePathList.size()) {
                    q += ' Comment_Code_Path__c =  \'' + comPath + '\' OR ';
                } else {
                    q += ' Comment_Code_Path__c =  \'' + comPath + '\' )';
                }
                
                n++;
            }
            
            q += ')'; // end level

            q += '))'; //end path or level

            q += ' AND Active__c = true';
            q += ' AND (Expiration_Date__c >= TODAY OR Expiration_Date__c = null)';

            System.debug(LoggingLevel.INFO, '####### MST query = \n ' + q);

            try {
                List <Metadata_Survey_Trigger__c> mstList = Database.query(q);
                System.debug(LoggingLevel.INFO, '####### MST query records returned \n ' + mstList);
                cccMstListMap.put (ccc.Id, mstList);
            } catch (Exception e) {
                System.debug('####### MST EXCEPTION: \n ' + e.getStackTraceString() + '-' + e.getLineNumber() + ' - ' + e.getTypeName());
            }
        }
        // list of new surveys to insert
        List <SObject> surveysToInsert = new List <SObject> ();
        List <MST_Action_Count__c> mstAction = new List <MST_Action_Count__c> ();

        

        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        for (Case_Comment_Code__c ccc: triggerNewMap.values()) {
            
            if (cccMstListMap.get(ccc.Id) != null) {
                for (Metadata_Survey_Trigger__c mst: cccMstListMap.get(ccc.Id)) {
                    if (globalDescribe.get(mst.Survey_Object__c) != null) {
                        sObject sObj = globalDescribe.get(mst.Survey_Object__c).newSObject();
                        sObj.put ('Case__c', ccc.Case__c);
                        sObj.put ('Metadata_Survey_Trigger__c', mst.Id);
                        
                        
                        if (mst.Survey_Object__c == 'Survey__c') {
                            sObj.put ('Survey_Type__c', mst.Type__c);
                            sObj.put ('Case_Product__c', ccc.Case_Product__c);
                            sObj.put ('Case_Comment_Code__c', ccc.Id);
                        }

                        if (mst.Survey_Object__c == 'Safety_Assessment_Survey__c') {
                            if (ccc.Case_Contact_Id__c != null) 
                                sObj.put ('Case_Contact_Id__c', ccc.Case_Contact_Id__c);
                                //ok this is absolutely illegal, but we are not going to bulk create comments, so WTH
                                Survey_Comment_Product__c scp = new Survey_Comment_Product__c ();
                                scp.Case_Product__c = ccc.Case_Product__c;
                                insert scp;
                                sObj.put ('Survey_Comment_Product__c', scp.Id);
                        }

                        surveysToInsert.add (sObj); 
                    } 
                }
            }
        }

        insert surveysToInsert;

        for (SObject so: surveysToInsert) {
            Id mstId = (Id) so.get('Metadata_Survey_Trigger__c');
            mstAction.add (new MST_Action_Count__c (Metadata_Survey_Trigger__c = mstId, Date_Triggered__c = System.now()));
        }

        insert mstAction;
    } 

    */
}