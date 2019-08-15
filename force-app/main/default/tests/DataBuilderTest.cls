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
            
        Map<String, Object> notifierMap = (Map<String, Object>)data.get('notifier');

        System.assertEquals(Notifier.NAME, (String)notifierMap.get('name'));
        System.assertEquals(Notifier.VERSION, (String)notifierMap.get('version'));

        Map<String, Object> body = (Map<String, Object>)data.get('body');

        System.assertEquals(expected, ((Map<String, Object>)body.get('message')).get('body'));
    }

    @isTest
    static void testBuildExceptionPayloadAnonymousBlock()
    {
        // TODO: to be implemented
        // Test recognition of AnonymousBlocks in DataBuilder.buildTraceBody() line 142
    }

    @isTest
    static void testBuildExceptionPayload()
    {
        DataBuilder subject = new DataBuilder(new Config('foo', 'bar'));
        String expectedMessage = 'Exception message in test';
        String expectedClass;

        try {
            DataBuilderTestException exc = new DataBuilderTestException(expectedMessage);
            expectedClass = exc.getTypeName();
            throw exc;
        } catch(Exception exc) {
            Map<String, Object> result = subject.buildPayload(exc);

            Map<String, Object> data = (Map<String, Object>)result.get('data');

            Map<String, Object> notifierMap = (Map<String, Object>)data.get('notifier');
            System.assertEquals(Notifier.NAME, (String)notifierMap.get('name'));
            System.assertEquals(Notifier.VERSION, (String)notifierMap.get('version'));

            Map<String, Object> body = (Map<String, Object>)data.get('body');
            Map<String, Object> trace = (Map<String, Object>)body.get('trace');
            Map<String, Object> excMap = (Map<String, Object>)trace.get('exception');

            System.assertEquals(expectedMessage, excMap.get('message'));
            System.assertEquals(expectedClass, excMap.get('class'));

            // TODO: full testing of exception frames needs to implemented;
            // I wasn't able to obtain the strack trace in tests just yet.
            // Not sure if it's possible at all.
            // Map<String, Object> frame = ((List<Map<String, Object>>)trace.get('frames'))[0];
        }
    }

    @isTest
    static void testBuildExceptionPayloadWithCustom()
    {
        DataBuilder subject = new DataBuilder(new Config('foo', 'bar'));
        Map<String, String> expectedCustom = new Map<String, String>();
        expectedCustom.put('foo', 'bar');

        DataBuilderTestException exc = new DataBuilderTestException('foobar');

        Map<String, Object> result = subject.buildPayload(exc, expectedCustom);
        Map<String, Object> data = (Map<String, Object>)result.get('data');
        Map<String, Object> custom = (Map<String, Object>)data.get('custom');

        System.assertEquals(expectedCustom.get('foo'), (String)custom.get('foo'));
    }

    @isTest
    static void testBuildTraceChainPayload()
    {
        DataBuilder subject = new DataBuilder(new Config('foo', 'bar'));
        String expectedMessage1 = 'Exception message in test 001';
        String expectedClass1;
        String expectedMessage2 = 'Exception message in test 002';
        String expectedClass2;

        try {
            try {
                DataBuilderTestException exc2 = new DataBuilderTestException(expectedMessage2);
                expectedClass2 = exc2.getTypeName();
                throw exc2;
            } catch(Exception exc2) {
                throw new ExceptionEmailParsingException(expectedMessage1, exc2);
            }
        } catch(Exception exc1) {
            expectedClass1 = exc1.getTypeName();

            Map<String, Object> result = subject.buildPayload(exc1);

            Map<String, Object> data = (Map<String, Object>)result.get('data');

            Map<String, Object> notifierMap = (Map<String, Object>)data.get('notifier');
            System.assertEquals(Notifier.NAME, (String)notifierMap.get('name'));
            System.assertEquals(Notifier.VERSION, (String)notifierMap.get('version'));

            Map<String, Object> body = (Map<String, Object>)data.get('body');
            List<Map<String, Object>> traceChain = (List<Map<String, Object>>)body.get('trace_chain');
            Map<String, Object> trace1 = (Map<String, Object>)traceChain[0];
            Map<String, Object> trace2 = (Map<String, Object>)traceChain[1];
            Map<String, Object> exc1Map = (Map<String, Object>)trace1.get('exception');
            Map<String, Object> exc2Map = (Map<String, Object>)trace2.get('exception');

            System.assertEquals(expectedMessage1, exc1Map.get('message'));
            System.assertEquals(expectedClass1, exc1Map.get('class'));

            System.assertEquals(expectedMessage2, exc2Map.get('message'));
            System.assertEquals(expectedClass2, exc2Map.get('class'));
        }
    }

    @isTest
    static void testBuildExceptionDataPayload()
    {
        DataBuilder subject = new DataBuilder(new Config('foo', 'bar'));

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

        Map<String, Object> result = subject.buildPayload(exData);

        Map<String, Object> data = (Map<String, Object>)result.get('data');

        Map<String, Object> custom = (Map<String, Object>)data.get('custom');

        System.assertEquals((String)expected.get('context'), (String)custom.get('context'));
            
        Map<String, Object> notifierMap = (Map<String, Object>)data.get('notifier');
        System.assertEquals(Notifier.NAME, (String)notifierMap.get('name'));
        System.assertEquals(Notifier.VERSION, (String)notifierMap.get('version'));

        Map<String, Object> body = (Map<String, Object>)data.get('body');
        Map<String, Object> trace = (Map<String, Object>)body.get('trace');

        Map<String, Object> excMap = (Map<String, Object>)trace.get('exception');

        System.assertEquals(expected.get('message'), excMap.get('message'));
        System.assertEquals(expected.get('className'), excMap.get('class'));

        Map<String, Object> frameMap = ((List<Map<String, Object>>)trace.get('frames'))[0];

        System.assertEquals(expected.get('fileName'), frameMap.get('filename'));
        System.assertEquals(expected.get('className'), frameMap.get('class_name'));
        System.assertEquals(expected.get('fileName'), frameMap.get('method'));
        System.assertEquals(expected.get('line'), frameMap.get('lineno'));
        System.assertEquals(expected.get('column'), frameMap.get('colno'));
    }
}
