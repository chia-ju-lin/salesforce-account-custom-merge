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
                } 
            }
    
            masterAccount.put(field, selectedValue);
        }         

        // 1. Savepoint before perform other operations
        Savepoint sp = Database.setSavepoint();       
        
        try{
            // 2. update master with selected values            
            update masterAccount;

            // 3. move childs from merged account into master account            
            List<String> childObjectNames = new List<String>();
            // TODO: Set the child objects
            childObjectNames.add('Opportunity');

            moveChildRecords(masterAccountId, mergedAccountId, childObjectNames);

            // 4. perform merge            
            Account updatedMasterAccount = [SELECT Id, Name FROM Account WHERE Id = :masterAccountId LIMIT 1];           
            Database.merge(updatedMasterAccount, mergedAccount, true);

            isMerged = true;
            mergeMessage = 'Merge successful!';

        }catch (Exception ex){

            // 5. rollback 2,3,4 if merge fail  
            Database.rollback(sp);
            mergeMessage = 'Merge fail!'+ex;
            isMerged = true; 
        }         
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

    public Boolean getDisableMergeButton() {         
        // if ERP(or EBP) ID exist in both master and merged         
        // if ERP(or EBP) in both master and merged are both empty
        // TODO: Set actual extrnalID custom fields
        
        Boolean isMasterERPIdEmpty = String.isBlank(masterAccount.ExternalID__c);
        Boolean isMergedERPIdEmpty = String.isBlank(mergedAccount.ExternalID__c);

        // Check if both external IDs are empty or both have values
        if ((isMasterERPIdEmpty && isMergedERPIdEmpty) || (!isMasterERPIdEmpty && !isMergedERPIdEmpty)) {
            return true; // Disable the Merge button
        }
        return false;
    }
}
