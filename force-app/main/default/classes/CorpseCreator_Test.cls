@IsTest
private class CorpseCreator_Test {
    
    @TestSetup
    static void makeData() {
        TestDataFactory.createBodyTypeWithParts();
    }

    @IsTest
    static void testGetCorpses() {
        String corpseName = 'Test Corpse';
        Body_Type__c bodyType = [SELECT Id, Name, (SELECT Id, Name FROM Body_Part_Types__r) FROM Body_Type__c LIMIT 1];

        List<Id> artistIds = new List<Id>();
        for (Body_Part_Type__c bpt : bodyType.Body_Part_Types__r) {
            artistIds.add(UserInfo.getUserId());
        }
 
        CorpseCreator.Request request = new CorpseCreator.Request();
        request.corpseName = corpseName;
        request.bodyTypeId = bodyType.Id;
        request.artistIds = artistIds;

        CorpseCreator creator = new CorpseCreator( new List<CorpseCreator.Request>{ request });

        Test.startTest();
        List<Exquisite_Corpse__c> corpses = creator.getCorpses();
        Test.stopTest();

        System.Assert.isFalse(corpses.isEmpty(), 'Should have received a corpse for the provided request');
        System.Assert.areEqual(corpseName, corpses[0].Name, 'Should have received a corpse with the provided name');
    }

    @IsTest
    static void testGetCorpsesWithInvalidUserList() {
        Body_Type__c bodyType = [SELECT Id, Name, (SELECT Id, Name FROM Body_Part_Types__r) FROM Body_Type__c LIMIT 1];

        List<Id> artistIds = new List<Id>();
        for (Body_Part_Type__c bpt : bodyType.Body_Part_Types__r) {
            artistIds.add(UserInfo.getUserId());
        }
        // Add one extra user id to create an invalid list
        artistIds.add(UserInfo.getUserId());
 
        CorpseCreator.Request request = new CorpseCreator.Request();
        request.corpseName = 'Test Corpse';
        request.bodyTypeId = bodyType.Id;
        request.artistIds = artistIds;

        CorpseCreator creator = new CorpseCreator( new List<CorpseCreator.Request>{ request });

        Test.startTest();
        try {
            creator.getCorpses();
            System.Assert.fail('Should have received an exception for the invalid user list');
        } catch (Exception e) {
            System.Assert.isTrue(e.getTypeName().contains('ExquisiteCorpseException'), 'Should have received an ExquisiteCorpseException');
            System.Assert.areEqual(CorpseCreator.INVALID_USER_LIST_MESSAGE, e.getMessage(), 'Did not receive the expected exception message');
        }
        Test.stopTest();
    }

}