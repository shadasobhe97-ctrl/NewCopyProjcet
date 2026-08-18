const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendChatNotification = functions.firestore
  .document("chat_rooms/{chatRoomId}/messages/{messageId}")
  .onCreate(async (snap, context) => {
    const messageData = snap.data();
    const chatRoomId = context.params.chatRoomId;

    // 1. تحديد من أرسل الرسالة
    const senderId = messageData.sender_id || messageData.senderId;
    const messageType = messageData.type || "text";

    // 2. صياغة نص الإشعار
    let bodyText = messageData.message;
    if (messageType === "image") bodyText = "📷 أرسل صورة";
    if (messageType === "video") bodyText = "🎥 أرسل فيديو";
    if (messageType === "audio") bodyText = "🎤 أرسل رسالة صوتية";

    // 3. جلب بيانات الغرفة
    const roomSnap = await admin.firestore().collection("chat_rooms").doc(chatRoomId).get();
    const roomData = roomSnap.data();

    if (!roomData) return null;

    let receiverId = "";
    let senderName = "رسالة جديدة";

    // تحديد الطرف المستقبل
    if (senderId === roomData.parent_id) {
       receiverId = roomData.driver_id;
       senderName = roomData.parent_name || "ولي الأمر";
    } else {
       receiverId = roomData.parent_id;
       senderName = roomData.driver_name || "السائق";
    }

    if (!receiverId) return null;

    // 4. جلب الـ FCM Token الخاص بالمستقبل من الفايربيز
    const userSnap = await admin.firestore().collection("users").doc(receiverId).get();
    if (!userSnap.exists || !userSnap.data().fcm_token) {
        console.log("لا يوجد توكن لهذا المستخدم:", receiverId);
        return null;
    }

    const fcmToken = userSnap.data().fcm_token;

    // 5. إرسال الإشعار
    const payload = {
      token: fcmToken,
      notification: {
        title: senderName,
        body: bodyText,
      },
      data: {
        type: "chat_message",
        chat_room_id: chatRoomId,
      }
    };

    return admin.messaging().send(payload)
      .then((response) => console.log("تم إرسال الإشعار بنجاح:", response))
      .catch((error) => console.error("خطأ في إرسال الإشعار:", error));
  });