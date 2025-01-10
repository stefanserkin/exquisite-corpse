public with sharing class BodyPartCanvasController {
    
    @AuraEnabled
    public static void saveFile(Id bodyPartId, String fileData) {
        // Validate input
        if (bodyPartId == null || String.isEmpty(fileData)) {
            throw new AuraHandledException('Invalid parameters provided.');
        }

        try {
            // Decode the Base64 image data
            String base64Data = fileData.split(',')[1]; // Remove the data:image/png;base64, prefix
            Blob imageBlob = EncodingUtil.base64Decode(base64Data);

            // Create a new ContentVersion record
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = 'BodyPartDrawing_' + bodyPartId;
            contentVersion.PathOnClient = 'BodyPartDrawing.png';
            contentVersion.VersionData = imageBlob;
            insert contentVersion;

            // Retrieve the ContentDocumentId
            ContentDocument contentDocument = [
                SELECT Id FROM ContentDocument WHERE Id IN (
                    SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id
                ) LIMIT 1
            ];

            // Link the file to the Body Part record
            ContentDocumentLink link = new ContentDocumentLink();
            link.ContentDocumentId = contentDocument.Id;
            link.LinkedEntityId = bodyPartId;
            link.ShareType = 'I'; // 'I' for Inferred permissions
            link.Visibility = 'AllUsers';
            insert link;
        } catch (Exception ex) {
            throw new AuraHandledException('Error saving file: ' + ex.getMessage());
        }
    }
    
}