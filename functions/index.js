const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();


// looks for opponent, found -> join chat, else => create chat
exports.requestChat = functions
  .runWith({ enforceAppCheck: true })
  .https.onCall(async (data, context) => {

    //Authentication 
    if (context.app == undefined) {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'The function must be called from an App Check verified app.');
    }

    // init
    const uid = context.auth.uid;
    const stance = data.stance;
    const topic = data.topic;
    const chatsCollection = admin.firestore().collection("chats");
    const chatsSnap = await chatsCollection
      .where('topic', '==', topic)
      .where(stance, "==", 'null')
      .orderBy('time')
      .limit(1).get();
    let yay;
    let nay;
    let chatID = "null";
    let found = false;

    // has opponent been found
    if (!chatsSnap.empty) {
      // join Chat, return opponent
      found = true;
      const chat = chatsSnap.docs.at(0);
      chatID = chat.id;
      // update chat with user
      if (stance == "yay") {
        await chatsCollection.doc(chatID).update({ yay: uid });
      } else {
        await chatsCollection.doc(chatID).update({ nay: uid });
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

      const data = {
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

    const response = {
      found: found,
      chat: chatID,
    }

    return response;
  });



exports.deleteChat = functions.runWith({ timeoutSeconds: 540, memory: '2GB' }).database.ref('/presence/{chatID}/{uid}/active').onUpdate(async (change, context) => {
  //function fires when a users active value has changed
  if (change.after.val() == false) {//user has gone offline
    const database = admin.database();
    const chatID = context.params.chatID;
    const usersID = context.params.uid;
    let opponentActive; //set to false if there is no opponent
    let opponentUserID;

    //get opponent chatID
    const snapChat = await database.ref('/presence/' + chatID).get();
    const numChildren = snapChat.numChildren();
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
    } else { //numChildren is equal to 1, the user has started searching but left 
      // before finding a match
      opponentActive = false;
    }
    //delete chat
    if (opponentActive == false) {
      //updating user ratings 
      const chatsDocRef = admin.firestore().collection("chats").doc(chatID);
      const chatSnap = await chatsDocRef.get();
      const chat = chatSnap.data();
      await updateReputation(chat.nay, chat.yayReview);
      await updateReputation(chat.yay, chat.nayReview);
      //delete chat from firestore
      if (chat.save == false) {
        await admin.firestore().recursiveDelete(chatsDocRef);
      }
      //delete chat from realtime  database
      await database.ref('/presence/' + chatID).remove().then(() => {
        functions.logger.log('//// ', chatsDocRef.path, ' delete successful');
      }).catch((error) => {
        functions.logger.log('//// ', chatsDocRef.path, ' delete unsuccessful: ', error);
      });
    }
  }
  return true;
});


async function updateReputation(uid, review) {
  if (review != "") {//no review was given so no update occurs
    const userRef = admin.firestore().collection("users").doc(uid);
    const userSnap = await userRef.get();
    let reputation = userSnap.data().reputation;
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


exports.deleteUserData = functions.auth.user().onDelete((user) => {
  const  uid = user.uid;
  const userRef = admin.firestore().collection("users").doc(uid);
  userRef.delete().then(() => {
      functions.logger.log('//// ', uid, ' delete successful');
    }).catch(() => {
      functions.logger.log('//// ', uid, ' delete unsuccessful');
    });
  return true;
});


exports.createUserData = functions.auth.user().onCreate((user) => {
  const uid = user.uid;
  const userRef = admin.firestore().collection("users");
  userRef.doc(uid).set({
    'reputation': 50,
    'username': user.displayName
  })
    .then(() => {
      functions.logger.log('//// ', uid, ' created successful');
    }).catch(() => {
      functions.logger.log('//// ', uid, ' created unsuccessful');
    });
  return true;
});

