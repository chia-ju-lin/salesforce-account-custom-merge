public with sharing class AccountMergeHelperTest {
    @isTest
    static void testRedirectToMergePage_SameAccountIds() {
        Account masterAccount = new Account(Name = 'Master Account');
        insert masterAccount;
        
        AccountMergeEntryController controller = new AccountMergeEntryController();
        controller.masterAccountId = masterAccount.Id;
        controller.mergedAccountId = masterAccount.Id;
        
        Test.startTest();
        // Call the method under test
        PageReference pageRef = controller.redirectToMergePage();
        Test.stopTest();
        
        // Assert the error message
        System.assertEquals('Please enter different Account IDs.', controller.errorMessage);
        // Assert that the page reference is null
        System.assertEquals(null, pageRef);
    }
        
    @isTest
    static void testAccountExists() {
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        AccountMergeEntryController controller = new AccountMergeEntryController();
        
        // Test valid account ID
        Boolean exists = controller.accountExists(account.Id);
        System.assertEquals(true, exists);
        
        // Test invalid account ID
        exists = controller.accountExists('invalidId');
        System.assertEquals(false, exists);
        
        // Test null account ID
        exists = controller.accountExists(null);
        System.assertEquals(false, exists);
    }
}