public with sharing class RollbarTestController {
    public PageReference test() {
        List<Account> aa = [SELECT Id, Name FROM Account WHERE Name = 'Acme'];
        Account ac = aa[2];
        return null;
    }
}
