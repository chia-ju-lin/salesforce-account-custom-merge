public class AccountMergeController {
    
    public Account masterAccount { get; private set; }
    public Account mergedAccount { get; private set; }
    public Map<String, Object> selectedFieldValues { get; set; }
    public List<String> fieldValues { get; private set; }
    public List<String> differentFields { get; private set; }
    public String mergeMessage { get; private set; }
    public Boolean isMerged { get; private set; }
    public String masterAccountId { get; private set; }
    public String mergedAccountId { get; private set; }

    public AccountMergeController() {
        masterAccountId = ApexPages.currentPage().getParameters().get('masterId');
        mergedAccountId = ApexPages.currentPage().getParameters().get('mergedId');

        Map<String, Schema.SObjectField> accountFields = Account.SObjectType.getDescribe().fields.getMap();
        String metadataFields = '';
        for (Schema.SObjectField field : accountFields.values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
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

        // Populate the selected values for each field
        differentFields = getDifferentFields();
        for (String field : differentFields) {
            if (masterAccount.get(field) != null) {
                selectedFieldValues.put(field, masterAccount.get(field));
            } else if (mergedAccount.get(field) != null) {
                selectedFieldValues.put(field, mergedAccount.get(field));
            }
}
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
        // Retrieve the selected field values
        for (String field : differentFields) {
            Object selectedValue = selectedFieldValues.get(field);
    
            if (selectedValue instanceof String) {
                Schema.DescribeFieldResult fieldDescribe = Account.SObjectType.getDescribe().fields.getMap().get(field).getDescribe();
                Schema.DisplayType fieldType = fieldDescribe.getType();
    
                if (fieldType == Schema.DisplayType.INTEGER) {
                    selectedValue = Integer.valueOf((String) selectedValue);
                } else if (fieldType == Schema.DisplayType.DOUBLE) {
                    selectedValue = Double.valueOf((String) selectedValue);
                } else if (fieldType == Schema.DisplayType.BOOLEAN) {
                    selectedValue = Boolean.valueOf((String) selectedValue);
                } /*
                else if (fieldType == Schema.DisplayType.DATE) {
                    selectedValue = Date.valueOf((String) selectedValue);
                } else if (fieldType == Schema.DisplayType.DATETIME) {
                    selectedValue = DateTime.valueOf((String) selectedValue);
                }
                */
            }
    
            masterAccount.put(field, selectedValue);
        }
    
        // Save the updated master account and perform other operations
        update masterAccount;

        //TODO: 
        // 1. update master with selected values
        // 2. insert merged child into master
        // 3. delete merged child
        // 4. merge    
        // 5. rollback the above if merge fail    
        
       
       isMerged = true;
       mergeMessage = 'Merge successful!';       
    }
    

    public Boolean getDisableMergeButton() {         
        // if ERP(or EBP) ID exist in both master and merged         
        // if ERP(or EBP) in both master and merged are both empty
        
        Boolean isMasterERPIdEmpty = String.isBlank(masterAccount.ExternalID__c);
        Boolean isMergedERPIdEmpty = String.isBlank(mergedAccount.ExternalID__c);

        // Check if both external IDs are empty or both have values
        if ((isMasterERPIdEmpty && isMergedERPIdEmpty) || (!isMasterERPIdEmpty && !isMergedERPIdEmpty)) {
            return true; // Disable the Merge button
        }
        return false;
    }
}
