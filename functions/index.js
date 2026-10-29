// Sends an FCM push for every new in-app notification so users hear about
// friend requests and group invites even when the app is closed.
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

const INVALID_TOKEN_CODES = new Set([
  "messaging/invalid-registration-token",
  "messaging/registration-token-not-registered",
]);

exports.pushOnNotification = onDocumentCreated(
  "smart_split/app/users/{uid}/notifications/{notificationId}",
  async (event) => {
    const data = event.data && event.data.data();
    if (!data) return;

    const { uid, notificationId } = event.params;
    const userRef = getFirestore().doc(`smart_split/app/users/${uid}`);
    const user = await userRef.get();
    const tokens = (user.get("fcmTokens") || []).filter(Boolean);
    if (tokens.length === 0) return;

    const response = await getMessaging().sendEachForMulticast({
      tokens,
      notification: { title: data.title || "", body: data.body || "" },
      data: {
        type: String(data.type || ""),
        refId: String(data.refId || ""),
        notificationId,
      },
      android: {
        priority: "high",
        // Same channel + tag as the app's local notification, so a push that
        // arrives while the app is open replaces it instead of duplicating.
        notification: { channelId: "social", tag: notificationId },
      },
    });

    const stale = [];
    response.responses.forEach((r, i) => {
      if (!r.success && r.error && INVALID_TOKEN_CODES.has(r.error.code)) {
        stale.push(tokens[i]);
      }
    });
    if (stale.length > 0) {
      await userRef.update({ fcmTokens: FieldValue.arrayRemove(...stale) });
    }
  }
);
