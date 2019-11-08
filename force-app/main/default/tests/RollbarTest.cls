@isTest
public class RollbarTest {
    @isTest(SeeAllData=true)
    public static void testLogMessage() {
        Test.setMock(HttpCalloutMock.class, new RollbarApiCalloutMock());

        HttpResponse response = Rollbar.log('info', 'Message from the Apex SDK');

        System.assertEquals(200, response.getStatusCode());
    }

    @isTest(SeeAllData=true)
    public static void testLogException() {
        Test.setMock(HttpCalloutMock.class, new RollbarApiCalloutMock());

        HttpResponse response = Rollbar.log(new DataBuilderTestException());

        System.assertEquals(200, response.getStatusCode());
    }

    @isTest(SeeAllData=true)
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

        HttpResponse response = Rollbar.log(ExceptionData.fromMap(exDataMap));

        System.assertEquals(200, response.getStatusCode());
    }
}