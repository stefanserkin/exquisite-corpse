@IsTest
public class TestDataFactory {

    public static Body_Type__c createBodyTypeWithParts() {
        Body_Type__c bodyType = new Body_Type__c();
        bodyType.Name = 'Hideous Monster';
        bodyType.Active__c = true;
        insert bodyType;

        List<Body_Part_Type__c> bpts = createBodyPartTypes(bodyType.Id, 3);
        insert bpts;

        return bodyType;
    }

    public static List<Body_Part_Type__c> createBodyPartTypes(Id bodyTypeId, Integer numberOfTypes) {
        List<Body_Part_Type__c> bpts = new List<Body_Part_Type__c>();
        for (Integer i = 0; i < numberOfTypes; i++) {
            Body_Part_Type__c bpt = new Body_Part_Type__c();
            bpt.Name = 'Test Body Part ' + String.valueOf(i);
            bpt.Body_Type__c = bodyTypeId;
            bpt.Sort_Order__c = i;
            bpts.add(bpt);
        }
        return bpts;
    }

    public static Exquisite_Corpse__c createCorpse(Body_Type__c bodyType) {
        bodyType = [
            SELECT Id, Name, (SELECT Id, Name, Sort_Order__c FROM Body_Part_Types__r)
              FROM Body_Type__c
             WHERE Id = :bodyType.Id
             LIMIT 1
        ];

        Exquisite_Corpse__c corpse = new Exquisite_Corpse__c();
        corpse.Body_Type__c = bodyType.Id;
        corpse.Name = 'Test Corpse';
        corpse.Status__c = 'In Progress';
        insert corpse;

        List<Body_Part__c> bodyParts = new List<Body_Part__c>();
        Integer counter = 0;
        for (Body_Part_Type__c bpt : bodyType.Body_Part_Types__r) {
            counter++;

            Body_Part__c bp = new Body_Part__c();
            bp.Exquisite_Corpse__c = corpse.Id;
            bp.Name = 'Test bpt ' + String.valueOf(counter);
            bp.Status__c = counter == 1 ? 'In Progress' : 'Waiting';
            bp.Artist__c = UserInfo.getUserId();
            bp.Body_Part_Type__c = bpt.Id;
            bodyParts.add(bp);
        }
        insert bodyParts;

        return corpse;
    }

}