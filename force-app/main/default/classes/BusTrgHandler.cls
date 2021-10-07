public with sharing class BusTrgHandler {

    public static boolean RunOnce = false;

    public static void onAfterInsert(List<Bus__c> insertedBuses) {
        List<Bus__c> busesToUpdate = ComputeResaleValues(insertedBuses);
        UPDATE busesToUpdate;
    }

    public static void onAfterUpdate(List<Bus__c> updatedBuses) {
        List<Bus__c> busesToUpdate = ComputeResaleValues(updatedBuses);
        UPDATE busesToUpdate;
    }

    private static List<Bus__c> ComputeResaleValues(List<Bus__c> buses) {
        List<Bus__c> busesToUpdate = new List<Bus__c>();        
        for (Bus__c bus : buses) {
            double resaleValue = 0;
            if (bus.Status__c == 'Ready For Use') {
                if (integer.valueOf(bus.Maximum_Capacity__c) == 24) {
                    resaleValue = 120000;                    
                }
                else if (integer.valueOf(bus.Maximum_Capacity__c) == 36) {
                    resaleValue = 160000;
                }                

                if (resaleValue > 0) {
                    if (integer.valueOf(bus.Model_Year__c) < 1973) {
                        // bus is historic, increase value by 34%.
                        resaleValue = resaleValue + (resaleValue * .34);
                    }

                    double milesReduction = bus.Odometer_Reading__c - 100000;
                    if (milesReduction > 0) {
                        // reduce value by 10 cents per mile over 100000.
                        resaleValue = resaleValue - (milesReduction * .1);
                    }

                    if (bus.Air_Conditioned__c) {
                        // bus with AC is worth 3% more.
                        resaleValue = resaleValue + (resaleValue * .03);
                    }
                }
            }
            Bus__c busToUpdate = new Bus__c();
            busToUpdate.Id = bus.Id;
            busToUpdate.Resale_Value__c = resaleValue;
            busesToUpdate.Add(busToUpdate);
    }
        return busesToUpdate;
    }
}