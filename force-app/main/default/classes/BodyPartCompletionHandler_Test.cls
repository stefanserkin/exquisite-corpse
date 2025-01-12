@IsTest
private class BodyPartCompletionHandler_Test {
    
    @TestSetup
    static void makeData() {
        Body_Type__c bodyType = TestDataFactory.createBodyTypeWithParts();
        TestDataFactory.createCorpse(bodyType);
    }

    @IsTest
    static void testCompletedRecord() {
        Body_Part__c bodyPart = [SELECT Id, Exquisite_Corpse__c, Sort_Order__c, Status__c FROM Body_Part__c WHERE Status__c = 'In Progress' LIMIT 1];
        bodyPart.Status__c = 'Complete';

        Test.startTest();
        update bodyPart;
        Test.stopTest();

        Exquisite_Corpse__c corpse = [
            SELECT Id, (SELECT Id, Sort_Order__c FROM Body_Parts__r WHERE Status__c = 'In Progress' ORDER BY Sort_Order__c ASC) 
              FROM Exquisite_Corpse__c
             WHERE Id = :bodyPart.Exquisite_Corpse__c
             LIMIT 1
        ];

        System.Assert.isFalse(corpse.Body_Parts__r.isEmpty(), 'Should have received the next in progress body part');
        System.Assert.areNotEqual(bodyPart.Id, corpse.Body_Parts__r[0].Id, 'Should not have received the original body part record');
        System.Assert.isTrue(corpse.Body_Parts__r[0].Sort_Order__c > bodyPart.Sort_Order__c, 'The new record\'s sort order should be greater than the original record\'s');
    }

}