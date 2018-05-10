/**
*@author: christopher.j.doyle@accenture.com
*@date: 02/03/2016
*@description: Controller for robotsText.page that determines if the evnironment is a Sandbox or Production
*@WR: 221 Robots.txt - Update to allow crawlers
**/ 
public class ctr_robotExtn {
   
    /*CMD example*/
	public String valueToDisplay{get;set;}
	
	//Find out if the environment is production or a sandbox
    boolean isItASandbox = [SELECT isSandbox FROM Organization LIMIT 1].isSandbox;
    
    //Call controlelr
    public ctr_robotExtn(){
        
        String queryFilter = 'Sandbox';
        String query = 'Select Robots_txt_Value__c from Metadata_RobotTxt__c WHERE Name = \'';
        
        //If the environment is not a sandbox replace the queryFilter with 'Production'
        if(!isItASandbox){
            
            queryFilter = 'Production';
            
        }
        
        query += queryFilter + '\' LIMIT 1';
        system.debug('>>>query'+query);
        
        //Run the database query
        list<Metadata_RobotTxt__c> listToDisplay = Database.query(query);
        //pass valueToDisplay to screen
       
        
        if(!listToDisplay.isEmpty()){
             valueToDisplay = listToDisplay[0].Robots_txt_Value__c;
        }
        else {
            valueToDisplay = 'Disallow: / # disallow indexing of all pages.';
        }

    }
}