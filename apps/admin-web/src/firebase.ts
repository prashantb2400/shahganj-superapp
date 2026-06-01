// apps/admin-web/src/firebase.ts
import { initializeApp } from 'firebase/app';
import { getAuth, GoogleAuthProvider } from 'firebase/auth';

const firebaseConfig = {
  apiKey: "AIzaSyDj3s7mgHG9XTp-6LOCDZNnvS-QrwOluqg",
  authDomain: "shahganj-superapp.firebaseapp.com",
  projectId: "shahganj-superapp",
  storageBucket: "shahganj-superapp.appspot.com",
  messagingSenderId: "1098278412237",
  appId: "1:1098278412237:web:8e68e4a9ab592fc689ee84"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Firebase Authentication & Google Auth Provider
export const auth = getAuth(app);
export const googleProvider = new GoogleAuthProvider();
googleProvider.setCustomParameters({ prompt: 'select_account' });
