public with sharing class Notifier
{
    public static final String NAME = 'rollbar-sf-apex';
    public static final String VERSION = '1.0.0';

    public Notifier(Config config)
    {
        this.config = config;
        this.dataBuilder = new DataBuilder(this.config);
    }

    public HttpResponse log(String level, String message)
    {
        String payload = JSON.serialize(this.dataBuilder.buildPayload(level, message));
        return reportPayload(payload);
    }

    public HttpResponse log(Exception exc)
    {
        String payload = JSON.serialize(this.dataBuilder.buildPayload(exc));
        return reportPayload(payload);
    }

    public HttpResponse log(ExceptionData exData)
    {
        String payload = JSON.serialize(this.dataBuilder.buildPayload(exData));
        return reportPayload(payload);
    }

    private HttpResponse reportPayload(String payload)
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