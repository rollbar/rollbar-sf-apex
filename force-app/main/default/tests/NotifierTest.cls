@isTest
public class NotifierTest {
    @isTest
    public static void testLogMessage(){
        insert new RollbarSettings__c(SendReports__c = true);
        RollbarTestHelper.setDefaultMock();

        Config config = new Config('foo', 'bar');

        Notifier subject = new Notifier(config);
        Item item = new Item('Message from the Apex SDK');

        Test.startTest();
        HttpResponse response = subject.log('info', item, SendMethod.SYNC);
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
        RollbarTestHelper.setDefaultMock();

        Config config = new Config('foo', 'bar');

        Notifier subject = new Notifier(config);
        DataBuilderTestException exc = new DataBuilderTestException();
        Item item = new Item(exc);

        Test.startTest();
        HttpResponse response = subject.log('error', item, SendMethod.SYNC);
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
        RollbarTestHelper.setDefaultMock();

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
        Item item = new Item(exData);

        Test.startTest();
        HttpResponse response = subject.log('error', item, SendMethod.SYNC);
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
        RollbarTestHelper.setDefaultMock();

        Config config = new Config('foo', 'bar');

        Notifier subject = new Notifier(config);
        Item item = new Item('Message from the Apex SDK');

        Test.startTest();
        HttpResponse response = subject.log('info', item, SendMethod.SYNC);
        Test.stopTest();

        System.assertEquals(response, null);
    }
}
