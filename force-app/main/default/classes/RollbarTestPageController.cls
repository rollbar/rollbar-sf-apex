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

    public Pagereference testLogExceptionNoRollbar() {
        this.buildData();
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
            throw ex;
        }
        return null;
    }

    public void sendApexExceptionNotification() {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] { 'rollbaremailservice@2my1sei6hsps5lb9mk19i6pcs6rgojf2drlc44ubduzh0ups3b.2e-mc3puaq.na91.apex.salesforce.com' };
        message.subject = 'Developer script exception from Rollbar, Inc. : RollbarTestPageController : Attempt to de-reference a null object';
        message.plainTextBody = 'Apex script unhandled exception by user/organization: 0052E00000Hy7Kg/00D2E000000mc3P\n' +
                                '\n' +
                                'Visualforce Page: /apex/RollbarTestPage\n' +
                                '\n' +
                                '\n' +
                                '\n' +
                                'caused by: System.NullPointerException: Attempt to de-reference a null object\n'+
                                '\n' +
                                'Class.RollbarTestPageController.buildVersionString: line 50, column 1\n'+
                                'Class.RollbarTestPageController.buildData: line 44, column 1\n'+
                                'Class.RollbarTestPageController.testLogException: line 26, column 1\n';
                                
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
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
