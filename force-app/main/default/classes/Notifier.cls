public with sharing class Notifier {

    public Notifier(Config config) {
        this.config = config;
    }

    public HttpResponse log(String level, String message) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(this.config.endpoint());
        request.setMethod('POST');

        String payload = this.buildPayload(level, message); 
        request.setBody(payload);

        System.debug(payload);

        Http http = new Http();
        HttpResponse response = http.send(request);

        System.debug(response);

        return response;
    }

    private String buildPayload(String level, String message) {
        return '{'+
            '"access_token":"'+this.config.accessToken()+'",'+
            '"data":{'+
                '"environment":"development",'+
                '"body":{'+
                    '"message":{'+
                        '"body":"'+message+'"'+
                    '}'+
                '},'+
                '"level":"'+level+'"'+
            '}'+
        '}';
    }

    private Config config = null;
}