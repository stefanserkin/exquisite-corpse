import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLatestFile from '@salesforce/apex/BodyPartCanvasController.getLatestFile';
import saveFile from '@salesforce/apex/BodyPartCanvasController.saveFile';

export default class DrawBodyPart extends LightningElement {
    @api bodyPartId;
    @api previousBodyPartId;
    @api corpseName;
    @api bodyPartType;

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
        // Convert canvas to Base64
        const imageData = this.canvas.toDataURL('image/png');
        const bodyPartId = this.bodyPartId;

        saveFile({
            bodyPartId,
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

    /**
     * Loads the shared zone from the previous body part's drawing
     */
    loadSharedZone() {
        getLatestFile({ bodyPartId: this.bodyPartId })
            .then((base64Data) => {
                const image = new Image();
                image.onload = () => {
                    this.ctx.drawImage(image, 0, this.canvas.height - 10, this.canvas.width, 10, 0, 0, this.canvas.width, 10);
                };
                image.src = 'data:image/png;base64,' + base64Data;
            })
            .catch((error) => {
                console.error('Error loading shared zone:', error);
            });
    }

    renderCanvasZones() {
        const zoneHeight = 10; // Height of the shared zone in pixels
        const canvasWidth = this.canvas.width;

        // Top shared zone
        this.ctx.fillStyle = "rgba(255, 0, 0, 0.2)"; // Semi-transparent red
        this.ctx.fillRect(0, 0, canvasWidth, zoneHeight);
        this.ctx.strokeStyle = "red";
        this.ctx.strokeRect(0, 0, canvasWidth, zoneHeight);

        // Bottom shared zone
        const bottomZoneY = this.canvas.height - zoneHeight;
        this.ctx.fillStyle = "rgba(0, 255, 0, 0.2)"; // Semi-transparent green
        this.ctx.fillRect(0, bottomZoneY, canvasWidth, zoneHeight);
        this.ctx.strokeStyle = "green";
        this.ctx.strokeRect(0, bottomZoneY, canvasWidth, zoneHeight);

        // Optional: Add text for clarity
        this.ctx.fillStyle = "black";
        this.ctx.font = "12px Arial";
        this.ctx.fillText("Shared Zone", 10, zoneHeight - 2); // Top zone
        this.ctx.fillText("Shared Zone", 10, bottomZoneY + zoneHeight - 2); // Bottom zone
    }

}