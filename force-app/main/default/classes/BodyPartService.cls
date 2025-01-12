/******************************************************************
 * @description Body Part Service
 * 
 * @author SerkinSolutions
 * @date 2025
 ******************************************************************/
public with sharing class BodyPartService {

    /**
     * Update body part record names to the default convention
     */
    public static void updateRecordNames(List<Body_Part__c> newList) {
        updateRecordNames(newList, null);
    }
    
    /**
     * Update record names for updated records - filters on changed artist values
     */
    public static void updateRecordNames(List<Body_Part__c> newList, Map<Id, Body_Part__c> oldMap) {
        List<Body_Part__c> bodyPartsToReName = new List<Body_Part__c>();

        if (oldMap == null) {
            bodyPartsToReName.addAll(newList);
        } else {
            // Identify parts with changed artists to re-name
            bodyPartsToReName.addAll( filterToChangedArtists(newList, oldMap) );
        }

        if (!bodyPartsToRename.isEmpty()) {
            BodyPartNamer.autoName(bodyPartsToReName);
        }
    }

    private static List<Body_Part__c> filterToChangedArtists(List<Body_Part__c> newList, Map<Id, Body_Part__c> oldMap) {
        List<Body_Part__c> filteredParts = new List<Body_Part__c>();
        for (Body_Part__c bp : newList) {
            if (bp.Artist__c != oldMap.get(bp.Id).Artist__c) {
                filteredParts.add(bp);
            }
        }
        return filteredParts;
    }

}