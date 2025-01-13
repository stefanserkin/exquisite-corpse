/******************************************************************
 * @description Handle naming of new body part records
 * 
 * @author SerkinSolutions
 * @date 2025
 ******************************************************************/
public with sharing class BodyPartNamer {

    private List<Body_Part__c> bodyParts;
    private Map<Id, Exquisite_Corpse__c> corpseMap;
    private Map<Id, Body_Part_Type__c> bodyPartTypeMap;
    private Map<Id, User> userMap;

    public BodyPartNamer(List<Body_Part__c> bodyParts) {
        this.bodyParts = bodyParts;
        loadMaps();
    }

    public List<Body_Part__c> autoName() {
        for (Body_Part__c bp : bodyParts) {
            bp.Name = constructBodyPartName(bp);
        }
        return bodyParts;
    }

    private String constructBodyPartName(Body_Part__c bodyPart) {
        Body_Part_Type__c partType = bodyPartTypeMap.get(bodyPart.Body_Part_Type__c);
        Exquisite_Corpse__c corpse = corpseMap.get(bodyPart.Exquisite_Corpse__c);
        String newName = corpse.Name + ' ' + partType.Name;
        if (bodyPart.Artist__c != null && userMap.containsKey(bodyPart.Artist__c)) {
            newName += ' - ' + userMap.get(bodyPart.Artist__c).FirstName;
        }
        return newName.left(80);
    }

    /**
     * Base data loaded in constructor
     */
    private void loadMaps() {
        this.corpseMap = getCorpseMap();
        this.bodyPartTypeMap = getBodyPartTypeMap();
        this.userMap = getUserMap();
    }

    private Map<Id, Exquisite_Corpse__c> getCorpseMap() {
        Set<Id> corpseIds = new Set<Id>();
        for (Body_Part__c bp : bodyParts) {
            corpseIds.add(bp.Exquisite_Corpse__c);
        }

        return new Map<Id, Exquisite_Corpse__c>([
            SELECT Id, Name
              FROM Exquisite_Corpse__c
             WHERE Id IN :corpseIds
        ]);
    }

    private Map<Id, Body_Part_Type__c> getBodyPartTypeMap() {
        Set<Id> bptIds = new Set<Id>();
        for (Body_Part__c bp : bodyParts) {
            bptIds.add(bp.Body_Part_Type__c);
        }

        return new Map<Id, Body_Part_Type__c>([
            SELECT Id, Name, Body_Type__r.Name
              FROM Body_Part_Type__c
             WHERE Id IN :bptIds
             ORDER BY Sort_Order__c ASC
        ]);
    }

    private Map<Id, User> getUserMap() {
        Set<Id> userIds = new Set<Id>();
        for (Body_Part__c bp : bodyParts) {
            if (bp.Artist__c != null) {
                userIds.add(bp.Artist__c);
            }
        }

        return new Map<Id, User>([
            SELECT Id, FirstName, LastName, Email
              FROM User
             WHERE Id IN :userIds
        ]);
    }

}