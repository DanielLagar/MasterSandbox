global class oneStopReply implements Messaging.InboundEmailHandler {
    
     /**
 *  This utility attempts to strip the reply portion of an email by looking for common reply seperators
 *  The reply separator depends on the email client, so it is not likely to strip all replies 100%
 *  This is a best effort for known email client formats. 
 *
 *  @param String original email message body
 *  @returns String email message with the reply lines stripped
 */
    global String stripResponse(String email) { 
    
    // Normalize line breaks
    email.replaceAll('\r\n', '\n');
    
    // Check for On ... wrote: that break to multiple lines and force to one line for filtering
    Pattern p = Pattern.compile('(?m)^On .+<[^>]+> wrote:$');
    Matcher m = p.matcher(email);
        
    if (m.find()) {
       
        email = email.substring(0,m.start()-1) + email.substring(m.start(), m.end()).replaceAll('\n', '') + email.substring(m.end()+1);
    }
    
    String[] lines = email.split('\n');
    String out = '';
    
    Boolean firstLine = true;
    for (String line : lines) {
        
        // Make sure the reply is not the first line of the message (workaround for Cirrus Insight in particular which starts with From:)
        if (!firstLine) { 
            if (line.equals('--') || line.equals('-- ') || 
                line.startsWith('-----Original Message-----') || 
                line.startsWith('--------------- Original Message ---------------') ||
                line.startsWith('________________________________') || 
                (line.startsWith('On ') && line.endsWith(' wrote:')) ||
                line.startsWith('From: ') ||
                line.startsWith('Sent from my iPhone')) {
                    break;
            }
        }
        firstLine = false;
        out += line + '\n';
    }
    return out;
}
    
    
    
    
      global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
          Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
          One_Stop__c onestopQuery;
          
          string emailString ='';
          emailString = email.plainTextBody;    
          system.debug('++++'+emailString);
          string requestNumber ;
          requestNumber = email.subject;  
          requestNumber = requestNumber.substringAfter('#');
          system.debug('---'+requestNumber);
          onestopQuery =  [select id, name from One_Stop__c where name = : requestNumber];
          
          String emailAddress = envelope.fromAddress;
          string ModifiedName ='' ;
          list<user> abv = [select id, name from user where email =: emailAddress  ];
          system.debug('99999999'+ abv.size());
          OneSTOPComment__c oneStopComments = new OneSTOPComment__c(X1STOP__c = onestopQuery.id);
        
          //string fname = email.fromname.substring(email.fromname.indexOf(' '));
          
         
          
          system.debug('999999'+oneStopComments);
           for (Messaging.InboundEmail.Header header : email.headers) {
                        
            if(  header.name != 'X-SFDC-DOMAINKEYS') 
                      system.debug('header'+ header.name+'header');
                else{
                    try{                        
                      if(abv.size()==1){  
                    oneStopComments.Comment1__c = stripResponse(emailString); 
                      oneStopComments.name__c = abv[0].Name;
                      }
                    else{
                         oneStopComments.Comment1__c = stripResponse(emailString); 
                      oneStopComments.name__c = 'Personal Email';
                    }
                      insert oneStopComments; 
                      }
                  catch(Exception e){
                      system.debug('Query Issue'+e);
                      }
              }
              
               }
          
            
            return result;      
          
          }
    
   
  }