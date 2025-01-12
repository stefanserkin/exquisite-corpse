trigger ExquisiteCorpseTrigger on Exquisite_Corpse__c (before update) {
    new ExquisiteCorpseTriggerHandler().run();
}