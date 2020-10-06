public with sharing class ExceptionEmailParser {
    public static ExceptionData parse(String emailBody) {
        List<String> lines = emailBody.split('\n');

        Map<String, Object> exDataMap = parseLines(lines);

        ExceptionData exData = ExceptionData.fromMap(exDataMap);

        return exData;
    }

    private static String fromName = 'ApexApplication';

    public static String fromName() {
        return fromName;
    }

    // Exception email bodies are generally unstructured text, with a few
    // (somewhat) consistent markers that can be used to extract the
    // ExceptionData elements.
    //
    // The parser is a simple state machine that iterates lines looking first
    // for the user/org line, then captures context lines until finding the
    // 'caused by' line. Finally it looks for the first stack frame line.
    // Blank lines are ignored.
    //
    // Not all emails will have the 'caused by' line, nor stack frame lines.
    // Some emails will have multiple context lines.
    //
    private enum ParseState {START, CONTEXT, STACK, STOP}

    private static Map<String, Object> parseLines(List<String> lines) {
        Map<String, Object> dataMap = new Map<String, Object>();
        ParseState state = ParseState.START;
        List<String> contextLines = new List<String>();

        for (String line : lines) {
            Boolean blank = String.isBlank(line);

            if (blank) {
                continue;
            } else if (state == ParseState.START) { // look for user/org line
                String userOrg = parseUserOrg(line);

                // TODO: Support multi-line format
                if (userOrg != null) {
                    dataMap.put('organization', userOrg);
                    state = ParseState.CONTEXT;
                }
            } else if (state == ParseState.CONTEXT) { // look for 'caused by' line
                if (line.startsWith('caused by:')) {
                    dataMap.put('className', parseClassName(line));
                    dataMap.put('message', parseMessage(line));
                    state = ParseState.STACK;
                } else {
                    // Add to context
                    contextLines.add(line);
                }
            } else if (state == ParseState.STACK) { // look for first stack frame
                String fileName = parseFileName(line);
                Integer lineno = parseLineno(line);
                Integer colno = parseColno(line);

                if (lineno != null && colno != null) { // tolerates missing fileName
                    dataMap.put('fileName', fileName);
                    dataMap.put('line', lineno);
                    dataMap.put('column', colno);
                    state = ParseState.STOP;
                }

            } else { // end
                break;
            }
        }

        if (state == ParseState.START) {
            // Handle unknown email format case where state is still 'start'.
            dataMap.put('message', 'Unknown Error');
            dataMap.put('context', String.join(lines, '\n'));
        } else {
            dataMap.put('context', String.join(contextLines, '\n'));
        }

        return dataMap;
    }

    public static String parseUserOrg(String line) {
        return parseContent(
            'Apex script unhandled( trigger)? exception by user/organization:(\n| )?(.*)',
            line,
            3
        );
    }

    public static String parseClassName(String line) {
        return parseContent(
            'caused by: ([^:]*):.*',
            line,
            1
        );
    }

    public static String parseMessage(String line) {
        return parseContent(
            'caused by: [^:]*: (.*)',
            line,
            1
        );
    }

    public static String parseFileName(String line) {
        return parseContent(
            '(.*): line [0-9]+, column [0-9]+',
            line,
            1
        );
    }

    public static Integer parseLineno(String line) {
        string str = parseContent(
            '.*: line ([0-9]+), column [0-9]+',
            line,
            1
        );

        return ((str != null) ? Integer.valueOf(str) : null);
    }

    public static Integer parseColno(String line) {
        string str = parseContent(
            '.*: line [0-9]+, column ([0-9]+)',
            line,
            1
        );

        return ((str != null) ? Integer.valueOf(str) : null);
    }

    private static String parseContent(String regex, String body, Integer groupToReturn) {
        Pattern pat = Pattern.compile(regex);
        Matcher mat = pat.matcher(body);
        mat.find();
        try {
            return mat.group(groupToReturn);
        } catch (StringException e) {
            return null; // when no match is found
        }
    }
}
