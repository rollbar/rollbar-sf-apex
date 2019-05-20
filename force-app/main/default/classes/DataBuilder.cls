public with sharing class DataBuilder {
    public DataBuilder(Config config) {
        this.config = config;
    }

    public Map<String, Object> buildPayload(String level, String message)
    {
        return buildPayloadStructure(level, this.buildMessageBody(message));
    }

    public Map<String, Object> buildPayload(Exception exc)
    {
        if (exc.getCause() != null) {
            return buildTraceChainPayload(exc);
        } else {
            return buildExceptionPayload(exc);
        }
    }

    public Map<String, Object> buildPayload(ExceptionData exData)
    {
        Map<String, Object> payload = buildPayloadStructure('error', this.buildTraceBody(exData));

        Map<String, Object> custom = new Map<String, Object>();
        custom.put('context', exData.context());

        Map<String, Object> data = (Map<String, Object>)payload.get('data');
        data.put('custom', custom);

        return payload;
    }

    private Map<String, Object> buildExceptionPayload(Exception exc)
    {
        return buildPayloadStructure('error', this.buildTraceBody(exc));
    }

    private Map<String, Object> buildTraceChainPayload(Exception exc)
    {
        Map<String, Object> outterExTrace = (Map<String, Object>)this.buildTraceBody(exc).get('trace');
        Map<String, Object> innerExTrace = (Map<String, Object>)this.buildTraceBody(exc.getCause()).get('trace');

        List<Map<String, Object>> traceChainList = new List<Map<String, Object>>();
        traceChainList.add(outterExTrace);
        traceChainList.add(innerExTrace);


        Map<String, Object> body = new Map<String, Object>();
        body.put('trace_chain', traceChainList);

        return buildPayloadStructure('error', body);
    }

    private Map<String, Object> buildPayloadStructure(String level, Map<String, Object> body)
    {
        Map<String, Object> data = this.buildDataStructure(level, this.config.environment(), body);

        Map<String, Object> structure = new Map<String, Object>();
        structure.put('access_token', this.config.accessToken());
        structure.put('data', data);
        return structure;
    }

    private Map<String, Object> buildDataStructure(String level, String environment, Map<String, Object> body)
    {
        Map<String, Object> notifierMap = new Map<String, Object>();
        notifierMap.put('name', Notifier.NAME);
        notifierMap.put('version', Notifier.VERSION);

        Map<String, Object> structure = new Map<String, Object>();
        structure.put('notifier', notifierMap);
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

    private Map<String, Object> buildTraceBody(ExceptionData exData)
    {
        List<Map<String, Object>> framesList = new List<Map<String, Object>>();

        Map<String, Object> frameMap = new Map<String, Object>();
        frameMap.put('filename', exData.fileName());
        frameMap.put('class_name', exData.className());
        frameMap.put('method', exData.fileName());
        frameMap.put('lineno', exData.line());
        frameMap.put('colno', exData.column());

        framesList.add(frameMap);

        Map<String, Object> excMap = new Map<String, Object>();
        excMap.put('class', exData.className());
        excMap.put('message', exData.message());
        
        return buildTraceStructure(excMap, framesList);
    }

    private Map<String, Object> buildTraceBody(Exception exc)
    {
        List<Map<String, Object>> framesList = new List<Map<String, Object>>();

        String[] frames = exc.getStackTraceString().split('\n');
        for (String frameStr : frames) {
            if (frameStr == '()') {
                continue;
            } else if (frameStr.toLowerCase() == 'caused by') {
                break;
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

        return buildTraceStructure(excMap, framesList);
    }

    private Map<String, Object> buildTraceStructure(
        Map<String, Object> exceptionMap,
        List<Map<String, Object>> framesList
    ) {
        Map<String, Object> body = new Map<String, Object>();

        Map<String, Object> traceMap = new Map<String, Object>();

        traceMap.put('exception', exceptionMap);
        traceMap.put('frames', framesList);

        body.put('trace', traceMap);

        return body;
    }

    private Config config;
}
