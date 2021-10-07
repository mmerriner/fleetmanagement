import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';
import Utils from 'c/utils';
import getStatuses from '@salesforce/apex/Bus.getStatuses';
import getCapacities from '@salesforce/apex/Bus.getCapacities';
import getBus from '@salesforce/apex/Bus.getBus';
import saveBus from '@salesforce/apex/Bus.saveBus';

export default class BusDetail extends LightningElement {
    @track bus;
    @track busName;
    @track statuses;
    @track capacities;
    busId;

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        getStatuses()
            .then(result => {
                this.statuses = result;
            });

        getCapacities()
            .then(result => {
                this.capacities = result;
            });

        registerListener('busselected', this.busSelected, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    busSelected(eventData) {
        this.busId = eventData.busId;
        this.getBusDetail();
    }

    getBusDetail() {
        this.bus = undefined;
        getBus({ busId: this.busId })
            .then(result => {
                this.bus = result;
                this.busName = result.Name;
                if (this.busId === '') {
                    this.busName = 'NEW';
                }
            });
    }

    handleFieldChange(event) {
        const field = event.target.name;
        if (field === 'Model_Year__c') {
            this.bus.Model_Year__c = event.target.value;
        }
        else if (field === 'Status__c') {
            this.bus.Status__c = event.target.value;
        }
        else if (field === 'Maximum_Capacity__c') {
            this.bus.Maximum_Capacity__c = event.target.value;
        }
        else if (field === 'Odometer_Reading__c') {
            this.bus.Odometer_Reading__c = event.target.value;
        }
    }

    handleCancelClick(event) {
        this.getBusDetail();
    }

    handleSaveClick(event) {
        saveBus({ bus: this.bus })
            .then(result => {
                this.bus = result;
                Utils.showToast(this, 'Bus Detail', 'Bus Saved', 'success');

                let message = {
                    'bus' : this.bus
                }
                fireEvent(this.pageRef, 'bussaved', message);
            });
    }

}