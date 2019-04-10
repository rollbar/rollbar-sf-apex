@isTest
public class RollbarTest {
    @isTest
    public static void testLogMessage() {
        Test.setMock(HttpCalloutMock.class, new RollbarApiCalloutMock());

        Rollbar.init('foo', 'test');
        HttpResponse response = Rollbar.log('info', 'Message from the Apex SDK');

        System.assertEquals(200, response.getStatusCode());
    }

    @isTest
    public static void testLogException() {
        Test.setMock(HttpCalloutMock.class, new RollbarApiCalloutMock());

        Rollbar.init('foo', 'test');
        HttpResponse response = Rollbar.log(new DataBuilderTestException());

        System.assertEquals(200, response.getStatusCode());
    }
}