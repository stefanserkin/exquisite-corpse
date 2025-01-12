/******************************************************************
 * @description Handle naming of new body part records
 * 
 * @author SerkinSolutions
 * @date 2025
 ******************************************************************/
public with sharing class BodyPartNamer {

    public static void autoName(List<Body_Part__c> bodyParts) {
        Map<Id, Body_Part_Type__c> bodyPartTypeMap = getBodyPartTypeMap(bodyParts);
        Map<Id, Exquisite_Corpse__c> corpseMap = getCorpseMap(bodyParts);
        Map<Id, User> userMap = getUserMap(bodyParts);
        for (Body_Part__c bp : bodyParts) {
            Body_Part_Type__c partType = bodyPartTypeMap.get(bp.Body_Part_Type__c);
            Exquisite_Corpse__c corpse = corpseMap.get(bp.Exquisite_Corpse__c);
            String newName = corpse.Name + ' ' + partType.Name;
            if (bp.Artist__c != null && userMap.containsKey(bp.Artist__c)) {
                newName += ' - ' + userMap.get(bp.Artist__c).FirstName;
            }
            bp.Name = newName.left(80);
        }
    }

    private static Map<Id, Exquisite_Corpse__c> getCorpseMap(List<Body_Part__c> bodyParts) {
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

    private static Map<Id, Body_Part_Type__c> getBodyPartTypeMap(List<Body_Part__c> bodyParts) {
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

    private static Map<Id, User> getUserMap(List<Body_Part__c> bodyParts) {
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