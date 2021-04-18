public interface Staff_ISearchFilter {
    String toSoqlView();
    Integer getPriority();
    Boolean isExpression();
}