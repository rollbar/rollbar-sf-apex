@isTest
public class RollbarConfigureControllerTest {

    public static String testAccessToken = 'testaccesstoken123';

    @TestSetup
    static void makeData(){
        RollbarSettings__c rollbarSettings = new RollbarSettings__c();
        rollbarSettings.AccessToken__c = RollbarConfigureControllerTest.testAccessToken;
        insert rollbarSettings;
    }

    @isTest
    public static void testFetchingAccessToken() {
        Test.startTest();

        RollbarConfigureController controller = new RollbarConfigureController();

        System.assertEquals(RollbarConfigureControllerTest.testAccessToken, controller.accessToken);

        Test.stopTest();
    }

    @isTest
    public static void testConfigure() {
        // Test.startTest();

        // RollbarConfigureController controller = new RollbarConfigureController();
        
        // String newToken = 'newtestaccesstoken987';
        // Config config = new Config(newToken, 'test');
        // controller.configure(config);

        // System.assertEquals(
        //     newToken,
        //     RollbarSettings__c.getInstance().AccessToken__c
        // );

        // TODO: test remote site settings getting configured - not sure how to do it yet
        // since tests don't support callouts and the only way to check this is through the
        // metadata API

        // TODO: test the email service getting set up - not sure how to do it yet
        // since tests don't support callouts and the only way to check this is through the
        // metadata API

        // TODO: test the apex exception email address getting set up - not sure how to do it yet
        // since tests don't support callouts and the only way to check this is through the
        // metadata API

        Test.stopTest();
    }
}
