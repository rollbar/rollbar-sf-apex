/**
 * Installation:
 * 1. Create a new SF org.
 * 1. Create a new Rollbar project.
 * 41 Add `RollbarSettings__c` custom settings in Setup -> Custom Settings with custom field `AccessToken__c`
        and configure your Rollbar project access token.
 * 1. Add https://api.rollbar.com in `Remote Site Settings` in Salesforce Setup.
 * 2. Add email service in `Email Services` in Salesforce Setup pointint to RollbarExceptionEmailHandler class.
        Check `Active` box.
 * 3. Add Salesforce-generated email address from the added email service to `Apex Exception Email` addresses.
        Leave `Accept Email From` field empty.
 */
public with sharing class Rollbar {

    public static Rollbar instance() {
        if (Rollbar.instance == null) {
            Rollbar.instance = new Rollbar();
        }

        return Rollbar.instance;
    }

    public static Rollbar init()
    {
        return Rollbar.init(
            RollbarSettings__c.getInstance().AccessToken__c,
            UserInfo.getOrganizationId()
        );
    }

    public static Rollbar init(String accessToken, String environment) {
        return Rollbar.init(new Config(accessToken, environment));
    }

    public static Rollbar init(Config config) {
        Rollbar instance = instance();
        instance.config = config;
        instance.notifier = new Notifier(instance.config);
        instance.initialized = true;
        return instance;
    }

    public static HttpResponse log(String level, String message) {
        Rollbar instance = initializedInstance();
        return instance.notifier.log(level, message);
    }

    public static HttpResponse log(Exception exc) {
        Rollbar instance = initializedInstance();
        return instance.notifier.log(exc);
    }

    public static HttpResponse log(Exception exc, Map<String, Object> custom) {
        Rollbar instance = initializedInstance();
        return instance.notifier.log(exc, custom);
    }

    public static HttpResponse log(ExceptionData exData) {
        Rollbar instance = initializedInstance();
        return instance.notifier.log(exData);
    }

    private static Rollbar initializedInstance()
    {
        Rollbar instance = Rollbar.instance();
        if (!instance.initialized) {
            throw new RollbarNotInitializedException('Rollbar has not been initialized');
        }

        return instance;
    }

    private Rollbar() {
    }

    private static Rollbar instance = null;
    private Config config = null;
    private Notifier notifier = null;
    private Boolean initialized = false;
}