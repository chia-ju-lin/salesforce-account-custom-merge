public class AccountMergeEntryController {
    public String masterAccountId { get; set; }
    public String mergedAccountId { get; set; }
    public String errorMessage { get; set; }

    public AccountMergeEntryController() {
        // Retrieve the masterAccountId from the URL parameter
        masterAccountId = ApexPages.currentPage().getParameters().get('masterAccountId');
    }

    public void redirectToMergePage() {
        // Check if the entered Account IDs exist
        if (!accountExists(masterAccountId) || !accountExists(mergedAccountId)) {
            errorMessage = 'One or both of the entered Account IDs do not exist.';
        } else {
            // Redirect to your existing VF page with the entered values as URL parameters
            String redirectUrl = '/apex/merge?masterId=' + masterAccountId + '&mergedId=' + mergedAccountId;
            PageReference pageRef = new PageReference(redirectUrl);
            pageRef.setRedirect(true);
            throw new MergePageRedirectException(pageRef);
        }
    }

    private Boolean accountExists(String accountId) {
        // Check if the Account ID exists by performing a SOQL query
        String soqlQuery = 'SELECT Id FROM Account WHERE Id = \'' + accountId + '\' LIMIT 1';
        List<Account> accounts = Database.query(soqlQuery);
        return !accounts.isEmpty();
    }

    public class MergePageRedirectException extends Exception {
        public PageReference pageReference { get; private set; }

        public MergePageRedirectException(PageReference pageRef) {
            this.pageReference = pageRef;
        }
    }
}
