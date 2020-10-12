public with sharing class Item {
    public Item(String message) {
        this.payloadType = ItemType.MESSAGE;
        this.message = message;
    }

    public Item(ExceptionData exData) {
        this.payloadType = ItemType.EXDATA;
        this.exData = exData;

        this.custom = new Map<String, Object>();
        custom.put('context', exData.context());
    }

    public Item(Exception exc) {
        this.payloadType = ItemType.EXC;
        this.exc = exc;
    }

    public enum ItemType { MESSAGE, EXC, EXDATA }

    public ItemType payloadType { get; private set; }
    public String message { get; private set; }
    public ExceptionData exData { get; private set; }
    public Exception exc { get; private set; }

    public String environment { get; set; }
    public Map<String, Object> custom { get; set; }
    public List<Telemetry> telemetry { get; set; }
    public Boolean isUncaught {
        get {
            if (isUncaught == null) {
                isUncaught = false;
            }

            return isUncaught;
        }
        set;
    }
    public String personId { get; set; }

    public Map<String, Object> diagnostic {
        get {
            if (diagnostic == null) {
                diagnostic = new Map<String, Object>();
            }

            return diagnostic;
        }
        private set;
    }
}
