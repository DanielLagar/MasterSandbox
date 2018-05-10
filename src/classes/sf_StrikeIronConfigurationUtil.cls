/*
  * @author: Oleg Rikkers
  * @date: 05/13/2014

  * @description: A utility class for accessing and setting up custom settings for strike iron web services
  * hawn.jf@pg.com
  *  Password01
  */
  
  
  
public with sharing class sf_StrikeIronConfigurationUtil {

    private static sf_StrikeIronConfigurationUtil config;
    
    private sf_StrikeIronConfigurationUtil () {}
    
    public static sf_StrikeIronConfigurationUtil getInstance() {
        if (config == null) {
            config = new sf_StrikeIronConfigurationUtil ();
        }
        
        return config;
    }
    
    public String getUsername () {
        StrikeIronConfiguration__c siCon = StrikeIronConfiguration__c.getInstance('username');
        if (siCon == null) { 
            return '';
        } else {
            return siCon.Value__c;
        }
    }
    
    public String getPassword () {
        StrikeIronConfiguration__c siCon = StrikeIronConfiguration__c.getInstance('password');
        if (siCon == null) { 
            return '';
        } else {
            return siCon.Value__c;
        }  
    }
    
    public String getZipCodeLookupUrl () {
        StrikeIronConfiguration__c siCon = StrikeIronConfiguration__c.getInstance('zipCodeLookUpUrl');
        if (siCon == null) { 
            return '';
        } else {
            return siCon.Value__c;
        }
    }

   public String getGlobalCodeLookupUrl () {
        StrikeIronConfiguration__c siCon = StrikeIronConfiguration__c.getInstance('globalCodeLookUpUrl');
        if (siCon == null) { 
            return '';
        } else {
            return siCon.Value__c;
        }
    }

    public String getValidateEmailUrl () {
        StrikeIronConfiguration__c siCon = StrikeIronConfiguration__c.getInstance('validateEmailUrl');
        if (siCon == null) { 
            return '';
        } else {
            return siCon.Value__c;
        }
    }

    public String getValidateAddressUrl () {
        StrikeIronConfiguration__c siCon = StrikeIronConfiguration__c.getInstance('validateAddressUrl');
        if (siCon == null) { 
            return '';
        } else {
            return siCon.Value__c;
        }
    }

    public String getValidateEmailTimeoutSeconds () {
        StrikeIronConfiguration__c siCon = StrikeIronConfiguration__c.getInstance('validateEmailTimeoutSeconds');
        if (siCon == null) { 
            return '';
        } else {
            return siCon.Value__c;
        }
    }

    public static void initSettings () {
        List <StrikeIronConfiguration__c> siConList = new List <StrikeIronConfiguration__c> ();
        StrikeIronConfiguration__c siCon = new StrikeIronConfiguration__c (Name='username', Value__c = 'user@example.com');
        siConList.add(siCon);

        StrikeIronConfiguration__c siCon1 = new StrikeIronConfiguration__c (Name='password', Value__c = 'password');
        siConList.add(siCon1);

        StrikeIronConfiguration__c siCon2 = new StrikeIronConfiguration__c (Name='zipCodeLookUpUrl', Value__c = 'http://ws.strikeiron.com/StrikeIron/ZIPPostalCodeInfo5/AdvancedZipInfo');
        siConList.add(siCon2);

        StrikeIronConfiguration__c siCon3 = new StrikeIronConfiguration__c (Name='validateEmailUrl', Value__c = 'http://ws.strikeiron.com/StrikeIron/emv6Hygiene');
        siConList.add(siCon3);

        StrikeIronConfiguration__c siCon4 = new StrikeIronConfiguration__c (Name='validateAddressUrl', Value__c = 'http://ws.strikeiron.com/StrikeIron/GlobalAddressVerification5/GlobalAddressVerification');
        siConList.add(siCon4);

        StrikeIronConfiguration__c siCon5 = new StrikeIronConfiguration__c (Name='validateEmailTimeoutSeconds', Value__c = '5');
        siConList.add(siCon5);

        StrikeIronConfiguration__c siCon6 = new StrikeIronConfiguration__c (Name='globalCodeLookUpUrl', Value__c = 'http://ws.strikeiron.com/StrikeIron/GlobalPostalCodeLookup3/GlobalPostalCodeLookup');
        siConList.add(siCon6);

        Database.insert (siConList, false); // only add what is missing
    }
}