@isTest
public class DataBuilderTest 
{
    @isTest
    static void testBuildMessagePayload()
    {
        DataBuilder subject = new DataBuilder(new Config('foo', 'bar'));
        String expected = 'Message built in DataBuilderTest';

        Map<String, Object> result = subject.buildPayload('info', expected);

        Map<String, Object> data = (Map<String, Object>)result.get('data');
        Map<String, Object> body = (Map<String, Object>)data.get('body');

        System.assertEquals(expected, ((Map<String, Object>)body.get('message')).get('body'));
    }

    @isTest
    static void testBuildExceptionPayload()
    {
        DataBuilder subject = new DataBuilder(new Config('foo', 'bar'));
        String expectedMessage = 'Exception message in test';
        DataBuilderTestException exc = new DataBuilderTestException(expectedMessage);
        String expectedClass = exc.getTypeName();

        Map<String, Object> result = subject.buildPayload(exc);

        Map<String, Object> data = (Map<String, Object>)result.get('data');
        Map<String, Object> body = (Map<String, Object>)data.get('body');
        Map<String, Object> trace = (Map<String, Object>)body.get('trace');
        Map<String, Object> excMap = (Map<String, Object>)trace.get('exception');

        System.assertEquals(expectedMessage, excMap.get('message'));
        System.assertEquals(expectedClass, excMap.get('class'));
    }
}
