@isTest
public class FlowEmailParserTest {
    private static String emailBody =
        '<!DOCTYPE html><html><p>\n' +
        'Error element myRule_1_A1 (FlowRecordUpdate).<br>\n' +
        'The flow tried to update these records: null.\n' +
        'You can look up ExceptionCode values in the\n' +
        '<a href=3D\'https://developer.salesforce.com/docs/\'>SOAP API Developer Guide</a>.<br>\n' +
        '</p>\n' +
        '<hr>\n' +
        '<p>\n' +
        '<span style=3D"font-weight:bold">Flow Details > </span><br>\n' +
        'Flow API Name: Contact_address_change_V2<br>\n' +
        'Type: Record < Change Process<br>\n' +
        'Version: <> 1<br>\n' +
        'Status: Active<br>\n' +
        'Org: Example Org (00D6g00000756dd)<br>\n' +
        '</p>\n' +
        '<p>\n' +
        '<span style=3D"font-weight:bold">Flow Interview Details</span><br>\n' +
        'Interview Label: Contact_address_change_V2-1_InterviewLabel<br>\n' +
        'Current User: Example User (0056g0000067Oja)<br>\n' +
        'Start time: 5/21/2020, 12:20 PM<br>\n' +
        'Duration: 0 seconds<br>\n' +
        '</p>\n' +
        '<p>\n' +
        '<span style=3D"font-weight:bold">How the Interview Started</span><br>\n' +
        'Example User (0056g0000067Oja) started the flow interview.<br>\n' +
        'Some of this flow\'s variables were set when the interview started.<br>\n' +
        'myVariable_old =3D Account (0015g00000NicIeBBJ)<br>\n' +
        'myVariable_current =3D Account (0015g00000NicIeBBJ)<br>\n' +
        '</p></body></html>\n';
        //     ^ Ends with a dangling "</body> because that's what the actual email body does.

    @isTest
    public static void testParse() {
        FlowEmailParser flowParser = new FlowEmailParser(emailBody);
        List<Telemetry> telemetryList = flowParser.parseTelemetry();

        System.assertEquals(telemetryList.size(), 4);

        for (Telemetry telemetry : telemetryList) {
            System.assertEquals(telemetry.level, 'info');
            System.assertEquals(telemetry.type, 'log');
            System.assertEquals(telemetry.source, 'server');

            String message = telemetry.body.get('message');
            System.assertEquals(message.split('\n').size(), 1);
        }
        System.assert(telemetryList.get(0).body.get('message').startsWith('Error element'));
        System.assert(telemetryList.get(1).body.get('message').startsWith('Flow Details'));
        System.assert(telemetryList.get(2).body.get('message').startsWith('Flow Interview Details'));
        System.assert(telemetryList.get(3).body.get('message').startsWith('How the Interview Started'));

        // Confirm handling of unexpected <>
        System.assert(telemetryList.get(1).body.get('message').contains('Change Process'));
        System.assert(telemetryList.get(1).body.get('message').contains('<>'));

        System.assertEquals(flowParser.currentUserId, '0056g0000067Oja');
    }
}
