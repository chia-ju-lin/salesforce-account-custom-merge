@isTest
public with sharing class AccountMergeDuplicateControllerTest {
    
    @testSetup 
    public static void setupTestData() {
        // Create Account 1 with a rating of 'Hot'
        Account account1 = new Account();
        account1.Name = 'Account aa';
        account1.Rating = 'Hot';
        
        // Create Account 2 with a rating of 'Cold'
        Account account2 = new Account();
        account2.Name = 'Account bb';
        account2.Rating = 'Cold';
        
        // Insert the accounts into the database
        List<Account> accountList = new List<Account>();
        accountList.add(account1);
        accountList.add(account2);
        insert accountList;
    }
    @isTest
    static void testLoadAccounts() {
        // Retrieve the IDs of the inserted accounts
        Account currentAccount = [SELECT Id, Name, Rating FROM Account WHERE Name = 'Account aa' LIMIT 1];
        // Set up the URL parameters
        Map<String, String> urlParams = new Map<String, String>();
        urlParams.put('masterAccountId', currentAccount.Id);
        Test.setCurrentPageReference(new PageReference('/apex/merge'));
        ApexPages.currentPage().getParameters().putAll(urlParams);

        // Instantiate the controller
        AccountMergeDuplicateController controller = new AccountMergeDuplicateController();

        // Verify the loaded accounts and display fields
        System.assertEquals(0, controller.duplicateAccounts.size());
        System.assertEquals(currentAccount.Id, controller.currentAccountId);
        System.assertEquals('Name', controller.displayFieldAPINames[0]);
        System.assertEquals('Rating', controller.displayFieldAPINames[1]);
        System.assertEquals('Account Name', controller.displayFieldLabels[0]);
        System.assertEquals('Prospect Rating', controller.displayFieldLabels[1]);
    }
    //I am not able to retrieve duplicated data in test context, alternative will be using (SeeAllData=true)
    /*
    @isTest
    static void testLoadDuplicateAccounts() {
        // Create test data
        Account masterAccount = new Account(Name = 'Account aa', Rating = 'Cold');
        Account mergedAccount = new Account(Name = 'Account aa Inc', Rating = 'Warm');
        insert new List<Account>{ masterAccount, mergedAccount };

        masterAccount = [SELECT Id, Name, Rating FROM Account WHERE Name = 'Account aa' AND Rating = 'Cold' LIMIT 1];
    // masterAccount = [SELECT Id, Name, Rating FROM Account WHERE Name = 'Apple' LIMIT 1];

        // Set the current account ID in the URL parameter
        Map<String, String> urlParams = new Map<String, String>{
            'masterAccountId' => masterAccount.Id
        };
        Test.setCurrentPageReference(new PageReference('/apex/merge'));
        ApexPages.currentPage().getParameters().putAll(urlParams);

        // Instantiate the controller
        AccountMergeDuplicateController controller = new AccountMergeDuplicateController();
        controller.loadAccounts();
        List<Account> result = AccountMergeHelper.getDuplicateAccounts(controller.currentAccountId, controller.displayFieldAPINames);
        List<Account> aa = [SELECT Id, Name, Rating FROM Account ];
        System.assertEquals(2, aa.size());
        // Verify the loaded accounts and display fields
        //System.assertEquals(1, controller.duplicateAccounts.size());
        //System.assertEquals(1, result.size());
        System.assertEquals(masterAccount.Id, controller.currentAccountId);
        System.assertEquals('Name', controller.displayFieldAPINames[0]);
        System.assertEquals('Rating', controller.displayFieldAPINames[1]);
        System.assertEquals('Account Name', controller.displayFieldLabels[0]);
        System.assertEquals('Prospect Rating', controller.displayFieldLabels[1]);
    }*/
        @isTest
    static void testMergeSelectedAccount() {
        // Create test data
        Account masterAccount = new Account(Name = 'Master Account');
        Account mergedAccount = new Account(Name = 'Merged Account');
        insert new List<Account>{ masterAccount, mergedAccount };

        // Set up the URL parameters
        Map<String, String> urlParams = new Map<String, String>();
        urlParams.put('masterAccountId', masterAccount.Id);
        urlParams.put('selectedAccountIdHidden', mergedAccount.Id);
        
        Test.setCurrentPageReference(new PageReference('/apex/merge'));
        ApexPages.currentPage().getParameters().putAll(urlParams);

        // Instantiate the controller
        AccountMergeDuplicateController controller = new AccountMergeDuplicateController();   

        // Call the mergeSelectedAccount method
        PageReference pageRef = controller.mergeSelectedAccount();

        // Verify the results
        System.assertEquals(null, controller.errorMessage);
        System.assertNotEquals(null, pageRef);
        // Add additional assertions as needed
    }


}