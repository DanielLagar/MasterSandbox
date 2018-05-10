/*
  * @author: Oleg Rikkers
  * @date: 05/19/2014

  * @description: StrikeIron 
  * http://ws.strikeiron.com/StrikeIron/emv6Hygiene
  * 
  *  
  */

public with sharing class sf_StrikeIronValidateEmailResponseBean {

	/*
	<MethodStatusRecord>
     <Results>
        <SIWsStatus>
           <StatusNbr>200</StatusNbr>
           <StatusDescription>Email Valid</StatusDescription>
        </SIWsStatus>
        <SIWsStatus>
           <StatusNbr>210</StatusNbr>
           <StatusDescription>Domain Confirmed</StatusDescription>
        </SIWsStatus>
        <SIWsStatus>
           <StatusNbr>220</StatusNbr>
           <StatusDescription>Analytics in Progress</StatusDescription>
        </SIWsStatus>
        <SIWsStatus>
           <StatusNbr>250</StatusNbr>
           <StatusDescription>Email Valid Potentially Dangerous</StatusDescription>
        </SIWsStatus>
        <SIWsStatus>
           <StatusNbr>260</StatusNbr>
           <StatusDescription>Domain Confirmed. Potentially Dangerous</StatusDescription>
        </SIWsStatus>
        <SIWsStatus>
           <StatusNbr>270</StatusNbr>
           <StatusDescription>Analytics in Progress Potentially Dangerous</StatusDescription>
        </SIWsStatus>
        <SIWsStatus>
           <StatusNbr>300</StatusNbr>
           <StatusDescription>Email Not Valid</StatusDescription>
        </SIWsStatus>
        <SIWsStatus>
           <StatusNbr>310</StatusNbr>
           <StatusDescription>Not Verified, Dangerous Domain</StatusDescription>
        </SIWsStatus>
        <SIWsStatus>
           <StatusNbr>400</StatusNbr>
           <StatusDescription>Invalid Input</StatusDescription>
        </SIWsStatus>
        <SIWsStatus>
           <StatusNbr>500</StatusNbr>
           <StatusDescription>Internal Error</StatusDescription>
        </SIWsStatus>
     </Results>
     <MethodName>VerifyEmail</MethodName>
  </MethodStatusRecord>
	*/

	public String statusNbr {get; set;}
	public String statusDescription {get; set;}
	public String reasonCode {get; set;}
	public String reasonDescription {get; set;}
	public String hygieneResult {get; set;}
	public String netProtected {get; set;}
	public String netProtectedBy {get; set;}
	public String sourceIdentifier {get; set;}
	public String email {get; set;}
	public String localPart {get; set;}
	public String domainPart {get; set;}
	public String ironStandardCertifiedTimestamp {get; set;}
  public String xmlString {get; set;}
  public Double processingTimeMs {get; set;}
  public String validationStatusForUser {get; set;}
}


/*
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
   <Header xmlns="http://schemas.xmlsoap.org/soap/envelope/">
      <SubscriptionInfo xmlns="http://ws.strikeiron.com">
         <LicenseStatusCode>0</LicenseStatusCode>
         <LicenseStatus>Valid license key</LicenseStatus>
         <LicenseActionCode>0</LicenseActionCode>
         <LicenseAction>Decremented hit count</LicenseAction>
         <RemainingHits>4999990</RemainingHits>
         <Amount>0</Amount>
      </SubscriptionInfo>
   </Header>
   <soap:Body>
      <VerifyEmailResponse xmlns="http://www.strikeiron.com/">
         <VerifyEmailResult>
            <ServiceStatus>
               <StatusNbr>200</StatusNbr>
               <StatusDescription>Email Valid</StatusDescription>
            </ServiceStatus>
            <ServiceResult>
               <Reason>
                  <Code>201</Code>
                  <Description>Mailbox Confirmed</Description>
               </Reason>
               <HygieneResult>Safe US</HygieneResult>
               <NetProtected>false</NetProtected>
               <NetProtectedBy/>
               <SourceIdentifier>?</SourceIdentifier>
               <Email>dev@sfdcdev.com</Email>
               <LocalPart>dev</LocalPart>
               <DomainPart>sfdcdev.com</DomainPart>
               <IronStandardCertifiedTimestamp xsi:nil="true"/>
               <DomainKnowledge/>
               <AddressKnowledge/>
            </ServiceResult>
         </VerifyEmailResult>
      </VerifyEmailResponse>
   </soap:Body>
</soap:Envelope>

*/