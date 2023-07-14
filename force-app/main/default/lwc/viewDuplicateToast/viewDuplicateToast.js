import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MyLWCComponent extends LightningElement {
    @api recordId;

    handleButtonClick() {
        if (this.recordId) {
            // Construct the VF page URL with the current record ID as a parameter
            const vfPageUrl = `/apex/mergeDuplicateSelection?masterAccountId=${this.recordId}`;

            // Show a toast message with a link
            const toastMessage = `Click <a href="${vfPageUrl}">here</a> to go to the VF page.`;
            const toastEvent = new ShowToastEvent({
                title: 'Toast Message',
                message: toastMessage,
                variant: 'info',
                mode: 'sticky' // Use 'sticky' mode to allow users to click the link in the toast message
            });
            this.dispatchEvent(toastEvent);
        }
    }
}


