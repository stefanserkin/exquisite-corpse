/******************************************************************
 * @description Trigger handler for the Body Part object
 * 
 * @author SerkinSolutions
 * @date 2025
 ******************************************************************/
public with sharing class BodyPartTriggerHandler extends TriggerHandler {

    private List<Body_Part__c> newList;
    private Map<Id, Body_Part__c> oldMap;

    public BodyPartTriggerHandler() {
        this.newList = (List<Body_Part__c>) Trigger.new;
        this.oldMap = (Map<Id, Body_Part__c>) Trigger.oldMap;
    }

    public override void beforeInsert() {
        // Auto-name records based on related context
        BodyPartService.updateRecordNames(newList);
    }

    public override void beforeUpdate() {
        // Auto-name records based on related context
        BodyPartService.updateRecordNames(newList, oldMap);
    }

}