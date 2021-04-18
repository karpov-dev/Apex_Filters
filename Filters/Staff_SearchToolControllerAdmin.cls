public without sharing class Staff_SearchToolControllerAdmin {
    @AuraEnabled
    public static Id associateApplication(Id appId) {
        return Staff_TORelationService.activateOrCreateByRoleId(appId, UserInfo.getUserRoleId()).Id;
    }

    @AuraEnabled (Cacheable = true)
    public static List<Contact> getContacts(List<String> fields, String jsonFilters) {
        return Staff_ContactManager.getContactsByJsonFilters(new Set<String> (fields), jsonFilters);
    }

    @AuraEnabled
    public static Id getContactIdByFilters(String jsonFilters) {
        List<Contact> contacts = Staff_ContactManager.getContactsByJsonFilters(new Set<String> {'Id'}, jsonFilters);

        return contacts.size() == 1
                ? contacts[0].Id
                : null;
    }

    @AuraEnabled
    public static Boolean sentStaffInvite(Id contactId) {
        if (String.isBlank(contactId)) return false;

        Id templateId = AssignScreen_Manager.getEmailTemplate(Staff_Constants.INVITATION_STAFF_TEMPLATE_DEV_NAME).Id;
        String staffOrgWideAddress = Constants.ORG_WIDE_EMAIL_TAGLIT_STAFF;
        return EmailService.sentEmail(templateId, UserInfo.getUserId(), contactId, null, staffOrgWideAddress);
    }

    @AuraEnabled
    public static Id findOrCreateContact(Contact contact, String jsonFilters) {
        if (contact == null) return null;

        contact.Id = getContactIdByFilters(jsonFilters);
        if (String.isBlank(contact.Id)) {
            insert contact;
        }

        return contact.Id;
    }
}