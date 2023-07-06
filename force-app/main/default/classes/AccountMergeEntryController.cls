public class AccountMergeEntryController {
        public String masterAccountId { get; set; }
        public String mergedAccountId { get; set; }

        public AccountMergeEntryController() {
            // Retrieve the masterAccountId from the URL parameter
            masterAccountId = ApexPages.currentPage().getParameters().get('masterAccountId');
        }
    
        public PageReference redirectToMergePage() {
            // Redirect to your existing VF page with the entered values as URL parameters
            PageReference pageRef = new PageReference('/apex/merge');
            pageRef.getParameters().put('masterId', masterAccountId);
            pageRef.getParameters().put('mergedId', mergedAccountId);
            return pageRef;
        }
    }
    