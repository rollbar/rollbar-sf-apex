@isTest
private class RollbarExceptionEmailHandlerTest {

    @isTest
    public static void testFlowEmail() {
        Test.setMock(HttpCalloutMock.class, new RollbarApiVerifyTelemetryCalloutMock());

        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.fromName = 'FlowApplication';
        email.htmlBody = '<html>Test Flow message</html>\n\n';

        Rollbar.init('test-token', 'test-env');

        RollbarExceptionEmailHandler handler = new RollbarExceptionEmailHandler();
        handler.handleInboundEmail(email, envelope);

        // Asserts valid payload in the mock.
    }
}
