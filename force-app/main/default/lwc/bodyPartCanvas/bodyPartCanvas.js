import { LightningElement, api, wire } from 'lwc';
import { RefreshEvent } from 'lightning/refresh';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getCorpseBodyParts from '@salesforce/apex/BodyPartCanvasController.getCorpseBodyParts';
import STATUS_FIELD from '@salesforce/schema/Body_Part__c.Status__c';
import CORPSE_NAME_FIELD from '@salesforce/schema/Body_Part__c.Exquisite_Corpse__r.Name';
import BODY_PART_TYPE_FIELD from '@salesforce/schema/Body_Part__c.Body_Part_Type__r.Name';

const fields = [STATUS_FIELD, CORPSE_NAME_FIELD, BODY_PART_TYPE_FIELD];

export default class BodyPartCanvas extends LightningElement {
    @api recordId;
    error;
    isLoading = false;

    status;
    corpseName;
    bodyPartType;

    wiredBodyParts = [];
    bodyParts;

    get isWaiting() {
        return this.status && this.status === 'Waiting';
    }

    get isInProgress() {
        return this.status && this.status === 'In Progress';
    }

    get isComplete() {
        return this.status && this.status === 'Complete';
    }

    get waitingOnInfo() {
        if (!this.bodyParts) {
            return;
        }
        console.log('Record id --> ', recordId);
        console.log(JSON.stringify(this.bodyParts));
        const activePart = this.bodyParts.find(obj => {
            return obj.id === this.recordId
        });
        console.log('found active part --> ' + JSON.stringify(activePart));
        return `Waiting on ${activePart.artistFirstName} to draw the ${activePart.bodyPartType} of the ${activePart.corpseName}`;
    }

    @wire(getCorpseBodyParts, { corpseId: '$recordId' })
    wiredResult(result) {
        this.isLoading = true;
        this.wiredBodyParts = result;

        if (result.data) {
            this.bodyParts = JSON.parse( JSON.stringify(result.data) );
            this.error = undefined;
        } else if (result.error) {
            this.bodyParts = undefined;
            this.error = result.error;
            console.error(this.error);
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields })
    record({ error, data }){
        if (data) {
            this.status = getFieldValue(data, STATUS_FIELD);
            this.corpseName = getFieldValue(data, CORPSE_NAME_FIELD);
            this.bodyPartType = getFieldValue(data, BODY_PART_TYPE_FIELD);
        } else if (error) {
            this.error = error;
        }
    }

    refreshComponent() {
        this.dispatchEvent(new RefreshEvent());
    }

}