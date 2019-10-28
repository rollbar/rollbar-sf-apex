public with sharing class RollbarConfigureController {

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
        this.configure(new Config(this.accessToken, UserInfo.getOrganizationId()));
        return null;
    }

    public void configure(Config config)
    { 
        this.accessToken = config.accessToken();
        upsert this.settings;

        MetadataService.createRemoteSiteSetting('RollbarAPI', config.endpoint());

        // TODO: the tooling and the metadataapi are one - just make sure the domain is whitelisted

        // TODO: add creation of the email service
        String serviceEmailAdress = createEmailService();

        // TODO: setup apex unhandled exception email
        setupApexNotificationEmail(serviceEmailAdress);

        // TODO: add error handling
    }

    public static String createEmailService()
    {
        MetadataService.EmailServicesFunction emailService = new MetadataService.EmailServicesFunction();
        emailService.fullName = 'RollbarEmailService';
        emailService.functionName = 'RollbarEmailService';
        emailService.apexClass = 'RollbarExceptionEmailHandler';
        emailService.isActive = true;
        emailService.attachmentOption = 'None';
        emailService.authenticationFailureAction = 'Discard';
        emailService.authorizationFailureAction = 'Discard';
        // TODO: authorizedSenders might have to be set up for security
        // emailServicesAddresses.
        emailService.functionInactiveAction = 'Discard';
        emailService.overLimitAction = 'Discard';
        emailService.isAuthenticationRequired = false;
        emailService.isErrorRoutingEnabled = false;
        emailService.isTextAttachmentsAsBinary = false;
        emailService.isTlsRequired = false;

        MetadataService.EmailServicesAddress emailServiceAddress = new MetadataService.EmailServicesAddress();
        emailServiceAddress.developerName = 'rollbar';
        emailServiceAddress.isActive = true;
        emailServiceAddress.localPart = 'rollbarEmailService';
        emailServiceAddress.runAsUser = UserInfo.getUserName();
        // TODO: set up authrizedSender for security
        // emailServiceAddress.authorizedSenders

        MetadataService.createEmailService(emailService, new List<MetadataService.EmailServicesAddress> { emailServiceAddress });

        EmailServicesFunction emailFunction = [SELECT Id FROM EmailServicesFunction WHERE FunctionName=:emailService.fullName];
        EmailServicesAddress emailServicesAddress = [SELECT Id, LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId = :emailFunction.Id];
        
        return emailServicesAddress.LocalPart + '@' + emailServicesAddress.EmailDomainName;
    }

    @future(callout=true)
    public static void setupApexNotificationEmail(String email)
    {
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v35.0/tooling/';

        HTTPRequest req = new HTTPRequest();
        req.setEndpoint(baseUrl + 'sobjects/ApexEmailNotification');
        req.setMethod('POST');
        // OAuth header
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        req.setBody('{'+
            '"Email" : "' + email + '"'+
        '}');

        Http h = new Http();
        HttpResponse res = h.send(req);

        // TODO: how to handle returning results from this if it's a future
    }
}
