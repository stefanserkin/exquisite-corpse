@IsTest
private class BodyPartCanvasController_Test {

    @TestSetup
    static void makeData() {
        Body_Type__c bodyType = TestDataFactory.createBodyTypeWithParts();
        TestDataFactory.createCorpse(bodyType);
    }

    @IsTest
    static void testSaveFile() {
        Body_Part__c bodyPart = [SELECT Id FROM Body_Part__c WHERE Status__c = 'In Progress' LIMIT 1];

        // Simulate a Base64 image string (small red dot PNG for testing purposes)
        String base64Image = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAHElEQVR42mP8z/C/HwAFwAMEAAADAAEd4EQaAAAAAElFTkSuQmCC';

        Test.startTest();
        BodyPartCanvasController.saveFile(bodyPart.Id, base64Image);
        Test.stopTest();

        ContentVersion[] contentVersions = [
            SELECT Id, Title, PathOnClient, VersionData
              FROM ContentVersion
             WHERE Title LIKE 'BodyPartDrawing_%'
        ];
        System.assertEquals(1, contentVersions.size(), 'One ContentVersion record should have been created');
        System.assert(contentVersions[0].PathOnClient.endsWith('.png'), 'The file should have a .png extension');

        ContentDocumentLink[] links = [
            SELECT Id, ContentDocumentId, LinkedEntityId, ShareType, Visibility
              FROM ContentDocumentLink
             WHERE LinkedEntityId = :bodyPart.Id
        ];
        System.assertEquals(1, links.size(), 'One ContentDocumentLink should have been created for the Body Part');
        System.assertEquals('I', links[0].ShareType, 'The ShareType should be inferred (I)');
    }
    
}