/******************************************************************
 * @description Trigger handler for the Exquisite Corpse object
 * 
 * @author SerkinSolutions
 * @date 2025
 ******************************************************************/
public with sharing class ExquisiteCorpseTriggerHandler extends TriggerHandler {

    private static final String STATUS_COMPLETE = 'Complete';

    private Map<Id, Exquisite_Corpse__c> newMap;
    private Map<Id, Exquisite_Corpse__c> oldMap;

    public ExquisiteCorpseTriggerHandler() {
        this.newMap = (Map<Id, Exquisite_Corpse__c>) Trigger.newMap;
        this.oldMap = (Map<Id, Exquisite_Corpse__c>) Trigger.oldMap;
    }
    
    public override void beforeUpdate() {
        // Stamp the completed date/time for newly completed corpses
        ExquisiteCorpseService.handleCompletedCorpses(newMap.values(), oldMap);
    }

}