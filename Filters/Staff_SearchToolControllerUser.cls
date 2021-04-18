public with sharing class Staff_SearchToolControllerUser {
    @AuraEnabled (Cacheable = true)
    public static List<Staff_Application__c> getStaffApplications(List<String> fields, String jsonFilters, String activeStatus) {
        return Staff_ApplicationService.getApplicationsByActiveStatus(fields, jsonFilters, activeStatus);
    }

    @AuraEnabled (Cacheable = true)
    public static Contact getContact(String contactId, List<String> fields) {
        if (String.isBlank(contactId) || fields == null || fields.isEmpty()) return null;

        List<Contact> contacts = ContactManager.getByIds(new Set<Id> {contactId}, new Set<String> (fields));

        return contacts.isEmpty() ? null : contacts.get(0);
    }
}