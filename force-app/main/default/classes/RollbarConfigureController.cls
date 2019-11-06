public with sharing class RollbarConfigureController {

    public Map<String, Boolean> checks  { get; private set; }
    public Boolean installed { get; private set; }

    protected RollbarSettings__c settings { get; set; }
    public String accessToken {
        get {
            return this.settings.AccessToken__c;
        }
        set {
            this.accessToken = this.settings.AccessToken__c = value;
        }
    }

    public RollbarConfigureController() {
        this.installed = false;
        this.settings = RollbarSettings__c.getOrgDefaults();
    }

    public Pagereference save()
    {
        
        Config config;
        
        try {
            config = new Config(this.accessToken, UserInfo.getOrganizationId());
        } catch(RollbarNotInitializedException ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Provided access token is incorrect.'));
            return (new PageReference('/apex/RollbarConfigure')).setRedirect(true);
        }

        RollbarInstaller.install(config);

        PageReference checkPage = new PageReference('/apex/RollbarInstallationCheck');
        checkPage.setRedirect(true);
        return checkPage;
    }

    public Pagereference saveAsync()
    {
        
        Config config;
        
        try {
            config = new Config(this.accessToken, UserInfo.getOrganizationId());
        } catch(RollbarNotInitializedException ex) {
            return null;
        }

        RollbarInstaller.install(config);

        return null;
    }

    public Pagereference check()
    {
        Config config;

        try {
            config = new Config(this.accessToken, UserInfo.getOrganizationId());
        } catch(RollbarNotInitializedException ex) {
            return null;
        }

        this.checks = RollbarInstaller.check(config);

        Boolean installed = true;
        for (String key : this.checks.keySet()) {
            if (!this.checks.get(key)) {
                installed = false;
            }
        }
        this.installed = installed;

        return null;
    }
}
