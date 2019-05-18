public with sharing class ExceptionData {
    public ExceptionData(
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

    public String message() {
        return this.message;
    }

    public String userOrg() {
        return this.userOrg;
    }

    public String fileName() {
        return this.fileName;
    }

    public String className() {
        return this.className;
    }

    public String context() {
        return this.context;
    }

    public Integer line() {
        return this.line;
    }

    public Integer column() {
        return this.column;
    }

    public String environment() {
        return this.environment;
    }

    public static ExceptionData fromMap(Map<String, Object> exData) {
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
