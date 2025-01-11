public with sharing class BodyPartTriggerHandler extends TriggerHandler {

    private List<Body_Part__c> newList;

    public BodyPartTriggerHandler() {
        this.newList = (List<Body_Part__c>) Trigger.new;
    }

    public override void beforeInsert() {
        BodyPartNamer.autoName(newList);
    }

    public override void beforeUpdate() {
        // Identify parts with changed artists to re-name
        Map<Id, Body_Part__c> oldMap = (Map<Id, Body_Part__c>) Trigger.oldMap;
        List<Body_Part__c> bodyPartsWithChangedArtist = new List<Body_Part__c>();
        for (Body_Part__c bp : newList) {
            if (bp.Artist__c != oldMap.get(bp.Id).Artist__c) {
                bodyPartsWithChangedArtist.add(bp);
            }
        }

        if (!bodyPartsWithChangedArtist.isEmpty()) {
            BodyPartNamer.autoName(bodyPartsWithChangedArtist);
        }
    }

}