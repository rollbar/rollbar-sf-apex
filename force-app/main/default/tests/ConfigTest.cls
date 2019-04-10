@isTest
private class ConfigTest {

    @isTest
    public static void testConfig() {
        Config subject = new Config('foo', 'production');

        System.assertEquals('foo', subject.accessToken());
        System.assertEquals('production', subject.environment());
        System.assertEquals('https://api.rollbar.com/api/1/item/', subject.endpoint());
    }
}