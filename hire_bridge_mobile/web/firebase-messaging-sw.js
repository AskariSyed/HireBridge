importScripts('https://www.gstatic.com/firebasejs/9.22.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.22.1/firebase-messaging-compat.js');

firebase.initializeApp({
    apiKey: 'AIzaSyDdKCuYdaY3FuIajayBz-16uJVFDjiDEUM',
    appId: '1:82967259176:web:cb4bedc858fa437bc6ed1d',
    messagingSenderId: '82967259176',
    projectId: 'hirebridge-c28e9',
    authDomain: 'hirebridge-c28e9.firebaseapp.com',
    storageBucket: 'hirebridge-c28e9.firebasestorage.app',
    measurementId: 'G-7F5YX99B82'
});

const messaging = firebase.messaging();
