/*
* @author:       Accenture
* @date:         15/07/2016
* @description:  live chat response for button availability
*/
public class gcr_LiveChatResponse {
    public List<ParentMessage> messages;
    public class ParentMessage {
        public String type;
        public gcr_LiveChatResponse.MessageClass message;
    }

    public class MessageClass {
		public List<gcr_LiveChatResponse.ResultClass> results;
    }

    public class ResultClass {
        public String id;
        public Boolean isAvailable;
    }
}