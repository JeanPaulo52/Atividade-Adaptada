        import { initializeApp } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-app.js";
        import { getAuth, onAuthStateChanged } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-auth.js";
        import { getFirestore, doc, getDoc } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-firestore.js";

        const firebaseConfig = {
            apiKey: "AIzaSyDmMuftAqoUBEoGHXtV0C_SZVHp5KmdNn4",
            authDomain: "atividadeadaptada.firebaseapp.com",
            projectId: "atividadeadaptada",
            storageBucket: "atividadeadaptada.firebasestorage.app",
            messagingSenderId: "37982590936",
            appId: "1:37982590936:web:f0bd7b5c5dd208e26a84ad"
        };

        const app = initializeApp(firebaseConfig);
        const auth = getAuth(app);
        const db = getFirestore(app);

        // Aguardar DOM carregar
        document.addEventListener('DOMContentLoaded', () => {
            onAuthStateChanged(auth, async (user) => {
                const desktopBtn = document.getElementById('login-btn-desktop');
                const mobileBtn = document.getElementById('login-btn-mobile');

                if (!desktopBtn || !mobileBtn) {
                    console.error('Botões não encontrados!');
                    return;
                }

                if (user) {
                    // Usuário logado: substituir por inicial do nome (rápido)
                    const initial = (user.displayName || user.email || 'U').charAt(0).toUpperCase();
                    const svg = `<svg width="40" height="40" viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="20" cy="20" r="20" fill="#3B82F6"/><text x="20" y="25" font-family="Arial" font-size="16" fill="white" text-anchor="middle">${initial}</text></svg>`;
                    const photoURL = `data:image/svg+xml;base64,${btoa(svg)}`;

                    // Substituir desktop
                    const desktopLink = document.createElement('a');
                    desktopLink.href = 'usuario.html';
                    desktopLink.className = 'hidden md:block';
                    desktopLink.innerHTML = `<img src="${photoURL}" class="w-10 h-10 rounded-full border-2 border-orange-500" alt="Perfil">`;
                    desktopBtn.parentNode.replaceChild(desktopLink, desktopBtn);

                    // Substituir mobile
                    const mobileLink = document.createElement('a');
                    mobileLink.href = 'usuario.html';
                    mobileLink.className = 'block mt-4';
                    mobileLink.innerHTML = `<img src="${photoURL}" class="w-10 h-10 rounded-full border-2 border-orange-500 mx-auto" alt="Perfil">`;
                    mobileBtn.parentNode.replaceChild(mobileLink, mobileBtn);

                    // Opcional: tentar atualizar com foto do Firestore em background (sem bloquear)
                    setTimeout(async () => {
                        try {
                            const profileRef = doc(db, 'users', user.uid);
                            const profileSnap = await getDoc(profileRef);
                            if (profileSnap.exists() && profileSnap.data().photoURL) {
                                const newPhotoURL = profileSnap.data().photoURL;
                                // Atualizar as imagens existentes
                                const desktopImg = desktopLink.querySelector('img');
                                const mobileImg = mobileLink.querySelector('img');
                                if (desktopImg) desktopImg.src = newPhotoURL;
                                if (mobileImg) mobileImg.src = newPhotoURL;
                            }
                        } catch (error) {
                            console.error('Erro ao buscar foto do Firestore:', error);
                        }
                    }, 100); // Pequeno delay para não interferir
                } else {
                    // Usuário não logado: manter como está
                }
            });
        });