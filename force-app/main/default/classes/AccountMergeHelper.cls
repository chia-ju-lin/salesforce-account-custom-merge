public class AccountMergeHelper {
    
    public List<Account> getDuplicateAccounts(Id currentAccountId, List<String> fields) {
        // Retrieve the DuplicateRecordSetIds for the current account ID
        Set<Id> duplicateRecordSetIds = new Set<Id>();
        for (DuplicateRecordItem item : [
            SELECT DuplicateRecordSetId
            FROM DuplicateRecordItem
            WHERE RecordId = :currentAccountId
        ]) {
            duplicateRecordSetIds.add(item.DuplicateRecordSetId);
        }

        // Construct the dynamic query string based on the selected fields
        String queryFields = 'Id, ';
        for (String field : fields) {
            queryFields += field + ', ';
        }
        queryFields = queryFields.removeEnd(', ');

        // Retrieve the duplicate account records related to the DuplicateRecordSetIds
        List<Account> duplicateAccounts = Database.query(''
            + 'SELECT ' + queryFields + ' '
            + 'FROM Account '
            + 'WHERE Id IN ('
                + 'SELECT RecordId '
                + 'FROM DuplicateRecordItem '
                + 'WHERE DuplicateRecordSetId IN :duplicateRecordSetIds'
            + ') '
            + 'AND Id != :currentAccountId'
        );

        return duplicateAccounts;
    }
}