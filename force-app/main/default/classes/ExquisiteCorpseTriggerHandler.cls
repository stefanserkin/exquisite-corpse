/******************************************************************
 * @description Trigger handler for the Exquisite Corpse object
 * 
 * @author SerkinSolutions
 * @date 2025
 ******************************************************************/
public with sharing class ExquisiteCorpseTriggerHandler extends TriggerHandler {

    private Map<Id, Exquisite_Corpse__c> newMap;

    public ExquisiteCorpseTriggerHandler() {
        this.newMap = (Map<Id, Exquisite_Corpse__c>) Trigger.newMap;
    }
    
    public override void afterInsert() {
        System.debug('do after insert stuff');
    }

}