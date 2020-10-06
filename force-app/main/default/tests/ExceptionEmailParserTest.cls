@isTest
public class ExceptionEmailParserTest {

    private static String emailBody =
            'Sandbox\n\n' +
            'Apex script unhandled exception by user/organization: 0050R000001t3Br/00D0R000000DUxZ' + '\n\n' +
            'ContactEx: execution of AfterInsert' + '\n\n' +
            'caused by: System.NullPointerException: Attempt to de-reference a null object' + '\n\n' +
            'Trigger.ContactEx: line 3, column 1';

    @isTest
    public static void testParse() {
        ExceptionData exData = ExceptionEmailParser.parse(emailBody);

        System.assertEquals(null, exData.environment());
        System.assertEquals('0050R000001t3Br/00D0R000000DUxZ', exData.userOrg());
        System.assertEquals('System.NullPointerException', exData.className());
        System.assertEquals('Attempt to de-reference a null object', exData.message());
        System.assertEquals('Trigger.ContactEx', exData.fileName());
        System.assertEquals('ContactEx: execution of AfterInsert', exData.context());
        System.assertEquals(3, exData.line());
        System.assertEquals(1, exData.column());
    }

    @isTest
    public static void testParseNoStack() {
        String emailBody =
            'Sandbox\n\n' +
            'Apex script unhandled exception by user/organization: 0050R000001t3Br/00D0R000000DUxZ' + '\n' +
            'Source organization: 00D0R000000DUxZ (null)' + '\n' +
            'Failed to process batch for class \'ccrz.ccProductIndexCleanupJob\' for job id \'8061F00001btixO\'' + '\n\n' +
            'caused by: System.DmlException: Delete failed. First exception on row 5 with id b4r2E000001ReGSQB0; first error: ENTITY_IS_DELETED, entity is deleted: []' + '\n\n' +
            '(System Code)\n\n\n\n';

        ExceptionData exData = ExceptionEmailParser.parse(emailBody);

        System.assertEquals('0050R000001t3Br/00D0R000000DUxZ', exData.userOrg());
        System.assertEquals('System.DmlException', exData.className());
        System.assertEquals('Delete failed. First exception on row 5 with id b4r2E000001ReGSQB0; first error: ENTITY_IS_DELETED, entity is deleted: []', exData.message());
        System.assertEquals('Source organization: 00D0R000000DUxZ (null)\nFailed to process batch for class \'ccrz.ccProductIndexCleanupJob\' for job id \'8061F00001btixO\'', exData.context());
    }

    @isTest
    public static void testParseNoCausedBy() {
        String emailBody =
            'Apex script unhandled exception by user/organization: 0050R000001t3Br/00D0R000000DUxZ' + '\n\n' +
            'Failed to process batch for class \'G2Crowd.CalculateAccountAveragesBatch\' for job id \'8061F00001btixO\'';

        ExceptionData exData = ExceptionEmailParser.parse(emailBody);

        System.assertEquals('0050R000001t3Br/00D0R000000DUxZ', exData.userOrg());
        System.assertEquals('Failed to process batch for class \'G2Crowd.CalculateAccountAveragesBatch\' for job id \'8061F00001btixO\'', exData.context());
    }

    @isTest
    public static void testParseUserOrg() {
        String result = ExceptionEmailParser.parseUserOrg(emailBody);
        System.assertEquals('0050R000001t3Br/00D0R000000DUxZ', result);
    }

    @isTest
    public static void testParseUserOrgTriggerSyntax() {
        String emailBody = 'Apex script unhandled trigger exception by user/organization: 0050R000001t3Br/00D0R000000DUxZ';
        String result = ExceptionEmailParser.parseUserOrg(emailBody);
        System.assertEquals('0050R000001t3Br/00D0R000000DUxZ', result);
    }

    @isTest
    public static void testParseUserOrgNewLineSyntax() {
        String emailBody = 'Apex script unhandled exception by user/organization:\n0050R000001t3Br/00D0R000000DUxZ';
        String result = ExceptionEmailParser.parseUserOrg(emailBody);
        System.assertEquals('0050R000001t3Br/00D0R000000DUxZ', result);
    }

    @isTest
    public static void testParseClassName() {
        String result = ExceptionEmailParser.parseClassName(emailBody);
        System.assertEquals('System.NullPointerException', result);
    }

    @isTest
    public static void testParseClassNameDoubleColon() {
        String emailBody = 'caused by: System.ListException: List index out of bounds: 2';
        String result = ExceptionEmailParser.parseClassName(emailBody);
        System.assertEquals('System.ListException', result);
    }

    @isTest
    public static void testParseMessage() {
        String result = ExceptionEmailParser.parseMessage(emailBody);
        System.assertEquals('Attempt to de-reference a null object', result);
    }

    @isTest
    public static void testParseMessageDoubleColon() {
        String emailBody = 'caused by: System.ListException: List index out of bounds: 2';
        String result = ExceptionEmailParser.parseMessage(emailBody);
        System.assertEquals('List index out of bounds: 2', result);
    }

    @isTest
    public static void testParseFileName() {
        String result = ExceptionEmailParser.parseFileName(emailBody);
        System.assertEquals('Trigger.ContactEx', result);
    }

    @isTest
    public static void testParseLineno() {
        Integer result = ExceptionEmailParser.parseLineno(emailBody);
        System.assertEquals(3, result);
    }

    @isTest
    public static void testParseColno() {
        Integer result = ExceptionEmailParser.parseColno(emailBody);
        System.assertEquals(1, result);
    }
}
