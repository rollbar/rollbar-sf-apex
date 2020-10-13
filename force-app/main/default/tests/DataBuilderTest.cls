@isTest
public class DataBuilderTest
{
    static User insertUser(String userAlias) {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Blob b = Crypto.GenerateAESKey(128);
        String username = EncodingUtil.ConvertTohex(b) + '@example.com';

        User u = new User(
            Alias = userAlias,
            Email = userAlias + '@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Tester',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = username
        );

         insert(u);

         return u;
    }

    @isTest
    static void testBuildMessagePayload()
    {
        DataBuilder subject = new DataBuilder(new Config('foo', 'bar'));
        String expected = 'Message built in DataBuilderTest';
        Item item = new Item(expected);

        User testUser = insertUser('test1');
        Map<String, Object> result;

        System.runAs(testUser) {
            result = subject.buildPayload('info', item);
        }

        Map<String, Object> data = (Map<String, Object>)result.get('data');

        Map<String, Object> person = (Map<String, Object>)data.get('person');
        System.assertEquals(testUser.Id, (String)person.get('id'));
        System.assertEquals(testUser.Username, (String)person.get('username'));
        System.assertEquals(testUser.Email, (String)person.get('email'));

        System.assertEquals(data.containsKey('custom'), false);

        Map<String, Object> notifierMap = (Map<String, Object>)data.get('notifier');

        System.assertEquals(Notifier.NAME, (String)notifierMap.get('name'));
        System.assertEquals(Notifier.VERSION, (String)notifierMap.get('version'));

        Map<String, Object> body = (Map<String, Object>)data.get('body');

        System.assertEquals(expected, ((Map<String, Object>)body.get('message')).get('body'));
    }

    @isTest
    static void testBuildMessagePayloadWithTelemetry()
    {
        DataBuilder subject = new DataBuilder(new Config('foo', 'bar'));

        List<Telemetry> telemetryList = new List<Telemetry>();
        telemetryList.add(new Telemetry(
            'info',
            'log',
            'server',
            987654321,
            new Map<String, String>{ 'message' => 'first' }
        ));
        telemetryList.add(new Telemetry(
            'info',
            'log',
            'server',
            987654321,
            new Map<String, String>{ 'message' => 'second' }
        ));
        Item item = new Item('Telemetry test');
        item.telemetry = telemetryList;
        item.isUncaught = true; // Make item look like a Flow error

        User testUser = insertUser('test2');
        item.personId = testUser.Id;

        Map<String, Object> result = subject.buildPayload('info', item);

        Map<String, Object> data = (Map<String, Object>)result.get('data');

        Map<String, Object> person = (Map<String, Object>)data.get('person');
        System.assertEquals(testUser.Id, (String)person.get('id'));
        System.assertEquals(testUser.Username, (String)person.get('username'));
        System.assertEquals(testUser.Email, (String)person.get('email'));

        Map<String, Object> body = (Map<String, Object>)data.get('body');

        List<Map<String, Object>> telemetryObjects = new List<Map<String, Object>>();
        for (Object instance : (List<Object>)body.get('telemetry')) {
            telemetryObjects.add((Map<String, Object>)instance);
        }

        for (Map<String, Object> telemetry : telemetryObjects) {
            System.assertEquals((String)telemetry.get('level'), 'info');
            System.assertEquals((String)telemetry.get('type'), 'log');
            System.assertEquals((String)telemetry.get('source'), 'server');
            System.assertEquals((Long)telemetry.get('timestamp_ms'), 987654321);
        }
        Map<String, String> messageBody = (Map<String, String>)telemetryObjects.get(0).get('body');
        System.assertEquals(messageBody.get('message'), 'first');
        messageBody = (Map<String, String>)telemetryObjects.get(1).get('body');
        System.assertEquals(messageBody.get('message'), 'second');
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
            Item item = new Item(exc);
            Map<String, Object> result = subject.buildPayload('error', item);

            Map<String, Object> data = (Map<String, Object>)result.get('data');

            System.assertEquals(data.containsKey('custom'), false);

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
        Item item = new Item(exc);
        item.custom = expectedCustom;

        Map<String, Object> result = subject.buildPayload('error', item);
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
            Item item = new Item(exc1);

            Map<String, Object> result = subject.buildPayload('error', item);

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
        Item item = new Item(exData);
        item.isUncaught = true;

        User testUser = insertUser('test3');
        item.personId = testUser.Id;

        Map<String, Object> result = subject.buildPayload('error', item);

        Map<String, Object> data = (Map<String, Object>)result.get('data');

        Map<String, Object> custom = (Map<String, Object>)data.get('custom');

        System.assertEquals((String)expected.get('context'), (String)custom.get('context'));

        Map<String, Object> person = (Map<String, Object>)data.get('person');
        System.assertEquals(testUser.Id, (String)person.get('id'));
        System.assertEquals(testUser.Username, (String)person.get('username'));
        System.assertEquals(testUser.Email, (String)person.get('email'));

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

    @isTest
    static void testBuildEachFrameType()
    {
        String[] input = new String[]{
            'Class.HelloWorld.hello: line 32, column 1', // Normal class context
            'Trigger.Log: line 8, column 1', // Trigger context
            'AnonymousBlock: line 2, column 1', // Anonymous context
            '(rollbar)', // Stripped frame
            'Class: line 32', // Invalid
            'Trigger: column 1' // Invalid
        };

        List <Map<String, Object>> output = new List <Map<String, Object>> {
            new Map<String, Object>{
                'class_name' => 'HelloWorld', 'method' => 'hello', 'lineno' => 32, 'colno' => 1
            },
            new Map<String, Object>{
                'class_name' => 'Trigger', 'method' => 'Log', 'lineno' => 8, 'colno' => 1
            },
            new Map<String, Object>{
                'class_name' => 'Unknown', 'method' => 'AnonymousBlock', 'lineno' => 2, 'colno' => 1
            },
            new Map<String, Object>{
                'class_name' => 'Unknown', 'method' => '(rollbar)', 'lineno' => '(unknown)', 'colno' => '(unknown)'
            },
            new Map<String, Object>{
                'class_name' => '(unknown)', 'method' => '(unknown)', 'lineno' => 32, 'colno' => '(unknown)'
            },
            new Map<String, Object>{
                'class_name' => 'Trigger', 'method' => '(unknown)', 'lineno' => '(unknown)', 'colno' => 1
            }
        };

        DataBuilder subject = new DataBuilder(new Config('foo', 'bar'));

        for(Integer i = 0; i < input.size(); i++){
            Map<String, Object> result = subject.buildTraceBody(input[i], 'Exception', 'Error message');
            Map<String, Object> trace = (Map<String, Object>)result.get('trace');
            Map<String, Object> frame = ((List<Map<String, Object>>)trace.get('frames'))[0];

            System.assertEquals(frame.get('class_name'), output[i].get('class_name'));
            System.assertEquals(frame.get('method'), output[i].get('method'));
            System.assertEquals(frame.get('lineno'), output[i].get('lineno'));
            System.assertEquals(frame.get('colno'), output[i].get('colno'));
        }
    }
}
