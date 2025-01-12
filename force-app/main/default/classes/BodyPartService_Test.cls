@IsTest
private class BodyPartService_Test {
    
    @TestSetup
    static void makeData() {
        Body_Type__c bodyType = TestDataFactory.createBodyTypeWithParts();
        TestDataFactory.createCorpse(bodyType);
    }

    @IsTest
    static void testSaveFile() {
        Body_Part__c bodyPart = [SELECT Id FROM Body_Part__c WHERE Status__c = 'In Progress' LIMIT 1];

        // Simulate a Base64 image string
        String base64Image = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAHElEQVR42mP8z/C/HwAFwAMEAAADAAEd4EQaAAAAAElFTkSuQmCC';

        Test.startTest();
        BodyPartService.saveFile(bodyPart.Id, base64Image);
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

    @IsTest
    static void testSaveFileWithEmptyFileData() {
        Body_Part__c bodyPart = [SELECT Id FROM Body_Part__c WHERE Status__c = 'In Progress' LIMIT 1];
        Test.startTest();
        try {
            BodyPartService.saveFile(bodyPart.Id, '');
            System.assert(false, 'Exception should have been thrown for empty fileData');
        } catch (Exception e) {
            System.Assert.isTrue(e.getTypeName().contains('ExquisiteCorpseException'), 'Should have received an ExquisiteCorpseException');
        }
        Test.stopTest();
    }
    
    /*
    @IsTest
    static void testSaveFileWithInvalidRecordId() {
        Test.startTest();
        try {
            BodyPartService.saveFile(null, 'validBase64ImageData');
            System.assert(false, 'Exception should have been thrown for null Body Part ID.');
        } catch (AuraHandledException ex) {
            System.assert(ex.getMessage().contains('Invalid parameters provided'), 'Expected exception for null Body Part ID.');
        }
        Test.stopTest();
    }
        */

}