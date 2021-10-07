public with sharing class Bus {

    @AuraEnabled
    public static List<Bus__c> getBuses() {
        try {
            return [
                SELECT Id
                    ,Name
                    ,Bus_Picture__c
                    ,Status__c
                FROM Bus__c
                ORDER BY Name
            ];
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Bus__c getBus(string busId){
        try {
            if (busId == '') {
                return new Bus__c();
            }
            else {
                return [
                    SELECT Id
                        ,Name
                        ,Air_Conditioned__c
                        ,Bus_Picture__c
                        ,Last_Reported_Location__c
                        ,Maximum_Capacity__c
                        ,Model_Year__c
                        ,Number_Of_Wheels__c
                        ,Odometer_Reading__c
                        ,Resale_Value__c
                        ,Status__c
                    FROM Bus__c
                    WHERE Id = :busId
                ];   
            }      
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Bus__c saveBus(Bus__c bus) {
        try {
            UPSERT bus;
            return getBus(bus.Id);
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<PicklistItem> getStatuses() {
        List<PicklistItem> values = new List<PicklistItem>();
        Schema.DescribeFieldResult source = Bus__c.Status__c.getDescribe();
        for (Schema.PicklistEntry picklistValue : source.getPicklistValues()) {
            values.add(new PicklistItem(picklistValue.getValue(), picklistValue.getValue()));
        }
        return values;
    }

    @AuraEnabled(cacheable=true)
    public static List<PicklistItem> getCapacities() {
        List<PicklistItem> values = new List<PicklistItem>();
        Schema.DescribeFieldResult source = Bus__c.Maximum_Capacity__c.getDescribe();
        for (Schema.PicklistEntry picklistValue : source.getPicklistValues()) {
            values.add(new PicklistItem(picklistValue.getValue(), picklistValue.getValue()));
        }
        return values;
    }
}