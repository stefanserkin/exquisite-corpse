/******************************************************************
 * @description Body Part Service
 * 
 * @author SerkinSolutions
 * @date 2025
 ******************************************************************/
public with sharing class BodyPartService {

    /**
     * Get ordered body parts for an exquisite corpse
     */
    public static List<BodyPart> getCorpseBodyParts(Id exquisiteCorpseId) {
        List<BodyPart> bodyParts = new List<BodyPart>();
        for (Body_Part__c sobj : queryForBodyParts(exquisiteCorpseId)) {
            bodyParts.add( new BodyPart(sobj) );
        }
        return bodyParts;
    }

    private static List<Body_Part__c> queryForBodyParts(Id exquisiteCorpseId) {
        return [
            SELECT Id, Name, Sort_Order__c, Status__c, Artist__c, 
                   Body_Part_Type__r.Name, Exquisite_Corpse__r.Name, Exquisite_Corpse__r.Status__c, 
                   Artist__r.FirstName, Artist__r.LastName, Artist__r.Email
              FROM Body_Part__c
             WHERE Exquisite_Corpse__c = :exquisiteCorpseId
              WITH SYSTEM_MODE
             ORDER BY Sort_Order__c ASC
        ];
    }


    /**
     * Gets the most recently saved image file linked to the body part record id
     */
    public static String getLatestFile(Id bodyPartId) {
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId 
              FROM ContentDocumentLink 
             WHERE LinkedEntityId = :bodyPartId 
              WITH SYSTEM_MODE
        ];

        if (links.isEmpty()) {
            throw new ExquisiteCorpseException('There are no files associated with record id ' + bodyPartId);
        }

        Set<Id> contentDocumentIds = new Set<Id>();
        for (ContentDocumentLink link : links) {
            contentDocumentIds.add(link.ContentDocumentId);
        }

        ContentVersion contentVersion = [
            SELECT VersionData 
              FROM ContentVersion 
             WHERE ContentDocumentId IN :contentDocumentIds
              WITH SYSTEM_MODE
             ORDER BY CreatedDate DESC
             LIMIT 1
        ];

        return EncodingUtil.base64Encode(contentVersion.VersionData);
    }


    /**
     * Save a new drawing for a body part
     * @return Content document id
     */
    public static Id saveFile(Id bodyPartId, String fileData) {
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
            return contentDocument.Id;
        } catch (Exception e) {
            throw new ExquisiteCorpseException('Error saving file: ' + e.getMessage());
        }
    }


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