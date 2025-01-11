import { LightningElement, api, wire } from 'lwc';
import { RefreshEvent } from 'lightning/refresh';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
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

    get isWaiting() {
        return this.status && this.status === 'Waiting';
    }

    get isInProgress() {
        return this.status && this.status === 'In Progress';
    }

    get isComplete() {
        return this.status && this.status === 'Complete';
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