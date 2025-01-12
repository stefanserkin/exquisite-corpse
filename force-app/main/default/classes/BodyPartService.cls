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

    /**
     * Save a new drawing for a body part
     */
    public static void saveFile(Id bodyPartId, String fileData) {
        try {
            // Remove the data:image/png;base64, prefix
            String base64Data = fileData.split(',')[1];
            Blob imageBlob = EncodingUtil.base64Decode(base64Data);

            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = 'BodyPartDrawing_' + bodyPartId;
            contentVersion.PathOnClient = 'BodyPartDrawing.png';
            contentVersion.VersionData = imageBlob;
            Database.insert(contentVersion, AccessLevel.USER_MODE);

            ContentDocument contentDocument = [
                SELECT Id 
                  FROM ContentDocument 
                 WHERE Id IN (SELECT ContentDocumentId 
                                FROM ContentVersion 
                               WHERE Id = :contentVersion.Id)
                  WITH USER_MODE
                 LIMIT 1
            ];

            ContentDocumentLink link = new ContentDocumentLink();
            link.ContentDocumentId = contentDocument.Id;
            link.LinkedEntityId = bodyPartId;
            link.ShareType = 'I';
            link.Visibility = 'AllUsers';
            Database.insert(link, AccessLevel.SYSTEM_MODE);

            Body_Part__c bodyPart = new Body_Part__c(Id = bodyPartId, Status__c = 'Complete');
            Database.update(bodyPart, AccessLevel.SYSTEM_MODE);
        } catch (Exception e) {
            throw new ExquisiteCorpseException('Error saving file: ' + e.getMessage());
        }
    }

}