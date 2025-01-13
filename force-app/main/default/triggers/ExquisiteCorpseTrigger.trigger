trigger ExquisiteCorpseTrigger on Exquisite_Corpse__c (before update, after update) {
    new ExquisiteCorpseTriggerHandler().run();
}