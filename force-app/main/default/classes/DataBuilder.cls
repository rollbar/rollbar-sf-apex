public with sharing class DataBuilder {
    public DataBuilder(Config config) {
        this.config = config;
    }

    public Map<String, Object> buildPayload(String level, String message)
    {
        Map<String, Object> body = this.buildMessageBody(message);

        Map<String, Object> data = this.buildDataStructure(level, this.config.environment(), body);

        Map<String, Object> payload = this.buildPayloadStructure(data);
        
        return payload;
    }

    public Map<String, Object> buildPayload(Exception exc)
    {
        Map<String, Object> body = this.buildTraceBody(exc);

        Map<String, Object> data = this.buildDataStructure('error', this.config.environment(), body);

        Map<String, Object> payload = this.buildPayloadStructure(data);
        
        return payload;
    }

    private Map<String, Object> buildPayloadStructure(Map<String, Object> data)
    {
        Map<String, Object> structure = new Map<String, Object>();
        structure.put('access_token', this.config.accessToken());
        structure.put('data', data);
        return structure;
    }

    private Map<String, Object> buildDataStructure(String level, String environment, Map<String, Object> body)
    {
        Map<String, Object> structure = new Map<String, Object>();
        structure.put('level', level);
        structure.put('environment', environment);
        structure.put('framework', 'apex');
        structure.put('body', body);
        return structure;
    }

    private Map<String, Object> buildMessageBody(String message)
    {
        Map<String, Object> messageMap = new Map<String, Object>();
        messageMap.put('body', message);

        Map<String, Object> body = new Map<String, Object>();
        body.put('message', messageMap);

        return body;
    }

    private Map<String, Object> buildTraceBody(Exception exc)
    {
        Map<String, Object> body = new Map<String, Object>();

        Map<String, Object> traceMap = new Map<String, Object>();

        List<Map<String, Object>> framesList = new List<Map<String, Object>>();

        String[] frames = exc.getStackTraceString().split('\n');
        for (String frameStr : frames) {
            if (frameStr == '()') {
                continue;
            }

            Map<String, Object> frameMap = new Map<String, Object>();
            frameMap.put('filename', frameStr);
            frameMap.put('class_name', frameStr.split(':')[0].split('\\.')[1]);
            frameMap.put('method', frameStr.split(':')[0].split('\\.')[2]);

            Pattern linePattern = Pattern.compile('line (\\d+)');
            Matcher lineMatcher = linePattern.matcher(frameStr);
            lineMatcher.find();
            frameMap.put('lineno', Integer.valueOf(lineMatcher.group(1)));

            Pattern colPattern = Pattern.compile('column (\\d+)');
            Matcher colMatcher = colPattern.matcher(frameStr);
            colMatcher.find();
            frameMap.put('colno', Integer.valueOf(colMatcher.group(1)));

            framesList.add(frameMap);
        }

        Map<String, Object> excMap = new Map<String, Object>();
        excMap.put('class', exc.getTypeName());
        excMap.put('message', exc.getMessage());

        traceMap.put('exception', excMap);
        traceMap.put('frames', framesList);
        body.put('trace', traceMap);

        return body;
    }

    private Config config;
}
