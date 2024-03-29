# hottake
### Description
 A chat application that allows you to engage in debates with anonymous individuals. You can select a topic and take a
 stance, and then debate with someone who holds the opposing view. After the debate concludes, you have the opportunity to
 rate your opponent. These ratings will be displayed next to your name whenever you participate in a debate.
 The application is available for both Android and Web platforms. For demo purposes, you can talk to ChatGPT
 if you go to the topic 'AI is Dangerous' and pick 'For'. This helps demo the app when you are the only current user.

### Images

<p float="left">
  <img src="https://user-images.githubusercontent.com/88403974/226691142-c04b7df1-8111-45fe-bf16-99ec85e7ab8f.png" width="250" />
  <img src="https://user-images.githubusercontent.com/88403974/226691907-26d9b6ff-92a9-49fa-bb3d-8be4abd6fc96.png" width="250" /> 
  <img src="https://user-images.githubusercontent.com/88403974/226692927-48989618-c83b-412b-9c04-a515f18dbc0c.png" width="250" />
</p>
<p float="left">
  <img src="https://user-images.githubusercontent.com/88403974/226692949-6aabb517-ddd6-49d3-8d70-61608c1ade15.png" width="250" />
  <img src="https://user-images.githubusercontent.com/88403974/226692957-9090ad3d-8b98-45f7-8552-4a43efd50496.png" width="250" />
  <img src="https://user-images.githubusercontent.com/88403974/226692971-bb68b94b-75a1-4be4-985f-c5cae01e8adb.png" width="250" />
</p>

### Technologies
   This app uses Flutter for the frontend and Firebase for the backend. My experience with flutter was decent, I enjoyed working with
   dart and building UI for Mobile but had trouble with state management and struggled to make flutter web feel like a website.
   Firebase was a pleasure to use since it is possible to stay within the free usage limits while developing an app. Services like Authentication
   are also provided but firebase. The only issue I had with firebase was that after using the Firestore for a bit I found out that there was
   no onDisconnect function available so I ended up using both the Realtime Database and the Firestore.

### Functionality 
  1. Topics are stored in a collection in the Firebase Firestore
  2. The app fetches the topics and shows them as buttons on the home page
  3. The user clicks on a topic and then is asked to pick a side (for or against the topic)
  4. An HTTP request (Firebase Functions) is made and a Chat Room ID is returned to the app
  5. A chat room loads in and the users can debate the topic
  6. Once a user is done debating then they can end the chat with a button
  7. When the chat has ended the users are able to rate their interaction with the opposing user
  8. Messages, chat room, and user data are stored in the Firestore while the chat goes on and is deleted when the chat ends.
  9. Users can change their usernames and see their reputation on the settings page.
  10. User can create an accout or use thier google account to make an accout.
  11. You can talk to a chat bot if you go to the topic 'AI is Dangerous' and pick 'For'. This helps demo when you are the only user.

### How to run
1. Install Flutter <br> https://docs.flutter.dev/get-started/install
2. Create a Firebase account <br> https://console.firebase.google.com/
3. Install Firebase <br> https://firebase.google.com/docs/flutter/setup?platform=ios
5. If you enable App Check in Firebase then you will need to use debug keys to run locally 
6. Files not included in repository:
    * lib/shared/private.dart (Contains reCapchta key for web App Check)
    * android/app/google-services.json (For android authentication, follow instructions in step 3)
    * lib/firebase_options.dart (Created when you init firebase in step 3)
    * web/token.js (For android apk authentication if you decide to upload to Play Store)

### Why

This app is a personal project I worked on to learn more about how Flutter work, mainly on how one codebase can be used to make apps on many platforms. I will also use this project on my developer portfolio.

### Database Structure
Firebase 
<p float="left">
  <img src="https://user-images.githubusercontent.com/88403974/227812636-95b98811-811c-4f40-a080-5caae3a694d3.png" width="350" />
  <img src="https://user-images.githubusercontent.com/88403974/227813109-428b711f-b09c-4eb5-bbc9-3bac2f0d4467.png" width="250" />
</p>
notes: 

  * The chats collection the path is actualy /chats/$topics/chats ,since it not necessary to search chats across topics, they are divided by topic. Firebase uses a collection -> doc -> collection -> doc stucture.
  * presences path is actualy /chats/$topics/presence following the chats collection structure. Realtime database uses JSON format.
