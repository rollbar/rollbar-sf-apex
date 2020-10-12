public with sharing class DataBuilder {
    public DataBuilder(Config config) {
        this.config = config;
    }

    public Map<String, Object> buildPayload(String level, Item item) {
        Map<String, Object> payload = new Map<String, Object>();
        Map<String, Object> data = buildData(level, item);

        payload.put('access_token', config.accessToken());
        payload.put('data', data);

        return payload;
    }

    private Map<String, Object> buildData(String level, Item item) {
        Map<String, Object> notifierMap = new Map<String, Object>();
        notifierMap.put('name', Notifier.NAME);
        notifierMap.put('version', Notifier.VERSION);
        notifierMap.put('diagnostic', item.diagnostic);

        Map<String, Object> data = new Map<String, Object>();
        data.put('notifier', notifierMap);
        data.put('level', level);
        data.put('environment', item.environment);
        data.put('framework', 'apex');
        data.put('body', buildBody(item));

        if (item.custom != null) {
            data.put('custom', item.custom);
        }

        return data;
    }

    private Map<String, Object> buildBody(Item item) {
        Map<String, Object> body;

        switch on item.payloadType {
            when MESSAGE {
                body = buildMessageBody(item);
            }
            when EXC {
                body = buildExceptionBody(item);
            }
            when EXDATA {
                body = buildExDataBody(item);
            }
        }

        if (item.telemetry != null) {
            body.put('telemetry', buildTelemetry(item));
        }

        return body;
    }

    private Map<String, Object> buildMessageBody(Item item) {
        Map<String, Object> messageMap = new Map<String, Object>();
        messageMap.put('body', item.message);

        Map<String, Object> body = new Map<String, Object>();
        body.put('message', messageMap);

        return body;
    }

    private Map<String, Object> buildExceptionBody(Item item) {
        Exception exc = item.exc;

        if (exc.getCause() == null) {
            return buildTraceBody(exc);
        }

        return buildTraceChainBody(exc);
    }

    private Map<String, Object> buildExDataBody(Item item) {
        return buildTraceBody(item.exData);
    }

    private Map<String, Object> buildTraceBody(ExceptionData exData) {
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

    private Map<String, Object> buildTraceChainBody(Exception exc) {
        Map<String, Object> outterExTrace = (Map<String, Object>)this.buildTraceBody(exc).get('trace');
        Map<String, Object> innerExTrace = (Map<String, Object>)this.buildTraceBody(exc.getCause()).get('trace');

        List<Map<String, Object>> traceChainList = new List<Map<String, Object>>();
        traceChainList.add(outterExTrace);
        traceChainList.add(innerExTrace);


        Map<String, Object> body = new Map<String, Object>();
        body.put('trace_chain', traceChainList);

        return body;
    }

    private Map<String, Object> buildTraceBody(Exception exc) {
        String stackTraceString = exc.getStackTraceString();
        String typeName = exc.getTypeName();
        String message = exc.getMessage();

        return buildTraceBody(stackTraceString, typeName, message);
    }

    @testVisible
    private Map<String, Object> buildTraceBody(
        String stackTraceString,
        String typeName,
        String message
    ) {
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

    private List<Object> buildTelemetry(Item item) {
        List<Object> telemetryList = new List<Object>();

        for (Telemetry t : item.telemetry) {
            telemetryList.add(t.toMap());
        }

        return telemetryList;
    }

    private Config config;
}
