/**
 * @description Service class for Account related operations
 */
public with sharing class AccountService {
    
    /**
     * @description Updates the annual revenue for a list of accounts
     * @param accountIds List of Account Ids to update
     * @param newRevenue New revenue value to set
     * @return List<Database.SaveResult> Results of the update operation
     */
    public static List<Database.SaveResult> updateAccountsRevenue(List<Id> accountIds, Decimal newRevenue) {
        List<Account> accountsToUpdate = new List<Account>();
        
        for (Id accId : accountIds) {
            accountsToUpdate.add(new Account(
                Id = accId,
                AnnualRevenue = newRevenue
            ));
        }
        
        return Database.update(accountsToUpdate, false);
    }
    
    /**
     * @description Creates a new account with the provided name
     * @param accountName Name of the account to create
     * @return The newly created Account record with Id
     */
    public static Account createAccount(String accountName) {
        Account newAccount = new Account(
            Name = accountName,
            Industry = 'Technology'
        );
        
        insert newAccount;
        return newAccount;
    }
}
