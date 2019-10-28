@isTest
public with sharing class PostInstallClassTest {
    @isTest
    static void testInstallScript() {
        PostInstallClass postinstall = new PostInstallClass();
        Test.testInstall(postinstall, null);

        

        Test.testInstall(postinstall, new Version(1,0));
    }
}
