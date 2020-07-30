@isTest
public class RollbarTest {
    @isTest
    public static void testLogMessage() {
        RollbarTestHelper.setDefaultMock();

        insert new RollbarSettings__c(SendReports__c = true);

        Test.startTest();
        Rollbar.init('test-token', 'test-env');
        HttpResponse response = Rollbar.log('info', 'Message from the Apex SDK', SendMethod.SYNC);
        Test.stopTest();

        System.assertEquals(200, response.getStatusCode());
    }

    @isTest
    public static void testLogMessageFuture() {
        RollbarTestHelper.setMock(new RollbarApiVerifyRequestCalloutMock());

        insert new RollbarSettings__c(AccessToken__c = 'test-token', SendReports__c = true);

        Test.startTest();
        Rollbar.log('info', 'Message from the Apex SDK', SendMethod.FUTURE);
        Test.stopTest();

        // Asserts valid payload in the mock.
    }

    @isTest
    public static void testLogMessageEvent() {
        RollbarTestHelper.setMock(new RollbarApiVerifyRequestCalloutMock());

        insert new RollbarSettings__c(AccessToken__c = 'test-token', SendReports__c = true);

        Test.startTest();
        Rollbar.log('info', 'Message from the Apex SDK', SendMethod.EVENT);
        Test.stopTest();

        // Asserts valid payload in the mock.
    }

    @isTest
    public static void testLogMessageWithCustomDataAndTelemetry() {
        RollbarTestHelper.setDefaultMock();

        insert new RollbarSettings__c(SendReports__c = true);

        Map<String, Object> customData = new Map<String, Object>{ 'foo' => 'bar' };
        List<Telemetry> telemetryList = new List<Telemetry>();

        Test.startTest();
        Rollbar.init('test-token', 'test-env');
        HttpResponse response = Rollbar.log(
            'info',
            'Message from the Apex SDK',
            customData,
            telemetryList,
            SendMethod.SYNC
        );
        Test.stopTest();

        System.assertEquals(200, response.getStatusCode());
    }

    @isTest
    public static void testLogException() {
        RollbarTestHelper.setDefaultMock();

        insert new RollbarSettings__c(SendReports__c = true);

        Test.startTest();
        Rollbar.init('test-token', 'test-env');
        HttpResponse response = Rollbar.log(new DataBuilderTestException(), SendMethod.SYNC);
        Test.stopTest();

        System.assertEquals(200, response.getStatusCode());
    }

    @isTest
    public static void testLogExceptionData() {
        RollbarTestHelper.setDefaultMock();

        insert new RollbarSettings__c(SendReports__c = true);

        Map<String, Object> exDataMap = new Map<String, Object>();
        exDataMap.put('environment', 'Sandbox');
        exDataMap.put('organization', 'TestOrg');
        exDataMap.put('className', 'TestClass');
        exDataMap.put('message', 'Test exception message');
        exDataMap.put('fileName', 'Class.ClassWithExceptionThrown.someMethod');
        exDataMap.put('context', 'Exception context');
        exDataMap.put('line', 14);
        exDataMap.put('column', 12);

        Test.startTest();
        Rollbar.init('test-token', 'test-env');
        HttpResponse response = Rollbar.log(ExceptionData.fromMap(exDataMap));
        Test.stopTest();

        System.assertEquals(200, response.getStatusCode());
    }

    @isTest
    public static void testConfigEnvironment() {
        insert new RollbarSettings__c(AccessToken__c = 'test-token', Environment__c = 'test-environment');

        Test.startTest();
        Rollbar instance = Rollbar.init(); // use environment from RollbarSettings
        Test.stopTest();

        System.assertEquals(instance.config().environment(), 'test-environment');
        System.assertEquals(instance.config().accessToken(), 'test-token');
        System.assertEquals(instance.notifier().config().environment(), 'test-environment');
        System.assertEquals(instance.notifier().config().accessToken(), 'test-token');
    }
}
