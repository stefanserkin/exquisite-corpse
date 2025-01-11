trigger ExquisiteCorpseTrigger on Exquisite_Corpse__c (after insert) {
    new ExquisiteCorpseTriggerHandler().run();
}