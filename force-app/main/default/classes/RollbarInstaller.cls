public with sharing class RollbarInstaller {

    public static String install(Config config)
    {
        return RollbarInstaller.enableServices(config.endpoint());
    }

    public static String enableServices(String apiDomain)
    {
        String message = null;
        RollbarSettings__c settings = RollbarSettings__c.getOrgDefaults();
        settings.Initialized__c = true;

        try {
            RollbarInstaller.enableRollbarApiCalls(settings, apiDomain);
            RollbarInstaller.enableApexNotificationsForwarding(settings);
        } catch (Exception e) {
            message = e.getMessage();
        }
        upsert settings;
        return message;
    }

    public static void saveToken(Config config)
    {
        RollbarSettings__c settings = RollbarSettings__c.getOrgDefaults();

        settings.AccessToken__c = config.accessToken();
        upsert settings;
    }

    public static String verifyToken(Config config)
    {
        String message = null;
        RollbarSettings__c settings = RollbarSettings__c.getOrgDefaults();

        try {
            settings.AccessToken__c = config.accessToken();
            settings.TokenValid__c = RollbarInstaller.accessTokenCorrect(config);
        } catch (Exception e) {
            message = e.getMessage();
        }
        upsert settings;
        return message;
    }

    public static void enableRollbarApiCalls(RollbarSettings__c settings, String apiDomain)
    {
        if (!rollbarApiEndpointAllowed(apiDomain)) {
            MetadataService.createRemoteSiteSetting('RollbarAPI', apiDomain);

            settings.SalesforceApiEnabled__c = metadataApiAllowed();
            settings.RollbarApiEnabled__c = rollbarApiEndpointAllowed(apiDomain);
            settings.RollbarNetworkAccess__c = rollbarPingSuccessful();
        } else if (!settings.RollbarNetworkAccess__c) {
            settings.RollbarNetworkAccess__c = rollbarPingSuccessful();
        }
    }

    public static void enableApexNotificationsForwarding(RollbarSettings__c settings)
    {
        String serviceEmailAddress;
        if (!rollbarEmailServiceSetUp()) {
            serviceEmailAddress = createEmailService();
        }
        settings.EmailServiceEnabled__c = rollbarEmailServiceSetUp();

        if (!apexNotificationsForwardingSetUp()) {
            setupApexNotificationEmail(serviceEmailAddress);
        }
        settings.NotificationForwardingEnabled__c = apexNotificationsForwardingSetUp();
    }

    public static String createEmailService()
    {
        EmailServiceInstaller.createEmailServiceFunction();
        EmailServiceInstaller.createEmailServiceAddress();

        Id emailFunctionId = EmailServiceInstaller.serviceId();
        EmailServicesAddress emailServicesAddress = [SELECT Id, LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId = :emailFunctionId];

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
        try {
            EmailServicesFunction emailFunction = [SELECT Id FROM EmailServicesFunction WHERE FunctionName='RollbarEmailService'];
            EmailServicesAddress emailServicesAddress = [SELECT Id, LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId = :emailFunction.Id];
        } catch (Exception ex) {
            return false;
        }

        return true;
    }

    public static Boolean apexNotificationsForwardingSetUp()
    {
        EmailServicesFunction emailFunction;
        EmailServicesAddress emailServicesAddress;
        try {
            emailFunction = [SELECT Id FROM EmailServicesFunction WHERE FunctionName='RollbarEmailService'];
            emailServicesAddress = [SELECT Id, LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId = :emailFunction.Id];
        } catch (Exception ex) {
            return false;
        }

        String emailServiceAddress = emailServicesAddress.LocalPart + '@' + emailServicesAddress.EmailDomainName;

        Boolean forwarding = false;
        ApexEmailNotification[] apexNotifications = [SELECT Email, UserId FROM ApexEmailNotification];
        for (ApexEmailNotification notification : apexNotifications) {
            if (notification.Email == emailServiceAddress) {
                forwarding = true;
            }
        }

        return forwarding;
    }

    public static Boolean accessTokenCorrect(Config config)
    {
        Rollbar.init(config);
        System.HttpResponse response = Rollbar.log('info', 'Rollbar Apex SDK installed correctly in ' + UserInfo.getOrganizationName());
        return response.getStatusCode() == 200;
    }


    public static Boolean metadataApiAllowed()
	{
		try {
			MetadataService.MetadataPort service = new MetadataService.MetadataPort();
			service.SessionHeader = new MetadataService.SessionHeader_element();
			service.SessionHeader.sessionId = UserInfo.getSessionId();
			List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
			MetadataService.ListMetadataQuery remoteSites = new MetadataService.ListMetadataQuery();
			remoteSites.type_x = 'RemoteSiteSetting';
			queries.add(remoteSites);
			service.listMetadata(queries, 28);
		} catch (Exception e) {
			return false;
		}
		return true;
	}
}
