public class Staff_StatementFilter implements Staff_ISearchFilter, Staff_IExpression {
    public enum DataType { StringType, DataType }
    public enum StatementOperator {
        None, Equal, NotEqualTo, Contains, DoesNotContain, LessThan,
        GreaterThan, LessOrEqual, GreaterOrEqual, Exist, NotExist, equalNull, notEqualNull
    }

    public DataType type { get; private set; }
    public String sfApiName { get; private set; }
    public StatementOperator operator { get; private set; }
    public String value { get; private set; }
    public String existSeparator { get; private set; }

    public Staff_StatementFilter(DataType type, String sfApiName, StatementOperator operator, String value) {
        if (type == null || String.isBlank(sfApiName) || operator == null) {
            throw new Staff_Searcher.Staff_SearcherException(Staff_Constants.ERROR_CANNOT_CREATE_STATEMENT_FILTER);
        }

        this.type = type;
        this.sfApiName = sfApiName;
        this.operator = operator;
        this.value = value;
    }

    public Staff_StatementFilter(DataType type, String sfApiName, StatementOperator operator, String value, String separator) {
        this(type, sfApiName, operator, value);
        this.existSeparator = separator;
    }

    public String toSoqlView() {
        if (String.isBlank(value) && !(operator == StatementOperator.equalNull || operator == StatementOperator.notEqualNull)) return '';

        switch on operator {
            when None {
                return ' ';
            }
            when equalNull, notEqualNull {
                value = Staff_Constants.SOQL_NULL;
                return getDataTypeStringView();
            }
        }

        switch on type {
            when StringType {
                switch on operator {
                    when DoesNotContain {
                        return getNotContainStringView();
                    }
                    when Exist, NotExist {
                        return getExistStringView();
                    }
                    when else {
                        return getCommonStringView();
                    }
                }
            }
            when DataType {
                return getDataTypeStringView();
            }
        }

        return '';
    }

    public Integer getPriority() {
        return Staff_Constants.FILTER_PRIORITY_MAP.get(Staff_StatementFilter.class.getName());
    }

    public Boolean isExpression() {
        return true;
    }

    private String wrapValueInQuote(String value) {
        return (operator == StatementOperator.Contains || operator == StatementOperator.DoesNotContain)
                ? '\'%' + value + '%\''
                : '\'' + value + '\'';
    }

    private String getCommonStringView() {
        return sfApiName + ' ' + Staff_Constants.OPERATOR_TO_SOQL_STRING.get(operator) + ' ' + wrapValueInQuote(value);
    }

    private String getNotContainStringView() {
        return '( ' + Staff_Constants.SOQL_NOT + ' ' + getCommonStringView() + ' )';
    }

    private String getExistStringView() {
        if (existSeparator == null) return sfApiName + ' ' + Staff_Constants.OPERATOR_TO_SOQL_STRING.get(operator) + '( ' + value + ' )';

        String soqlView = sfApiName + ' ' + Staff_Constants.OPERATOR_TO_SOQL_STRING.get(operator) + '( ';
        List<String> values = value.split(existSeparator);

        for (String valueVariant : values) {
            soqlView += wrapValueInQuote(valueVariant) + ',';
        }

        return soqlView.removeEnd(',') + ' )';
    }

    private String getDataTypeStringView() {
        return sfApiName + ' ' + Staff_Constants.OPERATOR_TO_SOQL_STRING.get(operator) + ' ' + value;
    }

    public class Wrapper implements Staff_IFilterWrapper {
        @AuraEnabled public String type;
        @AuraEnabled public String sfApiName;
        @AuraEnabled public String operator;
        @AuraEnabled public String value;
        @AuraEnabled public String separator;

        public Staff_ISearchFilter toFilter() {
            return (Staff_StatementFilter) getFilterObj();
        }

        public Object getFilterObj() {
            return new Staff_StatementFilter(
                    Staff_Constants.STATEMENT_FILTER_TYPE_TO_STRING.get(type),
                    sfApiName,
                    Staff_Constants.STRING_TO_OPERATOR.get(operator),
                    value,
                    separator
            );
        }
    }
}