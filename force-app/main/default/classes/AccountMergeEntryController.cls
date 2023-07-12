public class AccountMergeEntryController {
    public String masterAccountId { get; set; }
    public String mergedAccountId { get; set; }
    public String errorMessage { get; set; }

    public AccountMergeEntryController() {
        // Retrieve the masterAccountId from the URL parameter
        masterAccountId = ApexPages.currentPage().getParameters().get('masterAccountId');
    }

    public PageReference redirectToMergePage() {        
        
        // Call the AccountMergeHelper method and retrieve the MergeResult
        AccountMergeHelper.MergeResult mergeResult = AccountMergeHelper.redirectToMergePage(masterAccountId, mergedAccountId);
        
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