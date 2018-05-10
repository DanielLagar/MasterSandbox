/*
 * @author: Oleg Rikkers
 * @date: 05/13/2014

 * @description: StrikeIron interface. US463, US468  
*/

public interface sf_StrikeIronService {

   sf_StrikeIronZIPCodeLookupResponseBean lookupZIPCodeInfo (String zipCode);
   sf_StrikeIronGblCodeLookupResponseBean lookupGlobalPostalCode (String postalOrZipCode, String country);
   sf_StrikeIronValidateEmailResponseBean validateEmailAddress (String emailAddress);
   sf_StrikeIronValidateGblAddressRespBean validateGlobalAddress (String streetLines, String cityStateZip, String country);
}