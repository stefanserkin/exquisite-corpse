/************************************************************************
 * @description Save image files for the body part canvas lwc
 * 
 * @author SerkinSolutions
 * @date 2025
 ************************************************************************/
public with sharing class BodyPartCanvasController {
    
    @AuraEnabled
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
            Database.insert(link, AccessLevel.USER_MODE);

            Body_Part__c bodyPart = new Body_Part__c(Id = bodyPartId, Status__c = 'Complete');
            Database.update(bodyPart, AccessLevel.USER_MODE);
        } catch (Exception e) {
            throw new AuraHandledException('Error saving file: ' + e.getMessage());
        }
    }
    
}