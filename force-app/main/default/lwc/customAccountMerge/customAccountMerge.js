import { LightningElement, track } from 'lwc';

export default class CustomAccountMerge extends LightningElement {
    @track masterAccount;
    @track mergedAccount;
    @track selectedFieldValues = {};
    @track fieldOptions;
    @track mergeMessage;
    @track isMerged = false;

    connectedCallback() {
        // Hardcode the master account ID
        const masterAccountId = '0015I00000gxi2vQAA';
        // Retrieve the master account with fields defined in the metadata string
        this.masterAccount = { Id: masterAccountId, Name: 'Master Account', Rating: 'High' };

        // Hardcode the merged account ID
        const mergedAccountId = '0015I00000iqYcIQAU';
        // Retrieve the merged account with fields defined in the metadata string
        this.mergedAccount = { Id: mergedAccountId, Name: 'Merged Account', Rating: 'Low' };

        // Initialize the field values and options
        const metadataFields = 'Rating,Name'; // Example metadata fields
        this.fieldOptions = metadataFields.split(',').map(field => ({ label: field, value: field }));

        // Populate the selected values for each field
        this.fieldOptions.forEach(fieldOption => {
            const field = fieldOption.value;
            this.selectedFieldValues[field] = this.masterAccount[field];
        });
    }

    get selectedFieldValueOptions() {
        return this.fieldOptions.map(fieldOption => {
            return {
                ...fieldOption,
                selectedValue: this.selectedFieldValues[fieldOption.value],
                masterValue: this.masterAccount[fieldOption.value],
                mergedValue: this.mergedAccount[fieldOption.value]
            };
        });
    }

    handleFieldChange(event) {
        const field = event.target.name;
        const selectedValue = event.target.value;
        this.selectedFieldValues = { ...this.selectedFieldValues, [field]: selectedValue };
    }

    mergeAccounts() {
        // Update the master account with the selected field values
        Object.keys(this.selectedFieldValues).forEach(field => {
            this.masterAccount[field] = this.selectedFieldValues[field];
        });

        // Save the updated master account and perform other operations
        // ...

        // Set the merge message and flag
        this.mergeMessage = 'Merge successful!';
        this.isMerged = true;
    }

    get disableMergeButton() {
        // Disable the Merge button if necessary
        // ...
        return false;
    }
}