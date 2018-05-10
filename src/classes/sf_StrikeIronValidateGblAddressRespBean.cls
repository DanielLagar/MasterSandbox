/*
  * @author: Oleg Rikkers
  * @date: 05/19/2014

  * @description: StrikeIron 
  * http://ws.strikeiron.com/StrikeIron/GlobalAddressVerification5/GlobalAddressVerification
  * 
  *  
  */


public with sharing class sf_StrikeIronValidateGblAddressRespBean {
	    //ADDRESS VALIDATION

    /*
        SI Statuses for BASIC VALIDATE

        221 - Data correct on input (validated) 
        222 - Data corrected by web service 
        300 - Not Found 
        323 - Data cannot be corrected, but very likely to be deliverable                  
        324 - Data cannot be corrected, but fair chance that address is deliverable 
        325 - Data cannot be corrected, and unlikely to be deliverable 
        401 - At least one input address is required 
        402 - Input address cannot be empty 
        421 - No validation performed because country not unlocked 
        422 - No validation performed because country not recognized 
        500 - Internal Error 
        521 - Validation method not yet called (after parsing operation) 
        522 -  No validation performed because reference database not found 

    */
	public String statusNbr {get; set;}
	public String statusDescription {get; set;}
	public String xmlString {get; set;}
	public Double processingTimeMs {get; set;}

	public String buildingNumberMessage {get; set;}
	public String streetMessage {get; set;}
	public String cityMessage {get; set;}
	public String stateMessage {get; set;}
	public String zipMessage {get; set;}
	public String poBoxMessage {get; set;}
	public String buildingMessage {get; set;}
	public String orgMessage {get; set;}

	public String buildingNumberResult {get; set;}
	public String streetResult {get; set;}
	public String cityResult {get; set;}
	public String stateResult {get; set;}
	public String zipResult {get; set;}
	public String poBoxResult {get; set;}
	public String buildingResult {get; set;}
	public String orgResult {get; set;}

	public String org {get; set;}
	public String department {get; set;}
	public String contact {get; set;}
	public String buildingName {get; set;}
	public String streetNumber {get; set;}
	public String streetName {get; set;}
	public String poBox {get; set;}
	public String locality {get; set;}
	public String postalCode {get; set;}
	public String province {get; set;}
	public String country {get; set;}
	public String residue {get; set;}
	public String deliveryAddressLine {get; set;}
	public String countrySpecificLocalityLine {get; set;}
	public String formattedAddress {get; set;}
	public String resultPercentage {get; set;}
	public String elementMatchStatus {get; set;}
	public String elementMatchStatusTexts {get; set;}
	public String elementResultStatus {get; set;}
	public String elementResultStatusTexts {get; set;}


      /* This property returns formated StrikeIron output with just line breaks */
      public string getFormattedAddressWithHTMLBreaks() {
      	 
      	 	  System.debug('Controller_getFormattedAddressWithHTMLBreaks contact = ' + contact
      	 	  				+ '; BuildingName = ' + BuildingName
      	 	  				+ '; streetNumber = ' + streetNumber
      	 	  				+ '; StreetName = ' + StreetName
      	 	  				+ '; Locality = ' + Locality
      	 	  				+ '; Province = ' + Province
      	 	  				+ '; Country = ' + Country
      	 	  );
              String formatedaddresstemp = '';
              if(String.isNotBlank(contact) && contact.toLowerCase() != 'null')
              		formatedaddresstemp += (contact + '<br/>, ');
               if(String.isNotBlank(BuildingName) && BuildingName.toLowerCase() != 'null')
              		formatedaddresstemp += (BuildingName + ', ');
              		
              if(String.isNotBlank(streetNumber) && streetNumber.toLowerCase() != 'null')
              		formatedaddresstemp += streetNumber + ' ';
              		
              if(String.isNotBlank(StreetName) && StreetName.toLowerCase() != 'null')
              		formatedaddresstemp += StreetName;
              		
              if(String.isNotBlank(Locality) && Locality.toLowerCase() != 'null')
              		formatedaddresstemp += (',<br/>' + Locality);
              		
              if(String.isNotBlank(Province) && Province.toLowerCase() != 'null')
              		formatedaddresstemp += (',<br/>'+ Province);
              		
              if(String.isNotBlank(PostalCode) && PostalCode.toLowerCase() != 'null')
              		formatedaddresstemp += (', ' + PostalCode);
              		
              if(String.isNotBlank(Country) && Country.toLowerCase() != 'null')
              		formatedaddresstemp += (',<br/>' + Country);
              		

              		
              return formatedaddresstemp;
      }
      
      /* This property returns formated user's input with just line breaks */
      public static string getFormattedUserInputWithHTMLBreaks(String addressLine1, String addressLine2, String city, String state, String postalCode, String country){
              String formatedaddresstemp='';
              
              if(String.isNotBlank(addressLine1))
              		formatedaddresstemp = addressLine1;
              		
              if(String.isNotBlank(addressLine2))
              		formatedaddresstemp += ',<br/>' + addressLine2;
              		
              if(String.isNotBlank(city))
              		formatedaddresstemp += ',<br/>' + city;
              		
              if(String.isNotBlank(state))
              		formatedaddresstemp += ',<br/> ' + state;
              		
              if(String.isNotBlank(postalcode))
              		formatedaddresstemp += ', ' + postalCode + ',<br/>';
              		
              if(String.isNotBlank(country))
              		formatedaddresstemp +=  + country;
              		
              return formatedaddresstemp.toUpperCase();
      }
      
      /* This property returns formated StrikeIron output with just line breaks BRAZIL*/ 
      public string getFormattedAddressWithHTMLBreaksOption2() {
      	 
      	 	  System.debug('Controller_getFormattedAddressWithHTMLBreaks BRAZIL contact = ' + contact
      	 	  				+ '; BuildingName = ' + BuildingName
      	 	  				+ '; streetNumber = ' + streetNumber
      	 	  				+ '; StreetName = ' + StreetName
      	 	  				+ '; Locality = ' + Locality
      	 	  				+ '; Province = ' + Province
      	 	  				+ '; Country = ' + Country
      	 	  );
              String formatedaddresstemp = '';
              if(String.isNotBlank(contact) && contact.toLowerCase() != 'null')
              		formatedaddresstemp += (contact + '<br/>, ');
              		
              if(String.isNotBlank(BuildingName) && BuildingName.toLowerCase() != 'null')
              		formatedaddresstemp += (BuildingName + ', ');
              		
              if(String.isNotBlank(StreetName) && StreetName.toLowerCase() != 'null')
              		formatedaddresstemp += StreetName + ' ';
              		
              if(String.isNotBlank(streetNumber) && streetNumber.toLowerCase() != 'null')
              		formatedaddresstemp += streetNumber ;
              		
              if(String.isNotBlank(Locality) && Locality.toLowerCase() != 'null')
              		formatedaddresstemp += (',<br/>' + Locality);
              		
              if(String.isNotBlank(Province) && Province.toLowerCase() != 'null')
              		formatedaddresstemp += (',<br/> '+ Province);
              		
              if(String.isNotBlank(PostalCode) && PostalCode.toLowerCase() != 'null')
              		formatedaddresstemp += (',<br/> ' + PostalCode);
              		
              if(String.isNotBlank(Country) && Country.toLowerCase() != 'null')
              		formatedaddresstemp += (',<br/>' + Country);
              		
              return formatedaddresstemp;
      }
      
      /* This property returns formated user's input with just line breaks BRAZIL*/
      public static string getFormattedUserInputWithHTMLBreaksOption2(String addressLine1, String addressLine2, String city, String state, String postalCode, String country){
              String formatedaddresstemp='';
              
              if(String.isNotBlank(addressLine1))
              		formatedaddresstemp = addressLine1;
              		
              if(String.isNotBlank(addressLine2))
              		formatedaddresstemp += ',<br/>' + addressLine2;
              		
              if(String.isNotBlank(city))
              		formatedaddresstemp += ',<br/>' + city;
              		
              if(String.isNotBlank(state))
              		formatedaddresstemp += ', ' + state;
              		
              if(String.isNotBlank(postalcode))
              		formatedaddresstemp += ',<br/>' + postalCode;

              if(String.isNotBlank(country))
              		formatedaddresstemp += ',<br/>' + country;
              		
              return formatedaddresstemp.toUpperCase();
      }
      
      /* This property returns formated StrikeIron output with just line breaks ARGENTINA AND GERMANY*/ 
      public string getFormattedAddressWithHTMLBreaksOption3() {
      	 
      	 	  System.debug('Controller_getFormattedAddressWithHTMLBreaks ARGENTINA AND GERMANY contact = ' + contact
      	 	  				+ '; BuildingName = ' + BuildingName
      	 	  				+ '; streetNumber = ' + streetNumber
      	 	  				+ '; StreetName = ' + StreetName
      	 	  				+ '; Locality = ' + Locality
      	 	  				+ '; Province = ' + Province
      	 	  				+ '; Country = ' + Country
      	 	  );
              String formatedaddresstemp = '';
              if(String.isNotBlank(contact) && contact.toLowerCase() != 'null')
              		formatedaddresstemp += (contact + '<br/>, ');
              		
              if(String.isNotBlank(BuildingName) && BuildingName.toLowerCase() != 'null')
              		formatedaddresstemp += (BuildingName + ', ');
              		
              if(String.isNotBlank(streetNumber) && streetNumber.toLowerCase() != 'null')
              		formatedaddresstemp += streetNumber + ' ';
              		
              if(String.isNotBlank(StreetName) && StreetName.toLowerCase() != 'null')
              		formatedaddresstemp += StreetName;
              		
              if(String.isNotBlank(Locality) && Locality.toLowerCase() != 'null')
              		formatedaddresstemp += (',<br/>' + Locality);
              		
              if(String.isNotBlank(Province) && Province.toLowerCase() != 'null')
              		formatedaddresstemp += (',<br/>'+ Province);

              if(String.isNotBlank(PostalCode) && PostalCode.toLowerCase() != 'null')
              		formatedaddresstemp += (', ' + PostalCode);
              		
              if(String.isNotBlank(Country) && Country.toLowerCase() != 'null')
              		formatedaddresstemp += (',<br/>' + Country);
              		
              return formatedaddresstemp;
      }
      
      /* This property returns formated user's input with just line breaks ARGENTINA AND GERMANY*/
      public static string getFormattedUserInputWithHTMLBreaksOption3(String addressLine1, String addressLine2, String city, String state, String postalCode, String country){
              String formatedaddresstemp='';
              
              if(String.isNotBlank(addressLine1))
              		formatedaddresstemp = addressLine1;
              		
              if(String.isNotBlank(addressLine2))
              		formatedaddresstemp += ',<br/>' + addressLine2;
              		
              if(String.isNotBlank(city))
              		formatedaddresstemp += ',<br/>' + city;
              		
              if(String.isNotBlank(state))
              		formatedaddresstemp += ', ' + state;
              		
              if(String.isNotBlank(postalcode))
              		formatedaddresstemp += ', ' + postalCode;
              		
              if(String.isNotBlank(country))
              		formatedaddresstemp += ',<br/>' + country;
              		
              return formatedaddresstemp.toUpperCase();
      }
      
      
      /* This property returns formated StrikeIron output with just line breaks CHINA*/ 
      public string getFormattedAddressWithHTMLBreaksOption4() {
      	 
      	 	  System.debug('Controller_getFormattedAddressWithHTMLBreaks CHINA contact = ' + contact
      	 	  				+ '; BuildingName = ' + BuildingName
      	 	  				+ '; streetNumber = ' + streetNumber
      	 	  				+ '; StreetName = ' + StreetName
      	 	  				+ '; Locality = ' + Locality
      	 	  				+ '; Province = ' + Province
      	 	  				+ '; Country = ' + Country
      	 	  );
              String formatedaddresstemp = '';
              if(String.isNotBlank(contact) && contact.toLowerCase() != 'null')
              		formatedaddresstemp += (contact + '<br/>, ');
              		
              if(String.isNotBlank(BuildingName) && BuildingName.toLowerCase() != 'null')
              		formatedaddresstemp += (BuildingName + ', ');
              		
              if(String.isNotBlank(StreetName) && StreetName.toLowerCase() != 'null')
              		formatedaddresstemp += StreetName + ' ';
              		
              if(String.isNotBlank(streetNumber) && streetNumber.toLowerCase() != 'null')
              		formatedaddresstemp += streetNumber;
              		
              if(String.isNotBlank(Locality) && Locality.toLowerCase() != 'null')
              		formatedaddresstemp += (',<br/>' + Locality);
              		
              if(String.isNotBlank(PostalCode) && PostalCode.toLowerCase() != 'null')
              		formatedaddresstemp += (',<br/> ' + PostalCode);
              		
              if(String.isNotBlank(Province) && Province.toLowerCase() != 'null')
              		formatedaddresstemp += (', '+ Province);
              		
              if(String.isNotBlank(Country) && Country.toLowerCase() != 'null')
              		formatedaddresstemp += (',<br/>' + Country);
              		
              return formatedaddresstemp;
      }
      
      /* This property returns formated user's input with just line breaks CHINA*/
      public static string getFormattedUserInputWithHTMLBreaksOption4(String addressLine1, String addressLine2, String city, String state, String postalCode, String country){
              String formatedaddresstemp='';
              
              if(String.isNotBlank(addressLine1))
              		formatedaddresstemp = addressLine1;
              		
              if(String.isNotBlank(addressLine2))
              		formatedaddresstemp += ',<br/>' + addressLine2;
              		
              if(String.isNotBlank(city))
              		formatedaddresstemp += ',<br/>' + city;
              		
              if(String.isNotBlank(postalcode))
              		formatedaddresstemp += ',<br/> ' + postalCode;
              		
              if(String.isNotBlank(state))
              		formatedaddresstemp += ', ' + state;
              		
              if(String.isNotBlank(country))
              		formatedaddresstemp += ',<br/>' + country;
              		
              return formatedaddresstemp.toUpperCase();
      }
      
     
      /* This property returns formated StrikeIron output with just line breaks JAPAN*/ 
      public string getFormattedAddressWithHTMLBreaksOption5() {
      	 
      	 	  System.debug('Controller_getFormattedAddressWithHTMLBreaks JAPAN contact = ' + contact
      	 	  				+ '; BuildingName = ' + BuildingName
      	 	  				+ '; streetNumber = ' + streetNumber
      	 	  				+ '; StreetName = ' + StreetName
      	 	  				+ '; Locality = ' + Locality
      	 	  				+ '; Province = ' + Province
      	 	  				+ '; Country = ' + Country
      	 	  );
              String formatedaddresstemp = '';
              
             if(String.isNotBlank(contact) && contact.toLowerCase() != 'null')
              		formatedaddresstemp += (contact + '<br/>, ');
              
              if(String.isNotBlank(PostalCode) && PostalCode.toLowerCase() != 'null')
              		formatedaddresstemp += (PostalCode );  
              
              if(String.isNotBlank(Province) && Province.toLowerCase() != 'null')
              		formatedaddresstemp += (',<br/> '+ Province);      
              		
              if(String.isNotBlank(Locality) && Locality.toLowerCase() != 'null')
              		formatedaddresstemp += (', ' + Locality);              		
              		
               if(String.isNotBlank(BuildingName) && BuildingName.toLowerCase() != 'null')
              		formatedaddresstemp += (',<br/> ' + BuildingName + ', ');
              		
              if(String.isNotBlank(StreetName) && StreetName.toLowerCase() != 'null')
              		formatedaddresstemp += StreetName + ' ';
              		
              if(String.isNotBlank(streetNumber) && streetNumber.toLowerCase() != 'null')
              		formatedaddresstemp += streetNumber ;

              if(String.isNotBlank(Country) && Country.toLowerCase() != 'null')
              		formatedaddresstemp += (',<br/>' + Country);

              		
              return formatedaddresstemp;
      }
      
      /* This property returns formated user's input with just line breaks JAPAN*/
      public static string getFormattedUserInputWithHTMLBreaksOption5(String addressLine1, String addressLine2, String city, String state, String postalCode, String country){
              String formatedaddresstemp='';
              
              if(String.isNotBlank(postalcode))
              		formatedaddresstemp = postalCode;
              		
              if(String.isNotBlank(state))
              		formatedaddresstemp += ',<br/> ' + state;
              		
              if(String.isNotBlank(city))
              		formatedaddresstemp += ', ' + city;
              
              if(String.isNotBlank(addressLine1))
              		formatedaddresstemp += ', ' + addressLine1;
              		
              if(String.isNotBlank(addressLine2))
              		formatedaddresstemp += ', ' + addressLine2;
              		
              if(String.isNotBlank(country))
              		formatedaddresstemp += ',<br/>' + country;
              		
              return formatedaddresstemp.toUpperCase();
      }
      
     

     

}
/*
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
   <Header xmlns="http://schemas.xmlsoap.org/soap/envelope/">
      <SubscriptionInfo xmlns="http://ws.strikeiron.com">
         <LicenseStatusCode>0</LicenseStatusCode>
         <LicenseStatus>Valid license key</LicenseStatus>
         <LicenseActionCode>0</LicenseActionCode>
         <LicenseAction>Decremented hit count</LicenseAction>
         <RemainingHits>2999988</RemainingHits>
         <Amount>0</Amount>
      </SubscriptionInfo>
   </Header>
   <soap:Body>
      <BasicVerifyResponse xmlns="http://www.strikeiron.com">
         <BasicVerifyResult>
            <ServiceStatus>
               <StatusNbr>325</StatusNbr>
               <StatusDescription>Data cannot be corrected, and unlikely to be deliverable</StatusDescription>
            </ServiceStatus>
            <ServiceResult>
               <Organization/>
               <Department/>
               <Contact/>
               <BuildingName/>
               <StreetNumber>1</StreetNumber>
               <StreetName>MARKET</StreetName>
               <POBox/>
               <Locality>SAN FRAN</Locality>
               <PostalCode/>
               <Province/>
               <Country>UNITED STATES</Country>
               <Residue/>
               <DeliveryAddressLine>ONE MARKET</DeliveryAddressLine>
               <CountrySpecificLocalityLine>SAN FRAN</CountrySpecificLocalityLine>
               <FormattedAddress>ONE MARKET
SAN FRAN
UNITED STATES</FormattedAddress>
               <ResultPercentage>0</ResultPercentage>
               <ElementMatchStatus>02022000</ElementMatchStatus>
               <ElementMatchStatusTexts>Postal code: empty, City: not checked, Province: empty, Street: not checked, Building number: not checked, PO Box: empty, Building: empty, Organization: empty</ElementMatchStatusTexts>
               <ElementResultStatus>00000000</ElementResultStatus>
               <ElementResultStatusTexts>Postal code: empty, City: empty, Province: empty, Street: empty, Building number: empty, PO Box: empty, Building: empty, Organization: empty</ElementResultStatusTexts>
            </ServiceResult>
         </BasicVerifyResult>
      </BasicVerifyResponse>
   </soap:Body>
</soap:Envelope>

*/