@isTest
global class RollbarApiVerifyRequestCalloutMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        String body = req.getBody();
        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(body);
        Map<String, Object> data = (Map<String, Object>)payload.get('data');

        Map<String, Object> notifierMap = (Map<String, Object>)data.get('notifier');
        System.assertEquals(Notifier.NAME, (String)notifierMap.get('name'));
        System.assertEquals(Notifier.VERSION, (String)notifierMap.get('version'));

        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"err":0,"result":{"id":null,"uuid":"e5ea9bee-08e6-41cc-a850-1863980dc224"}}');
        return response;
    }
}
