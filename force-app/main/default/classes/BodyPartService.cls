/******************************************************************
 * @description Body Part Service
 * 
 * @author SerkinSolutions
 * @date 2025
 ******************************************************************/
public with sharing class BodyPartService {

    private static final String STATUS_COMPLETE = 'Complete';
    private static final String FILE_NAME_PREFIX = 'BodyPartDrawing_';

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

    /**
     * Gets the most recently saved image file linked to the body part record id
     */
    public static String getLatestFile(Id bodyPartId) {
        Id contentDocumentId = getMostRecentContentDocumentId(bodyPartId);

        if (contentDocumentId == null) {
            throw new ExquisiteCorpseException('There are no files associated with record id ' + bodyPartId);
        }

        ContentVersion contentVersion = getContentVersion(contentDocumentId);
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
            contentVersion.Title = FILE_NAME_PREFIX + String.valueOf(bodyPartId);
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
     * Handle associated actions when a body part status is changed to Complete
     */
    public static void handleStatusCompleted(List<Body_Part__c> newList, Map<Id, Body_Part__c> oldMap) {
        List<Body_Part__c> completedParts = filterToNewlyCompleted(newList, oldMap);
        if (!completedParts.isEmpty()) {
            new BodyPartCompletionHandler(completedParts).run();
        }
    }

    private static List<Body_Part__c> filterToNewlyCompleted(List<Body_Part__c> newList, Map<Id, Body_Part__c> oldMap) {
        List<Body_Part__c> filteredParts = new List<Body_Part__c>();
        for (Body_Part__c bp : newList) {
            if (bp.Status__c == STATUS_COMPLETE && oldMap.get(bp.Id).Status__c != STATUS_COMPLETE) {
                filteredParts.add(bp);
            }
        }
        return filteredParts;
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
        List<Body_Part__c> bodyPartsToRename = new List<Body_Part__c>();

        if (oldMap == null) {
            bodyPartsToRename.addAll(newList);
        } else {
            // Identify parts with changed artists to re-name
            bodyPartsToRename.addAll( filterToChangedArtists(newList, oldMap) );
        }

        if (!bodyPartsToRename.isEmpty()) {
            BodyPartNamer.autoName(bodyPartsToRename);
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

    /******************************************************************
     * Data retrieval
     ******************************************************************/

    /**
     * Get body parts for an exquisite corpse id
     */
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
     * Get the most recent content document linked to an sobject record id
     */
    private static Id getMostRecentContentDocumentId(Id linkedEntityId) {
        Id contentDocumentId;

        List<AggregateResult> ars = [
            SELECT MAX(ContentDocumentId) docId
              FROM ContentDocumentLink 
             WHERE LinkedEntityId = :linkedEntityId 
               AND ContentDocument.Title LIKE 'BodyPartDrawing_%'
        ];

        if (ars != null && !ars.isEmpty()) {
            contentDocumentId = (Id) ars[0].get('docId');
        }

        return contentDocumentId;
    }

    /**
     * Get the most recently created content version for a set of contentDocumentIds
     */
    private static ContentVersion getContentVersion(Id contentDocumentId) {
        return [
            SELECT VersionData 
              FROM ContentVersion 
             WHERE ContentDocumentId = :contentDocumentId
              WITH SYSTEM_MODE
             ORDER BY CreatedDate DESC
             LIMIT 1
        ];
    }

}