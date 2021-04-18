public class Staff_OrderFilter implements Staff_ISearchFilter {
    public enum OrderDirection { Direction_ASC, Direction_DESC }
    public enum NullsDirection { First, Last }

    public String sfApiName { get; private set; }
    public OrderDirection direction { get; private set; }
    public NullsDirection directionNulls { get; private set; }

    public Staff_OrderFilter(String sfApiFieldName, OrderDirection direction) {
        if (String.isBlank(sfApiFieldName) || direction == null) {
            throw new Staff_Searcher.Staff_SearcherException(Staff_Constants.ERROR_CANNOT_CREATE_ORDER_FILTER);
        }

        this.sfApiName = sfApiFieldName;
        this.direction = direction;
    }

    public Staff_OrderFilter(String sfApiFieldName, OrderDirection direction, NullsDirection directionNulls) {
        this(sfApiFieldName, direction);

        if (directionNulls == null) {
            throw new Staff_Searcher.Staff_SearcherException(Staff_Constants.ERROR_CANNOT_CREATE_ORDER_FILTER);
        }
        this.directionNulls = directionNulls;
    }

    public String toSoqlView() {
        return directionNulls != null
                ? directionToString() + ' ' + nullsToString()
                : directionToString();
    }

    public Integer getPriority() {
        return Staff_Constants.FILTER_PRIORITY_MAP.get(Staff_OrderFilter.class.getName());
    }

    public Boolean isExpression() {
        return false;
    }

    private String directionToString() {
        return Staff_Constants.SOQL_ORDER_BY + ' ' + sfApiName + ' ' + Staff_Constants.ORDER_DIRECTION_TO_STRING.get(direction);
    }

    private String nullsToString() {
        return Staff_Constants.SOQL_NULLS + ' ' + Staff_Constants.NULLS_DIRECTION_TO_STRING.get(directionNulls);
    }

    public class Wrapper implements Staff_IFilterWrapper{
        @AuraEnabled public String sfFieldApiName;
        @AuraEnabled public String direction;
        @AuraEnabled public String directionNulls;

        public Staff_ISearchFilter toFilter() {
            return (Staff_ISearchFilter) getFilterObj();
        }

        public Object getFilterObj() {
            Staff_OrderFilter.OrderDirection orderDirection = Staff_Constants.STRING_TO_ORDER_DIRECTION.get(direction);
            Staff_OrderFilter.NullsDirection nullsDirection = Staff_Constants.STRING_TO_NULLS_DIRECTION.get(directionNulls);

            return nullsDirection != null
                    ? new Staff_OrderFilter(sfFieldApiName, orderDirection, nullsDirection)
                    : new Staff_OrderFilter(sfFieldApiName, orderDirection);
        }
    }
}