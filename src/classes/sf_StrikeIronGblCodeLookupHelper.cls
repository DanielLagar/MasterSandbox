/*
  * @author: Oleg Rikkers
  * @date: 05/13/2014

  * @description: creates request xml for GlobalPostalCode Lookup request and processes response
  * 
  *  
  */

public with sharing class sf_StrikeIronGblCodeLookupHelper {
	
	private static sf_StrikeIronConfigurationUtil configUtil = sf_StrikeIronConfigurationUtil.getInstance();
    
    public static String createRequestXML (String postalCode, String country) {
        String xml = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.strikeiron.com" xmlns:str="http://www.strikeiron.com">';
        //header
        xml += '<soapenv:Header><ws:LicenseInfo><ws:RegisteredUser>';
        xml += '<ws:UserID>' + configUtil.getUsername() + '</ws:UserID>';
        xml += '<ws:Password>' + configUtil.getPassword() +'</ws:Password>';
        xml += '</ws:RegisteredUser></ws:LicenseInfo></soapenv:Header>';
        
        //body
        xml += '<soapenv:Body><str:LookupPostalCode>';
        xml += '<str:PostalOrZIPCode>' + postalCode + '</str:PostalOrZIPCode>';
        xml += '<str:Country>' + country + '</str:Country>';
        xml += '</str:LookupPostalCode></soapenv:Body></soapenv:Envelope>';
        
        return xml;
    }
    
    public static sf_StrikeIronGblCodeLookupResponseBean parseResponse (Dom.Document doc) {
        
        sf_StrikeIronGblCodeLookupResponseBean bean = new sf_StrikeIronGblCodeLookupResponseBean ();
        bean.xmlString = doc.toXmlString();
        Dom.XmlNode root = doc.getRootElement();

        for (Dom.XmlNode node: root.getChildElements()) {
            if(node.getName()=='Body')  {
                for (Dom.XmlNode bodyNode: node.getChildElements()[0].getChildElements()[0].getChildElements()) {
                    if (bodyNode.getName() == 'ServiceStatus') {
                        for (Dom.XmlNode serviceNode: bodyNode.getChildElements()) {
                            if (serviceNode.getName() == 'StatusNbr') {
                                bean.statusNbr = serviceNode.getText();
                            } else if (serviceNode.getName() == 'StatusDescription') {
                                bean.statusDescription = serviceNode.getText();
                            }
                        }
                    } else if (bodyNode.getName() == 'ServiceResult') {
                        if (!bodyNode.getChildElements().isEmpty()) {
                            for (Dom.XmlNode resultNode: bodyNode.getChildElements()[0].getChildElements()) {
                                if (resultNode.getName() == 'City'){
                                    bean.city = resultNode.getText();
                                } else if (resultNode.getName() == 'StateOrProvince'){
                                    bean.stateOrProvince = resultNode.getText();
                                } else if (resultNode.getName() == 'PostalOrZIPCode'){
                                      bean.postalOrZIPCode = resultNode.getText();
                                } else if (resultNode.getName() == 'Country'){
                                      bean.country = resultNode.getText();
                                } else if (resultNode.getName() == 'StreetName'){
                                    bean.streetName = resultNode.getText().toUpperCase();
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return bean;
    
    }
}




/*
	
	POST http://ws.strikeiron.com/StrikeIron/GlobalPostalCodeLookup2/GlobalPostalCodeLookup HTTP/1.1
Accept-Encoding: gzip,deflate
Content-Type: text/xml;charset=UTF-8
SOAPAction: "http://www.strikeiron.com/LookupPostalCode"
Content-Length: 903
Host: ws.strikeiron.com
Connection: Keep-Alive
User-Agent: Apache-HttpClient/4.1.1 (java 1.5)


	<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.strikeiron.com" xmlns:str="http://www.strikeiron.com">
   <soapenv:Header>
      <ws:LicenseInfo>
         <!--Optional:-->
         <ws:RegisteredUser>
            <!--Optional:-->
            <ws:UserID>hawn.jf@pg.com</ws:UserID>
            <!--Optional:-->
            <ws:Password>Password01</ws:Password>
         </ws:RegisteredUser>
      </ws:LicenseInfo>
   </soapenv:Header>
   <soapenv:Body>
      <str:LookupPostalCode>
         <!--Optional:-->
         <str:PostalOrZIPCode>EC2R 8AH</str:PostalOrZIPCode>
         <!--Optional:-->
         <str:Country>UNITED KINGDOM</str:Country>
      </str:LookupPostalCode>
   </soapenv:Body>
</soapenv:Envelope>

*/


/*

	<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
   <Header xmlns="http://schemas.xmlsoap.org/soap/envelope/">
      <SubscriptionInfo xmlns="http://ws.strikeiron.com">
         <LicenseStatusCode>0</LicenseStatusCode>
         <LicenseStatus>Valid license key</LicenseStatus>
         <LicenseActionCode>0</LicenseActionCode>
         <LicenseAction>Decremented hit count</LicenseAction>
         <RemainingHits>299646</RemainingHits>
         <Amount>0</Amount>
      </SubscriptionInfo>
   </Header>
   <soap:Body>
      <LookupPostalCodeResponse xmlns="http://www.strikeiron.com">
         <LookupPostalCodeResult>
            <ServiceStatus>
               <StatusNbr>210</StatusNbr>
               <StatusDescription>Found</StatusDescription>
            </ServiceStatus>
            <ServiceResult>
               <LookupPostalCodeRecord>
                  <City>LONDON</City>
                  <StateOrProvince/>
                  <PostalOrZIPCode>EC2R 8AH</PostalOrZIPCode>
                  <Country>GBR</Country>
                  <StreetName>THREADNEEDLE STREET</StreetName>
               </LookupPostalCodeRecord>
            </ServiceResult>
         </LookupPostalCodeResult>
      </LookupPostalCodeResponse>
   </soap:Body>
</soap:Envelope>

*/