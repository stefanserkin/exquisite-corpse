public class BodyPart {

    /**
     * Body Part Information
     */
    @AuraEnabled
    public Id id;

    @AuraEnabled
    public String name;

    @AuraEnabled
    public Decimal sortOrder;

    @AuraEnabled
    public String status;

    /**
     * Body Part Type Information
     */
    @AuraEnabled
    public String bodyPartType;

    /**
     * Exquisite Corpse Information
     */
    @AuraEnabled
    public String corpseName;

    @AuraEnabled
    public String corpseStatus;

    /**
     * Assigned User Information
     */
    @AuraEnabled
    public Id artistId;

    @AuraEnabled
    public String artistFirstName;

    @AuraEnabled
    public String artistLastName;

    @AuraEnabled
    public String artistEmail;

    /**
     * Create a body part from a Body_Part__c sobject
     * Must include all data from parent objects
     */
    public BodyPart(Body_Part__c sobj) {
        this.id = sobj.Id;
        this.name = sobj.Name;
        this.sortOrder = sobj.Sort_Order__c;
        this.status = sobj.Status__c;
        this.corpseName = sobj.Exquisite_Corpse__r.Name;
        this.corpseStatus = sobj.Exquisite_Corpse__r.Status__c;
        this.bodyPartType = sobj.Body_Part_Type__r.Name;
        this.artistId = sobj.Artist__c;
        this.artistFirstName = sobj.Artist__r.FirstName;
        this.artistLastName = sobj.Artist__r.LastName;
        this.artistEmail = sobj.Artist__r.Email;
    }

}