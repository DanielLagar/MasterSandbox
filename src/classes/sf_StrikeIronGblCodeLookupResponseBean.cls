/*
  * @author: Oleg Rikkers
  * @date: 05/22/2014

  * @description: StrikeIron 
  * http://ws.strikeiron.com/StrikeIron/GlobalPostalCodeLookup2/GlobalPostalCodeLookup
  * 
  *  
  */


public with sharing class sf_StrikeIronGblCodeLookupResponseBean {
	


	public String statusNbr {get; set;}
	public String statusDescription {get; set;}
	public String xmlString {get; set;}
  	public Double processingTimeMs {get; set;}

  	public String streetName {get; set;}
  	public String city {get; set;}
  	public String stateOrProvince {get; set;}
  	public String postalOrZIPCode {get; set;}
  	public String country {get; set;}



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