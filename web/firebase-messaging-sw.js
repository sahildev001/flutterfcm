importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
   apiKey: 'AIzaSyApi68YhyHladlwRvMTa7M8F_mOwcEHAnQ',
    appId: '1:1079259920025:web:2ce64d8903bc2fede6aa08',
      messagingSenderId: '1079259920025',
      projectId: 'flutterfirebase-7fe99',
      authDomain: 'flutterfirebase-7fe99.firebaseapp.com',
      storageBucket: 'flutterfirebase-7fe99.appspot.com',
      databaseURL: 'https://flutterfirebase-7fe99-default-rtdb.firebaseio.com',
      measurementId: 'G-0274H0WPTQ',
});
// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessage", m);
});