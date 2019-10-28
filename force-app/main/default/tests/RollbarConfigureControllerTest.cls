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
}
