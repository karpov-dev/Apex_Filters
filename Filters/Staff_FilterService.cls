public with sharing class Staff_FilterService {

    public static List<Staff_ISearchFilter> wrapperToFilters(FiltersWrapper filtersWrapper) {
        if (filtersWrapper == null) return new List<Staff_ISearchFilter>();

        List<Staff_ISearchFilter> allFilters = new List<Staff_ISearchFilter>();
        List<Staff_IFilterWrapper> wrappers = new List<Staff_IFilterWrapper>();

        wrappers.addAll(filtersWrapper.expressions);
        wrappers.addAll(filtersWrapper.statements);
        wrappers.addAll(filtersWrapper.results);
        wrappers.add(filtersWrapper.order);

        for (Staff_IFilterWrapper wrapper: wrappers) {
            if (wrapper != null) {
                allFilters.add(wrapper.toFilter());
            }
        }

        return allFilters;
    }

    public class FiltersWrapper {
        @AuraEnabled public List<Staff_Expression.Wrapper> expressions;
        @AuraEnabled public List<Staff_StatementFilter.Wrapper> statements;
        @AuraEnabled public List<Staff_ResultFilter.Wrapper> results;
        @AuraEnabled public Staff_OrderFilter.Wrapper order;

        public FiltersWrapper() {
            expressions = new List<Staff_Expression.Wrapper>();
            statements = new List<Staff_StatementFilter.Wrapper>();
            results = new List<Staff_ResultFilter.Wrapper>();
        }
    }
}