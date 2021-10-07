global class BusMaintenanceScheduler implements Database.Batchable<sObject>, Schedulable {

    //System.schedule('Bus Maintenance Scheduler', '0, 0, 1, *, *, ?', new BusMaintenanceScheduler());

    global Database.queryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(
            [SELECT Id
                ,Odometer_Reading__c
            FROM Bus__c
            WHERE Maximum_Capacity__c = '60']
        );
    }

    global void execute(Database.BatchableContext context, List<Bus__c> buses) {
        List<Maintenance_Work_Order__c> workOrdersToAdd = new List<Maintenance_Work_Order__c>();
        List<Bus__c> busesToUpdate = new List<Bus__c>();
        Set<Id> busIds = (new Map<Id, Bus__c>(buses).keySet());

        // Get list of bus/garage junction records with a garage that can service selected buses.
        List<Bus_Garage_Association__c> busGarages = 
            [SELECT Id
                ,Bus__r.Id
                ,Garage__r.Id
                ,Distance__c
            FROM Bus_Garage_Association__c
            WHERE Bus__r.Id IN :busIds
            ORDER BY Bus__r.Id, Distance__c];

        // Get max bus odometer reading from maintenance work orders.
        List<AggregateResult> lastBusMaintenance = 
            [SELECT Bus__r.Id BusId
                ,MAX(Odometer_Reading__c) OdometerReading
            FROM Maintenance_Work_Order__c
            WHERE Bus__r.Id IN :busIds
            GROUP BY Bus__r.Id];

        for (Bus__c bus : buses) {
            // Find the last odometer reading for the bus from the maintenace records.
            integer lastOdometerReading = 0;
            for (AggregateResult maintenace : lastBusMaintenance) {
                if (maintenace.get('BusId') == bus.Id) {
                    lastOdometerReading = integer.valueOf(maintenace.get('OdometerReading'));
                    break;
                }
            }

            if ((bus.Odometer_Reading__c - lastOdometerReading) >= 5000) {
                // It has been 5000 or more miles since last maintenance, schedule a work order.

                // Find first garage for the bus, it should be the closest to the bus location.
                string garageId = '';
                for (Bus_Garage_Association__c garageAssociation : busGarages) {
                    if (garageAssociation.Bus__r.Id == bus.Id) {
                        garageId = garageAssociation.Garage__r.Id;
                        break;
                    }
                }

                if (garageId != '') {
                    // Create maintenance work order and set bus status to Scheduled For Maintenance
                    Maintenance_Work_Order__c workOrder = new Maintenance_Work_Order__c();
                    workOrder.Bus__c = bus.Id;
                    workOrder.Garage__c = garageId;
                    workOrder.Odometer_Reading__c = bus.Odometer_Reading__c;
                    workOrder.Reason__c = 'Routine 5000 mile maintenance.';
                    workOrder.Scheduled_Time__c = DateTime.Now();
                    workOrdersToAdd.add(workOrder);
                    
                    Bus__c busToUpdate = new Bus__c();
                    busToUpdate.Id = bus.Id;
                    busToUpdate.Status__c = 'Scheduled For Maintenance';
                    busesToUpdate.add(busToUpdate);
                }
            }
        }

        if (workOrdersToAdd.size() > 0) {
            INSERT workOrdersToAdd;
        }
        if (busesToUpdate.size() > 0) {
            UPDATE busesToUpdate;
        }
    }

    global void finish(Database.BatchableContext context) {

    }

    global void execute(SchedulableContext context) {
        Database.executeBatch(new BusMaintenanceScheduler());
    }
}