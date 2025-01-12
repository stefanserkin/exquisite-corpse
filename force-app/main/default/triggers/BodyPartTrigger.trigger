trigger BodyPartTrigger on Body_Part__c (before insert, before update, after update) {
    new BodyPartTriggerHandler().run();
}