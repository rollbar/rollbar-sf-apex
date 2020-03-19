public with sharing class Config {
    public Config(String accessToken, String environment) {
        if (accessToken == null || accessToken.length() == 0 || accessToken == '') {
            throw new RollbarNotInitializedException();
        }
        this.accessToken = accessToken;
        this.environment = environment;
    }

    public Config() {
        // Allows access to the default endpoint without a token.
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
    private String endpoint = 'https://api.rollbar.com/api/1/item/';
}
