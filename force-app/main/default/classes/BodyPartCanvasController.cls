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
            BodyPartService.saveFile(bodyPartId, fileData);
        } catch (Exception e) {
            throw new AuraHandledException('Error saving file: ' + e.getMessage());
        }
    }
    
}