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
    private enum ParseState {USER_ORG, CONTEXT, STACK, STOP}

    private static Map<String, Object> parseLines(List<String> lines) {
        Map<String, Object> dataMap = new Map<String, Object>();
        ParseState state = ParseState.USER_ORG;
        List<String> contextLines = new List<String>();
        String prevLine = null;

        for (String line : lines) {
            if (String.isBlank(line)) { continue; }

            switch on state {
                when USER_ORG {
                    state = handleUserOrgLine(line, prevLine, dataMap);
                    prevLine = line;
                }
                when CONTEXT {
                    state = handleContextLine(line, contextLines, dataMap);
                }
                when STACK {
                    state = handleStackLine(line, dataMap);
                }
                when STOP {
                    break;
                }
            }
        }

        if (state == ParseState.USER_ORG) {
            // Handle unknown email format case where state is still USER_ORG.
            dataMap.put('message', 'Unknown Error');
            dataMap.put('context', String.join(lines, '\n'));
        } else {
            dataMap.put('context', String.join(contextLines, '\n'));
        }

        return dataMap;
    }

    private static ParseState handleUserOrgLine(String line, String prevLine, Map<String, Object> dataMap) {
        String userOrg = parseUserOrg(line);

        if (userOrg != null && !String.isBlank(userOrg)) {
            dataMap.put('organization', userOrg);
            return ParseState.CONTEXT;
        }

        // The user/org data may span two lines.
        // Try concatenating with the previous line.
        if (prevLine != null){
            userOrg = parseUserOrg(prevLine + ' ' + line);

            if (userOrg != null) {
                dataMap.put('organization', userOrg);
                return ParseState.CONTEXT;
            }
        }

        return ParseState.USER_ORG;
    }

    private static ParseState handleContextLine(String line, List<String> contextLines, Map<String, Object> dataMap) {
        if (line.startsWith('caused by:')) {
            dataMap.put('className', parseClassName(line));
            dataMap.put('message', parseMessage(line));
            return ParseState.STACK;
        } else {
            // Add to context
            contextLines.add(line);
        }

        return ParseState.CONTEXT;
    }

    private static ParseState handleStackLine(String line, Map<String, Object> dataMap) {
        String fileName = parseFileName(line);
        Integer lineno = parseLineno(line);
        Integer colno = parseColno(line);

        if (lineno != null && colno != null) { // tolerates missing fileName
            dataMap.put('fileName', fileName);
            dataMap.put('line', lineno);
            dataMap.put('column', colno);
            return ParseState.STOP;
        }

        return ParseState.STACK;
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
