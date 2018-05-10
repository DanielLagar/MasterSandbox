/*
  * @author: Oleg Rikkers
  * @date: 05/13/2014

  * @description: creates request xml for Validate Email request and processes response
  * 
  *  
  */

public with sharing class sf_StrikeIronValidateEmailHelper {
	

	private static sf_StrikeIronConfigurationUtil configUtil = sf_StrikeIronConfigurationUtil.getInstance();


	public static String createRequestXML (String emailAddress) {
        String xml = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.strikeiron.com" xmlns:str="http://www.strikeiron.com/">';
        
        //header
        xml += '<soapenv:Header><ws:LicenseInfo><ws:RegisteredUser>';
        xml += '<ws:UserID>' + configUtil.getUsername() + '</ws:UserID>';
        xml += '<ws:Password>' + configUtil.getPassword() +'</ws:Password>';
        xml += '</ws:RegisteredUser></ws:LicenseInfo></soapenv:Header>';
        
        //body
        xml += '<soapenv:Body><str:VerifyEmail>';
        xml += '<str:Email>' + emailAddress + '</str:Email>';
        xml += '<str:Timeout>' + configUtil.getValidateEmailTimeoutSeconds() + '</str:Timeout>';
        //xml += '<str:OptionalSourceId>' + sf_StrikeIronValidateEmailHelper + '</str:OptionalSourceId>';
        xml += '</str:VerifyEmail></soapenv:Body></soapenv:Envelope>';
        
        return xml;
    }


    public static sf_StrikeIronValidateEmailResponseBean parseResponse (Dom.Document doc) {
        
        sf_StrikeIronValidateEmailResponseBean bean = new sf_StrikeIronValidateEmailResponseBean ();
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
                            if (resultNode.getName() == 'Reason'){
                         
                            	for (Dom.XmlNode reasonNode: resultNode.getChildElements()) {
                            		if (reasonNode.getName() == 'Code'){
                            			bean.reasonCode = reasonNode.getText();
                        			} else if (reasonNode.getName() == 'Description'){
                        				bean.reasonDescription = reasonNode.getText();
                        			}
                            	}

                            }  else if (resultNode.getName() == 'HygieneResult'){
                                bean.hygieneResult = resultNode.getText();
                            } else if (resultNode.getName() == 'NetProtected'){
                                bean.netProtected = resultNode.getText();
                            } else if (resultNode.getName() == 'NetProtectedBy'){
                                bean.netProtectedBy = resultNode.getText();
                            } else if (resultNode.getName() == 'SourceIdentifier'){
                                bean.sourceIdentifier = resultNode.getText();
                            } else if (resultNode.getName() == 'Email'){
                                bean.email = resultNode.getText();
                            } else if (resultNode.getName() == 'LocalPart'){
                                bean.localPart = resultNode.getText();
                            } else if (resultNode.getName() == 'DomainPart'){
  								bean.domainPart = resultNode.getText();
                            } else if (resultNode.getName() == 'IronStandardCertifiedTimestamp'){
                            	bean.ironStandardCertifiedTimestamp = resultNode.getText();
                            }
                        }
                    }
                }
            }
        }
        
        if (bean.statusNbr == '200' || bean.statusNbr == '210'
        	|| bean.statusNbr == '250' || bean.statusNbr == '260') {
        	bean.validationStatusForUser = 'Valid';
        } else if (bean.statusNbr == '300' || bean.statusNbr == '310'
        	|| bean.statusNbr == '400') {
        	bean.validationStatusForUser = 'Invalid';
        } else if (bean.statusNbr == '500' ){
        	bean.validationStatusForUser = 'Timed Out';
        } else if (bean.statusNbr == '220' || bean.statusNbr == '270'){
        	bean.validationStatusForUser = 'Analytics in Progress';
        } else {
        	bean.validationStatusForUser = 'Internal Error';
        }

        return bean;
    
    }

}