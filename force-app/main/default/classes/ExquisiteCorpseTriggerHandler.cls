/******************************************************************
 * @description Trigger handler for the Exquisite Corpse object
 * 
 * @author SerkinSolutions
 * @date 2025
 ******************************************************************/
public with sharing class ExquisiteCorpseTriggerHandler extends TriggerHandler {

    private ExquisiteCorpseService exquisiteCorpseService;

    public ExquisiteCorpseTriggerHandler() {
        List<Exquisite_Corpse__c> newList = (List<Exquisite_Corpse__c>) Trigger.new;
        Map<Id, Exquisite_Corpse__c> oldMap = (Map<Id, Exquisite_Corpse__c>) Trigger.oldMap;
        this.exquisiteCorpseService = new ExquisiteCorpseService(newList, oldMap);
    }
    
    public override void beforeUpdate() {
        // Stamp the completed date/time for newly completed corpses
        this.exquisiteCorpseService.handleCompletedCorpses();
    }

    public override void afterUpdate() {
        // Update names of child body parts if relevant details have changed
        this.exquisiteCorpseService.renameBodyParts();
    }

}