@isTest
public class AccountMergeControllerTest {
  
    @isTest
    static void testMergeAccounts() {
        // Create master and merged accounts
        Account masterAccount = new Account(Name = 'Account 1');
        Account mergedAccount = new Account(Name = 'Account 2');
        insert masterAccount;
        insert mergedAccount;
    
        // Retrieve the IDs of the inserted accounts
        masterAccount = [SELECT Id FROM Account WHERE Id = :masterAccount.Id LIMIT 1];
        mergedAccount = [SELECT Id FROM Account WHERE Id = :mergedAccount.Id LIMIT 1];
    
        // Set up the controller
        AccountMergeController controller = new AccountMergeController();
        controller.masterAccountId = masterAccount.Id;
        controller.mergedAccountId = mergedAccount.Id;
    
        // Set field values for testing
        String testFieldValue = 'Test Field Value';
        controller.selectedFieldValues = new Map<String, Object>{
            'Rating' => 'Cold'
        };
    
        Test.startTest();
        // Call the method under test
        controller.mergeAccounts();
        Test.stopTest();
    
        // Assert the merge message
        System.assertEquals('Success!', controller.mergeMessage);
    
        // Assert that the accounts were merged
        Account mergedAccountAfterMerge = [SELECT Id, IsDeleted FROM Account WHERE Id = :mergedAccount.Id ALL ROWS];
        System.assertEquals(true, mergedAccountAfterMerge.IsDeleted);
    }
    
    
    @isTest
    static void testDisableMergeButton() {
        // Create master and merged accounts
        Account masterAccount = new Account(Name = 'Master Account');
        Account mergedAccount = new Account(Name = 'Merged Account');
        insert masterAccount;
        insert mergedAccount;

        // Set up the controller
        AccountMergeController controller = new AccountMergeController();
        controller.masterAccountId = masterAccount.Id;
        controller.mergedAccountId = mergedAccount.Id;

        // Test case 1: Both external IDs are empty
        masterAccount.ExternalID__c = '';
        mergedAccount.ExternalID__c = '';
        update masterAccount;
        update mergedAccount;
        Boolean disableMergeButton = controller.getDisableMergeButton();
        System.assertEquals(true, disableMergeButton);

        // Test case 2: Both external IDs have values
        masterAccount.ExternalID__c = '123';
        mergedAccount.ExternalID__c = '456';
        update masterAccount;
        update mergedAccount;
        disableMergeButton = controller.getDisableMergeButton();
        System.assertEquals(true, disableMergeButton);

        // Test case 3: One external ID is empty and the other has a value
        masterAccount.ExternalID__c = '';
        mergedAccount.ExternalID__c = '456';
        update masterAccount;
        update mergedAccount;
        disableMergeButton = controller.getDisableMergeButton();
        System.assertEquals(false, disableMergeButton);
    }
}