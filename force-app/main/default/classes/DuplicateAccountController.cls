public class DuplicateAccountController {
    public List<Account> duplicateAccounts { get; set; }
    public String selectedAccountId { get; set; }
    public List<SelectOption> accountOptions { get; set; }
    public String currentAccountId { get; set; }

    public DuplicateAccountController() {
        //selectedAccountId = null;
        accountOptions = new List<SelectOption>();
        loadAccounts();
    }

    
    public void loadAccounts() {
        // Assuming you have the current account ID stored in a variable called 'currentAccountId'
        currentAccountId = '0015I00000iqj4TQAQ';
    
        DuplicateAccountRetriever accountRetriever = new DuplicateAccountRetriever();
        duplicateAccounts = accountRetriever.getDuplicateAccounts(currentAccountId);
        
        accountOptions = new List<SelectOption>();
        for (Account account : duplicateAccounts) {
            accountOptions.add(new SelectOption(account.Id, account.Id));
        }
    
        // Set the first account ID as the default selectedAccountId
        if (accountOptions.size() > 0) {
            selectedAccountId = accountOptions[0].getValue();
        }
    }
    

    public List<SelectOption> getAccountOptions() {
        return accountOptions;
    }

    public PageReference mergeSelectedAccount() {
        // Perform the merge operation with the selected account
        String redirectUrl = '/apex/merge?masterId=' + currentAccountId + '&mergedId=' + selectedAccountId;
        PageReference pageRef = new PageReference(redirectUrl);
        pageRef.setRedirect(true);
        return pageRef;
    }
}
