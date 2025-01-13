@IsTest
private class ExquisiteCorpseService_Test {

    @TestSetup
    static void makeData() {
        Body_Type__c bodyType = TestDataFactory.createBodyTypeWithParts();
        TestDataFactory.createCorpse(bodyType);
    }

    @IsTest
    static void testHandleCompletedCorpses() {
        Exquisite_Corpse__c corpse = [SELECT Id, Status__c, Completed_Date_Time__c FROM Exquisite_Corpse__c LIMIT 1];
        corpse.Status__c = 'Complete';

        Test.startTest();
        update corpse;
        Test.stopTest();

        Exquisite_Corpse__c refreshedCorpse = [SELECT Id, Status__c, Completed_Date_Time__c FROM Exquisite_Corpse__c WHERE Id = :corpse.Id LIMIT 1];
        System.Assert.isNotNull(refreshedCorpse.Completed_Date_Time__c, 'Should have received a completed date/time');
    }

    @IsTest
    static void testRenameBodyParts() {
        Exquisite_Corpse__c corpse = [SELECT Id, Name FROM Exquisite_Corpse__c LIMIT 1];
        corpse.Name = 'A very new name';

        Test.startTest();
        update corpse;
        Test.stopTest();

        List<Body_Part__c> bodyParts = [SELECT Name FROM Body_Part__c WHERE Exquisite_Corpse__c = :corpse.Id];
        for (Body_Part__c bodyPart : bodyParts) {
            System.Assert.isTrue(bodyPart.Name.contains(corpse.Name), 'Body part name should contain the new corpse name');
        }
    }
    
}