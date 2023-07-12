public class AccountMergeDuplicateController {
    public List<Account> duplicateAccounts { get; set; }
    public String selectedAccountId { get; set; }
    public List<SelectOption> accountOptions { get; set; }
    public String currentAccountId { get; set; }
    public List<String> displayFieldAPINames { get; set; }
    public List<String> displayFieldLabels { get; set; }
    public String errorMessage { get; set; }

    public AccountMergeDuplicateController() {

        // Retrieve the masterAccountId from the URL parameter
        currentAccountId = ApexPages.currentPage().getParameters().get('masterAccountId');
        accountOptions = new List<SelectOption>();
        displayFieldAPINames = new List<String>();
        displayFieldLabels = new List<String>();
        loadAccounts();
    }

    public void loadAccounts() {         

        // Get the selected fields from Custom Metadata Type dynamically
        Custom_Merge_Settings__mdt setting = Custom_Merge_Settings__mdt.getInstance('lulu_Sandbox');
        if (null == setting || null == setting.FieldAPINames__c){
            errorMessage = 'Please define which fields to display in the custom meta data!';
            return;
        }

        displayFieldAPINames = setting.FieldAPINames__c.split(',');

        // Get the field labels dynamically from the schema
        Schema.DescribeSObjectResult accountDescribe = Account.SObjectType.getDescribe();
        displayFieldLabels = new List<String>();

        for (String fieldAPIName : displayFieldAPINames) {
            displayFieldLabels.add(accountDescribe.fields.getMap().get(fieldAPIName).getDescribe().getLabel());
        }

        duplicateAccounts = AccountMergeHelper.getDuplicateAccounts(currentAccountId, displayFieldAPINames);

         // Set the first account ID as the default selectedAccountId         
         if (duplicateAccounts.size() > 0) {
            selectedAccountId = duplicateAccounts[0].Id;
        }
    }

    public PageReference mergeSelectedAccount() {
        // Retrieve the selected Account ID from the hidden input field
        selectedAccountId = ApexPages.currentPage().getParameters().get('selectedAccountIdHidden');
        
        // Call the AccountMergeHelper method and retrieve the MergeResult
        AccountMergeHelper.MergeResult mergeResult = AccountMergeHelper.redirectToMergePage(currentAccountId, selectedAccountId);
        
        if (mergeResult.errorMessage != null) {
            // Retrieve the error message from mergeResult.errorMessage
            errorMessage = mergeResult.errorMessage;
            return null;
        } else if (mergeResult.pageRef != null) {
            // Handle the successful redirection
            return mergeResult.pageRef;            
        } else {
            // Handle other scenarios or errors
            errorMessage = 'Unexpected error occurred.';
            return null;
        }
    
    }
}