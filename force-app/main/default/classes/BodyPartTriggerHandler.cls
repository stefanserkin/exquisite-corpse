public with sharing class BodyPartTriggerHandler extends TriggerHandler {

    private List<Body_Part__c> newList;

    public BodyPartTriggerHandler() {
        this.newList = (List<Body_Part__c>) Trigger.new;
    }

    public override void beforeInsert() {
        for (Body_Part__c bp : newList) {
            bp.Name = 'I am a body part';
        }
    }

}