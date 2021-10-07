import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import getBuses from '@salesforce/apex/Bus.getBuses';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';

export default class BusTiles extends NavigationMixin(LightningElement) {
    @track buses = [];

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        registerListener('bussaved', this.busSaved, this);
        getBuses()
            .then(result => {
                this.buses = result;
            });
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    handleNewBusClick(event) {
        let message = {
            'busId' : ''
        }
        fireEvent(this.pageRef, 'busselected', message);
    }

    busSaved(eventData) {
        let found = false;
        for (let n = 0; n < this.buses.length; n++) {
            if (this.buses[n].Id === eventData.bus.Id) {
                found = true;
                n = this.buses.length;
            }
        }
        if (!found) {
            this.buses.push(eventData.bus);
        }
    }
}