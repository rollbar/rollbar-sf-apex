// Use this mock to assert the API is not called.
@isTest
global class RollbarApiAssertNotCalledMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        System.assert(false, 'Rollbar API should not be called.');

        return null;
    }
}
