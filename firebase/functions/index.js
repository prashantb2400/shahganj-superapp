// firebase/functions/index.js
const { onRequest, onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { logger } = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();

/**
 * 1. [CRITICAL ORDER ALERTS]: Triggers FCM push notifications + custom arpeggio audio assets
 * Triggers on a new document write inside /orders collection.
 */
exports.onOrderCreated = onDocumentCreated("orders/{orderId}", async (event) => {
    const orderData = event.data.data();
    const orderId = event.params.orderId;
    const merchantId = orderData.merchantId;

    logger.log(`New order created: ${orderId} for merchant: ${merchantId}`);

    try {
        // Fetch target merchant FCM Token
        const merchantDoc = await db.collection("users").doc(merchantId).get();
        if (!merchantDoc.exists) {
            logger.warn(`Merchant profile not found: ${merchantId}`);
            return;
        }

        const merchantData = merchantDoc.data();
        const fcmToken = merchantData.fcmToken;

        if (!fcmToken) {
            logger.warn(`Merchant does not possess active FCM token registration: ${merchantId}`);
            return;
        }

        // Send high-priority push notification playing custom arpeggio MP3 (Rule 10 & Section 8)
        const payload = {
            token: fcmToken,
            notification: {
                title: "🚨 URGENT: New Incoming Order!",
                body: `Incoming prep assignment ₹${orderData.totals.total}. Accept order within 3 minutes.`
            },
            android: {
                priority: "high",
                notification: {
                    sound: "order_alert", // triggers order_alert.mp3 sound inside android res/raw/
                    channelId: "critical_alerts_channel",
                    vibrateTimings: ["500ms", "1000ms", "500ms", "1000ms"],
                    priority: "max",
                    visibility: "public"
                }
            }
        };

        const response = await admin.messaging().send(payload);
        logger.log(`Critical FCM arpeggio alert successfully dispatched: ${response}`);

    } catch (error) {
        logger.error(`Failed to dispatch critical merchant notification trigger:`, error);
    }
});

/**
 * 2. [ADMIN VETTING TRIGGER]: Triggers role sync when admin approves merchant profile
 * Triggers on document updates inside /merchants collection.
 */
exports.onListingVetted = onDocumentUpdated("merchants/{merchantId}", async (event) => {
    const beforeData = event.data.before.data();
    const afterData = event.data.after.data();
    const merchantId = event.params.merchantId;

    // Check if status changed to approved
    if (beforeData.status !== "approved" && afterData.status === "approved") {
        logger.log(`Merchant ${merchantId} has been vetted and approved by Admin.`);

        try {
            // Update app-wide user role to "merchant" in the master users collection
            await db.collection("users").doc(merchantId).update({
                role: "merchant",
                lastActive: admin.firestore.FieldValue.serverTimestamp()
            });

            logger.log(`AppUser role sync completed successfully for UID: ${merchantId}`);

        } catch (error) {
            logger.error(`Failed to execute user role sync transaction:`, error);
        }
    }
});

/**
 * 3. [GEO DISPATCH DISPATCHER]: Assign closest e-rickshaw driver (Proximity checks)
 * Triggered on Order status transitioning to 'confirmed' / 'preparing'.
 */
exports.assignRiderToOrder = onDocumentUpdated("orders/{orderId}", async (event) => {
    const afterData = event.data.after.data();
    const orderId = event.params.orderId;

    // Only assign rider on transition to 'confirmed' (preparing state)
    if (event.data.before.data().status !== "confirmed" && afterData.status === "confirmed") {
        logger.log(`Order ${orderId} confirmed. Initializing captive e-rickshaw dispatch loop.`);

        try {
            const merchantId = afterData.merchantId;
            
            // Query closest online available riders linked to this merchant (Proximity Section 10 Phase 3)
            const ridersSnapshot = await db.collection("riders")
                .where("merchantId", isEqualTo: merchantId)
                .where("isOnline", "==", true)
                .where("status", "==", "available")
                .limit(5)
                .get();

            if (ridersSnapshot.empty) {
                logger.warn(`No online captive e-rickshaw riders available for merchant: ${merchantId}`);
                return;
            }

            // Assign the first available rider (in production, compute standard distance matrices)
            const selectedRiderDoc = ridersSnapshot.docs[0];
            const riderId = selectedRiderDoc.id;
            const riderData = selectedRiderDoc.data();

            // Update order doc with assigned rider and update rider status to busy
            const batch = db.batch();
            
            batch.update(db.collection("orders").doc(orderId), {
                riderId: riderId,
                status: "preparing"
            });

            batch.update(db.collection("riders").doc(riderId), {
                status: "busy"
            });

            await batch.commit();

            logger.log(`Successfully dispatched e-rickshaw Rider: ${riderData.name} (${riderId}) to Order: ${orderId}`);

        } catch (error) {
            logger.error(`Error in captive e-rickshaw rider auto-assignment dispatch:`, error);
        }
    }
});
