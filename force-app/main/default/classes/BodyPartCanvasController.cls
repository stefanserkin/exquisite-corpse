/************************************************************************
 * @description Save and retrieve image files for the body part canvas lwc
 * 
 * @author SerkinSolutions
 * @date 2025
 ************************************************************************/
public with sharing class BodyPartCanvasController {

    @AuraEnabled(cacheable=true)
    public static List<BodyPart> getCorpseBodyParts(Id corpseId) {
        try {
            return BodyPartService.getCorpseBodyParts(corpseId);
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving corpse body parts: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getLatestFile(Id bodyPartId) {
        try {
            String base64Data = BodyPartService.getLatestFile(bodyPartId);
            return base64Data;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving file: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static String saveFile(Id bodyPartId, String fileData) {
        try {
            Id contentDocumentId = BodyPartService.saveFile(bodyPartId, fileData);
            return String.valueOf(contentDocumentId);
        } catch (Exception e) {
            throw new AuraHandledException('Error saving file: ' + e.getMessage());
        }
    }
    
}