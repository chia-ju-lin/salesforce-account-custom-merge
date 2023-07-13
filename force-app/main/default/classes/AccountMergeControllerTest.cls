@isTest
public class AccountMergeControllerTest {   

    @testSetup 
    public static void setupTestData() {
        // Create Account 1 with a rating of 'Hot'
        Account account1 = new Account();
        account1.Name = 'Account 1';
        account1.Rating = 'Hot';
        
        // Create Account 2 with a rating of 'Cold'
        Account account2 = new Account();
        account2.Name = 'Account 2';
        account2.Rating = 'Cold';
        
        // Insert the accounts into the database
        List<Account> accountList = new List<Account>();
        accountList.add(account1);
        accountList.add(account2);
        insert accountList;
    }

    @isTest
    static void testMergeAccounts() {
        // Create master and merged accounts in setup
        /*
        Account masterAccount = new Account(Name = 'Account 1');
        Account mergedAccount = new Account(Name = 'Account 2');
        insert masterAccount;
        insert mergedAccount;*/

        // Retrieve the IDs of the inserted accounts
        Account masterAccount = [SELECT Id, Name, Rating FROM Account WHERE Name = 'Account 1' LIMIT 1];
        Account mergedAccount = [SELECT Id, Name, Rating FROM Account WHERE Name = 'Account 2' LIMIT 1];

        // Set up the URL parameters
        Map<String, String> urlParams = new Map<String, String>();
        urlParams.put('masterId', masterAccount.Id);
        urlParams.put('mergedId', mergedAccount.Id);
        // Add the 'Name', 'Rating' fields to the URL parameters for selectedFieldValues
        urlParams.put('Name', 'Merged Account');
        urlParams.put('Rating', 'Cold');

        // Set up the page parameters with URL parameters
        Test.setCurrentPageReference(new PageReference('/apex/merge'));
        ApexPages.currentPage().getParameters().putAll(urlParams);

        // Set up the controller
        AccountMergeController controller = new AccountMergeController();

        // Set field values for testing
        //String testFieldValue = 'Test Field Value';
        /*controller.selectedFieldValues = new Map<String, Object>{
            'Name'=> 'Account 1',
            'Rating' => 'Cold'
        };*/

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

    
    /*
    
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
        Boolean disableMergeButton = controller.disableMerge;
        System.assertEquals(true, disableMergeButton);

        // Test case 2: Both external IDs have values
        masterAccount.ExternalID__c = '123';
        mergedAccount.ExternalID__c = '456';
        update masterAccount;
        update mergedAccount;
        disableMergeButton = controller.disableMerge;
        System.assertEquals(true, disableMergeButton);

        // Test case 3: One external ID is empty and the other has a value
        masterAccount.ExternalID__c = '';
        mergedAccount.ExternalID__c = '456';
        update masterAccount;
        update mergedAccount;
        disableMergeButton = controller.disableMerge;
        System.assertEquals(false, disableMergeButton);
    }*/
}