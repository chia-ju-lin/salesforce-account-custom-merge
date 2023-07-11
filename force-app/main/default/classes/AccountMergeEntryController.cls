public class AccountMergeEntryController {
    public String masterAccountId { get; set; }
    public String mergedAccountId { get; set; }
    public String errorMessage { get; set; }

    public AccountMergeEntryController() {
        // Retrieve the masterAccountId from the URL parameter
        masterAccountId = ApexPages.currentPage().getParameters().get('masterAccountId');
    }

    public PageReference redirectToMergePage() {
        // Check if the master and merged Account IDs are identical
        if (masterAccountId != null && mergedAccountId != null && masterAccountId.length() >= 15 && mergedAccountId.length() >= 15) {
            String masterIdFirst15 = masterAccountId.substring(0, 15);
            String mergedIdFirst15 = mergedAccountId.substring(0, 15);
            
            if (masterIdFirst15.equals(mergedIdFirst15)) {
                errorMessage = 'Please enter different Account IDs.';
                return null;
            }
        }
        
        // Check if the entered Account IDs exist
        if (!accountExists(masterAccountId) || !accountExists(mergedAccountId)) {
            errorMessage = 'One or both of the entered Account IDs do not exist.';
            return null;
        }
        try {
            // Redirect to your existing VF page with the entered values as URL parameters
            String redirectUrl = '/apex/merge?masterId=' + masterAccountId + '&mergedId=' + mergedAccountId;
            PageReference pageRef = new PageReference(redirectUrl);
            pageRef.setRedirect(true);
            return pageRef;
        } catch (Exception e) {
            errorMessage = 'Unexpected exception: '+ e;
            return null;
        }
    }
    
    @testVisible
    private Boolean accountExists(String accountId) {   
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
    

}
