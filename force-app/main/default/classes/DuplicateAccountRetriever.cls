public class DuplicateAccountRetriever {
    public List<Account> getDuplicateAccounts(Id currentAccountId) {
        // Retrieve the DuplicateRecordSetIds for the current account ID
        Set<Id> duplicateRecordSetIds = new Set<Id>();
        for (DuplicateRecordItem item : [
            SELECT DuplicateRecordSetId
            FROM DuplicateRecordItem
            WHERE RecordId = :currentAccountId
        ]) {
            duplicateRecordSetIds.add(item.DuplicateRecordSetId);
        }

        // Retrieve the duplicate account records related to the DuplicateRecordSetIds
        //TODO: query fields configiable to Account Owner Alias
        List<Account> duplicateAccounts = [
            SELECT Id, Name, Rating
            FROM Account
            WHERE Id IN (
                SELECT RecordId
                FROM DuplicateRecordItem
                WHERE DuplicateRecordSetId IN :duplicateRecordSetIds
            )
            AND Id != :currentAccountId
        ];

        return duplicateAccounts;
    }
}
