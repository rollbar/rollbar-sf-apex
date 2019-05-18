public with sharing class ExceptionEmailParser {
    public static ExceptionData parse(String emailBody) {

        ExceptionData exData = new ExceptionData(
            parseEnvironment(emailBody),
            parseUserOrg(emailBody),
            parseClassName(emailBody),
            parseMessage(emailBody),
            parseFileName(emailBody),
            parseContext(emailBody),
            parseLine(emailBody),
            parseColumn(emailBody)
        );

        return exData;
    }

    public static String parseEnvironment(String emailBody) {
        return emailBody.split('\\n')[0];
    }

    public static String parseUserOrg(String emailBody) {
        return parseContent(
            'Apex script unhandled( trigger)? exception by user/organization:(\n| )?(.*)',
            emailBody,
            3
        );
    }

    public static String parseClassName(String emailBody) {
        return parseContent(
            'caused by: ([^:]*):.*',
            emailBody,
            1
        );
    }

    public static String parseMessage(String emailBody) {
        return parseContent(
            'caused by: [^:]*: (.*)',
            emailBody,
            1
        );
    }

    public static String parseFileName(String emailBody) {
        return parseContent(
            '(.*): line [0-9]+, column [0-9]+',
            emailBody,
            1
        );
    }

    public static String parseContext(String emailBody) {
        return emailBody.split('\\n')[4];
    }

    public static Integer parseLine(String emailBody) {
        return Integer.valueOf(parseContent(
            '.*: line ([0-9]+), column [0-9]+',
            emailBody,
            1
        ));
    }

    public static Integer parseColumn(String emailBody) {
        return Integer.valueOf(parseContent(
            '.*: line [0-9]+, column ([0-9]+)',
            emailBody,
            1
        ));
    }

    private static String parseContent(String regex, String body, Integer groupToReturn) {
        Pattern pat = Pattern.compile(regex);
        Matcher mat = pat.matcher(body);
        mat.find();
        return mat.group(groupToReturn);
    }
}
