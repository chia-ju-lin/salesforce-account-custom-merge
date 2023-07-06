# Purpose of the Project: 

The functionality is similar to the standard salesfoce merge function.
This project provids the following functionality.
- UI to allow two manual input for the account IDs
- Display all fieds which have differnt values between the two accouts for the selection
- After clicking the merge
    - all childs will move to the master account 
    - the selected values will be update to the maser account
    - the merged account will be removed
    - if any DML exception happend, the records will rollback
- Please note that all Date, DateTime and not editable fields are not displaied
- Please modify all *TODOs before using this function

## VF pages

- force-app/main/default/pages/mergeEntry.page
- force-app/main/default/pages/merge.page
- how to link the VF to a detail page?
    - go to Account Object Manger/New button or Link, add "masterAccountId={!Account.Id}" as url parameter
    ![Alt text](image-3.png)


## Apex classes

- force-app/main/default/classes/AccountMergeEntryController.cls
- force-app/main/default/classes/AccountMergeController.cls

### Child Object Customization

Modify the code under force-app/main/default/classes/AccountMergeController.cls

- specify which child object you want to move, the code is inside mergeAccounts()
    ```java
    // 3. move childs from merged account into master account            
            List<String> childObjectNames = new List<String>();
            // TODO: Set the child objects
            childObjectNames.add('Opportunity');
    ```

- specify the exernal ID 
    ```java
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
    ```


### Disable Merge Conditon Customization

Modify the code under force-app/main/default/classes/AccountMergeController.cls inside getDisableMergeButton()

- set exterinal field 
    ```java
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
    ```


