/*
  * @author: Oleg Rikkers
  * @date: 05/13/2014

  * @description: creates request xml for Validate Global Address request and processes response
  * 
  *  
  */


public with sharing class sf_StrikeIronValidateGblAddressHelper {
	public class sf_StrikeIronValidateGblAddressHelperException extends Exception {}
	private static sf_StrikeIronConfigurationUtil configUtil = sf_StrikeIronConfigurationUtil.getInstance();


	public static String createRequestXML (String streetLines, String cityStateZip, String country) {
        String xml = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.strikeiron.com" xmlns:str="http://www.strikeiron.com">';
        //header
        xml += '<soapenv:Header><ws:LicenseInfo><ws:RegisteredUser>';
        xml += '<ws:UserID>' + configUtil.getUsername() + '</ws:UserID>';
        xml += '<ws:Password>' + configUtil.getPassword() +'</ws:Password>';
        xml += '</ws:RegisteredUser></ws:LicenseInfo></soapenv:Header>';
        
        //body
        xml += '<soapenv:Body><str:BasicVerify>';
        xml += '<str:StreetAddressLines>' + streetLines.escapeXML() + '</str:StreetAddressLines>';
        xml += '<str:CountrySpecificLocalityLine>' + cityStateZip.escapeXML() + '</str:CountrySpecificLocalityLine>';
        xml += '<str:Country>' + country.escapeXML() + '</str:Country>';
 
        xml += '</str:BasicVerify></soapenv:Body></soapenv:Envelope>';
        
        return xml;
    }


    public static sf_StrikeIronValidateGblAddressRespBean parseResponse (Dom.Document doc) {
        
        sf_StrikeIronValidateGblAddressRespBean bean = new sf_StrikeIronValidateGblAddressRespBean ();
        bean.xmlString = doc.toXmlString();
        System.debug(LoggingLevel.INFO, 'sf_StrikeIronValidateGblAddressRespBean parseResponse \n' + doc.toXmlString());
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
                            if (resultNode.getName() == 'Organization'){
                         		  bean.org = resultNode.getText();
                            }  else if (resultNode.getName() == 'Department'){
                              bean.department = resultNode.getText();
                            } else if (resultNode.getName() == 'Contact'){
                              bean.contact = resultNode.getText();
                            } else if (resultNode.getName() == 'BuildingName'){
                              bean.buildingName = resultNode.getText();
                            } else if (resultNode.getName() == 'StreetNumber'){
                              bean.streetNumber = resultNode.getText();
                            } else if (resultNode.getName() == 'StreetName'){
                              bean.streetName = resultNode.getText();
                            } else if (resultNode.getName() == 'POBox'){
                                bean.poBox = resultNode.getText();
                            } else if (resultNode.getName() == 'Locality'){
  								            bean.locality = resultNode.getText();
                            } else if (resultNode.getName() == 'PostalCode'){
                            	bean.postalCode = resultNode.getText();
                            } else if (resultNode.getName() == 'Province'){
                            	bean.province = resultNode.getText();
                            } else if (resultNode.getName() == 'Country'){
                            	bean.country = resultNode.getText();
                            } else if (resultNode.getName() == 'Residue'){
                            	bean.residue = resultNode.getText();
                            } else if (resultNode.getName() == 'DeliveryAddressLine'){
                            	bean.deliveryAddressLine = resultNode.getText();
                            }else if (resultNode.getName() == 'CountrySpecificLocalityLine'){
                            	bean.countrySpecificLocalityLine = resultNode.getText();
                            }else if (resultNode.getName() == 'FormattedAddress'){
                            	bean.formattedAddress = resultNode.getText();
                            } else if (resultNode.getName() == 'ResultPercentage'){
                            	bean.resultPercentage = resultNode.getText();
                            } else if (resultNode.getName() == 'ElementMatchStatus'){
                            	bean.elementMatchStatus = resultNode.getText();
                            } else if (resultNode.getName() == 'ElementMatchStatusTexts'){
                            	bean.elementMatchStatusTexts = resultNode.getText();

                              try { //break out message into elements for error messages
                                //this is pretty fragile so feel free to improve
                                for (String s: bean.elementMatchStatusTexts.split (',')) {
                                  String field = s.split(':')[0].trim();
                                  String message = s.split(':')[1].trim();
                                  message = message.equalsIgnoreCase('empty')? '': message;
                                  if (field.equalsIgnoreCase ('Postal Code')) {
                                    	bean.zipMessage = message;
                                  } else if (field.equalsIgnoreCase   ('City')) {
                                    	bean.cityMessage = message;
                                  } else if (field.equalsIgnoreCase   ('Province')) {
                                    	bean.stateMessage = message;
                                  } else if (field.equalsIgnoreCase   ('Street')) {
                                    	bean.streetMessage = message;
                                  } else if (field.equalsIgnoreCase   ('City')) {
                                    	bean.cityMessage = message;
                                  } else if (field.equalsIgnoreCase   ('Building number')) {
                                    	bean.buildingNumberMessage = message;
                                  } else if (field.equalsIgnoreCase   ('PO Box')) {
                                    	bean.poBoxMessage = message;
                                  } else if (field.equalsIgnoreCase   ('Building')) {
                                    	bean.buildingMessage = message; 
                                  } else if (field.equalsIgnoreCase   ('Organization')) {
                                    	bean.orgMessage = message;
                                  }

                                }
                                
                              } catch (Exception e) {
                                system.debug(e);
                              }


                            }else if (resultNode.getName() == 'ElementResultStatus'){
                            	bean.elementResultStatus = resultNode.getText();
                            }else if (resultNode.getName() == 'ElementResultStatusTexts'){
                            	bean.elementResultStatusTexts = resultNode.getText();
                            }
                            
							try{
								String resultStatus =  !String.isEmpty(bean.elementResultStatusTexts) ? bean.elementResultStatusTexts.replace('validated, but changed (synonyms, old names)', sf_Constants.STRIKE_IRON_MESSAGE_VALIDATED_BUT_CHANGED) : '';
								resultStatus =  resultStatus.replace('validated, but standardized', sf_Constants.STRIKE_IRON_MESSAGE_VALIDATED_BUT_STANDARDIZED);
	                             for (String s: resultStatus.split (',')) {
		                                  String field = !s.split(':').isEmpty() ? s.split(':')[0].trim() : 'Country';
		                                  String result = s.split(':').size() > 1 ? s.split(':')[1].trim() : 'empty';
		                                  result = result.equalsIgnoreCase('empty')? '': result;
		                                  if (field.equalsIgnoreCase ('Postal Code')) {
		                                    	bean.zipResult = result;
		                                  } else if (field.equalsIgnoreCase   ('City')) {
		                                    	bean.cityResult = result;
		                                  } else if (field.equalsIgnoreCase   ('Province')) {
		                                    	bean.stateResult = result;
		                                  } else if (field.equalsIgnoreCase   ('Street')) {
		                                    	bean.streetResult = result;
		                                  } else if (field.equalsIgnoreCase   ('City')) {
		                                    	bean.cityResult = result;
		                                  } else if (field.equalsIgnoreCase   ('Building number')) {
		                                    	bean.buildingNumberResult = result;
		                                  } else if (field.equalsIgnoreCase   ('PO Box')) {
		                                    	bean.poBoxResult = result;
		                                  } else if (field.equalsIgnoreCase   ('Building')) {
		                                    	bean.buildingResult = result; 
		                                  } else if (field.equalsIgnoreCase   ('Organization')) {
		                                    	bean.orgResult = result;
		                                  }
	
	                                }
                              } catch (Exception e) {
                                system.debug(e);
                                throw new sf_StrikeIronValidateGblAddressHelperException ('Error: ' + e.getMessage() + ' ' + e.getStackTraceString());
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
	<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
   <Header xmlns="http://schemas.xmlsoap.org/soap/envelope/">
      <SubscriptionInfo xmlns="http://ws.strikeiron.com">
         <LicenseStatusCode>0</LicenseStatusCode>
         <LicenseStatus>Valid license key</LicenseStatus>
         <LicenseActionCode>0</LicenseActionCode>
         <LicenseAction>Decremented hit count</LicenseAction>
         <RemainingHits>2999978</RemainingHits>
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
               <StreetName>street berlin</StreetName>
               <POBox/>
               <Locality>1 STREET</Locality>
               <PostalCode/>
               <Province>berlin</Province>
               <Country>GERMANY</Country>
               <Residue/>
               <DeliveryAddressLine>street berlin 1</DeliveryAddressLine>
               <CountrySpecificLocalityLine>1 STREET</CountrySpecificLocalityLine>
               <FormattedAddress>street berlin 1
1 STREET
GERMANY</FormattedAddress>
               <ResultPercentage>0</ResultPercentage>
               <ElementMatchStatus>03212000</ElementMatchStatus>
               <ElementMatchStatusTexts>Postal code: empty, City: matched with errors, Province: not checked, Street: not found, Building number: not checked, PO Box: empty, Building: empty, Organization: empty</ElementMatchStatusTexts>
               <ElementResultStatus>00000000</ElementResultStatus>
               <ElementResultStatusTexts>Postal code: empty, City: empty, Province: empty, Street: empty, Building number: empty, PO Box: empty, Building: empty, Organization: empty</ElementResultStatusTexts>
            </ServiceResult>
         </BasicVerifyResult>
      </BasicVerifyResponse>
   </soap:Body>
</soap:Envelope>

*/