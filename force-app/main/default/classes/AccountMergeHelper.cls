public class AccountMergeHelper {
    // Define a global variable for the field API names
    public static List<String> displayFieldAPINames;
    
    public class MergeResult {
        public PageReference pageRef { get; set; }
        public String errorMessage { get; set; }
    }
    
    public static MergeResult redirectToMergePage(String masterAccountId, String mergedAccountId) {
        MergeResult result = new MergeResult();
        result.errorMessage = null;
        
        // Check if the master and merged Account IDs are identical
        if (masterAccountId != null && mergedAccountId != null && masterAccountId.length() >= 15 && mergedAccountId.length() >= 15) {
            String masterIdFirst15 = masterAccountId.substring(0, 15);
            String mergedIdFirst15 = mergedAccountId.substring(0, 15);
            
            if (masterIdFirst15.equals(mergedIdFirst15)) {
                result.errorMessage = 'Please enter different Account IDs.';
                return result;
            }
        }
        
        // Check if the entered Account IDs exist
        if (!accountExists(masterAccountId) || !accountExists(mergedAccountId)) {
            result.errorMessage = 'One or both of the entered Account IDs do not exist.';
            return result;
        }
        
        
        // Redirect to your existing VF page with the entered values as URL parameters
        String redirectUrl = '/apex/merge?masterId=' + masterAccountId + '&mergedId=' + mergedAccountId;
        PageReference pageRef = new PageReference(redirectUrl);
        pageRef.setRedirect(true);
        result.pageRef = pageRef;
        return result;
        
    }
    
    @testVisible
    public static Boolean accountExists(String accountId) {   
        // Check if the Account ID is valid
        if (accountId == null || (accountId.length() != 15 && accountId.length() != 18)) {
            return false;
        }

        try {
            // Check if the Account ID exists by performing a SOQL query
            String soqlQuery = 'SELECT Id FROM Account WHERE Id = \'' + accountId + '\' LIMIT 1';
            List<Account> accounts = Database.query(soqlQuery);
            return !accounts.isEmpty();
        } catch (Exception e) {
            return false;
        }
    }
    
    public static List<Account> getDuplicateAccounts(Id currentAccountId) {
        // Ensure that displayFieldAPINames is initialized
        if (displayFieldAPINames == null) {
            retrieveFieldAPINames();
        }
        // Retrieve the DuplicateRecordSetIds for the current account ID
        Set<Id> duplicateRecordSetIds = new Set<Id>();
        for (DuplicateRecordItem item : [
            SELECT DuplicateRecordSetId
            FROM DuplicateRecordItem
            WHERE RecordId = :currentAccountId
        ]) {
            duplicateRecordSetIds.add(item.DuplicateRecordSetId);
        }
    
        // Construct the dynamic query string based on the selected fields
        String queryFields = 'Id, ' + String.join(displayFieldAPINames, ', ');
    
        // Retrieve the duplicate account records related to the DuplicateRecordSetIds
        List<Account> duplicateAccounts = Database.query(''
            + 'SELECT ' + queryFields + ' '
            + 'FROM Account '
            + 'WHERE Id IN ('
                + 'SELECT RecordId '
                + 'FROM DuplicateRecordItem '
                + 'WHERE DuplicateRecordSetId IN :duplicateRecordSetIds'
            + ') '
            + 'AND Id != :currentAccountId'
        );
    
        return duplicateAccounts;
    }
    
     // Separate method to retrieve field API names and set the global variable
     public static void retrieveFieldAPINames() {
        Custom_Merge_Settings__mdt setting = Custom_Merge_Settings__mdt.getInstance('lulu_Sandbox');
        if (null == setting || null == setting.FieldAPINames__c) {
            // Handle error or exception if necessary
        }

        displayFieldAPINames = setting.FieldAPINames__c.split(',');
    }

    // Method to get field labels dynamically from the schema
    public static List<String> getFieldLabels() {
        Schema.DescribeSObjectResult accountDescribe = Account.SObjectType.getDescribe();
        List<String> displayFieldLabels = new List<String>();

        for (String fieldAPIName : displayFieldAPINames) {
            displayFieldLabels.add(accountDescribe.fields.getMap().get(fieldAPIName).getDescribe().getLabel());
        }

        return displayFieldLabels;
    }
    @AuraEnabled(cacheable=true)
    public static Integer getDuplicateAccountsCount(Id currentAccountId) {
        try {
            // Retrieve the DuplicateRecordSetIds for the current account ID
            Set<Id> duplicateRecordSetIds = new Set<Id>();
            for (DuplicateRecordItem item : [
                SELECT DuplicateRecordSetId
                FROM DuplicateRecordItem
                WHERE RecordId = :currentAccountId
            ]) {
                duplicateRecordSetIds.add(item.DuplicateRecordSetId);
            }
    
            // Retrieve the count of duplicate account records related to the DuplicateRecordSetIds
            Integer duplicateAccountsCount = [
                SELECT COUNT()
                FROM Account
                WHERE Id IN (
                    SELECT RecordId
                    FROM DuplicateRecordItem
                    WHERE DuplicateRecordSetId IN :duplicateRecordSetIds
                )
                AND Id != :currentAccountId
            ];
    
            return duplicateAccountsCount;
        } catch (Exception e) {
            return 0; // Return 0 in case of any exceptions
        }
    }
    
    
}