/*
* @author:       Accenture
* @date:         30/08/2016
* @description:  Test class for general care hub testing
* CHANGE LOG
* DATE          NAME                CHANGE DESCRIPTION
* 01/09/2016    Accenture           Initial Draft
*/
@isTest(SeeAllData = false)
global class gcr_mockApiClass {
    /*
    * @author:       Accenture
    * @date:         30/08/2016
    * @description:  Mock class strike iron email check
    * CHANGE LOG
    * DATE          NAME                CHANGE DESCRIPTION
    * 01/09/2016    Accenture           Initial Draft
    */
    global class gcr_strikeIronMock implements HttpCalloutMock {
        global HttpResponse respond(HTTPRequest htpRequest) {
            HttpResponse retVal = new HttpResponse();
            StaticResource staticRes = null;
            String apiEndpoint = htpRequest.getEndpoint();

            if (StrikeIronConfiguration__c.getInstance('validateEmailUrl') != null) {
                if(StrikeIronConfiguration__c.getInstance('validateEmailUrl').Value__c != null
                && StrikeIronConfiguration__c.getInstance('validateEmailUrl').Value__c.equalsIgnoreCase(apiEndpoint)) {
                    staticRes = [ SELECT Id, Body FROM StaticResource WHERE Name ='siTestEmailResponse' ];
                    if (htpRequest.getBody().contains('test@gmail.com')) {
                        retVal.setBodyAsBlob(staticRes.body);
                    } else if (htpRequest.getBody().contains('<str:Email>test.data@gmail.com</str:Email>')) {
                        String response = staticRes.body.toString();
                        response = response.replace('<StatusNbr>300</StatusNbr>', '<StatusNbr>200</StatusNbr>');
                        response = response.replace('<Code>305</Code>', '<Code>200</Code>');
                        retVal.setBody(response);
                    }
                    retVal.setStatusCode(200);
                } else if (StrikeIronConfiguration__c.getInstance('validateAddressUrl').Value__c != null
                && StrikeIronConfiguration__c.getInstance('validateAddressUrl').Value__c.equalsIgnoreCase(apiEndpoint)) {
                    staticRes = [ SELECT Id, Body FROM StaticResource WHERE Name ='siTestAddressResponse' ];
                    String response = staticRes.body.toString();
                    if (htpRequest.getBody().contains('NE59HN') && htpRequest.getBody().contains('Newcastle')) {
                        response = response.replace('<StatusNbr>325</StatusNbr>', '<StatusNbr>221</StatusNbr>');
                        retVal.setBody(response);
                    } else if (htpRequest.getBody().contains('NE55HN') && htpRequest.getBody().contains('Newcastle')) {
                        response = response.replace('<StatusNbr>325</StatusNbr>', '<StatusNbr>222</StatusNbr>');
                        retVal.setBody(response);
                    }
                    retVal.setStatusCode(200);
                }
            }
            return retVal;
        }
    }
    
    /*
    * @author:       Accenture
    * @date:         30/08/2016
    * @description:  Mock class live chat button availability
    * CHANGE LOG
    * DATE          NAME                CHANGE DESCRIPTION
    * 05/09/2016    Accenture           Initial Draft
    */
     global class gcr_liveAgentButton implements HttpCalloutMock {
        global HttpResponse respond(HTTPRequest htpRequest) {
            HttpResponse retVal = new HttpResponse();
            gcr_LiveChatResponse.ResultClass resultClass = new gcr_LiveChatResponse.ResultClass();
            resultClass.id = '57380000000TOBM';
            resultClass.isAvailable = true;
            
            gcr_LiveChatResponse.MessageClass message = new gcr_LiveChatResponse.MessageClass();
            message.results = new List<gcr_LiveChatResponse.ResultClass>();
            message.results.add(resultClass);
            
            gcr_LiveChatResponse.ParentMessage parentMessage = new gcr_LiveChatResponse.ParentMessage();
            parentMessage.type = 'Availability';
            parentMessage.message = message;
            
            gcr_LiveChatResponse chatResponse = new gcr_LiveChatResponse();
            chatResponse.messages = new List<gcr_LiveChatResponse.ParentMessage>();
            chatResponse.messages.add(parentMessage);
            
            retVal.setBody(JSON.serialize(chatResponse));
            retVal.setStatus('OK');
            retVal.setStatusCode(200);
            
            return retVal;
        }
     }
}