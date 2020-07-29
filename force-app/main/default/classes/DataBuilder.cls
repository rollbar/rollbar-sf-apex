public with sharing class DataBuilder {
    public DataBuilder(Config config) {
        this.config = config;
    }

    public Map<String, Object> buildPayload(String level, String message, Map<String, Object> custom, List<Telemetry> telemetry)
    {
        return buildPayloadStructure(level, buildMessageBody(message, telemetry), custom);
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

        if (custom != null) {
            structure.put('custom', custom);
        }

        return structure;
    }

    private Map<String, Object> buildMessageBody(String message, List<Telemetry> telemetry)
    {
        Map<String, Object> messageMap = new Map<String, Object>();
        messageMap.put('body', message);

        Map<String, Object> body = new Map<String, Object>();
        body.put('message', messageMap);

        if (telemetry != null) {
            List<Object> telemetryList = new List<Object>();

            for (Telemetry t : telemetry) {
                telemetryList.add(t.toMap());
            }
            body.put('telemetry', telemetryList);
        }

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
        String stackTraceString = exc.getStackTraceString();
        String typeName = exc.getTypeName();
        String message = exc.getMessage();

        return buildTraceBody(stackTraceString, typeName, message);

    }

    @testVisible
    private Map<String, Object> buildTraceBody(String stackTraceString, String typeName, String message)
    {
        List<Map<String, Object>> framesList = new List<Map<String, Object>>();

        String[] frames = stackTraceString.split('\n');
        for (String frameStr : frames) {
            if (frameStr == '()' || frameStr == '') {
                continue;
            } else if (frameStr.toLowerCase() == 'caused by') {
                break;
            }

            Map<String, Object> frameMap = new Map<String, Object>();
            frameMap.put('filename', frameStr);

            String[] location = frameStr.split(':')[0].split('\\.');
            Integer locationLength = location.size();
            String className = '(unknown)';
            String methodName = '(unknown)';
            switch on location[0] {
                when 'Class' {
                    if (locationLength > 1) {
                        className = location[1];
                    }
                    if (locationLength > 2) {
                        methodName = location[2];
                    }
                }
                when 'Trigger' {
                    className = 'Trigger';
                    if (locationLength > 1) {
                        methodName = location[1];
                    }
                }
                when else { // e.g. "AnonymousBlock"
                    className = 'Unknown';
                    methodName = location[0];
                }
            }

            frameMap.put('class_name', className);
            frameMap.put('method', methodName);

            try {
                Pattern linePattern = Pattern.compile('line (\\d+)');
                Matcher lineMatcher = linePattern.matcher(frameStr);
                lineMatcher.find();
                frameMap.put('lineno', Integer.valueOf(lineMatcher.group(1)));
            } catch (StringException e) {
                frameMap.put('lineno', '(unknown)');
            }

            try {
                Pattern colPattern = Pattern.compile('column (\\d+)');
                Matcher colMatcher = colPattern.matcher(frameStr);
                colMatcher.find();
                frameMap.put('colno', Integer.valueOf(colMatcher.group(1)));
            } catch (StringException e) {
                frameMap.put('colno', '(unknown)');
            }

            framesList.add(frameMap);
        }

        Map<String, Object> excMap = new Map<String, Object>();
        excMap.put('class', typeName);
        excMap.put('message', message);

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
