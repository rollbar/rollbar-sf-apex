@isTest
private class RollbarExceptionEmailHandlerTest {

    @isTest
    public static void testFlowEmail() {
        Test.setMock(HttpCalloutMock.class, new RollbarApiVerifyTelemetryCalloutMock());

        upsert new RollbarSettings__c(AccessToken__c = 'test-token', ReportFlowErrors__c = true);

        Test.startTest();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.fromName = 'FlowApplication';
        email.subject = 'Test Flow';
        email.htmlBody = '<html>Test Flow block 1\n\nTest Flow Block 2</html>\n\n';

        RollbarExceptionEmailHandler handler = new RollbarExceptionEmailHandler();
        handler.handleInboundEmail(email, envelope);
        Test.stopTest();

        // Asserts valid payload in the mock.
    }

    @isTest
    public static void testFlowEmailDisabled() {
        Test.setMock(HttpCalloutMock.class, new RollbarApiAssertNotCalledMock());

        upsert new RollbarSettings__c(AccessToken__c = 'test-token', ReportFlowErrors__c = false);

        Test.startTest();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.fromName = 'FlowApplication';
        email.htmlBody = '<html>Test Flow message</html>\n\n';

        RollbarExceptionEmailHandler handler = new RollbarExceptionEmailHandler();
        handler.handleInboundEmail(email, envelope);
        Test.stopTest();

        // Asserts API is not called in the mock.
    }
}
