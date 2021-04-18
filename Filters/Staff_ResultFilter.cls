public class Staff_ResultFilter implements Staff_ISearchFilter {
    public enum ResultOperator { LimitOperator, OffsetOperator }

    public ResultOperator operator { get; private set; }
    public Integer value { get; private set; }

    public Staff_ResultFilter(ResultOperator operator, Integer value) {
        if (operator == null || value == null) {
            throw new Staff_Searcher.Staff_SearcherException(Staff_Constants.ERROR_CANNOT_CREATE_RESULT_FILTER);
        }

        this.operator = operator;
        this.value = value;
    }

    public String toSoqlView() {
        return Staff_Constants.RESULT_OPERATOR_TO_STRING.get(operator) + ' ' + String.valueOf(value);
    }

    public Integer getPriority() {
        switch on operator {
            when LimitOperator {
                return Staff_Constants.FILTER_PRIORITY_MAP.get(Staff_ResultFilter.class.getName() + ' ' + Staff_Constants.SOQL_LIMIT);
            }
            when OffsetOperator {
                return Staff_Constants.FILTER_PRIORITY_MAP.get(Staff_ResultFilter.class.getName() + ' ' + Staff_Constants.SOQL_OFFSET);
            }
        }

        return -1;
    }

    public Boolean isExpression() {
        return false;
    }

    public class Wrapper implements Staff_IFilterWrapper{
        @AuraEnabled public String operator;
        @AuraEnabled public String value;

        public Staff_ISearchFilter toFilter() {
            return (Staff_ISearchFilter) getFilterObj();
        }

        public Object getFilterObj() {
            return new Staff_ResultFilter(Staff_Constants.STRING_TO_RESULT_OPERATOR.get(operator), Integer.valueOf(value));
        }
    }
}