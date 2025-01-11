trigger BodyPartTrigger on Body_Part__c (before insert) {
    new BodyPartTriggerHandler().run();
}