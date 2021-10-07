import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';

export default class BusTile extends LightningElement {
    @api bus;
    selectedBusId;

    @wire(CurrentPageReference) pageRef;

    get selected() {
        return (this.selectedBusId === this.bus.Id) ? 'tile selected' : 'tile';
    }

    connectedCallback() {
        registerListener('busselected', this.busSelected, this);
        registerListener('bussaved', this.busSaved, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    busSelected(eventData) {
        this.selectedBusId = eventData.busId;
    }

    busSaved(eventData) {
        if (this.bus.Id === eventData.bus.Id) {
            this.bus = eventData.bus;
        }
    }

    handleBusClick(event) {
        let message = {
            'busId' : this.bus.Id
        }
        fireEvent(this.pageRef, 'busselected', message);
    }
}