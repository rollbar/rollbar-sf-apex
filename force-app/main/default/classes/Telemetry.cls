public with sharing class Telemetry {
    public String level { get; set; }
    public String type { get; set; }
    public String source { get; set; }
    public Long timestamp { get; set; }
    public Map<String, String> body { get; set; }

    public Telemetry(
        String level,
        String type,
        String source,
        Long timestamp,
        Map<String, String> body
    ) {
        this.level = level;
        this.type = type;
        this.source = source;
        this.timestamp = timestamp;
        this.body = body;
    }
    public Telemetry() {}

    public static Telemetry fromMap(Map<String, Object> inMap) {
        return new Telemetry(
            (String)inMap.get('level'),
            (String)inMap.get('type'),
            (String)inMap.get('source'),
            (Long)inMap.get('timestamp_ms'),
            (Map<String, String>)inMap.get('body')
        );
    }

    public Map<String, Object> toMap() {
        Map<String, Object> outMap = new Map<String, Object>();

        outMap.put('level', this.level);
        outMap.put('type', this.type);
        outMap.put('source', this.source);
        outMap.put('timestamp_ms', this.timestamp);
        outMap.put('body', this.body);

        return outMap;
    }
}
