/******************************************************************
 * @description Trigger handler for the Body Part object
 * 
 * @author SerkinSolutions
 * @date 2025
 ******************************************************************/
public with sharing class BodyPartTriggerHandler extends TriggerHandler {

    private BodyPartService bodyPartService;

    public BodyPartTriggerHandler() {
        List<Body_Part__c> newList = (List<Body_Part__c>) Trigger.new;
        Map<Id, Body_Part__c> oldMap = (Map<Id, Body_Part__c>) Trigger.oldMap;
        this.bodyPartService = new BodyPartService(newList, oldMap);
    }

    public override void beforeInsert() {
        // Auto-name records based on related context
        this.bodyPartService.updateRecordNames();
    }

    public override void beforeUpdate() {
        // Sync artist user to owner field
        // this.bodyPartService.syncArtistToOwner(newList, oldMap);

        // Auto-name records based on related context
        this.bodyPartService.updateRecordNames();
    }

    public override void afterUpdate() {
        // Handle related actions for newly completed body part records
        this.bodyPartService.handleStatusCompleted();
    }

}