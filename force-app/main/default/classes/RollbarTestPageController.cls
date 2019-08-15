public with sharing class RollbarTestPageController {
    public RollbarTestPageController() {

    }

    public PageReference testUnhadledException() {
        String myString = null;
        myString.length();
        return null;
    }

    public PageReference testLogMessage() {
        Rollbar.init();
        Rollbar.log('info', 'Hello world from my Salesforce org');
        return null;
    }

    public Pagereference testLogException() {
        Rollbar.init();
        try {
            this.buildData();
        } catch(Exception ex) {
            Map<String, Object> custom = new Map<String, Object>();
            custom.put('project', 'foo');
            custom.put('project_view', 'bar');
            Rollbar.log(
                ex,
                custom
            );
        }
        return null;
    }

    public Map<String, String> buildData()
    {
        Map<String, String> structure = new Map<String, String>();
        structure.put('language', 'Apex');
        structure.put('version', this.buildVersionString());
        return structure;
    }
    
    public String buildVersionString() {
        String version = null;
        if (version.length() == 0) {
            version = this.getMajor() +
                '.' +
                this.getMinor() +
                '.' +
                this.getPatch();
        }
        return version;
    }
    
    public String getMajor() {
        return '1';
    }
    
    public String getMinor() {
        return '2';
    }
    
    public String getPatch() {
        return '3';
    }
}
