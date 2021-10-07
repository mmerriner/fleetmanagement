trigger Bus on Bus__c (after insert, after update) {

    if (Trigger.isAfter && Trigger.isInsert && !BusTrgHandler.RunOnce) {
        BusTrgHandler.RunOnce = true;
        BusTrgHandler.onAfterInsert(Trigger.New);
    }
    else if (Trigger.isAfter && Trigger.isUpdate && !BusTrgHandler.RunOnce) {
        BusTrgHandler.RunOnce = true;
        BusTrgHandler.onAfterUpdate(Trigger.New);
    }

}