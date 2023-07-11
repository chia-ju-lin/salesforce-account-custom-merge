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
        PageReference pageRef = controller.redirectToMergePage();
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
        PageReference pageRef = controller.redirectToMergePage();
        Test.stopTest();
        
        // Assert the error message
        System.assertEquals('One or both of the entered Account IDs do not exist.', controller.errorMessage);
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
        PageReference pageRef = controller.redirectToMergePage();
        Test.stopTest();
        
        // Assert the error message
        System.assertEquals('Please enter different Account IDs.', controller.errorMessage);
        // Assert that the page reference is null
        System.assertEquals(null, pageRef);
    }
    
    /*
    @isTest
    static void testRedirectToMergePage_Exception() {
        AccountMergeEntryController controller = new AccountMergeEntryController();
        controller.masterAccountId = 'invalidId';
        controller.mergedAccountId = 'validId';
        
        Test.startTest();
        // Call the method under test
        PageReference pageRef = controller.redirectToMergePage();
        Test.stopTest();
        
        // Assert the error message
        //System.assert(controller.errorMessage.startsWith('Unexpected exception:'));
        // Assert the error message is not empty
        System.debug('Actual error message: ' + controller.errorMessage);
        System.assertNotEquals('', controller.errorMessage, 'Error message is empty');
        // Assert that the page reference is null
        System.assertEquals(null, pageRef);
    }*/    
    
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