public with sharing class RollbarTestPageController {

    public String emulateUsersMsg { get; set; }

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

    public Pagereference sendApexExceptionNotification() {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        String wrong = null;
        wrong.length();
        message.toAddresses = new String[] { 'rollbaremailservice@10k3q3i5i9b2p119xg21u65u5g32rfldv4k1u79cr5ukyjh72d.1h-5a5meaa.cs79.apex.sandbox.salesforce.com' };
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

        return null;
    }

    public Pagereference sendApexExceptionNotificationInBackground() {
        RollbarTestPageController.sendApexExceptionNotificationFuture();
        return null;
    }

    @future(callout=true)
    public static void sendApexExceptionNotificationFuture() {
        RollbarTestPageController controller = new RollbarTestPageController();
        controller.sendApexExceptionNotification();
    }

    public Pagereference emulateUsersInBackground() {
        String action = emulateUserAction();
        emulateUsersMsg = action;
        return null;
    }

    public String emulateUserAction() {
        String now = Datetime.now().format('HH:mm:ss');

        switch on (Math.ceil(Math.random() * 3.00).intValue()) {
            when 1 {
                RollbarTestPageController.testLogExceptionNoRollbarFuture();
                return '[' + now + '] User has tried building buggy version data object.';
            }
            when 2 {
                RollbarTestPageController.testUnhadledExceptionFuture();
                return '[' + now + '] User has tried to get a length of a buggy String object.';
            }
            when 3 {
                RollbarTestPageController.testNoRowsForAssignment();
                return '[' + now + '] User has tried to fetch a single account information from a multiple accounts query statement.';
            }
        }

        return '';
    }

    @future
    public static void testLogExceptionNoRollbarFuture() {
        RollbarTestPageController controller = new RollbarTestPageController();
        controller.testLogExceptionNoRollbar();
    }

    @future
    public static void testUnhadledExceptionFuture() {
        RollbarTestPageController controller = new RollbarTestPageController();
        controller.testUnhadledException();
    }

    @future
    public static void testNoRowsForAssignment() {
        Account accounts = [SELECT Id FROM Account];
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
