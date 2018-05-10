/*
  * @author: Oleg Rikkers
  * @date: 05/13/2014

  * @description: StrikeIron implementation.
  * 
  *  
  */
  
public with sharing class sf_StrikeIronServiceImpl implements sf_StrikeIronService {
    private static sf_StrikeIronConfigurationUtil configUtil = sf_StrikeIronConfigurationUtil.getInstance();
    
    
    public sf_StrikeIronZIPCodeLookupResponseBean lookupZIPCodeInfo (String zipCode) {
        
        Long startDt = Datetime.now().getTime();
        sf_StrikeIronZIPCodeLookupResponseBean respBean = new sf_StrikeIronZIPCodeLookupResponseBean ();
        String reqBody = sf_StrikeIronZIPCodeLookupHelper.createRequestXML (zipCode);
        System.debug(LoggingLevel.INFO, 'reqBody \n' + reqBody);
        Http h = new Http ();
        HttpRequest req = new HttpRequest ();
        req.setEndpoint (configUtil.getZipCodeLookupUrl());
        req.setMethod ('POST');
        req.setHeader ('Content-Type', 'text/xml;charset=UTF-8');
        req.setHeader ('SOAPAction', 'http://www.strikeiron.com/ZIPCodeLookup');
        req.setBody (reqBody);
        HttpResponse res = h.send(req);

        if (res.getStatusCode() == 200) {
            respBean = sf_StrikeIronZIPCodeLookupHelper.parseResponse(res.getBodyDocument());   
        } else {
            throw new sf_StrikeIronServiceImplException ('Wevservice Error occurred - ' + res.getStatusCode() + ': ' + res.getStatus());
        }
        respBean.processingTimeMs = Datetime.now().getTime() - startDt; 
        return respBean;
    }

    public sf_StrikeIronGblCodeLookupResponseBean lookupGlobalPostalCode (String postalOrZipCode, String country) {
        sf_StrikeIronGblCodeLookupResponseBean respBean = new sf_StrikeIronGblCodeLookupResponseBean ();

        Long startDt = Datetime.now().getTime();
        
        String reqBody = sf_StrikeIronGblCodeLookupHelper.createRequestXML (postalOrZipCode, country);
        System.debug(LoggingLevel.INFO, 'reqBody \n' + reqBody);
        Http h = new Http ();
        HttpRequest req = new HttpRequest ();
        req.setEndpoint (configUtil.getGlobalCodeLookupUrl());
        req.setMethod ('POST');
        req.setHeader ('Content-Type', 'text/xml;charset=UTF-8');
        req.setHeader ('SOAPAction', 'http://www.strikeiron.com/LookupPostalCode');
        req.setBody (reqBody);
        HttpResponse res = h.send(req);

        if (res.getStatusCode() == 200) {
            respBean = sf_StrikeIronGblCodeLookupHelper.parseResponse(res.getBodyDocument());   
        } else {
            throw new sf_StrikeIronServiceImplException ('Wevservice Error occurred - ' + res.getStatusCode() + ': ' + res.getStatus());
        }
        respBean.processingTimeMs = Datetime.now().getTime() - startDt; 



        return respBean;
    }


    public sf_StrikeIronValidateEmailResponseBean validateEmailAddress (String emailAddress) {
        sf_StrikeIronValidateEmailResponseBean respBean;
        Long startDt = Datetime.now().getTime();

        String reqBody = sf_StrikeIronValidateEmailHelper.createRequestXML (emailAddress);
        System.debug(LoggingLevel.INFO, 'reqBody \n' + reqBody);
        Http h = new Http ();
        HttpRequest req = new HttpRequest ();
        req.setEndpoint (configUtil.getValidateEmailUrl());
        req.setMethod ('POST');
        req.setHeader ('Content-Type', 'text/xml;charset=UTF-8');
        req.setHeader ('SOAPAction', 'http://www.strikeiron.com/VerifyEmail');
        req.setBody (reqBody);
        HttpResponse res = h.send(req);
        if (res.getStatusCode() == 200) {
            respBean = sf_StrikeIronValidateEmailHelper.parseResponse(res.getBodyDocument());  
        } else {
            throw new sf_StrikeIronServiceImplException ('Wevservice Error occurred - ' + res.getStatusCode() + ': ' + res.getStatus());
        }
        
        respBean.processingTimeMs = Datetime.now().getTime() - startDt;
        return respBean;

    }


    public sf_StrikeIronValidateGblAddressRespBean validateGlobalAddress (String streetLines, String cityStateZip, String country) {
        sf_StrikeIronValidateGblAddressRespBean respBean;
        Long startDt = Datetime.now().getTime();

        String reqBody = sf_StrikeIronValidateGblAddressHelper.createRequestXML (streetLines, cityStateZip, country);
        System.debug(LoggingLevel.INFO, 'reqBody \n' + reqBody);
        Http h = new Http ();
        HttpRequest req = new HttpRequest ();
        req.setEndpoint (configUtil.getValidateAddressUrl());
        req.setMethod ('POST');
        req.setHeader ('Content-Type', 'text/xml;charset=UTF-8');
        req.setHeader ('SOAPAction', 'http://www.strikeiron.com/BasicVerify');
        req.setBody (reqBody);
        HttpResponse res = h.send(req);

        if (res.getStatusCode() == 200) {
            respBean = sf_StrikeIronValidateGblAddressHelper.parseResponse(res.getBodyDocument());
        } else {
            throw new sf_StrikeIronServiceImplException ('Wevservice Error occurred - ' + res.getStatusCode() + ': ' + res.getStatus());
        }

        
        respBean.processingTimeMs = Datetime.now().getTime() - startDt;

        return respBean;
    }



    public class sf_StrikeIronServiceImplException extends Exception {}
}