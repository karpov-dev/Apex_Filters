public with sharing class Staff_Expression implements Staff_ISearchFilter, Staff_IExpression {
    public enum Relation { And_Relation, Or_Relation }

    public List<Staff_IExpression> filters { get; private set; }
    public Relation relationBetweenFilters { get; private set; }

    public Staff_Expression(List<Staff_IExpression> filters, Relation relationBetweenFilters) {
        if (filters == null || relationBetweenFilters == null || filters.isEmpty()) {
            throw new Staff_Searcher.Staff_SearcherException(Staff_Constants.ERROR_CANNOT_CREATE_EXPRESSION);
        }

        this.filters = filters;
        this.relationBetweenFilters = relationBetweenFilters;
    }

    public String toSoqlView() {
        List<String> stringViews = new List<String>();

        for (Staff_IExpression filter : filters) {
            String soqlView = filter.toSoqlView();
            if (!String.isBlank(soqlView)) {
                stringViews.add(soqlView);
            }
        }

        return stringViews.isEmpty()
                ? ''
                : '( ' + String.join(stringViews, ' ' + Staff_Constants.RELATION_TO_STRING.get(relationBetweenFilters) + ' ') + ' )';
    }

    public Integer getPriority() {
        return Staff_Constants.FILTER_PRIORITY_MAP.get(Staff_Expression.class.getName());
    }

    public Boolean isExpression() {
        return true;
    }

    public class Wrapper implements Staff_IFilterWrapper {
        @AuraEnabled public String relation;
        @AuraEnabled public List<Staff_StatementFilter.Wrapper> filters;
        @AuraEnabled public List<Staff_Expression.Wrapper> expressions;


        public Staff_ISearchFilter toFilter() {
            return (Staff_ISearchFilter) getFilterObj();
        }

        public Object getFilterObj() {
            Relation expressionRelation = Staff_Constants.STRING_TO_RELATION.get(relation);
            List<Staff_IExpression> allFilters = new List<Staff_IExpression>();

            if (filters != null) {
                for (Staff_StatementFilter.Wrapper statement : filters) {
                    allFilters.add((Staff_IExpression) statement.getFilterObj());
                }
            }

            if (expressions != null) {
                for (Staff_Expression.Wrapper expression : expressions) {
                    allFilters.add((Staff_IExpression) expression.getFilterObj());
                }
            }

            return new Staff_Expression(allFilters, expressionRelation);
        }
    }
}