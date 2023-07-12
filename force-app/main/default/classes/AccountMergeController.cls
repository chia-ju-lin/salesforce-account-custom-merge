public class AccountMergeController {
    
    public Account masterAccount { get; private set; }
    public Account mergedAccount { get; private set; }
    public Map<String, Object> selectedFieldValues { get; set; }
    public List<String> fieldValues { get; private set; }
    public List<String> differentFields { get; private set; }
    public List<String> childObjectNames { get; private set; }
    public List<String> restrictedExternalFields { get; private set; }
    public String mergeMessage { get; private set; }
    public Boolean isMerged { get; private set; }
    public String masterAccountId { get; set; }
    public String mergedAccountId { get; set; }
    public Map<String, String> fieldLabels { get; private set; }
    public String disableMergeMessage { get; private set; }
    public Boolean disableMerge { get; private set; }

    public AccountMergeController() {        
        // Get IDs from URL parameter
        masterAccountId = ApexPages.currentPage().getParameters().get('masterId');
        mergedAccountId = ApexPages.currentPage().getParameters().get('mergedId');        

        // Retrieve all fieds for the Account Object
        Map<String, Schema.SObjectField> accountFields = Account.SObjectType.getDescribe().fields.getMap();
        String metadataFields = '';
        for (Schema.SObjectField field : accountFields.values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            // Exclude date, datetime and non editable fields
            if (fieldDescribe.isUpdateable() && fieldDescribe.getType() != Schema.DisplayType.DATETIME && fieldDescribe.getType() != Schema.DisplayType.DATE) {
                metadataFields += fieldDescribe.getName() + ',';
            }
        }

        metadataFields = metadataFields.removeEnd(','); // Remove the trailing comma
        fieldValues = metadataFields.split(',');

        String soqlQuery = 'SELECT ' + metadataFields + ' FROM Account WHERE Id = \'' + masterAccountId + '\' LIMIT 1';
        masterAccount = Database.query(soqlQuery);

        String soqlQuery2 = 'SELECT ' + metadataFields + ' FROM Account WHERE Id = \'' + mergedAccountId + '\' LIMIT 1';
        mergedAccount = Database.query(soqlQuery2);

        // Initialize the selected values map
        selectedFieldValues = new Map<String, Object>();

        // Populate fieldlabels and the default selected values for each field
        fieldLabels = new Map<String, String>();
        differentFields = getDifferentFields();
        for (String field : differentFields) {
            Schema.DescribeFieldResult fieldDescribe = Account.SObjectType.getDescribe().fields.getMap().get(field).getDescribe();
            fieldLabels.put(field, fieldDescribe.getLabel());

            if (masterAccount.get(field) != null) {
                selectedFieldValues.put(field, masterAccount.get(field));
            } else if (mergedAccount.get(field) != null) {
                selectedFieldValues.put(field, mergedAccount.get(field));
            }
        }
        
        // Get disable Button
        checkDisableMergeCondition();
        
    }

    private List<String> getDifferentFields() {
        List<String> df = new List<String>();
    
        for (String fieldName : fieldValues) {
            Object masterValue = masterAccount.get(fieldName);
            Object mergedValue = mergedAccount.get(fieldName);
    
            if (masterValue != mergedValue) {
                df.add(fieldName);
            }
        }    
        return df;
    }

    public void mergeAccounts() {
        
        isMerged = true;

        // Savepoint before performing any DML operations
        Savepoint sp = Database.setSavepoint();
        
        try {    
            // Update merged account for unique fields to prevent duplication error when updating master
            updateUniqueFieldsInMergedAccountAndPrepareMasterAccount();
    
            // Update master with selected values
            update masterAccount;
    
            // Move child records from merged account into master account
            moveChildRecords(masterAccountId, mergedAccountId, childObjectNames);
    
            // Perform merge
            performMerge();
            mergeMessage = 'Success!';
        } catch (Exception ex) {
            // Handle exception and rollback if necessary            
            mergeMessage = 'Merge failed! ' + ex.getMessage();
            Database.rollback(sp);
        }         
    }

    private void updateUniqueFieldsInMergedAccountAndPrepareMasterAccount() {
        // Retrieve the user selected field values
        for (String field : differentFields) {
           // Object selectedValue = selectedFieldValues.get(field);
           Object selectedValue = ApexPages.currentPage().getParameters().get(field);
    
         if (selectedValue instanceof String) {            
        
                Schema.DescribeFieldResult fieldDescribe = Account.SObjectType.getDescribe().fields.getMap().get(field).getDescribe();
                Schema.DisplayType fieldType = fieldDescribe.getType();
    
                String stringValue = (String) selectedValue;
                if (fieldType == Schema.DisplayType.INTEGER) {
                    selectedValue = Integer.valueOf(stringValue);
                } else if (fieldType == Schema.DisplayType.DOUBLE || fieldType == Schema.DisplayType.CURRENCY || fieldType == Schema.DisplayType.PERCENT) {
                    selectedValue = Decimal.valueOf(stringValue);
                } else if (fieldType == Schema.DisplayType.BOOLEAN) {
                    selectedValue = Boolean.valueOf(stringValue);
                }
                
                // Check if the field is unique and update the merged account's field
                // TODO: might need additional customization if the field is specified with special rules 
                if (fieldDescribe.isUnique() && (fieldType == Schema.DisplayType.INTEGER || fieldType == Schema.DisplayType.DOUBLE)) {
                    mergedAccount.put(field, 0);
                }else if (fieldDescribe.isUnique()){
                    mergedAccount.put(field, 'tempValue');
                }
            }
    
            masterAccount.put(field, selectedValue);
        }
    
        // Update merged account with the unique field values
        update mergedAccount;
    }
    
    private void performMerge() {
        Account updatedMasterAccount = [SELECT Id FROM Account WHERE Id = :masterAccountId LIMIT 1];
        Account updatedMergedAccount = [SELECT Id FROM Account WHERE Id = :mergedAccountId LIMIT 1];
        Database.merge(updatedMasterAccount, updatedMergedAccount, true);
    }
    

    public void moveChildRecords(Id masterAccountId, Id mergedAccountId, List<String> childObjectNames) {
        // Iterate over each child object name in the list
        for (String childObjectName : childObjectNames) {
            // Prepare the dynamic SOQL query to retrieve child records for the merged account
            String soqlQuery = 'SELECT Id FROM ' + childObjectName + ' WHERE AccountId = :mergedAccountId';
            
            // Query the child records dynamically
            List<SObject> childRecords = Database.query(soqlQuery);
            
            // Move child records to the master account
            for (SObject childRecord : childRecords) {
                // TODO:Set the master account as the new parent
                childRecord.put('AccountId', masterAccountId);                
                
                // Insert the child record under the master account
                Database.update(childRecord);
            }
        }
    } 
    
    private Boolean isSetCustomMetadataType() {
        // Get the selected fields from Custom Metadata Type Custom_Merge_Settings__mdt.ChildObjectNames__c
        // TODO: Set the child objects in salesforce and use the instance 
        Custom_Merge_Settings__mdt setting = Custom_Merge_Settings__mdt.getInstance('lulu_Sandbox');

        if (null == setting){
            disableMergeMessage = 'Please define the custom metada type: custom merge setting.';
            disableMerge = true; // Disable the Merge button
            return false;
        } else if( null == setting.ChildObjectNames__c){
            disableMergeMessage = 'Please define the child relateion via custom metada type.';
            disableMerge = true; // Disable the Merge button
            return false;
        } else if(null == setting.RestrictedExternalFields__c){
            disableMergeMessage = 'Please define the restricted external fields via custom metada type.';
            disableMerge = true; // Disable the Merge button
            return false;
        }
        childObjectNames = new List<String>();
        childObjectNames = setting.ChildObjectNames__c.split(',');

        restrictedExternalFields = new List<String>();
        restrictedExternalFields = setting.RestrictedExternalFields__c.split(',');
        return true;
        
    }

    public void restrictExternalFields(List<String> restrictedExternalFields) {
        for (String field : restrictedExternalFields) {
            Boolean isMasterFieldEmpty = String.isBlank((String) masterAccount.get(field));
            Boolean isMergedFieldEmpty = String.isBlank((String) mergedAccount.get(field));
    
            // Check if both fields are empty or both have values
            if ((isMasterFieldEmpty && isMergedFieldEmpty) || (!isMasterFieldEmpty && !isMergedFieldEmpty)) {
                disableMergeMessage = 'Both ' + field + ' fields are empty or both have values. Merging is not allowed.';
                disableMerge = true; // Disable the Merge button
                break; // Exit the loop after the first field that meets the condition
            }
        }
    }


    public void checkDisableMergeCondition() {
        // disable merge if custom meta data type is not defined
        if (!isSetCustomMetadataType()){
            return;
        }
        // disable merge if resticted fieds condition are met
        restrictExternalFields(restrictedExternalFields);
            
    }
}