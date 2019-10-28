public class PostInstallClass implements InstallHandler {
    public void onInstall(InstallContext context) {
        if (context.previousVersion() == null) {
            // TODO: set up the access token
        }

        // TODO: set up the email service
        
        // TODO: add email service's email address to Apex exception emails list
    }
}