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
      topic: topic,
      yay: yay,
      nay: nay,
      active: true,
      save: false,
      nayReview: "",
      yayReview: "",
      time: new Date(),
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


//fuction fires when a user active value has changed
exports.deleteChat = functions.runWith({timeoutSeconds: 540, memory: '2GB'}).database.ref('/presence/{chatID}/{uid}/active').onUpdate(async (change, context) => {
  const newValue = change.after.val();
  if (newValue == false) {//user has gone offline
    const database = admin.database();
    const chatID = context.params.chatID;
    var usersID = context.params.uid;
    var opponentActive; //set to false if there is no opponent
    var opponentUserID;

    //get opponent chatID
    const snapChat = await database.ref('/presence/' + chatID).get();
    var numChildren = snapChat.numChildren();
    functions.logger.log('num children: ', numChildren);
    if (numChildren == 2) {
      snapChat.forEach((value) => {
        if (value.key != usersID) {
          opponentUserID = value.key;
        }
      });

      //get opponent active value
      const snap = await database.ref('/presence/' + chatID + '/' + opponentUserID + '/active').get();
      const value = snap.val();
      if (value == true) {
        opponentActive = true;
      } else {
        opponentActive = false;
      }
    } else { //numChildren is equal to 1, the user has started seaching but left 
            // before finding a match
      opponentActive = false;
    } 
    //delete chat
    functions.logger.log('active: ', opponentActive);
    if (opponentActive == false) {
      //updating user ratings 
      const chatsDocRef = admin.firestore().collection("chats").doc(chatID);
      const chatSnap = await chatsDocRef.get();
      const chat = chatSnap.data();
      await updateReputation(chat.nay, chat.yayReview);
      await updateReputation(chat.yay, chat.nayReview);
      //delete chat from firestore
      if (chat.save == false) {
        const path = chatsDocRef.path;
        functions.logger.log('path to delete: ', path);
        await admin.firestore().recursiveDelete(chatsDocRef);
      }
      //delete chat from presence
      await database.ref('/presence/' + chatID).remove();
      return true;
    }
  }
  return true;
});


async function updateReputation(uid, review) {
  if (review != "") {//no review was given so no update occures
    userRef = admin.firestore().collection("users").doc(uid);
    const userSnap = await userRef.get();
    var reputation = userSnap.data().reputation;
    if (review == "good") {
      reputation = reputation + 5;
      if (reputation > 100) {//max is 100
        reputation = 100;
      }
    }
    if (review == "bad") {
      reputation = reputation - 5;
      if (reputation < 0) {//min is 0
        reputation = 0;
      }
    }
    await userRef.update({ "reputation": reputation });
  }
}