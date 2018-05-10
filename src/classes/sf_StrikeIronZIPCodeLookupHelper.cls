/*
  * @author: Oleg Rikkers
  * @date: 05/13/2014

  * @description: creates request xml for ZipLookup request and processes response
  * 
  *  
  */
  
public with sharing class sf_StrikeIronZIPCodeLookupHelper {
    private static sf_StrikeIronConfigurationUtil configUtil = sf_StrikeIronConfigurationUtil.getInstance();
    
    public static String createRequestXML (String zipCode) {
        String xml = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.strikeiron.com" xmlns:str="http://www.strikeiron.com">';
        
        //header
        xml += '<soapenv:Header><ws:LicenseInfo><ws:RegisteredUser>';
        xml += '<ws:UserID>' + configUtil.getUsername() + '</ws:UserID>';
        xml += '<ws:Password>' + configUtil.getPassword() +'</ws:Password>';
        xml += '</ws:RegisteredUser></ws:LicenseInfo></soapenv:Header>';
        
        //body
        xml += '<soapenv:Body><str:ZIPCodeLookup>';
        xml += '<str:ZIPOrPostalCode>' + zipCode + '</str:ZIPOrPostalCode>';
        xml += '</str:ZIPCodeLookup></soapenv:Body></soapenv:Envelope>';
        
        return xml;
    }
    
    public static sf_StrikeIronZIPCodeLookupResponseBean parseResponse (Dom.Document doc) {
        
        sf_StrikeIronZIPCodeLookupResponseBean bean = new sf_StrikeIronZIPCodeLookupResponseBean ();
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
                        for (Dom.XmlNode resultNode: bodyNode.getChildElements()) {
                            if (resultNode.getName() == 'FormattedZIPOrPostalCode'){
                                bean.formattedZIPOrPostalCode = resultNode.getText();
                            }  else if (resultNode.getName() == 'City'){
                                bean.city = resultNode.getText();
                            } else if (resultNode.getName() == 'StateOrProvinceCode'){
                                bean.stateOrProvinceCode = resultNode.getText();
                            } else if (resultNode.getName() == 'StateOrProvinceName'){
                                bean.stateOrProvinceName = resultNode.getText();
                            } else if (resultNode.getName() == 'CountryCode'){
                                bean.countryCode = resultNode.getText();
                            } else if (resultNode.getName() == 'CountryName'){
                                bean.countryName = resultNode.getText().toUpperCase();
                            } else if (resultNode.getName() == 'CountyName'){
                                bean.countyName = resultNode.getText();
                            } else if (resultNode.getName() == 'Aliases'){

                                bean.aliases = new List <sf_StrikeIronZIPCodeLookupResponseBean.AliasInfo> (); 

                                for (Dom.XmlNode aliasNode: resultNode.getChildren()) {
                                    if (aliasNode.getName() == 'AliasInfo'){
                                        sf_StrikeIronZIPCodeLookupResponseBean.AliasInfo info = new sf_StrikeIronZIPCodeLookupResponseBean.AliasInfo();
                                        
                                        for (Dom.XmlNode aNode: aliasNode.getChildren()) {
                                            
                                            if (aNode.getName() == 'AliasCityName'){
                                                info.aliasCityName = aNode.getText().replaceAll('(\\s+)', ' ');//remove extra spaces
                                            } else if (aNode.getName() == 'AliasCityAbbrev'){
                                                info.aliasCityAbbrev = aNode.getText();
                                            } else if (aNode.getName() == 'FacilityCode'){
                                                info.facilityCode = aNode.getText();
                                            } else if (aNode.getName() == 'FacilityDescription'){
                                                info.facilityDescription = aNode.getText();
                                            }
                                        }

                                        bean.aliases.add (info);
                                    }
                                }
                            } else if (resultNode.getName() == 'Streets'){

                                bean.streets = new List <sf_StrikeIronZIPCodeLookupResponseBean.StreetInfo> (); 

                                for (Dom.XmlNode streetNode: resultNode.getChildren()) {
                                    if (streetNode.getName() == 'StreetInfo'){
                                        sf_StrikeIronZIPCodeLookupResponseBean.StreetInfo street = new sf_StrikeIronZIPCodeLookupResponseBean.StreetInfo();
                                    
                                        for (Dom.XmlNode sNode: streetNode.getChildren()) {
                                            
                                            if (sNode.getName() == 'ZIPPlus4Low'){
                                                street.zipPlus4Low = sNode.getText();
                                            } else if (sNode.getName() == 'ZIPPlus4High'){
                                                street.zipPlus4High = sNode.getText();
                                            } else if (sNode.getName() == 'StreetPreDirection'){
                                                street.streetPreDirection = sNode.getText();
                                            } else if (sNode.getName() == 'StreetSuffix'){
                                                street.streetSuffix = sNode.getText();
                                            } else if (sNode.getName() == 'StreetPostDirection'){
                                                street.streetPostDirection = sNode.getText();
                                            } else if (sNode.getName() == 'StreetName'){
                                                street.streetName = sNode.getText();
                                            } else if (sNode.getName() == 'StreetNumberLow'){
                                                street.streetNumberLow = sNode.getText();
                                            } else if (sNode.getName() == 'StreetNumberLowCanadaSuffix'){
                                                street.streetNumberLowCanadaSuffix = sNode.getText();
                                            } else if (sNode.getName() == 'StreetNumberHigh'){
                                                street.streetNumberHigh = sNode.getText();
                                            } else if (sNode.getName() == 'StreetNumberHighCanadaSuffix'){
                                                street.sStreetNumberHighCanadaSuffix = sNode.getText();
                                            } else if (sNode.getName() == 'OddEvenCode'){
                                                street.oddEvenCode = sNode.getText();
                                            } else if (sNode.getName() == 'SecondaryAbbreviation'){
                                                street.secondaryAbbreviation = sNode.getText();
                                            } else if (sNode.getName() == 'SecondaryStreetNumberLow'){
                                                street.secondaryStreetNumberLow = sNode.getText();
                                            } else if (sNode.getName() == 'SecondaryStreetNumberHigh'){
                                                street.secondaryStreetNumberHigh = sNode.getText();
                                            } else if (sNode.getName() == 'SecondaryOddEvenCode'){
                                                street.secondaryOddEvenCode = sNode.getText();
                                            } else if (sNode.getName() == 'BuildingFirmName'){
                                                street.buildingFirmName = sNode.getText();
                                            } else if (sNode.getName() == 'RecordTypeCode'){
                                                street.recordTypeCode = sNode.getText();
                                            } else if (sNode.getName() == 'CarrierRouteId'){
                                                street.carrierRouteId = sNode.getText();
                                            } else if (sNode.getName() == 'BaseAlterateCode'){
                                                street.baseAlterateCode = sNode.getText();
                                            } else if (sNode.getName() == 'LACSStatusInd'){
                                                street.lACSStatusInd = sNode.getText();
                                            } else if (sNode.getName() == 'GovernmentBuildingInd'){
                                                street.governmentBuildingInd = sNode.getText();
                                            } else if (sNode.getName() == 'CongressionalDistrictNumber'){
                                                street.congressionalDistrictNumber = sNode.getText();
                                            } else if (sNode.getName() == 'CanadaStreetSequenceCode'){
                                                street.canadaStreetSequenceCode = sNode.getText();
                                            }
                                        } //end street

                                        bean.streets.add (street); 
                                    } //end if StreetInfo
                                } //end streets
                            }
                        }
                    }
                }
            }
        }
        
        return bean;
    
    }

    /*
             <SIWsStatus>
                           <StatusNbr>201</StatusNbr>
                           <StatusDescription>5 Digit US ZIP Code Found</StatusDescription>
                        </SIWsStatus>
                        <SIWsStatus>
                           <StatusNbr>202</StatusNbr>
                           <StatusDescription>9 Digit US ZIP Code Found</StatusDescription>
                        </SIWsStatus>
                        <SIWsStatus>
                           <StatusNbr>203</StatusNbr>
                           <StatusDescription>CA Postal Code Found</StatusDescription>
                        </SIWsStatus>
                        <SIWsStatus>
                           <StatusNbr>301</StatusNbr>
                           <StatusDescription>5 Digit US ZIP Code Not Found</StatusDescription>
                        </SIWsStatus>
                        <SIWsStatus>
                           <StatusNbr>302</StatusNbr>
                           <StatusDescription>9 Digit US ZIP Code Not Found</StatusDescription>
                        </SIWsStatus>
                        <SIWsStatus>
                           <StatusNbr>304</StatusNbr>
                           <StatusDescription>9 Digit US ZIP Code Not Found.  5 Digit ZIP Code Found.</StatusDescription>
                        </SIWsStatus>
                        <SIWsStatus>
                           <StatusNbr>305</StatusNbr>
                           <StatusDescription>CA Postal Code Not Found</StatusDescription>
                        </SIWsStatus>
                        <SIWsStatus>
                           <StatusNbr>401</StatusNbr>
                           <StatusDescription>String is not a valid US ZIP Code or CA Postal Code format</StatusDescription>
                        </SIWsStatus>
                        <SIWsStatus>
                           <StatusNbr>500</StatusNbr>
                           <StatusDescription>Internal Error</StatusDescription>
                        </SIWsStatus>
    */

    public static ApexPages.Severity getMessageSeverityFromCode (String code) {
        if (code == '201' || code == '202'
            || code == '203') {
            return ApexPages.Severity.INFO;
        } else {
            return ApexPages.Severity.WARNING;
        }    
    }
}




/* SAMPLE REQUEST

<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.strikeiron.com" xmlns:str="http://www.strikeiron.com">
   <soapenv:Header>
      <ws:LicenseInfo>
         <!--Optional:-->
         <ws:UnregisteredUser>
            <!--Optional:-->
            <ws:EmailAddress>?</ws:EmailAddress>
         </ws:UnregisteredUser>
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
      <str:ZIPCodeLookup>
         <!--Optional:-->
         <str:ZIPOrPostalCode>60440-1134</str:ZIPOrPostalCode>
      </str:ZIPCodeLookup>
   </soapenv:Body>
</soapenv:Envelope>


*/



  
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