public with sharing class EmailServiceInstaller {

    public static Id classId() {
        Id id = [
            SELECT Id FROM ApexClass
            WHERE Name = 'RollbarExceptionEmailHandler' AND Namespaceprefix = 'rollbar'
            LIMIT 1
        ].Id;
        return id;
    }

    public static Id serviceId() {
        Id id = [
            SELECT Id FROM EmailServicesFunction
            WHERE FunctionName = 'RollbarEmailService'
            LIMIT 1
        ].Id;
        return id;
    }

    public static void createEmailServiceFunction()
    {
        String baseUrl = URL.getOrgDomainUrl().toExternalForm() + '/services/Soap/u/48.0';

        HTTPRequest req = new HTTPRequest();
        req.setEndpoint(baseUrl);
        req.setMethod('POST');
        req.setHeader('SOAPAction', '""');
        req.setHeader('Content-Type', 'text/xml');
        req.setBody(
            '<?xml version="1.0" encoding="utf-8"?>' +
              '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:partner.soap.sforce.com" xmlns:urn1="urn:sobject.partner.soap.sforce.com">' +
                '<env:Header>' +
                    '<urn:SessionHeader>' +
                        '<urn:sessionId>'+UserInfo.getSessionId()+'</urn:sessionId>' +
                    '</urn:SessionHeader>' +
                '</env:Header>' +
                '<env:Body>' +
                    '<urn:create>' +
                        '<urn:sObjects>' +
                            '<urn1:type>EmailServicesFunction</urn1:type>' +
                            '<urn1:IsActive>true</urn1:IsActive>' +
                            '<urn1:ApexClassId>' + EmailServiceInstaller.classId() + '</urn1:ApexClassId>' +
                            '<urn1:FunctionName>RollbarEmailService</urn1:FunctionName>' +
                            '<urn1:AttachmentOption>None</urn1:AttachmentOption>' +
                        '</urn:sObjects>' +
                    '</urn:create>' +
                '</env:Body>' +
            '</env:Envelope>'
        );

        Http h = new Http();
        HttpResponse res = h.send(req);
    }

    public static void createEmailServiceAddress()
    {
        String baseUrl = URL.getOrgDomainUrl().toExternalForm() + '/services/Soap/u/48.0';

        HTTPRequest req = new HTTPRequest();
        req.setEndpoint(baseUrl);
        req.setMethod('POST');
        req.setHeader('SOAPAction', '""');
        req.setHeader('Content-Type', 'text/xml');
        req.setBody(
            '<?xml version="1.0" encoding="utf-8"?>' +
              '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:partner.soap.sforce.com" xmlns:urn1="urn:sobject.partner.soap.sforce.com">' +
                '<env:Header>' +
                    '<urn:SessionHeader>' +
                        '<urn:sessionId>'+UserInfo.getSessionId()+'</urn:sessionId>' +
                    '</urn:SessionHeader>' +
                '</env:Header>' +
                '<env:Body>' +
                    '<urn:create>' +
                        '<urn:sObjects>' +
                            '<urn1:type>EmailServicesAddress</urn1:type>' +
                            '<urn1:IsActive>true</urn1:IsActive>' +
                            '<urn1:FunctionId>' + EmailServiceInstaller.serviceId() + '</urn1:FunctionId>' +
                            '<urn1:DeveloperName>rollbar</urn1:DeveloperName>' +
                            '<urn1:LocalPart>rollbarEmailService</urn1:LocalPart>' +
                            '<urn1:RunAsUserId>' + UserInfo.getUserId() + '</urn1:RunAsUserId>' +
                        '</urn:sObjects>' +
                    '</urn:create>' +
                '</env:Body>' +
            '</env:Envelope>'
        );

        Http h = new Http();
        HttpResponse res = h.send(req);
    }

    public static void deleteEmailServiceFunction(EmailServicesFunction emailServiceFunction)
    {
        String baseUrl = URL.getOrgDomainUrl().toExternalForm() + '/services/Soap/u/48.0';

        HTTPRequest req = new HTTPRequest();
        req.setEndpoint(baseUrl);
        req.setMethod('POST');
        req.setHeader('SOAPAction', '""');
        req.setHeader('Content-Type', 'text/xml');
        req.setBody(
            '<?xml version="1.0" encoding="utf-8"?>' +
              '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:partner.soap.sforce.com">' +
                '<env:Header>' +
                    '<urn:SessionHeader>' +
                        '<urn:sessionId>'+UserInfo.getSessionId()+'</urn:sessionId>' +
                    '</urn:SessionHeader>' +
                '</env:Header>' +
                '<env:Body>' +
                    '<urn:delete>' +
                        '<urn:ids>' +
                            emailServiceFunction.Id +
                        '</urn:ids>' +
                    '</urn:delete>' +
                '</env:Body>' +
            '</env:Envelope>'
        );

        Http h = new Http();
        HttpResponse res = h.send(req);
    }

    public static void deleteEmailServiceAddress(EmailServicesAddress emailServiceAddress)
    {
        String baseUrl = URL.getOrgDomainUrl().toExternalForm() + '/services/Soap/u/48.0';

        HTTPRequest req = new HTTPRequest();
        req.setEndpoint(baseUrl);
        req.setMethod('POST');
        req.setHeader('SOAPAction', '""');
        req.setHeader('Content-Type', 'text/xml');
        req.setBody(
            '<?xml version="1.0" encoding="utf-8"?>' +
              '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:partner.soap.sforce.com">' +
                '<env:Header>' +
                    '<urn:SessionHeader>' +
                        '<urn:sessionId>'+UserInfo.getSessionId()+'</urn:sessionId>' +
                    '</urn:SessionHeader>' +
                '</env:Header>' +
                '<env:Body>' +
                    '<urn:delete>' +
                        '<urn:ids>' +
                            emailServiceAddress.Id +
                        '</urn:ids>' +
                    '</urn:delete>' +
                '</env:Body>' +
            '</env:Envelope>'
        );

        Http h = new Http();
        HttpResponse res = h.send(req);
    }
}
