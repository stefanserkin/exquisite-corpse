/******************************************************************
 * @description When a body part record is completed, handle related actions
 *   - If additional body parts are waiting, update the next record's status to In Progress
 *   - If no additional body parts are waiting, update the corpse status to Complete
 * 
 * @author SerkinSolutions
 * @date 2025
 ******************************************************************/
public without sharing class BodyPartCompletionHandler {
    
    private static final String STATUS_COMPLETE = 'Complete';
    private static final String STATUS_IN_PROGRESS = 'In Progress';
    private static final String STATUS_WAITING = 'Waiting';

    private List<Body_Part__c> completedBodyParts;
    private List<Body_Part__c> bodyPartsToUpdate;
    private List<Exquisite_Corpse__c> completedCorpses;
    
    public BodyPartCompletionHandler(List<Body_Part__c> completedBodyParts) {
        this.completedBodyParts = completedBodyParts;
        this.bodyPartsToUpdate = new List<Body_Part__c>();
        this.completedCorpses = new List<Exquisite_Corpse__c>();
    }

    public void run() {
        List<Exquisite_Corpse__c> corpsesWithNextPart = getCorpsesWithNextBodyPart();
        for (Exquisite_Corpse__c corpse : getCorpsesWithNextBodyPart()) {
            if (!corpse.Body_Parts__r.isEmpty()) {
                Body_Part__c nextPart = corpse.Body_Parts__r[0];
                nextPart.Status__c = STATUS_IN_PROGRESS;
                bodyPartsToUpdate.add(nextPart);
            } else {
                corpse.Status__c = STATUS_COMPLETE;
                completedCorpses.add(corpse);
            }
        }
        commitChanges();
    }

    private List<Exquisite_Corpse__c> getCorpsesWithNextBodyPart() {
        Set<Id> corpseIds = getCorpseIds();
        return [
            SELECT Id, Status__c, 
                   (SELECT Id, Status__c 
                      FROM Body_Parts__r 
                     WHERE Status__c = :STATUS_WAITING 
                     ORDER BY Sort_Order__c ASC 
                     LIMIT 1)
              FROM Exquisite_Corpse__c
             WHERE Id IN :corpseIds
              WITH SYSTEM_MODE
        ];
    }

    private Set<Id> getCorpseIds() {
        Set<Id> corpseIds = new Set<Id>();
        for (Body_Part__c bp : completedBodyParts) {
            corpseIds.add(bp.Exquisite_Corpse__c);
        }
        return corpseIds;
    }

    private void commitChanges() {
        List<SObject> sobjectsToUpdate = new List<SObject>();
        sobjectsToUpdate.addAll(bodyPartsToUpdate);
        sobjectsToUpdate.addAll(completedCorpses);
        Database.update(sobjectsToUpdate, AccessLevel.SYSTEM_MODE);
    }

}