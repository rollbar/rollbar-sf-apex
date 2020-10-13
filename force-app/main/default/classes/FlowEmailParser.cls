public with sharing class FlowEmailParser {
    private String emailBody;
    public String currentUserId { get; private set; }

    public FlowEmailParser(String emailBody) {
        this.emailBody =  emailBody;
    }

    public List<Telemetry> parseTelemetry() {
        List<String> lines = emailBody.split('\n');

        return parseLines(lines);
    }

    private static String fromName = 'FlowApplication';

    public static String fromName() {
        return fromName;
    }

    // Flow email message blocks are generally multiline and separated by
    // one or more lines of white space. There are an arbitrary number of blocks
    // and an arbitrary number of lines within a block.
    //
    // This parser converts each block into a 'log' telemetry event.
    // Telemetry messages don't render line breaks, so we use punctuation to
    // format the message and improve readability.
    private List<Telemetry> parseLines(List<String> lines) {
        List<Telemetry> telemetryList = new List<Telemetry>();
        Boolean blank = true;
        Boolean prevBlank = true;

        // Init these to ensure any initial state below is safe.
        String messageFirstLine = '';
        List<String> messageLines = new List<String>();

        for (String line : lines) {
            String plain = stripHtmlTags(line);
            blank = String.isBlank(plain);

            // Lightweight state machine using blank, prevBlank.
            if (prevBlank && blank) {
                // continue to next block.
            } else if (prevBlank && !blank) { // start new block
                // Handle first line separately for better formatting.
                messageFirstLine = plain + ' ';
                messageLines = new List<String>();
            } else if (!prevBlank && !blank) { // continue block
                messageLines.add(plain);

                // Assume any internal line might be the user id
                extractUserId(plain);
            } else { // end block
                String message = messageFirstLine + String.join(messageLines, ', ');
                telemetryList.add(addMessage(message));
            }
            prevBlank = blank;
        }

        return telemetryList;
    }

    private Telemetry addMessage(String message) {
        return new Telemetry(
            'info',
            'log',
            'server',
            Datetime.now().getTime(),
            new Map<String, String>{ 'message' => message }
        );
    }

    // Flow emails are delivered in html format only.
    // This tag stripper is forgiving of <> characters within the content
    // as it will only match innermost brackets where additional brackets exist.
    // (Flow error emails can't be counted on to be valid html in all cases.)
    //
    // NB: String.stripHtmlTags() is not used, as it is scheduled for deprecation,
    // doesn't remove all tags, and its implementation isn't open for review.
    private String stripHtmlTags(String html) {
        String HTML_TAGS = '<[^<>]+>';
        Pattern pattern = Pattern.compile(HTML_TAGS);
        Matcher matcher = pattern.matcher(html);
        return matcher.replaceAll('');
    }

    // Look for the first occurence of a line starting "Current User:",
    // with the user id in parens. Once an id is found, ignore all
    // later lines.
    private Void extractUserId(String line) {
        if (!String.isBlank(currentUserId)) { return; }

        String CURRENT_USER_PATTERN = 'Current User:.*[(](.*)[)]';
        Pattern pattern = Pattern.compile(CURRENT_USER_PATTERN);

        Matcher matcher = pattern.matcher(line);
        if (matcher.matches()) {
            currentUserId = matcher.group(1);
        }
    }
}
