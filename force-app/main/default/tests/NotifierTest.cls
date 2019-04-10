@isTest
public class NotifierTest {
    @isTest
    public static void testLog(){
        Test.setMock(HttpCalloutMock.class, new RollbarApiCalloutMock());

        Config config = new Config('foo', 'bar');

        Notifier subject = new Notifier(config);

        HttpResponse response = subject.log('info', 'Message from the Apex SDK');

        System.assertEquals(200, response.getStatusCode());
        
        JSONParser parser = JSON.createParser(response.getBody());
        Integer err = null;
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                (parser.getText() == 'err')) {
                parser.nextToken();
                err = parser.getIntegerValue();
            }
        }

        System.assertEquals(0, err);
    }
}