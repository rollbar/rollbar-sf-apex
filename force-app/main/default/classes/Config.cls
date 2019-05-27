public with sharing class Config {
    public Config(String accessToken, String environment) {
        if (accessToken == null || accessToken == '') {
            throw new RollbarNotInitializedException('Invalid access token');
        }

        this.accessToken = accessToken;
        this.environment = environment;
        this.endpoint = 'https://api.rollbar.com/api/1/item/';
    }

    public String accessToken() {
        return this.accessToken;
    }

    public String environment() {
        return this.environment;
    }

    public String endpoint() {
        return this.endpoint;
    }

    private String accessToken = null;
    private String environment = null;
    private String endpoint = null;
}