@isTest
public class RollbarTest {
    @isTest
    public static void testLogMessage() {
        Test.setMock(HttpCalloutMock.class, new RollbarApiCalloutMock());

        Rollbar.init('test-token', 'test-env');
        HttpResponse response = Rollbar.log('info', 'Message from the Apex SDK', SendMethod.SYNC);

        System.assertEquals(200, response.getStatusCode());
    }

    @isTest
    public static void testLogMessageFuture() {
        Test.setMock(HttpCalloutMock.class, new RollbarApiVerifyRequestCalloutMock());

        insert new RollbarSettings__c(AccessToken__c = 'test-token');

        Test.startTest();
        Rollbar.log('info', 'Message from the Apex SDK', SendMethod.FUTURE);
        Test.stopTest();

        // Asserts valid payload in the mock.
    }

    @isTest
    public static void testLogMessageEvent() {
        Test.setMock(HttpCalloutMock.class, new RollbarApiVerifyRequestCalloutMock());

        insert new RollbarSettings__c(AccessToken__c = 'test-token');

        Test.startTest();
        Rollbar.log('info', 'Message from the Apex SDK', SendMethod.EVENT);
        Test.stopTest();

        // Asserts valid payload in the mock.
    }

    @isTest
    public static void testLogException() {
        Test.setMock(HttpCalloutMock.class, new RollbarApiCalloutMock());

        Rollbar.init('test-token', 'test-env');
        HttpResponse response = Rollbar.log(new DataBuilderTestException(), SendMethod.SYNC);

        System.assertEquals(200, response.getStatusCode());
    }

    @isTest
    public static void testLogExceptionData() {
        Test.setMock(HttpCalloutMock.class, new RollbarApiCalloutMock());

        Map<String, Object> exDataMap = new Map<String, Object>();
        exDataMap.put('environment', 'Sandbox');
        exDataMap.put('organization', 'TestOrg');
        exDataMap.put('className', 'TestClass');
        exDataMap.put('message', 'Test exception message');
        exDataMap.put('fileName', 'Class.ClassWithExceptionThrown.someMethod');
        exDataMap.put('context', 'Exception context');
        exDataMap.put('line', 14);
        exDataMap.put('column', 12);

        Rollbar.init('test-token', 'test-env');
        HttpResponse response = Rollbar.log(ExceptionData.fromMap(exDataMap));

        System.assertEquals(200, response.getStatusCode());
    }
}
