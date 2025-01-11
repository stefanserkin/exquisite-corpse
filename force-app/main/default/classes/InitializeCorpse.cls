public with sharing class InitializeCorpse {
    
    /*
    public static void fromBodyType(List<Exquisite_Corpse__c> newList) {
        Map<Id, Body_Type__c> bodyTypeMap = getBodyTypeMap(newList);

    }

    private static Map<Id, Body_Type__c> getBodyTypeMap(List<Exquisite_Corpse__c> corpses) {
        Set<Id> bodyTypeIds = new Set<Id>();
        for (Exquisite_Corpse__c corpse : newList) {
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