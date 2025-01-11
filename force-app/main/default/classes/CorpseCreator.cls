public with sharing class CorpseCreator {

    /*
    private List<Exquisite_Corpse__c> corpses;
    private Map<Id, Body_Type__c> bodyTypesWithParts;

    public CorpseCreator(List<Exquisite_Corpse__c> corpses) {
        this.corpses = corpses;
        this.bodyTypesWithParts = loadBodyTypeMap();
    }

    public static List<Body_Part__c> createBodyParts() {
        List<Body_Part__c> bodyParts = new List<Body_Part__c>();
        for (Exquisite_Corpse__c corpse : corpses) {
            Body_Type__c bodyType = bodyTypesWithParts.get(corpse.Body_Type__c);
            for (Body_Part_Type__c bpt : bodyType.Body_Part_Types__r) {
                bodyParts.add(
                    new Body_Part__c(
                        Exquisite_Corpse__c = corpse.Id,
                        Body_Part_Type__c = bpt.Id
                    )
                );
            }
        }
        insert bodyParts;
        return bodyParts;
    }

    private static Map<Id, Body_Type__c> loadBodyTypeMap() {
        Set<Id> bodyTypeIds = new Set<Id>();
        for (Exquisite_Corpse__c corpse : corpses) {
            bodyTypeIds.add(corpse.Body_Type__c);
        }

        return new Map<Id, Body_Part__c>([
            SELECT Id, Name,
                   (SELECT Id, Name, Sort_Order__c FROM Body_Part_Types__r)
              FROM Body_Type__c
             WHERE Id IN :bodyTypeIds
        ]);
    }
        */
}