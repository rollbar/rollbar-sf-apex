trigger EventSend on RollbarEvent__e (after insert) {
    Notifier notifier = Rollbar.initializedInstance().notifier();

    for (RollbarEvent__e event : Trigger.New) {
        notifier.methodSend(event.Data1__c, SendMethod.FUTURE);
    }
}
