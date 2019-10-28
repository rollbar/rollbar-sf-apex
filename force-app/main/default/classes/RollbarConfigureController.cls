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
            return null;
        }

        RollbarInstaller.install(config);

        PageReference checkPage = new PageReference('/apex/RollbarInstallationCheck');
        checkPage.setRedirect(true);
        return checkPage;
    }

    public Pagereference check()
    {
        Config config = new Config(this.accessToken, UserInfo.getOrganizationId());

        this.checks = RollbarInstaller.check(config);

        Boolean installed = true;
        for (String key : this.checks.keySet()) {
            if (!this.checks.get(key)) {
                installed = false;
                break;
            }
        }
        this.installed = installed;

        return null;
    }
}
