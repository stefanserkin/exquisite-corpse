import { LightningElement, api, wire, track } from 'lwc';
import { RefreshEvent } from 'lightning/refresh';
import { refreshApex } from '@salesforce/apex';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getCorpseBodyParts from '@salesforce/apex/BodyPartCanvasController.getCorpseBodyParts';
import CORPSE_ID_FIELD from '@salesforce/schema/Body_Part__c.Exquisite_Corpse__c';

export default class BodyPartCanvas extends LightningElement {
    @api recordId;
    error;
    isLoading = false;

    corpseId;
    wiredBodyParts = [];
    @track bodyParts;

    get currentBodyPart() {
        return this.bodyParts?.find(obj => obj.id === this.recordId);
    }

    get isWaiting() {
        return this.currentBodyPart && this.currentBodyPart.status === 'Waiting';
    }

    get isInProgress() {
        return this.currentBodyPart && this.currentBodyPart.status === 'In Progress';
    }

    get isComplete() {
        return this.currentBodyPart && this.currentBodyPart.status === 'Complete';
    }

    get waitingOnInfo() {
        if (!this.bodyParts) return;
        const activePart = this.bodyParts.find(obj => {
            return obj.id === this.recordId
        });
        return `Waiting on ${activePart.artistFirstName} to draw the ${activePart.bodyPartType} of the ${activePart.corpseName}`;
    }

    @wire(getCorpseBodyParts, { corpseId: '$corpseId' })
    wiredResult(result) {
        this.isLoading = true;
        this.wiredBodyParts = result;

        if (result.data) {
            console.log('got body part data');
            this.bodyParts = JSON.parse( JSON.stringify(result.data) );
            console.log(JSON.stringify(this.bodyParts));
            this.error = undefined;
        } else if (result.error) {
            this.bodyParts = undefined;
            this.error = result.error;
            console.error(this.error);
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [CORPSE_ID_FIELD] })
    record({ error, data }){
        if (data) {
            console.log('wired record with corpse id --> ');
            this.corpseId = getFieldValue(data, CORPSE_ID_FIELD);
            console.log(this.corpseId);
        } else if (error) {
            this.error = error;
            console.error(this.error);
        }
    }

    refreshComponent() {
        refreshApex(this.wiredBodyParts);
        this.dispatchEvent(new RefreshEvent());
    }

}