trigger BodyPartTrigger on Body_Part__c (before insert, before update) {
    new BodyPartTriggerHandler().run();
}