public with sharing class Staff_Searcher {
    public static String generateString(String objApiName, Set<String> fields, List<Staff_ISearchFilter> filters) {
        if (String.isBlank(objApiName) || fields == null || fields.isEmpty()) {
            throw new Staff_SearcherException(Staff_Constants.ERROR_INVALID_PARAMS_TO_SEARCH);
        }

        String soqlString = Staff_Constants.SOQL_SELECT + ' ' + String.join(new List<String>(fields), ', ') + ' ' + Staff_Constants.SOQL_FROM + ' ' + objApiName;
        if (!(filters == null || filters.isEmpty())) {
            soqlString += toSoqlView(filters);
        }

        return soqlString.normalizeSpace();
    }

    private static String toSoqlView(List<Staff_ISearchFilter> filters) {
        String[] separatedFilters = separateFiltersByPriority(filters);

        return String.join(separatedFilters, ' ');
    }

    private static String[] separateFiltersByPriority(List<Staff_ISearchFilter> filters) {
        String[] queryElements = new String[Staff_Constants.FILTER_PRIORITY_MAP.size()];

        for (Staff_ISearchFilter filter : filters) {
            Integer priority = filter.getPriority();

            if (String.isBlank(queryElements[priority])) {
                queryElements[priority] = getSoqlView(filter, Staff_Constants.SOQL_WHERE);
            } else {
                queryElements[priority] += getSoqlView(filter, Staff_Constants.SOQL_AND);
            }
        }

        return queryElements;
    }

    private static String getSoqlView(Staff_ISearchFilter filter, String relation) {
        String queryView = filter.toSoqlView();

        return filter.isExpression() && !String.isBlank(queryView)
                ? ' ' + relation + ' ' + queryView
                : queryView;
    }

    public class Staff_SearcherException extends Exception { }
}