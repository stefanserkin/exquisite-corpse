/******************************************************************
 * @description Exquisite Corpse Service
 * 
 * @author SerkinSolutions
 * @date 2025
 ******************************************************************/
public with sharing class ExquisiteCorpseService {

    private static final String STATUS_COMPLETE = 'Complete';

    private List<Exquisite_Corpse__c> newList;
    private Map<Id, Exquisite_Corpse__c> oldMap;

    public ExquisiteCorpseService(List<Exquisite_Corpse__c> newList, Map<Id, Exquisite_Corpse__c> oldMap) {
        this.newList = newList;
        this.oldMap = oldMap;
    }
    
    /**
     * Stamp the completed date/time for newly completed corpses
     */
    public void handleCompletedCorpses() {
        for (Exquisite_Corpse__c corpse : newList) {
            if (corpse.Status__c == STATUS_COMPLETE && oldMap.get(corpse.Id).Status__c != STATUS_COMPLETE) {
                corpse.Completed_Date_Time__c = Datetime.now();
            }
        }
    }

    /**
     * Re-name all child body parts
     */
    public void renameBodyParts() {
        List<Exquisite_Corpse__c> corpsesWithNameChanges = filterToCorpsesWithNameChanges();
        if (!corpsesWithNameChanges.isEmpty()) {
            List<Body_Part__c> bodyPartsToRename = getBodyPartsForCorpses(corpsesWithNameChanges);
            bodyPartsToRename = new BodyPartNamer(bodyPartsToRename).autoName();
            Database.update(bodyPartsToRename, AccessLevel.SYSTEM_MODE);
        }
    }

    /**
     * Filter records in trigger to corpses with name changes
     */
    private List<Exquisite_Corpse__c> filterToCorpsesWithNameChanges() {
        List<Exquisite_Corpse__c> filteredCorpses = new List<Exquisite_Corpse__c>();
        for (Exquisite_Corpse__c corpse : newList) {
            if (corpse.Name != oldMap.get(corpse.Id).Name) {
                filteredCorpses.add(corpse);
            }
        }
        return filteredCorpses;
    }

    private static List<Body_Part__c> getBodyPartsForCorpses(List<Exquisite_Corpse__c> corpses) {
        return [
            SELECT Id, Body_Part_Type__c, Artist__c, Exquisite_Corpse__c
              FROM Body_Part__c
             WHERE Exquisite_Corpse__c IN :corpses
              WITH SYSTEM_MODE
        ];
    }

}