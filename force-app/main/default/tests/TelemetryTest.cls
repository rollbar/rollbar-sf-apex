@isTest
private class TelemetryTest {

    @isTest
    public static void testConstructor() {
        Telemetry telemetry =  new Telemetry(
            'info',
            'log',
            'server',
            987654321,
            new Map<String, String>{ 'foo' => 'bar' }
        );
        System.assertEquals(telemetry.level, 'info');
        System.assertEquals(telemetry.type, 'log');
        System.assertEquals(telemetry.source, 'server');
        System.assertEquals(telemetry.timestamp, 987654321);
        System.assertEquals(telemetry.body.get('foo'), 'bar');
    }

    @isTest
    public static void testMap() {
        Map<String, Object> inMap = new Map<String, Object>();
        inMap.put('level', 'info');
        inMap.put('type', 'log');
        inMap.put('source', 'server');
        inMap.put('timestamp_ms', 987654321);
        inMap.put('body', new Map<String, String>{ 'foo' => 'bar' });

        Telemetry telemetry = Telemetry.fromMap(inMap);

        Map<String, Object> outMap = telemetry.toMap();

        System.assertEquals(outMap.get('level'), 'info');
        System.assertEquals(outMap.get('type'), 'log');
        System.assertEquals(outMap.get('source'), 'server');
        System.assertEquals(outMap.get('timestamp_ms'), 987654321);
        Map<String, String> body = (Map<String, String>) outMap.get('body');
        System.assertEquals(body.get('foo'), 'bar');
    }
}
