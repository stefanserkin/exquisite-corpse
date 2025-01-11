BEGIN TRANSACTION;
CREATE TABLE "Body_Part_Type__c" (
	id VARCHAR(255) NOT NULL, 
	"Name" VARCHAR(255), 
	"Sort_Order__c" VARCHAR(255), 
	"Body_Type__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Body_Part_Type__c" VALUES('Body_Part_Type__c-1','Legs','3.0','Body_Type__c-1');
INSERT INTO "Body_Part_Type__c" VALUES('Body_Part_Type__c-2','Feet','4.0','Body_Type__c-1');
INSERT INTO "Body_Part_Type__c" VALUES('Body_Part_Type__c-3','Head','1.0','Body_Type__c-1');
INSERT INTO "Body_Part_Type__c" VALUES('Body_Part_Type__c-4','Torso','2.0','Body_Type__c-1');
CREATE TABLE "Body_Type__c" (
	id VARCHAR(255) NOT NULL, 
	"Active__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Body_Type__c" VALUES('Body_Type__c-1','True','Homo Sapien');
COMMIT;
