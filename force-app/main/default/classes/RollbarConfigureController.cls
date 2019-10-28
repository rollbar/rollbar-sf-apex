public with sharing class RollbarConfigureController {

    public Map<String, Boolean> checks  { get; private set; }

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
        this.settings = RollbarSettings__c.getOrgDefaults();
    }

    public Pagereference save()
    {
        Config config = new Config(this.accessToken, UserInfo.getOrganizationId());

        RollbarInstaller.install(config);

        return null;
    }

    public Pagereference check()
    {
        Config config = new Config(this.accessToken, UserInfo.getOrganizationId());

        this.checks = RollbarInstaller.check(config);
        
        return null;
    }
}
