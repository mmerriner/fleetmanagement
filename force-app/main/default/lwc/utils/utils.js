import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Utils {
    static showToast(caller, title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        caller.dispatchEvent(evt);
    }

}