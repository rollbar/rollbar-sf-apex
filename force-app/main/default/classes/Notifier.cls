public with sharing class Notifier
{
    public static final String NAME = 'rollbar-sf-apex';
    public static final String VERSION = '1.10.0';

    public Notifier(Config config)
    {
        this.config = config;
        this.dataBuilder = new DataBuilder(this.config);
    }

    public HttpResponse log(String level, String message)
    {
        return send(dataBuilder.buildPayload(level, message));
    }

    public HttpResponse log(Exception exc)
    {
        return send(dataBuilder.buildPayload(exc));
    }

    public HttpResponse log(Exception exc, Map<String, Object> custom)
    {
        return send(dataBuilder.buildPayload(exc, custom));
    }

    public HttpResponse log(ExceptionData exData)
    {
        return send(dataBuilder.buildPayload(exData));
    }

    private HttpResponse send(Map<String, Object> payload)
    {
        return send(JSON.serialize(payload));
    }

    private HttpResponse send(String payload)
    {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(this.config.endpoint());
        request.setMethod('POST');
        request.setBody(payload);

        Http http = new Http();
        HttpResponse response = http.send(request);

        return response;
    }

    private Config config;
    private DataBuilder dataBuilder;
}
