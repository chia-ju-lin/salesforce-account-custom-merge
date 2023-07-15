import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import './viewDuplicateToast.css';
import getDuplicateAccountsCount from '@salesforce/apex/AccountMergeHelper.getDuplicateAccountsCount';



export default class MyLWCComponent extends NavigationMixin(LightningElement) {
    @api recordId;

    get vfIDPageUrl() {
        return `/apex/mergeIDSelection?masterAccountId=${this.recordId}`;
    }

    get vfPageUrl() {
        return `/apex/mergeDuplicateSelection?masterAccountId=${this.recordId}`;
    }
    duplicateAccountsCount = 0;

    @wire(getDuplicateAccountsCount, { currentAccountId: '$recordId' })
    wiredDuplicateAccountsCount({ error, data }) {
        console.log('*******Record ID:', this.recordId); // Check the value of recordId
        if (data) {
            this.duplicateAccountsCount = data;
            console.log('***********Duplicate Accounts Count:', this.duplicateAccountsCount); // Check the count value
            if (this.duplicateAccountsCount !== 0) {
                this.showDuplicateAccountsToast();
            }
        } else if (error) {
            console.error('********error: ', error);
        }
    }

    
    connectedCallback() {
        if (this.duplicateAccountsCount !== 0) {
            this.showDuplicateAccountsToast();
        }
    }

    showDuplicateAccountsToast() {
        const event = new ShowToastEvent({
            title: 'It looks as if duplicates exist for this Account. a ',
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
    

    handleButtonClick() {
        const event = new ShowToastEvent({
            title: 'It looks as if duplicates exist for this Account. b',
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
