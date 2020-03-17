global with sharing class ExceptionData {
    global ExceptionData(
        String environment,
        String userOrg,
        String className,
        String message,
        String fileName,
        String context,
        Integer line,
        Integer column
    ) {
        this.environment = environment;
        this.userOrg = userOrg;
        this.className = className;
        this.message = message;
        this.context = context;
        this.fileName = fileName;
        this.line = line;
        this.column = column;
    }

    global String message() {
        return this.message;
    }

    global String userOrg() {
        return this.userOrg;
    }

    global String fileName() {
        return this.fileName;
    }

    global String className() {
        return this.className;
    }

    global String context() {
        return this.context;
    }

    global Integer line() {
        return this.line;
    }

    global Integer column() {
        return this.column;
    }

    global String environment() {
        return this.environment;
    }

    global static ExceptionData fromMap(Map<String, Object> exData) {
        return new ExceptionData(
            (String)exData.get('environment'),
            (String)exData.get('organization'),
            (String)exData.get('className'),
            (String)exData.get('message'),
            (String)exData.get('fileName'),
            (String)exData.get('context'),
            (Integer)exData.get('line'),
            (Integer)exData.get('column')
        );
    }

    protected String environment;
    protected String userOrg;
    protected String fileName;
    protected Integer line;
    protected Integer column;
    protected String className;
    protected String message;
    protected String context;
}
