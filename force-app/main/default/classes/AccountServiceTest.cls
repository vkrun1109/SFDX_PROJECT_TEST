/**
 * @description Test class for AccountService
 */
@isTest
private class AccountServiceTest {
    
    @isTest
    static void testCreateAccount() {
        Test.startTest();
        Account testAccount = AccountService.createAccount('Test Account');
        Test.stopTest();
        
        // Verify the account was created
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(1, accounts.size(), 'Account was not created');
        System.assertEquals('Test Account', accounts[0].Name, 'Account name does not match');
    }
    
    @isTest
    static void testUpdateAccountsRevenue() {
        // Create test data
        List<Account> testAccounts = new List<Account>{
            new Account(Name='Test 1', AnnualRevenue = 1000),
            new Account(Name='Test 2', AnnualRevenue = 2000)
        };
        insert testAccounts;
        
        List<Id> accountIds = new List<Id>{
            testAccounts[0].Id,
            testAccounts[1].Id
        };
        
        Test.startTest();
        List<Database.SaveResult> results = AccountService.updateAccountsRevenue(accountIds, 5000);
        Test.stopTest();
        
        // Verify the update was successful
        List<Account> updatedAccounts = [SELECT Id, AnnualRevenue FROM Account WHERE Id IN :accountIds];
        for (Account acc : updatedAccounts) {
            System.assertEquals(5000, acc.AnnualRevenue, 'Annual Revenue was not updated correctly');
        }
    }
}
