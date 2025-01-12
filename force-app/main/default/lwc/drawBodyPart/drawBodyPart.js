import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLatestFile from '@salesforce/apex/BodyPartCanvasController.getLatestFile';
import saveFile from '@salesforce/apex/BodyPartCanvasController.saveFile';

const ZONE_HEIGHT = 25;

export default class DrawBodyPart extends LightningElement {
    @api bodyPartId;
    @api bodyParts;

    error;
    isLoading = false;
    hasDrawnInBottomZone = false;

    canvas;
    ctx;

    zoneHeight = ZONE_HEIGHT;

    get currentBodyPartIndex() {
        return this.bodyParts?.findIndex(obj => obj.id === this.bodyPartId);
    }

    get currentBodyPart() {
        if (!this.currentBodyPartIndex) return;
        return this.bodyParts[this.currentBodyPartIndex];
    }

    get previousBodyPart() {
        if (!this.currentBodyPartIndex || this.currentBodyPartIndex === 0) return;
        return this.bodyParts[this.currentBodyPartIndex - 1];
    }

    get hasNextBodyPart() {
        console.log('evaluating has next body part');
        console.log('current index: ',this.currentBodyPartIndex);
        console.log('body parts length: ',this.bodyParts.length);
        return this.currentBodyPartIndex != null && this.currentBodyPartIndex != undefined && this.currentBodyPartIndex < this.bodyParts.length - 1 ? true : false;
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
            if (this.previousBodyPart) {
                this.loadSharedZone();
            } else {
                this.renderCanvasZones();
            }
        }
    }

    setupDrawing() {
        let isDrawing = false;
        const rect = this.canvas.getBoundingClientRect();
        const zoneHeight = this.zoneHeight;

        /*
        this.canvas.addEventListener('mousedown', (event) => {
            const y = event.clientY - rect.top;
            if (y > zoneHeight) { // Prevent drawing in the top zone
                isDrawing = true;
                this.ctx.beginPath();
                this.ctx.moveTo(event.clientX - rect.left, y);
            }
        });
        
        this.canvas.addEventListener('mousemove', (event) => {
            const y = event.clientY - rect.top;
            if (isDrawing && y > zoneHeight) {
                this.ctx.lineTo(event.clientX - rect.left, y);
                this.ctx.stroke();

                // Check if the drawing is in the bottom zone
                const bottomZoneY = this.canvas.height - zoneHeight;
                if (y >= bottomZoneY) {
                    this.hasDrawnInBottomZone = true;
                }
            }
        });
        */

        this.canvas.addEventListener('mousedown', (event) => {
            const y = event.clientY - rect.top;
    
            // Allow drawing anywhere for the first body part
            if (!this.previousBodyPart || y > zoneHeight) {
                isDrawing = true;
                this.ctx.beginPath();
                this.ctx.moveTo(event.clientX - rect.left, y);
            }
        });

        this.canvas.addEventListener('mousemove', (event) => {
            const y = event.clientY - rect.top;
    
            // Allow drawing anywhere for the first body part
            if (isDrawing && (!this.previousBodyPart || y > zoneHeight)) {
                this.ctx.lineTo(event.clientX - rect.left, y);
                this.ctx.stroke();
    
                // Check if the drawing is in the bottom zone
                const bottomZoneY = this.canvas.height - zoneHeight;
                if (y >= bottomZoneY) {
                    this.hasDrawnInBottomZone = true;
                }
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
        this.hasDrawnInBottomZone = false;
    }

    saveDrawing() {
        console.log('has next body part --> ', this.hasNextBodyPart);
        if (this.hasNextBodyPart && !this.hasDrawnInBottomZone) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Drawing Not Complete',
                    message: `Don't forget to fill in the green zone of the image, so the next artist knows where to begin!`,
                    variant: 'warning'
                })
            );
            return;
        }

        this.isLoading = true;

        // Save current canvas state
        const canvasBackup = this.ctx.getImageData(0, 0, this.canvas.width, this.canvas.height);

        // Temporarily remove overlays
        const zoneHeight = this.zoneHeight;
        const bottomZoneY = this.canvas.height - zoneHeight;

        // Remove top overlay (if applicable)
        if (this.previousBodyPart) {
            this.ctx.clearRect(0, 0, this.canvas.width, zoneHeight); // Top zone overlay
        }

        // Temporarily clear the bottom zone overlay (not the user drawing)
        this.ctx.save(); // Save the context state
        this.ctx.globalCompositeOperation = 'destination-out'; // Only clear the overlay
        this.ctx.fillStyle = "rgba(0, 255, 0, 0.2)"; // Match overlay color
        this.ctx.fillRect(0, bottomZoneY, this.canvas.width, zoneHeight); // Clear overlay
        this.ctx.restore(); // Restore original context state

        // Convert canvas to Base64
        const imageData = this.canvas.toDataURL('image/png');

        // Restore original canvas state
        this.ctx.putImageData(canvasBackup, 0, 0);

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
            })
            .finally(() => {
                this.renderCanvasZones(); // Reapply overlays after saving
            });
    }

    /**
     * Loads the shared zone from the previous body part's drawing
     */
    loadSharedZone() {
        console.log('ready to load shared zone with id --> ' + this.previousBodyPart.id);

        getLatestFile({ bodyPartId: this.previousBodyPart.id })
            .then((base64Data) => {
                const image = new Image();
                image.onload = () => {
                    // Draw the shared zone
                    this.ctx.drawImage(image, 0, this.canvas.height - this.zoneHeight, this.canvas.width, this.zoneHeight, 0, 0, this.canvas.width, this.zoneHeight);
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

        console.log('currentBodyPartIndex:', this.currentBodyPartIndex);
        console.log('bodyParts:', JSON.stringify(this.bodyParts));
        console.log('bodyPartId:', this.bodyPartId);
    
        // Skip top zone for the first body part
        if (!this.previousBodyPart) {
            console.log('First body part: no top zone.');
        } else {
            // Top shared zone
            this.ctx.fillStyle = "rgba(255, 0, 0, 0.2)";
            this.ctx.fillRect(0, 0, canvasWidth, zoneHeight);
            this.ctx.strokeStyle = "black";
            this.ctx.strokeRect(0, 0, canvasWidth, zoneHeight);
        }
    
        console.log('has next body part --> ',this.hasNextBodyPart);
        // Bottom shared zone
        if (this.hasNextBodyPart) {
            const bottomZoneY = this.canvas.height - zoneHeight;
            this.ctx.fillStyle = "rgba(0, 255, 0, 0.2)";
            this.ctx.fillRect(0, bottomZoneY, canvasWidth, zoneHeight);
            this.ctx.strokeStyle = "black";
            this.ctx.strokeRect(0, bottomZoneY, canvasWidth, zoneHeight);
        }
    }

}