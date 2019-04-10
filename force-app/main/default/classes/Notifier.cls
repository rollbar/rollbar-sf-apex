public with sharing class Notifier
{

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

    private HttpResponse reportPayload(String payload)
    {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(this.config.endpoint());
        request.setMethod('POST');
        request.setBody(payload);

        System.debug(payload);

        Http http = new Http();
        HttpResponse response = http.send(request);

        System.debug(response);

        return response;
    }

    private Config config;
    private DataBuilder dataBuilder;
}