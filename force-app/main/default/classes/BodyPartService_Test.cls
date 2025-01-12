@IsTest
private class BodyPartService_Test {
    
    @TestSetup
    static void makeData() {
        Body_Type__c bodyType = TestDataFactory.createBodyTypeWithParts();
        TestDataFactory.createCorpse(bodyType);
    }

    @IsTest
    static void testGetCorpseBodyParts() {
        Exquisite_Corpse__c corpse = [SELECT Id, (SELECT Id, Status__c, Body_Part_Type__r.Name, Artist__r.FirstName FROM Body_Parts__r ORDER BY Sort_Order__c ASC) FROM Exquisite_Corpse__c LIMIT 1];
        Test.startTest();
        List<BodyPart> bodyParts = BodyPartService.getCorpseBodyParts(corpse.Id);
        Test.stopTest();
        System.Assert.areEqual(corpse.Body_Parts__r.size(), bodyParts.size(), 'Received incorrect number of body parts');
        for (Integer i = 0; i < bodyParts.size(); i++) {
            System.Assert.areEqual(corpse.Body_Parts__r[i].Body_Part_Type__r.Name, bodyParts[i].bodyPartType, 'Received incorrect body part type');
            System.Assert.areEqual(corpse.Body_Parts__r[i].Artist__r.FirstName, bodyParts[i].artistFirstName, 'Received incorrect artist first name');
            System.Assert.areEqual(corpse.Body_Parts__r[i].Status__c, bodyParts[i].status, 'Received incorrect artist first name');
        }
    }

    @IsTest
    static void testGetLatestFile() {
        Body_Part__c bodyPart = [SELECT Id FROM Body_Part__c LIMIT 1];

        Blob fileBlob = Blob.valueOf('Test File Content');
        ContentVersion contentVersion = new ContentVersion(
            Title = 'BodyPartDrawing_' + String.valueOf(bodyPart.Id),
            PathOnClient = 'test-file.png',
            VersionData = fileBlob,
            IsMajorVersion = true
        );
        insert contentVersion;

        ContentDocumentLink contentLink = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1].ContentDocumentId,
            LinkedEntityId = bodyPart.Id,
            ShareType = 'I',
            Visibility = 'AllUsers'
        );
        insert contentLink;

        Test.startTest();
        String base64File = BodyPartService.getLatestFile(bodyPart.Id);
        Test.stopTest();

        System.Assert.areEqual(EncodingUtil.base64Encode(fileBlob), base64File, 'The Base64-encoded file content does not match.');
    }

    @IsTest
    static void testGetLatestFileWithNoFiles() {
        Body_Part__c bodyPart = [SELECT Id FROM Body_Part__c LIMIT 1];

        Test.startTest();
        try {
            String result = BodyPartService.getLatestFile(bodyPart.Id);
            System.Assert.fail('Expected exception for missing file, but no exception was thrown.');
        } catch (ExquisiteCorpseException e) {
            System.Assert.isTrue(
                e.getMessage().contains('There are no files associated with record id'),
                'Expected exception message for missing file.'
            );
        }
        Test.stopTest();
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

}