/*
  * @author: Oleg Rikkers
  * @date: 05/13/2014

  * @description: StrikeIron 
  * http://ws.strikeiron.com/StrikeIron/ZIPPostalCodeInfo5/AdvancedZipInfo
  * 
  *  
  */
  
  
public with sharing class sf_StrikeIronZIPCodeLookupResponseBean {
    
    public Double processingTimeMs {get; set;}
    public String xmlString {get; set;}
    public String statusNbr {get; set;}
    public String statusDescription {get; set;}
    public String formattedZIPOrPostalCode {get; set;}
    public String city {get; set;}
    public String stateOrProvinceCode {get; set;}
    public String stateOrProvinceName {get; set;}
    public String countryCode {get; set;}
    public String countryName {get; set;}
    public String countyName {get; set;}
    public List <AliasInfo> aliases {get {
        if (aliases == null) {
          aliases = new List <AliasInfo> ();
        } 

        return aliases;

      } set;}
      
    public List <StreetInfo> streets {get {
        if (streets == null) {
          streets = new List <StreetInfo> ();
        }
        return streets;

      } set;}

    /*
        <Aliases>
          <AliasInfo>
             <AliasCityName>BOLINGBROOK</AliasCityName>
             <AliasCityAbbrev></AliasCityAbbrev>
             <FacilityCode>P</FacilityCode>
             <FacilityDescription>Post Office</FacilityDescription>
             <MailingNameInd>Y</MailingNameInd>
             <UniqueNameInd></UniqueNameInd>
          </AliasInfo>
       </Aliases>
    */
    public class AliasInfo {
        public String aliasCityName {get; set;}
        public String aliasCityAbbrev {get; set;}
        public String facilityCode {get; set;}
        public String facilityDescription {get; set;}

    }


    /*
        <Streets>
                  <StreetInfo>
                     <ZIPPlus4Low>1134</ZIPPlus4Low>
                     <ZIPPlus4High>1134</ZIPPlus4High>
                     <StreetPreDirection></StreetPreDirection>
                     <StreetName>ABERDEEN</StreetName>
                     <StreetSuffix>CT</StreetSuffix>
                     <StreetPostDirection></StreetPostDirection>
                     <StreetNumberLow>800</StreetNumberLow>
                     <StreetNumberLowCanadaSuffix/>
                     <StreetNumberHigh>899</StreetNumberHigh>
                     <StreetNumberHighCanadaSuffix/>
                     <OddEvenCode>B</OddEvenCode>
                     <SecondaryAbbreviation></SecondaryAbbreviation>
                     <SecondaryStreetNumberLow></SecondaryStreetNumberLow>
                     <SecondaryStreetNumberHigh></SecondaryStreetNumberHigh>
                     <SecondaryOddEvenCode></SecondaryOddEvenCode>
                     <BuildingFirmName></BuildingFirmName>
                     <RecordTypeCode>S</RecordTypeCode>
                     <CarrierRouteId>C023</CarrierRouteId>
                     <BaseAlterateCode>B</BaseAlterateCode>
                     <LACSStatusInd></LACSStatusInd>
                     <GovernmentBuildingInd></GovernmentBuildingInd>
                     <CongressionalDistrictNumber>13</CongressionalDistrictNumber>
                     <CanadaStreetSequenceCode/>
                  </StreetInfo>
               </Streets>
    */

    public class StreetInfo {
        public String zipPlus4Low {get; set;}
        public String zipPlus4High {get; set;}
        public String streetPreDirection {get; set;}
        public String streetName {get; set;}
        public String streetSuffix {get; set;}
        public String streetPostDirection {get; set;}
        public String streetNumberLow {get; set;}
        public String streetNumberLowCanadaSuffix {get; set;}
        public String streetNumberHigh {get; set;}
        public String sStreetNumberHighCanadaSuffix {get; set;}
        public String oddEvenCode {get; set;}
        public String secondaryAbbreviation {get; set;}
        public String secondaryStreetNumberLow {get; set;}
        public String secondaryStreetNumberHigh {get; set;}
        public String secondaryOddEvenCode {get; set;}
        public String buildingFirmName {get; set;}
        public String recordTypeCode {get; set;}
        public String carrierRouteId {get; set;}
        public String baseAlterateCode {get; set;}
        public String lACSStatusInd {get; set;}
        public String governmentBuildingInd {get; set;}
        public String congressionalDistrictNumber {get; set;}
        public String canadaStreetSequenceCode {get; set;}

    }
}
  
  /* SAMPLE XML RESPONSE
  
  <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
   <Header xmlns="http://schemas.xmlsoap.org/soap/envelope/">
      <SubscriptionInfo xmlns="http://ws.strikeiron.com">
         <LicenseStatusCode>0</LicenseStatusCode>
         <LicenseStatus>Valid license key</LicenseStatus>
         <LicenseActionCode>0</LicenseActionCode>
         <LicenseAction>Decremented hit count</LicenseAction>
         <RemainingHits>787468</RemainingHits>
         <Amount>0</Amount>
      </SubscriptionInfo>
   </Header>
   <soap:Body>
      <ZIPCodeLookupResponse xmlns="http://www.strikeiron.com">
         <ZIPCodeLookupResult>
            <ServiceStatus>
               <StatusNbr>202</StatusNbr>
               <StatusDescription>9 Digit US ZIP Code Found</StatusDescription>
            </ServiceStatus>
            <ServiceResult>
               <OriginalZIPOrPostalCode>60440-1134</OriginalZIPOrPostalCode>
               <FormattedZIPOrPostalCode>60440-1134</FormattedZIPOrPostalCode>
               <City>BOLINGBROOK</City>
               <StateOrProvinceCode>IL</StateOrProvinceCode>
               <StateOrProvinceName>ILLINOIS</StateOrProvinceName>
               <CountryCode>US</CountryCode>
               <CountryName>United States</CountryName>
               <CountyName>WILL</CountyName>
               <ClassificationCode></ClassificationCode>
               <ClassificationDescription>Non-Unique (Standard) Zip Code</ClassificationDescription>
               <CityDeliveryInd>Y</CityDeliveryInd>
               <RateSortCode>B</RateSortCode>
               <RateSortDescription>Carrier Route Sortation/Rates Apply-Merging NOT Permitted</RateSortDescription>
               <AreaCodes>630</AreaCodes>
               <TimeZoneName>Central Time</TimeZoneName>
               <StandardGMTOffset>-6</StandardGMTOffset>
               <DaylightGMTOffset>-5</DaylightGMTOffset>
               <GMTOffsetText>GMT-06:00</GMTOffsetText>
               <UsesDayLightSavingsInd>Y</UsesDayLightSavingsInd>
               <Latitude>41.69814</Latitude>
               <Longitude>-88.07749</Longitude>
               <Elevation>536</Elevation>
               <CountyArea>837</CountyArea>
               <StateFIPS>17</StateFIPS>
               <CountyFIPS>197</CountyFIPS>
               <USPSFinanceNbr>164410</USPSFinanceNbr>
               <MSA>1602</MSA>
               <PMSA>1600</PMSA>
               <CBSA>16980</CBSA>
               <CBSADiv>16974</CBSADiv>
               <CBSATitle>Chicago-Naperville-Arlington Heights, IL</CBSATitle>
               <Aliases>
                  <AliasInfo>
                     <AliasCityName>BOLINGBROOK</AliasCityName>
                     <AliasCityAbbrev></AliasCityAbbrev>
                     <FacilityCode>P</FacilityCode>
                     <FacilityDescription>Post Office</FacilityDescription>
                     <MailingNameInd>Y</MailingNameInd>
                     <UniqueNameInd></UniqueNameInd>
                  </AliasInfo>
               </Aliases>
               <Streets>
                  <StreetInfo>
                     <ZIPPlus4Low>1134</ZIPPlus4Low>
                     <ZIPPlus4High>1134</ZIPPlus4High>
                     <StreetPreDirection></StreetPreDirection>
                     <StreetName>ABERDEEN</StreetName>
                     <StreetSuffix>CT</StreetSuffix>
                     <StreetPostDirection></StreetPostDirection>
                     <StreetNumberLow>800</StreetNumberLow>
                     <StreetNumberLowCanadaSuffix/>
                     <StreetNumberHigh>899</StreetNumberHigh>
                     <StreetNumberHighCanadaSuffix/>
                     <OddEvenCode>B</OddEvenCode>
                     <SecondaryAbbreviation></SecondaryAbbreviation>
                     <SecondaryStreetNumberLow></SecondaryStreetNumberLow>
                     <SecondaryStreetNumberHigh></SecondaryStreetNumberHigh>
                     <SecondaryOddEvenCode></SecondaryOddEvenCode>
                     <BuildingFirmName></BuildingFirmName>
                     <RecordTypeCode>S</RecordTypeCode>
                     <CarrierRouteId>C023</CarrierRouteId>
                     <BaseAlterateCode>B</BaseAlterateCode>
                     <LACSStatusInd></LACSStatusInd>
                     <GovernmentBuildingInd></GovernmentBuildingInd>
                     <CongressionalDistrictNumber>13</CongressionalDistrictNumber>
                     <CanadaStreetSequenceCode/>
                  </StreetInfo>
               </Streets>
            </ServiceResult>
         </ZIPCodeLookupResult>
      </ZIPCodeLookupResponse>
   </soap:Body>
</soap:Envelope>
  
  */