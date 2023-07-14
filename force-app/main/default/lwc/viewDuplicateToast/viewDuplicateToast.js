import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import './viewDuplicateToast.css';


export default class MyLWCComponent extends NavigationMixin(LightningElement) {
    @api recordId;

    get vfPageUrl() {
        return `/apex/mergeDuplicateSelection?masterAccountId=${this.recordId}`;
    }

    handleButtonClick() {
        const event = new ShowToastEvent({
            title: 'Potential duplicates',
            message: '{0}',
            messageData: [
                {
                    url: this.vfPageUrl,
                    label: 'View Duplicates',
                },
            ],
            variant: 'info',
        });

        this.dispatchEvent(event);
    }
}
