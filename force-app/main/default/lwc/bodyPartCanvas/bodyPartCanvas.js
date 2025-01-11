import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveFile from '@salesforce/apex/BodyPartCanvasController.saveFile';

export default class BodyPartCanvas extends LightningElement {
    @api bodyPartId; // The current Body Part record ID
    @api bodyPartType; // Type of the Body Part (e.g., Head, Torso, Legs)

    canvas;
    ctx;

    connectedCallback() {
        this.resetCanvas = this.resetCanvas.bind(this);
        this.saveDrawing = this.saveDrawing.bind(this);
    }

    renderedCallback() {
        if (!this.canvas) {
            this.canvas = this.template.querySelector('canvas');
            this.ctx = this.canvas.getContext('2d');
            this.setupDrawing();
        }
    }

    setupDrawing() {
        let isDrawing = false;
        const rect = this.canvas.getBoundingClientRect();

        this.canvas.addEventListener('mousedown', (event) => {
            isDrawing = true;
            this.ctx.beginPath();
            this.ctx.moveTo(event.clientX - rect.left, event.clientY - rect.top);
        });

        this.canvas.addEventListener('mousemove', (event) => {
            if (isDrawing) {
                this.ctx.lineTo(event.clientX - rect.left, event.clientY - rect.top);
                this.ctx.stroke();
            }
        });

        this.canvas.addEventListener('mouseup', () => {
            isDrawing = false;
        });

        this.canvas.addEventListener('mouseleave', () => {
            isDrawing = false;
        });
    }

    resetCanvas() {
        this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    }

    saveDrawing() {
        const imageData = this.canvas.toDataURL('image/png'); // Convert canvas to Base64
        const bodyPartId = this.bodyPartId;

        saveFile({
            bodyPartId,
            fileData: imageData
        })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Drawing saved successfully!',
                        variant: 'success'
                    })
                );
                this.resetCanvas();
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error saving drawing',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
}