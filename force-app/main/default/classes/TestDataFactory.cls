@IsTest
public class TestDataFactory {

    /*
    public static Body_Part_Set__c createBodyPartSetWithTypes() {
        Body_Part_Set__c bps = new Body_Part_Set__c();
        bps.Name = 'Test Species';
        bps.Active__c = true;
        insert bps;

        List<Body_Part_Type__c> bpts = createBodyPartTypes(bps.Id, 3);
        insert bpts;

        return bps;
    }

    public static List<Body_Part_Type__c> createBodyPartTypes(Id bodyPartSetId, Integer numberOfTypes) {
        List<Body_Part_Type__c> bpts = new List<Body_Part_Type__c>();
        for (Integer i = 0; i < numberOfTypes; i++) {
            Body_Part_Type__c bpt = new Body_Part_Type__c();
            bpt.Name = 'Test Body Part ' + String.valueOf(i);
            bpt.Body_Part_Set__c = bodyPartSetId;
            bpt.Sort_Order__c = i;
            bpts.add(bpt);
        }
        return bpts;
    }

    public static Exquisite_Corpse__c createCorpse(Body_Part_Set__c bodyPartSet) {
        Body_Part_Set__c bps = [
            SELECT Id, Name, (SELECT Id, Name, Sort_Order__c FROM Body_Part_Types__r)
              FROM Body_Part_Set__c
             WHERE Id = :bodyPartSet.Id
             LIMIT 1
        ];

        Exquisite_Corpse__c corpse = new Exquisite_Corpse__c();
        corpse.Body_Part_Set__c = bps.Id;
        corpse.Name = 'Test Corpse';
        corpse.Status__c = 'In Progress';
        insert corpse;

        List<Body_Part__c> bodyParts = new List<Body_Part__c>();
        Integer counter = 0;
        for (Body_Part_Type__c bpt : bps.Body_Part_Types__r) {
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
    */
}