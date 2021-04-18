public with sharing class Staff_FiltersWrapper {
    @AuraEnabled public List<Staff_Expression.Wrapper> expressions;
    @AuraEnabled public List<Staff_StatementFilter.Wrapper> statements;
    @AuraEnabled public List<Staff_ResultFilter.Wrapper> results;
    @AuraEnabled public Staff_OrderFilter.Wrapper order;

    public Staff_FiltersWrapper() {
        expressions = new List<Staff_Expression.Wrapper>();
        statements = new List<Staff_StatementFilter.Wrapper>();
        results = new List<Staff_ResultFilter.Wrapper>();
    }

    public List<Staff_ISearchFilter> toFilters() {
        List<Staff_ISearchFilter> allFilters = new List<Staff_ISearchFilter>();
        List<Staff_IFilterWrapper> wrappers = new List<Staff_IFilterWrapper>();

        wrappers.addAll(expressions);
        wrappers.addAll(statements);
        wrappers.addAll(results);
        wrappers.add(order);

        for (Staff_IFilterWrapper wrapper: wrappers) {
            if (wrapper != null) {
                allFilters.add(wrapper.toFilter());
            }
        }

        return allFilters;
    }
}