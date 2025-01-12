import { LightningElement, api, wire } from 'lwc';
import getLatestFile from '@salesforce/apex/BodyPartCanvasController.getLatestFile';

export default class PreviewBodyPart extends LightningElement {
    @api bodyPartId;
    imageSrc;
    error;

    connectedCallback() {
        this.loadImage();
    }

    loadImage() {
        if (!this.bodyPartId) {
            this.error = 'Body Part ID is required to preview the image';
            return;
        }

        getLatestFile({ bodyPartId: this.bodyPartId })
            .then((base64Data) => {
                this.imageSrc = 'data:image/png;base64,' + base64Data;
                this.error = undefined;
            })
            .catch((error) => {
                this.imageSrc = undefined;
                this.error = error.body.message || 'Failed to load the image';
                console.error('Error loading image:', error);
            });
    }
}