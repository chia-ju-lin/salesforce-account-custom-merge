public class DuplicateAccountController {
    public List<Account> duplicateAccounts { get; set; }
    public String selectedAccountId { get; set; }
    public List<SelectOption> accountOptions { get; set; }
    public String currentAccountId { get; set; }
    public List<String> displayFieldAPINames { get; set; }
    public List<String> displayFieldLabels { get; set; }

    public DuplicateAccountController() {
        accountOptions = new List<SelectOption>();
        displayFieldAPINames = new List<String>();
        displayFieldLabels = new List<String>();
        loadAccounts();
    }

    public void loadAccounts() {
        // Assuming you have the current account ID stored in a variable called 'currentAccountId'
        currentAccountId = '0015I00000iqj4TQAQ';      

        // Get the selected fields from Custom Metadata Type dynamically
        Custom_Merge_Settings__mdt setting = Custom_Merge_Settings__mdt.getInstance('lulu_Sandbox');
        //DuplicateViewSetting__mdt setting = Custom_Merge_Settings__mdt.getInstance('FieldAPINames');
        displayFieldAPINames = setting.FieldAPINames__c.split(',');

        // Get the field labels dynamically from the schema
        Schema.DescribeSObjectResult accountDescribe = Account.SObjectType.getDescribe();
        displayFieldLabels = new List<String>();

        for (String fieldAPIName : displayFieldAPINames) {
            displayFieldLabels.add(accountDescribe.fields.getMap().get(fieldAPIName).getDescribe().getLabel());
        }

        DuplicateAccountRetriever accountRetriever = new DuplicateAccountRetriever();
        duplicateAccounts = accountRetriever.getDuplicateAccounts(currentAccountId, displayFieldAPINames);

         // Set the first account ID as the default selectedAccountId
         if (duplicateAccounts.size() > 0) {
            selectedAccountId = duplicateAccounts[0].Id;
        }
    }

    public PageReference mergeSelectedAccount() {
        // Retrieve the selected Account ID from the hidden input field
        selectedAccountId = ApexPages.currentPage().getParameters().get('selectedAccountIdHidden');
        
        // Perform the merge operation with the selected account
        String redirectUrl = '/apex/merge?masterId=' + currentAccountId + '&mergedId=' + selectedAccountId;
        PageReference pageRef = new PageReference(redirectUrl);
        pageRef.setRedirect(true);
        return pageRef;
    }
}
