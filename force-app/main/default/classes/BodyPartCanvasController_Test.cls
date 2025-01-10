@IsTest
private class BodyPartCanvasController_Test {

    @IsTest
    static void testSaveFile() {
        Exquisite_Corpse__c testCorpse = new Exquisite_Corpse__c(Name = 'Test Corpse');
        insert testCorpse;

        Body_Part__c testBodyPart = new Body_Part__c(
            Name = 'Test Body Part',
            Exquisite_Corpse__c = testCorpse.Id
        );
        insert testBodyPart;

        // Simulate a Base64 image string (small red dot PNG for testing purposes)
        String base64Image = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAHElEQVR42mP8z/C/HwAFwAMEAAADAAEd4EQaAAAAAElFTkSuQmCC';

        Test.startTest();
        BodyPartCanvasController.saveFile(testBodyPart.Id, base64Image);
        Test.stopTest();

        ContentVersion[] contentVersions = [
            SELECT Id, Title, PathOnClient, VersionData
            FROM ContentVersion
            WHERE Title LIKE 'BodyPartDrawing_%'
        ];
        System.assertEquals(1, contentVersions.size(), 'One ContentVersion record should have been created.');
        System.assert(contentVersions[0].PathOnClient.endsWith('.png'), 'The file should have a .png extension.');

        ContentDocumentLink[] links = [
            SELECT Id, ContentDocumentId, LinkedEntityId, ShareType, Visibility
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :testBodyPart.Id
        ];
        System.assertEquals(1, links.size(), 'One ContentDocumentLink should have been created for the Body Part.');
        System.assertEquals('I', links[0].ShareType, 'The ShareType should be inferred (I).');
    }

    /*
    @IsTest
    static void testSaveFileWithInvalidInput() {
        Test.startTest();
        try {
            BodyPartCanvasController.saveFile(null, 'validBase64ImageData');
            System.assert(false, 'Exception should have been thrown for null Body Part ID.');
        } catch (AuraHandledException ex) {
            System.assert(ex.getMessage().contains('Invalid parameters provided'), 'Expected exception for null Body Part ID.');
        }

        // Test with an empty fileData
        try {
            BodyPartCanvasController.saveFile(Id.valueOf('001000000000000AAA'), '');
            System.assert(false, 'Exception should have been thrown for empty fileData.');
        } catch (AuraHandledException ex) {
            System.assert(ex.getMessage().contains('Invalid parameters provided'), 'Expected exception for empty fileData.');
        }
        Test.stopTest();
    }
        */
    
}