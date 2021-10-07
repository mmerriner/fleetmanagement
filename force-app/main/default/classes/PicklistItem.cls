public with sharing class PicklistItem {
    public PicklistItem(string itemLabel, string itemValue) {
        value = itemValue;
        label = itemLabel;
    }

    @AuraEnabled
    public string label { get; set; }

    @AuraEnabled
    public string value { get; set; }
}