@isTest
public class NotifierTest {
    @isTest
    public static void testLogMessage(){
        insert new RollbarSettings__c(SendReports__c = true);
        Test.setMock(HttpCalloutMock.class, new RollbarApiCalloutMock());

        Config config = new Config('foo', 'bar');

        Notifier subject = new Notifier(config);

        Test.startTest();
        HttpResponse response = subject.log('info', 'Message from the Apex SDK', null, null, SendMethod.SYNC);
        Test.stopTest();

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

    @isTest
    public static void testLogException(){
        insert new RollbarSettings__c(SendReports__c = true);
        Test.setMock(HttpCalloutMock.class, new RollbarApiCalloutMock());

        Config config = new Config('foo', 'bar');

        Notifier subject = new Notifier(config);

        DataBuilderTestException exc = new DataBuilderTestException();

        Test.startTest();
        HttpResponse response = subject.log('error', exc, null, SendMethod.SYNC);
        Test.stopTest();

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

    @isTest
    public static void testLogExceptionData(){
        insert new RollbarSettings__c(SendReports__c = true);
        Test.setMock(HttpCalloutMock.class, new RollbarApiCalloutMock());

        Config config = new Config('foo', 'bar');

        Notifier subject = new Notifier(config);

        Map<String, Object> expected = new Map<String, Object>();
        expected.put('environment', 'Sandbox');
        expected.put('organization', 'TestOrg');
        expected.put('className', 'TestClass');
        expected.put('message', 'Test exception message');
        expected.put('fileName', 'Class.ClassWithExceptionThrown.someMethod');
        expected.put('context', 'Exception context');
        expected.put('line', 14);
        expected.put('column', 12);

        ExceptionData exData = ExceptionData.fromMap(expected);

        Test.startTest();
        HttpResponse response = subject.log(exData, SendMethod.SYNC);
        Test.stopTest();

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

    @isTest
    public static void testSendReportsDisabled(){
        insert new RollbarSettings__c(SendReports__c = false);
        Test.setMock(HttpCalloutMock.class, new RollbarApiCalloutMock());

        Config config = new Config('foo', 'bar');

        Notifier subject = new Notifier(config);

        Test.startTest();
        HttpResponse response = subject.log('info', 'Message from the Apex SDK', null, null, SendMethod.SYNC);
        Test.stopTest();

        System.assertEquals(response, null);
    }
}
