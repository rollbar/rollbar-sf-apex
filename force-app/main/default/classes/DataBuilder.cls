public with sharing class DataBuilder {
    public DataBuilder(Config config) {
        this.config = config;
    }

    public Map<String, Object> buildPayload(String level, String message, Map<String, Object> custom)
    {
        return buildPayloadStructure(level, buildMessageBody(message), custom);
    }

    public Map<String, Object> buildPayload(String level, Exception exc, Map<String, Object> custom)
    {
        return buildPayloadStructure(level, buildExceptionBody(exc), custom);
    }

    public Map<String, Object> buildPayload(ExceptionData exData)
    {
        Map<String, Object> custom = new Map<String, Object>();
        custom.put('context', exData.context());

        return buildPayloadStructure('error', buildTraceBody(exData), custom);
    }

    private Map<String, Object> buildExceptionBody(Exception exc)
    {
        if (exc.getCause() == null) {
            return buildTraceBody(exc);
        } else {
            return buildTraceChainBody(exc);
        }
    }

    private Map<String, Object> buildTraceChainBody(Exception exc)
    {
        Map<String, Object> outterExTrace = (Map<String, Object>)this.buildTraceBody(exc).get('trace');
        Map<String, Object> innerExTrace = (Map<String, Object>)this.buildTraceBody(exc.getCause()).get('trace');

        List<Map<String, Object>> traceChainList = new List<Map<String, Object>>();
        traceChainList.add(outterExTrace);
        traceChainList.add(innerExTrace);


        Map<String, Object> body = new Map<String, Object>();
        body.put('trace_chain', traceChainList);

        return body;
    }

    private Map<String, Object> buildPayloadStructure(
        String level,
        Map<String, Object> body,
        Map<String, Object> custom
    ) {
        Map<String, Object> data = this.buildDataStructure(
            level,
            this.config.environment(),
            body,
            custom
        );

        Map<String, Object> structure = new Map<String, Object>();
        structure.put('access_token', this.config.accessToken());
        structure.put('data', data);
        return structure;
    }

    private Map<String, Object> buildDataStructure(
        String level,
        String environment,
        Map<String, Object> body,
        Map<String, Object> custom
    ) {

        Map<String, Object> notifierMap = new Map<String, Object>();
        notifierMap.put('name', Notifier.NAME);
        notifierMap.put('version', Notifier.VERSION);

        Map<String, Object> structure = new Map<String, Object>();
        structure.put('notifier', notifierMap);
        structure.put('level', level);
        structure.put('environment', environment);
        structure.put('framework', 'apex');
        structure.put('body', body);
        structure.put('custom', custom);

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

            String className = frameStr.split(':')[0];
            String methodName = '';
            if (className != 'AnonymousBlock') {
                className = className.split('\\.')[1];
                methodName = frameStr.split(':')[0].split('\\.')[2];
            }

            frameMap.put('class_name', className);
            frameMap.put('method', methodName);

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
