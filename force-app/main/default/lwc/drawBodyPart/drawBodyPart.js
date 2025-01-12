import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLatestFile from '@salesforce/apex/BodyPartCanvasController.getLatestFile';
import saveFile from '@salesforce/apex/BodyPartCanvasController.saveFile';

const ZONE_HEIGHT = 15;

export default class DrawBodyPart extends LightningElement {
    @api bodyPartId;
    @api bodyParts;

    zoneHeight = ZONE_HEIGHT;

    error;
    isLoading = false;

    canvas;
    ctx;

    get currentBodyPartIndex() {
        return this.bodyParts?.findIndex(obj => obj.id === this.bodyPartId);
    }

    get currentBodyPart() {
        if (!this.currentBodyPartIndex) return;
        return this.bodyParts[this.currentBodyPartIndex];
    }

    get previousBodyPart() {
        if (!this.currentBodyPartIndex || this.currentBodyPartIndex < 1) return;
        return this.bodyParts[this.currentBodyPartIndex - 1];
    }

    connectedCallback() {
        this.resetCanvas = this.resetCanvas.bind(this);
        this.saveDrawing = this.saveDrawing.bind(this);
    }

    renderedCallback() {
        if (!this.canvas) {
            this.canvas = this.template.querySelector('canvas');
            this.ctx = this.canvas.getContext('2d');
            this.setupDrawing();
            this.loadSharedZone();
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
        this.renderCanvasZones();
    }

    saveDrawing() {
        this.isLoading = true;
        // Convert canvas to Base64
        const imageData = this.canvas.toDataURL('image/png');

        saveFile({
            bodyPartId: this.bodyPartId,
            fileData: imageData
        })
            .then((result) => {
                console.log('New Content Document ID: ' + result);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Drawing saved successfully!',
                        variant: 'success'
                    })
                );
                this.resetCanvas();
                this.dispatchEvent(new CustomEvent('refresh'));
                this.isLoading = false;
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error saving drawing',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
                this.isLoading = false;
            });
    }

    /**
     * Loads the shared zone from the previous body part's drawing
     */
    loadSharedZone() {
        if (!this.previousBodyPart) {
            this.renderCanvasZones();
            return;
        }

        console.log('ready to load shared zone with id --> ' + this.previousBodyPart.id);

        getLatestFile({ bodyPartId: this.previousBodyPart.id })
            .then((base64Data) => {
                const image = new Image();
                image.onload = () => {
                    // Draw the shared zone
                    this.ctx.drawImage(image, 0, this.canvas.height - this.zoneHeight, this.canvas.width, 10, 0, 0, this.canvas.width, this.zoneHeight);
                    // Format shared zones on the canvas
                    this.renderCanvasZones();
                    this.isLoading = false;
                };
                image.src = 'data:image/png;base64,' + base64Data;
            })
            .catch((error) => {
                console.error('Error loading shared zone:', error);
                this.isLoading = false;
                // Fallback to render zones even if shared zone fails
                this.renderCanvasZones();
            });
    }

    renderCanvasZones() {
        const zoneHeight = this.zoneHeight;
        const canvasWidth = this.canvas.width;

        // Top shared zone
        if (this.previousBodyPart) {
            // Semi-transparent red
            this.ctx.fillStyle = "rgba(255, 0, 0, 0.2)";
            this.ctx.fillRect(0, 0, canvasWidth, zoneHeight);
            this.ctx.strokeStyle = "red";
            this.ctx.strokeRect(0, 0, canvasWidth, zoneHeight);
            this.ctx.fillStyle = "black";
            this.ctx.font = "12px Arial";
            this.ctx.fillText("Shared Zone", 10, zoneHeight - 2);
        }

        // Bottom shared zone
        if (this.currentBodyPartIndex < (this.bodyParts.length - 1)) {
            const bottomZoneY = this.canvas.height - zoneHeight;
            // Semi-transparent green
            this.ctx.fillStyle = "rgba(0, 255, 0, 0.2)";
            this.ctx.fillRect(0, bottomZoneY, canvasWidth, zoneHeight);
            this.ctx.strokeStyle = "green";
            this.ctx.strokeRect(0, bottomZoneY, canvasWidth, zoneHeight);
            this.ctx.fillStyle = "black";
            this.ctx.font = "12px Arial";
            this.ctx.fillText("Shared Zone", 10, bottomZoneY + zoneHeight - 2);
        }
    }

}