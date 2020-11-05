public with sharing class Notifier
{
    public static final String NAME = 'rollbar-sf-apex';
    public static final String VERSION = '2.3.0';

    public Notifier(Config config)
    {
        this.config = config;
        this.dataBuilder = new DataBuilder(this.config);
    }

    public HttpResponse log(String level, String message, Map<String, Object> custom, List<Telemetry> telemetry, SendMethod method)
    {
        return send(dataBuilder.buildPayload(level, message, custom, telemetry), method);
    }

    public HttpResponse log(String level, Exception exc, Map<String, Object> custom, SendMethod method)
    {
        return send(dataBuilder.buildPayload(level, exc, custom), method);
    }

    public HttpResponse log(ExceptionData exData, SendMethod method)
    {
        return send(dataBuilder.buildPayload(exData), method);
    }

    public HttpResponse send(Map<String, Object> payload, SendMethod method)
    {
        if(!RollbarSettings__c.getOrgDefaults().SendReports__c) { return null; }

        return methodSend(JSON.serialize(payload), method);
    }

    public HttpResponse methodSend(String payload, SendMethod method)
    {
        HttpResponse response = null;

        switch on method {
            when SYNC {
                response = syncSend(payload);
            }
            when FUTURE {
                Notifier.futureSend(payload);
            }
            when else {
                eventSend(payload);
            }
        }

        return response;
    }

    private void eventSend(String payload)
    {
        RollbarEvent__e event = new RollbarEvent__e(Data1__c = payload);

        EventBus.publish(event);
    }

    @future (callout=true)
    private static void futureSend(String payload)
    {
        Notifier notifier = Rollbar.initializedInstance().notifier();

        notifier.syncSend(payload);
    }

    private HttpResponse syncSend(String payload)
    {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(this.config.endpoint());
        request.setMethod('POST');
        request.setBody(payload);

        Http http = new Http();
        HttpResponse response = http.send(request);

        return response;
    }

    public Config config() {
        return config;
    }

    private Config config;
    private DataBuilder dataBuilder;
}
