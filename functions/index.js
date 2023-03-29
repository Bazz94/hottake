const functions = require('firebase-functions');
const admin = require('firebase-admin');
const private = require('./private');
let OPENAI_API_KEY = private.OPENAI_API_KEY();
const { Configuration, OpenAIApi } = require("openai");
const configuration = new Configuration({
  apiKey: OPENAI_API_KEY,
});
// eslint-disable-next-line no-unused-vars
const openai = new OpenAIApi(configuration);
admin.initializeApp();

/* 
  This function looks for a chat to join, if there is a chat room already open 
  or if one needs to be made. In either case a chat id will be return.
*/
exports.requestChat = functions
  .runWith({ enforceAppCheck: true })
  .https.onCall(async (data, context) => {

    //kill switch 
    // eslint-disable-next-line no-constant-condition
    if (false) {
      return null;
    }

    //App Check Authentication 
    // if (context.app == undefined) {
    //   throw new functions.https.HttpsError(
    //     'failed-precondition',
    //     'The function must be called from an App Check verified app.');
    // }

    // init
    const uid = context.auth.uid;
    const stance = data.stance;
    const topic = data.topic;
    const chatsCollection = admin.firestore().collection("chats").doc(topic).collection("chats");
    let yay;
    let nay;
    let chatID = "null";
    let found = false;

    if (topic == 'AI is Dangerous' && stance == 'yay') {
      found = true;

      if (stance == "yay") {
        yay = uid;
        nay = "chatGPT";
      } else {
        yay = "chatGPT";
        nay = uid;
      }

      const data = {
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
      await chatsCollection.doc(chatID).collection("messages").add({
        content: "You are speaking to a chat bot, you go first",
        owner: "admin",
        time: new Date()
      });

      functions.logger.log("//// chatID: ", chatID);

      const response = {
        found: found,
        chat: chatID,
      }

      return response;
    }
    //if not ai


    const chatsSnap = await chatsCollection
      .where(stance, "==", 'null')
      .orderBy('time')
      .limit(1).get();

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


/*
  This function is responsible for deleting a chat room when all the users have left it.
  This includes chat data in the Firestore and Realtime database.
*/
exports.deleteChat = functions.runWith({ timeoutSeconds: 540, memory: '2GB' }).database.ref('/presence/{topic}/chats/{chatID}/{uid}/active').onUpdate(async (change, context) => {
  //function fires when a users active value has changed
  if (change.after.val() == false) {//user has gone offline
    const database = admin.database();
    const chatID = context.params.chatID;
    const usersID = context.params.uid;
    const topic = context.params.topic
    let opponentActive; //set to false if there is no opponent
    let opponentUserID;

    //get opponent chatID
    const snapChat = await database.ref('/presence/' + topic + '/chats/' + chatID).get();
    const numChildren = snapChat.numChildren();
    if (numChildren == 2) {
      snapChat.forEach((value) => {
        if (value.key != usersID) {
          opponentUserID = value.key;
        }
      });

      //get opponent active value
      const snap = await database.ref('/presence/' + topic + '/chats/' + chatID + '/' + opponentUserID + '/active').get();
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
      const chatsDocRef = admin.firestore().collection("chats").doc(topic).collection("chats").doc(chatID);
      const chatSnap = await chatsDocRef.get();
      const chat = chatSnap.data();
      await updateReputation(chat.nay, chat.yayReview);
      await updateReputation(chat.yay, chat.nayReview);
      //delete chat from firestore
      if (chat.save == false) {
        await admin.firestore().recursiveDelete(chatsDocRef);
      }
      //delete chat from realtime  database
      await database.ref('/presence/' + topic + '/chats/' + chatID).remove().then(() => {
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

/* 
  This fires when a user has been deleted from the authentication list.
  It will delete the user data in the Firestore.
*/
exports.deleteUserData = functions.auth.user().onDelete(async (user) => {
  const uid = user.uid;
  const userRef = admin.firestore().collection("users").doc(uid);
  await userRef.delete().then(() => {
    functions.logger.log('//// ', uid, ' delete successful');
  }).catch(() => {
    functions.logger.log('//// ', uid, ' delete unsuccessful');
  });
  return true;
});

/* 
  This fires when a user has been created. It creates the user data in 
  the Firestore but only if the user was created by logging in through
  google login.
*/
exports.createUserData = functions.auth.user().onCreate(async (user) => {
  if (user.displayName != null) {
    const uid = user.uid;
    const userRef = admin.firestore().collection("users");
    await userRef.doc(uid).set({
      'reputation': 50,
      'username': user.displayName
    })
      .then(() => {
        functions.logger.log('//// ', uid, ' created successful');
      }).catch(() => {
        functions.logger.log('//// ', uid, ' created unsuccessful');
      });
  }
  return true;
});


/*
  This functions matches a use with chatGPT so that they can test the app if there are no other users.
  It only works on the topic 'AI is Dangerous' and 'for' as the stance.
*/
exports.chatGPT = functions.firestore
  .document('chats/AI is Dangerous/chats/{chatID}/messages/{messageID}')
  // eslint-disable-next-line no-unused-vars
  .onCreate(async (snap, context) => {
    const owner = snap.data().owner;
    if (owner != "chatGPT" && owner != "admin") {
      const chatID = context.params.chatID;
      let messages = [];
      messages.push({
        "role": "system",
        "content": "You are debating and are against the topic AI is dangerous, only respond in 1 sentence"
      });
      const messagesRef = admin.firestore().collection("chats")
        .doc("AI is Dangerous").collection("chats").doc(chatID).collection("messages");
      const messagesCollection = await messagesRef.orderBy("time").get();

      messagesCollection.docs.forEach((value) => {
        let content = value.data().content;
        let owner = value.data().owner;
        let message;
        if (owner != "admin" && owner != "chatGPT") {
          message = { "role": "user", "content": content };
        } else if (owner == "chatGPT") {
          message = { "role": "assistant", "content": content };
        }
        if (message != null) {
          messages.push(message);
        }
      });
      if (messages.length < 12) {
        functions.logger.log("//// send request: ");
        // eslint-disable-next-line no-unused-vars
        const completion = await openai.createChatCompletion({
          model: "gpt-3.5-turbo",
          max_tokens: 50,
          messages: messages,
        }).then((value) => {
          const response = value.data.choices[0].message.content;
          console.log("//// response: ", response);
          messagesRef.add({
            content: response,
            owner: "chatGPT",
            time: new Date()
          });
          console.log("//// total tokens used: ", value.data.usage.total_tokens.toString());
        })
          .catch((reason) => {
            console.log("//// error: ", reason);
            messagesRef.add({
              content: "Chat GPT is unavailable",
              owner: "chatGPT",
              time: new Date()
            });
          });
      } else {
        messagesRef.add({
          content: "The maximum messages allowed has been reached",
          owner: "admin",
          time: new Date()
        });
        const chatRef = admin.firestore().collection("chats")
          .doc("AI is Dangerous").collection("chats");
        await chatRef.doc(chatID).update({
          'active': false,
        });
      }
    }
    return true;
  });