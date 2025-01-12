/******************************************************************
 * @description Exquisite Corpse Service
 * 
 * @author SerkinSolutions
 * @date 2025
 ******************************************************************/
public with sharing class ExquisiteCorpseService {
    
    /**
     * Stamp the completed date/time for newly completed corpses
     */
    public static void handleCompletedCorpses(List<Exquisite_Corpse__c> newMap, Map<Id, Exquisite_Corpse__c> oldMap) {
        for (Exquisite_Corpse__c corpse : newMap.values()) {
            if (corpse.Status__c == STATUS_COMPLETE && oldMap.get(corpse.Id).Status__c != STATUS_COMPLETE) {
                corpse.Completed_Date_Time__c = Datetime.now();
            }
        }
    }

}