const functions = require('firebase-functions');
const admin = require('firebase-admin');
const Firestore = require('@google-cloud/firestore');
const { database } = require("firebase-admin");
admin.initializeApp();
const firestore = new Firestore({
  projectId: process.env.GOOGLE_CLOUD_PROJECT,
});

// looks for opponent, found -> join chat, else => create chat
exports.requestChat = functions.https.onCall(async (data, context) => {

  // init
  const uid = context.auth.uid;
  var found = false;
  var stance = data.stance;
  var topic = data.topic;
  var chatsCollection = admin.firestore().collection("chats");
  var yay;
  var nay;
  var chatID = "null";
  var database = admin.database();
  var chatsSnap = await chatsCollection.where(stance, "==", "null").orderBy("time").limit(100).get();
  // has opponent been found
  if (!chatsSnap.empty) {
    // join Chat, return opponent
    found = true;
    var chat = chatsSnap.docs.at(0);
    chatID = chat.id;
    // update chat with user
    if (stance == "yay") {
      chatsCollection.doc(chatID).update({ yay: uid });
    } else {
      chatsCollection.doc(chatID).update({ nay: uid });
    }
  } else { //Opponent not found
    // create Chat
    if (stance == "yay") {
      yay = uid;
      nay = "null";
    } else {
      yay = "null";
      nay = uid;
    }

    var data = {
      save: "false",
      nay: nay,
      yay: yay,
      topic: topic,
      time: new Date()
    };
    //create chat in chats
    await chatsCollection.add(data).then((documentSnapshot) =>
      chatID = documentSnapshot.id);
    await chatsCollection.doc(chatID).collection("messages").add({
      content: topic,
      owner: "admin",
      time: new Date()
    });
  }

  functions.logger.log("//// chatID: ", chatID);

  response = {
    found: found,
    chat: chatID,
  }

  return response;
});



exports.deleteChat = functions.runWith({timeoutSeconds: 540, memory: '2GB'}).database.ref('/presence/{chatID}/{uid}/active').onUpdate(async (change, context) => {
  const newValue = change.after.val();
  if (newValue == "false") {
    const database = admin.database();
    const chatID = context.params.chatID;
    var active;
    var userID;

    //get opponent chatID
    const snapChat = await database.ref('/presence/' + chatID).get();
    snapChat.forEach((value) => {
      if (value.key != context.params.uid) {
        userID = value.key;
      }
    });

    //get opponent active value
    const snap = await database.ref('/presence/' + chatID + '/' + userID + '/active').get();
    const v = snap.val();
    if (v == "true") {
      active = true;
    } else {
      active = false;
    }

    //delete chat
    functions.logger.log('active: ', active);
    if (active == false) {
      const chatsDocRef = admin.firestore().collection("chats").doc(chatID);
      const chatSnap = await chatsDocRef.get();
      const save = chatSnap.data().save;
      if (save == 'false') {
        const path = chatsDocRef.path;
        functions.logger.log('path to delete: ', path);
        admin.firestore().recursiveDelete(chatsDocRef);
      }
      //delete chat from presence
      database.ref('/presence/' + chatID).remove();
      return true;
    }
  }
  return true;
});
