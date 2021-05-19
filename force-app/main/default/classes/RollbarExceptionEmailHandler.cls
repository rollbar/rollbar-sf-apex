global class RollbarExceptionEmailHandler implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
                                                           Messaging.InboundEnvelope env){

        // Create an InboundEmailResult object for returning the result of the
        // Apex Email Service
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

        try {
            try {
                parseAndSend(email);
            } catch(Exception exc) {
                exc.getStackTraceString(); // without those calls strack trace string is not populated
                throw new ExceptionEmailParsingException('Unable to process unhandled exception email', exc);
            }
        } catch(ExceptionEmailParsingException wrapper) {
            wrapper.getStackTraceString(); // without those calls strack trace string is not populated

            Map<String, String> custom = new Map<String, String>();
            custom.put('email_body', getUnknownEmailBody(email));

            Rollbar.log(wrapper, custom);
        }

        // Set the result to true. No need to send an email back to the user
        // with an error message
        result.success = true;

        // Return the result for the Apex Email Service
        return result;
    }

    private void parseAndSend(Messaging.InboundEmail email) {
        RollbarSettings__c settings = RollbarSettings__c.getOrgDefaults();
        String emailBody = '';

        Rollbar.init();

        // The fromName field is the most reliable known way to differentiate
        // Exception and Flow email types.
        if (email.fromName == ExceptionEmailParser.fromName()) {
            if (!settings.ReportUncaughtExceptions__c) { return; }

            emailBody = email.plainTextBody;
            ExceptionData exData = ExceptionEmailParser.parse(emailBody);

            Item item = new Item(exData);
            item.isUncaught = true;
            item.personId = exData.userId();
            item.diagnostic.put('emailBody', emailBody);

            Rollbar.log('error', item, SendMethod.SYNC);
        } else if (email.fromName == FlowEmailParser.fromName()) {
            if (!settings.ReportFlowErrors__c) { return; }

            emailBody = email.htmlBody;
            FlowEmailParser flowParser = new FlowEmailParser(emailBody);
            List<Telemetry> telemetry = flowParser.parseTelemetry();

            Item item = new Item(email.subject);
            item.isUncaught = true;
            item.personId = flowParser.currentUserId;
            item.telemetry = telemetry;
            item.diagnostic.put('emailBody', emailBody);

            Rollbar.log('error', item, SendMethod.SYNC);
        } else {
            if (!settings.ReportUnknownEmailType__c) { return; }

            // Unknown email type.
            Item item = new Item(email.subject);
            item.isUncaught = true;
            item.diagnostic.put('emailBody', emailBody);
            item.diagnostic.put('fromName', email.fromName);

            Rollbar.log('error', item, SendMethod.SYNC);
        }
    }

    // Salesforce emails may contain either plain or html parts, but in the
    // case of Exception and Flow emails, they don't contain both.
    // This helper prefers plain, but will return html is it's the only part found.
    private String getUnknownEmailBody(Messaging.InboundEmail email) {
        String emailBody = email.plainTextBody;

        // Use html Body if no plain body is found.
        if (emailBody == null || emailBody == '') {
            emailBody = email.htmlBody;
        }
        return emailBody;
    }
}
