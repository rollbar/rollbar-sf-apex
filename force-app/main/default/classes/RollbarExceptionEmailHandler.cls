global class RollbarExceptionEmailHandler implements Messaging.InboundEmailHandler {
 
  global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, 
                                                       Messaging.InboundEnvelope env){
 
    // Create an InboundEmailResult object for returning the result of the 
    // Apex Email Service
    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

    String emailBody = '';

    // Add the email plain text into the local variable 
    emailBody = email.plainTextBody;

    Rollbar.init('access-token', UserInfo.getOrganizationId());

    try {
      try {
        ExceptionData exData = ExceptionEmailParser.parse(emailBody);
        Rollbar.log(exData);
      } catch(Exception exc) {
        exc.getStackTraceString(); // without those calls strack trace string is not populated
        throw new ExceptionEmailParsingException('Unable to process unhandled email', exc);
      }
    } catch(ExceptionEmailParsingException wrapper) {
      wrapper.getStackTraceString(); // without those calls strack trace string is not populated

      Map<String, String> custom = new Map<String, String>();
      custom.put('email_body', emailBody);

      Rollbar.log(wrapper, custom);
    }

    // Set the result to true. No need to send an email back to the user 
    // with an error message
    result.success = true;

    // Return the result for the Apex Email Service
    return result;
  }
}