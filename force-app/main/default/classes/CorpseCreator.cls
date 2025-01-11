public with sharing class CorpseCreator {

    @TestVisible
    private static final String INVALID_USER_LIST_MESSAGE = 'The number of users must match the number of body parts';

    private static final String DEFAULT_STATUS = 'In Progress';
    private static final String WAITING_STATUS = 'Waiting';
    private static final String DEFAULT_CORPSE_NAME = 'New Corpse';

    private List<Request> requests;
    private Map<Id, Body_Type__c> bodyTypesWithParts;
    private Map<String, Exquisite_Corpse__c> corpsesByRequestId;

    public CorpseCreator(List<Request> requests) {
        this.requests = requests;
        this.bodyTypesWithParts = loadBodyTypeMap();
    }

    public List<Exquisite_Corpse__c> getCorpses() {
        createCorpsesFromRequests();
        insert corpsesByRequestId.values();
        List<Body_Part__c> bodyParts = createBodyPartsForCorpses();
        insert bodyParts;
        return corpsesByRequestId.values();
    }

    private void createCorpsesFromRequests() {
        corpsesByRequestId = new Map<String, Exquisite_Corpse__c>();
        for (Request request : requests) {
            validateRequest(request);

            Exquisite_Corpse__c corpse = new Exquisite_Corpse__c();
            corpse.Body_Type__c = request.bodyTypeId;
            corpse.Status__c = DEFAULT_STATUS;
            corpse.Name = request.corpseName ?? DEFAULT_CORPSE_NAME;
            corpsesByRequestId.put(request.id, corpse);
        }
    }

    private void validateRequest(Request req) {
        if (req.artistIds.size() != bodyTypesWithParts.get(req.bodyTypeId).Body_Part_Types__r.size()) {
            throw new ExquisiteCorpseException(INVALID_USER_LIST_MESSAGE);
        }
    }

    private List<Body_Part__c> createBodyPartsForCorpses() {
        List<Body_Part__c> bodyParts = new List<Body_Part__c>();

        for (Request request : requests) {
            Exquisite_Corpse__c corpse = corpsesByRequestId.get(request.id);
            List<Body_Part_Type__c> bodyPartTypes = bodyTypesWithParts.get(corpse.Body_Type__c).Body_Part_Types__r;
            for (Integer i = 0; i < bodyPartTypes.size(); i++) {
                Body_Part__c part = new Body_Part__c();
                part.Exquisite_Corpse__c = corpse.Id;
                part.Body_Part_Type__c = bodyPartTypes[i].Id;
                part.Artist__c = request.artistIds[i];
                part.Status__c = i == 0 ? DEFAULT_STATUS : WAITING_STATUS;
                bodyParts.add(part);
            }
        }
        return bodyParts;
    }

    private Map<Id, Body_Type__c> loadBodyTypeMap() {
        Set<Id> bodyTypeIds = new Set<Id>();
        for (Request request : requests) {
            bodyTypeIds.add(request.bodyTypeId);
        }

        return new Map<Id, Body_Type__c>([
            SELECT Id, Name,
                   (SELECT Id, Name, Sort_Order__c FROM Body_Part_Types__r)
              FROM Body_Type__c
             WHERE Id IN :bodyTypeIds
        ]);
    }

    /**
     * To use the CorpseCreator, create a request object with a Body_Type__c id and a collection of user ids
     */

    public class Request {
        public String id {get; private set;}
        public Id bodyTypeId {get; set;}
        public List<Id> artistIds {get; set;}
        public String corpseName {get; set;}

        public Request() {
            this.id = System.UUID.randomUUID().toString();
        }
    }

}