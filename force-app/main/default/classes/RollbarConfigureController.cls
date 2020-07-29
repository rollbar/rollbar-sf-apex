public with sharing class RollbarConfigureController {

    protected RollbarSettings__c settings { get; set; }

    public Boolean reportUncaughtExceptions { get; set; }
    public Boolean reportFlowErrors { get; set; }
    public Boolean reportUnknownEmailType { get; set; }
    public Boolean sendReports { get; set; }
    public String environment { get; set; }
    public String accessToken {
        get {
            return this.settings.AccessToken__c;
        }
        set {
            this.accessToken = this.settings.AccessToken__c = value;
        }
    }

    public Boolean tokenIsBlank {
        get {
            return String.isBlank(this.AccessToken);
        }
    }

    public String configState { get; private set; }
    public String error { get; private set; }

    public RollbarConfigureController() {
        this.settings = RollbarSettings__c.getOrgDefaults();
        this.reportUncaughtExceptions = this.settings.ReportUncaughtExceptions__c;
        this.reportFlowErrors = this.settings.ReportFlowErrors__c;
        this.reportUnknownEmailType = this.settings.ReportUnknownEmailType__c;
        this.sendReports = this.settings.SendReports__c;
        this.environment = this.settings.Environment__c;
        updateConfigState();
    }

    public Pagereference install()
    {
        String message = RollbarInstaller.install(new Config());
        if (!String.isBlank(message)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, message));
        }
        this.settings = RollbarSettings__c.getOrgDefaults();
        updateConfigState();
        return null;
    }

    public Pagereference verifyToken()
    {
        String message;

        try {
            Config config = new Config(this.accessToken, this.settings.Environment__c);
            message = RollbarInstaller.verifyToken(config);
        } catch (RollbarNotInitializedException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Provided access token is incorrect.'));
        }
        if (!String.isBlank(message)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, message));
        }
        this.settings = RollbarSettings__c.getOrgDefaults();
        this.reportUncaughtExceptions = this.settings.ReportUncaughtExceptions__c;
        this.reportFlowErrors = this.settings.ReportFlowErrors__c;
        this.reportUnknownEmailType = this.settings.ReportUnknownEmailType__c;
        this.sendReports = this.settings.SendReports__c;
        this.environment = this.settings.Environment__c;
        updateConfigState();
        return null;
    }

    public Pagereference updateSettings()
    {
        String message;

        this.settings = RollbarSettings__c.getOrgDefaults();
        this.settings.ReportUncaughtExceptions__c = this.reportUncaughtExceptions;
        this.settings.ReportFlowErrors__c = this.reportFlowErrors;
        this.settings.ReportUnknownEmailType__c = this.reportUnknownEmailType;
        this.settings.SendReports__c = this.sendReports;
        this.settings.Environment__c = this.environment;
        upsert this.settings;

        updateConfigState();
        return null;
    }

    public Pagereference uninstall() {
        RollbarInstaller.prepareUninstall();

        this.settings = RollbarSettings__c.getOrgDefaults();
        this.settings.PreparedForUninstall__c = true;
        upsert this.settings;
        updateConfigState();
        return null;
    }

    public Pagereference reinstall() {
        this.settings.PreparedForUninstall__c = false;
        upsert this.settings;
        updateConfigState();
        return null;
    }

    public void updateConfigState() {
        if (this.settings.PreparedForUninstall__c) {
            this.configState = 'ConfigState.UNINSTALL';
        } else if (!this.settings.Initialized__c) {
            this.configState = 'ConfigState.INIT';
        } else if (!this.settings.SalesforceApiEnabled__c) {
            this.configState = 'ConfigState.SF_API';
        } else if (!this.settings.RollbarApiEnabled__c) {
            this.configState = 'ConfigState.ROLLBAR_API';
        } else if (!this.settings.RollbarNetworkAccess__c) {
            this.configState = 'ConfigState.NETWORK';
        } else if (!this.settings.EmailServiceEnabled__c) {
            this.configState = 'ConfigState.EMAIL_SERVICE';
        } else if (!this.settings.NotificationForwardingEnabled__c) {
            this.configState = 'ConfigState.FORWARDING';
        } else if (!this.settings.TokenValid__c) {
            this.configState = 'ConfigState.TOKEN';
        } else {
            this.configState = 'ConfigState.COMPLETE';
        }
    }
}
