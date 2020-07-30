@isTest
global class RollbarTestHelper {
    global static void setDefaultMock() {
        Test.setMock(HttpCalloutMock.class, new RollbarApiCalloutMock());
    }

    global static void setMock(HttpCalloutMock mock) {
        Test.setMock(HttpCalloutMock.class, mock);
    }
}
