public with sharing class RollbarInstaller {
    
    public static Map<String, Boolean> check(Config config)
    {
        Map<String, Boolean> checks = new Map<String, Boolean>();

        try {
            checks.put('rollbarApiEndpointAllowed', rollbarApiEndpointAllowed(config.endpoint()));
        } catch (Exception ex) {
            checks.put('rollbarApiEndpointAllowed', false);
        }

        try {
            checks.put('rollbarPingSuccessful', rollbarPingSuccessful());
        } catch (Exception ex) {
            checks.put('rollbarPingSuccessful', false);
        }

        try {
            checks.put('rollbarEmailServiceSetUp', rollbarEmailServiceSetUp());
        } catch (Exception ex) {
            checks.put('rollbarEmailServiceSetUp', false);
        }
        
        try {
            checks.put('apexNotificationsForwardingSetUp', apexNotificationsForwardingSetUp());
        } catch (Exception ex) {
            checks.put('apexNotificationsForwardingSetUp', false);
        }

        try {
            checks.put('accessTokenCorrect', accessTokenCorrect(config));
        } catch (Exception ex) {
            checks.put('accessTokenCorrect', false);
        }

        return checks;
    }

    public static void install(Config config)
    {
        RollbarInstaller.saveSettings(config);

        RollbarInstaller.enableRollbarApiCalls(config.endpoint());

        // TODO: the tooling and the metadataapi are one - just make sure the domain is whitelisted

        RollbarInstaller.enableApexNotificationsForwarding();
    }

    public static void saveSettings(Config config)
    {
        RollbarSettings__c settings = RollbarSettings__c.getOrgDefaults();
        settings.AccessToken__c = config.accessToken();
        upsert settings;
    }

    @future(callout=true)
    public static void enableRollbarApiCalls(String apiDomain)
    {
        MetadataService.createRemoteSiteSetting('RollbarAPI', apiDomain);
    }

    @future(callout=true)
    public static void enableApexNotificationsForwarding()
    {
        String serviceEmailAdress = createEmailService();
        setupApexNotificationEmail(serviceEmailAdress);
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

    public static Boolean rollbarApiEndpointAllowed(String endpoint)
    {
        MetadataService.MetadataPort service = MetadataService.createServiceWithSession();
        MetadataService.ReadRemoteSiteSettingResult result = (MetadataService.ReadRemoteSiteSettingResult)service.readMetadata('RemoteSiteSetting', new String[] {'RollbarAPI'});

        MetadataService.Metadata[] records = result.getRecords();

        if (records.size() == 0) {
            return false;
        }

        MetadataService.RemoteSiteSetting setting = (MetadataService.RemoteSiteSetting)result.getRecords()[0];
        
        if (setting.fullName != 'RollbarAPI') {
            return false;
        }

        if (!endpoint.contains(setting.url)) {
            return false;
        }

        return true;
    }

    public static Boolean rollbarPingSuccessful()
    {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.rollbar.com/api/1/status/ping');
        request.setMethod('GET');

        Http http = new Http();
        HttpResponse response = http.send(request);

        return response.getStatusCode() == 200;
    }

    public static Boolean rollbarEmailServiceSetUp()
    {
        // TODO: remove when installation is finished
        return true;
        
        // try {
        //     EmailServicesFunction emailFunction = [SELECT Id FROM EmailServicesFunction WHERE FunctionName='RollbarEmailService'];
        //     EmailServicesAddress emailServicesAddress = [SELECT Id, LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId = :emailFunction.Id];
        // } catch (Exception ex) {
        //     return false;    
        // }

        // return true;
    }

    public static Boolean apexNotificationsForwardingSetUp()
    {
        // TODO: remove when installation is finished
        return true;

        // EmailServicesFunction emailFunction;
        // EmailServicesAddress emailServicesAddress;
        // try {
        //     emailFunction = [SELECT Id FROM EmailServicesFunction WHERE FunctionName='RollbarEmailService'];
        //     emailServicesAddress = [SELECT Id, LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId = :emailFunction.Id];
        // } catch (Exception ex) {
        //     return false;    
        // }

        // String emailServiceAddress = emailServicesAddress.LocalPart + '@' + emailServicesAddress.EmailDomainName;

        // Boolean forwarding = false;
        // ApexEmailNotification[] apexNotifications = [SELECT Email, UserId FROM ApexEmailNotification];
        // for (ApexEmailNotification notification : apexNotifications) {
        //     if (notification.Email == emailServiceAddress) {
        //         forwarding = true;
        //     }
        // }

        // return forwarding;
    }

    public static Boolean accessTokenCorrect(Config config)
    {
        Rollbar.init(config);
        return Rollbar.log('info', 'Rollbar Apex SDK installed correctly in ' + UserInfo.getOrganizationName()).
            getStatusCode() == 200;
    }
}
