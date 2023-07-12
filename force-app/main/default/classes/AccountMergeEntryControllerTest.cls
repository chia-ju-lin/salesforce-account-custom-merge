@isTest
public class AccountMergeEntryControllerTest {


    @isTest
    static void testRedirectToMergePage() {
        // Create test data
        Account masterAccount = new Account(Name = 'Master Account');
        Account mergedAccount = new Account(Name = 'Merged Account');
        insert new List<Account>{ masterAccount, mergedAccount };
        
        AccountMergeEntryController controller = new AccountMergeEntryController();
        controller.masterAccountId = masterAccount.Id;
        controller.mergedAccountId = mergedAccount.Id;
        
        Test.startTest();
        // Call the method under test
        Pagereference ref = controller.redirectToMergePage();       
        
        // Assert the error message
        System.assertEquals(null, controller.errorMessage);
        // Assert that the page reference is null
        System.assertEquals('/apex/merge?masterId=' + masterAccount.Id + '&mergedId=' + mergedAccount.Id, ref.getUrl());
        
        
        // Call the method under test
        AccountMergeHelper.MergeResult result = AccountMergeHelper.redirectToMergePage(controller.masterAccountId,controller.mergedAccountId);
        PageReference pageRef = result.pageRef;
        Test.stopTest();
        
        // Assert the results
        System.assertEquals('/apex/merge?masterId=' + masterAccount.Id + '&mergedId=' + mergedAccount.Id, pageRef.getUrl());
    }
    
    @isTest
    static void testRedirectToMergePage_InvalidAccountIds() {

        AccountMergeEntryController controller = new AccountMergeEntryController();
        controller.masterAccountId = 'invalidId1';
        controller.mergedAccountId = 'invalidId2';
        
        Test.startTest();
        // Call the method under test
        AccountMergeHelper.MergeResult result = AccountMergeHelper.redirectToMergePage(controller.masterAccountId,controller.mergedAccountId);
        PageReference pageRef = result.pageRef;
        String error = result.errorMessage;
        Test.stopTest();
        
        // Assert the error message
        System.assertEquals('One or both of the entered Account IDs do not exist.', error);
        // Assert that the page reference is null
        System.assertEquals(null, pageRef);
    }
    
    @isTest
    static void testRedirectToMergePage_SameAccountIds() {
        Account masterAccount = new Account(Name = 'Master Account');
        insert masterAccount;
        
        AccountMergeEntryController controller = new AccountMergeEntryController();
        controller.masterAccountId = masterAccount.Id;
        controller.mergedAccountId = masterAccount.Id;
        
        Test.startTest();
        // Call the method under test
        AccountMergeHelper.MergeResult result = AccountMergeHelper.redirectToMergePage(controller.masterAccountId,controller.mergedAccountId);
        PageReference pageRef = result.pageRef;
        String error = result.errorMessage;
        Test.stopTest();
        
        // Assert the error message
        System.assertEquals('Please enter different Account IDs.', error);
        // Assert that the page reference is null
        System.assertEquals(null, pageRef);
    }

        
    @isTest
    static void testAccountExists() {
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        AccountMergeEntryController controller = new AccountMergeEntryController();
        
        // Test valid account ID
        Boolean exists = AccountMergeHelper.accountExists(account.Id);
        System.assertEquals(true, exists);
        
        // Test invalid account ID
        exists = AccountMergeHelper.accountExists('invalidId');
        System.assertEquals(false, exists);
        
        // Test not exist account ID
        exists = AccountMergeHelper.accountExists('0015I00000iqj2qQAA');
        System.assertEquals(false, exists);

        Test.startTest();
        // Call the method under test
        Pagereference ref = controller.redirectToMergePage();
        AccountMergeHelper.MergeResult result = AccountMergeHelper.redirectToMergePage(controller.masterAccountId,controller.mergedAccountId);
        PageReference pageRef = result.pageRef;
        String error = result.errorMessage;
        Test.stopTest();
        
        // Assert the error message
        System.assertNotEquals(null, controller.errorMessage);
        System.assertNotEquals(null, error);
        // Assert that the page reference is null
        System.assertEquals(null, ref);
        System.assertEquals(null, pageRef);
    }
}