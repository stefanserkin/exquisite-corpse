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
CREATE TABLE "Body_Part__c" (
	id VARCHAR(255) NOT NULL, 
	"Name" VARCHAR(255), 
	"Status__c" VARCHAR(255), 
	"Body_Part_Type__c" VARCHAR(255), 
	"Exquisite_Corpse__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Body_Part__c" VALUES('Body_Part__c-1','Hideous Monster Head - User','In Progress','Body_Part_Type__c-3','Exquisite_Corpse__c-1');
INSERT INTO "Body_Part__c" VALUES('Body_Part__c-2','Hideous Monster Torso - User','Waiting','Body_Part_Type__c-4','Exquisite_Corpse__c-1');
INSERT INTO "Body_Part__c" VALUES('Body_Part__c-3','Hideous Monster Legs - User','Waiting','Body_Part_Type__c-1','Exquisite_Corpse__c-1');
INSERT INTO "Body_Part__c" VALUES('Body_Part__c-4','Hideous Monster Feet - User','Waiting','Body_Part_Type__c-2','Exquisite_Corpse__c-1');
CREATE TABLE "Body_Type__c" (
	id VARCHAR(255) NOT NULL, 
	"Active__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Body_Type__c" VALUES('Body_Type__c-1','True','Homo Sapien');
CREATE TABLE "Exquisite_Corpse__c" (
	id VARCHAR(255) NOT NULL, 
	"Completed_Date_Time__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"Status__c" VARCHAR(255), 
	"Body_Type__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Exquisite_Corpse__c" VALUES('Exquisite_Corpse__c-1','','Hideous Monster','In Progress','Body_Type__c-1');
COMMIT;
