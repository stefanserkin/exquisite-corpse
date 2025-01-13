@IsTest
private class BodyPartNamer_Test {
    
    @TestSetup
    static void makeData() {
        TestDataFactory.createBodyTypeWithParts();
    }

    @IsTest
    static void testAutoName() {
        Body_Type__c bodyType = [SELECT Id, Name, (SELECT Id, Name FROM Body_Part_Types__r LIMIT 1) FROM Body_Type__c LIMIT 1];
        Body_Part_Type__c partType = bodyType.Body_Part_Types__r[0];
        Exquisite_Corpse__c corpse = new Exquisite_Corpse__c(Name = 'TestCorpse', Body_Type__c = bodyType.Id, Status__c = 'In Progress');
        insert corpse;

        Body_Part__c bodyPart = new Body_Part__c(
            Exquisite_Corpse__c = corpse.Id, 
            Body_Part_Type__c = partType.Id,
            Artist__c = UserInfo.getUserId(),
            Status__c = 'In Progress'
        );
        Test.startTest();
        new BodyPartNamer( new List<Body_Part__c>{ bodyPart } ).autoName();
        Test.stopTest();

        System.Assert.isNotNull(bodyPart.Name, 'The body part should have received a name');
        System.Assert.isTrue(bodyPart.Name.contains(corpse.Name), 'The auto name should include the corpse name');
        System.Assert.isTrue(bodyPart.Name.contains(partType.Name), 'The auto name should include the body part type name');
        System.Assert.isTrue(bodyPart.Name.contains(UserInfo.getFirstName()), 'The auto name should include the artist\'s first name');
    }

    @IsTest
    static void testAutoNameWithoutArtist() {
        Body_Type__c bodyType = [SELECT Id, Name, (SELECT Id, Name FROM Body_Part_Types__r LIMIT 1) FROM Body_Type__c LIMIT 1];
        Body_Part_Type__c partType = bodyType.Body_Part_Types__r[0];
        Exquisite_Corpse__c corpse = new Exquisite_Corpse__c(Name = 'TestCorpse', Body_Type__c = bodyType.Id, Status__c = 'In Progress');
        insert corpse;

        // Create body part without an artist defined
        Body_Part__c bodyPart = new Body_Part__c(
            Exquisite_Corpse__c = corpse.Id, 
            Body_Part_Type__c = partType.Id,
            Status__c = 'In Progress'
        );

        Test.startTest();
        new BodyPartNamer( new List<Body_Part__c>{ bodyPart } ).autoName();
        Test.stopTest();

        System.Assert.isNotNull(bodyPart.Name, 'The body part should have received a name');
        System.Assert.isTrue(bodyPart.Name.contains(corpse.Name), 'The auto name should include the corpse name');
        System.Assert.isTrue(bodyPart.Name.contains(partType.Name), 'The auto name should include the body part type name');
    }

}