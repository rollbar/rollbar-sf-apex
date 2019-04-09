@isTest
global class RollbarApiCalloutMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();

        response.setStatusCode(200);

        response.setBody('{"err":0,"result":{"id":null,"uuid":"e5ea9bee-08e6-41cc-a850-1863980dc224"}}');

        return response;
    }
}