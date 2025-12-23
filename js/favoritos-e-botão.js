        import { initializeApp } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-app.js";
        import { getAuth, onAuthStateChanged } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-auth.js";
        import { getFirestore, doc, setDoc, deleteDoc, getDoc, collection, query, where, getDocs } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-firestore.js";

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

        let currentUser = null;
        const activityTitle = document.getElementById('activity-title').innerText;
        const activityId = activityTitle.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, ''); // ID limpo do título
        const activityImage = document.querySelector('.preview-a4 img').src;
        const favoriteBtn = document.getElementById('favorite-btn');

        // Verificar autenticação
        onAuthStateChanged(auth, async (user) => {
            currentUser = user;

            // Personalizar botão de login
            const desktopBtn = document.getElementById('login-btn-desktop');
            const mobileBtn = document.getElementById('login-btn-mobile');

            if (desktopBtn && mobileBtn) {
                if (user) {
                    // Usuário logado: substituir por inicial do nome (rápido)
                    const initial = (user.displayName || user.email || 'U').charAt(0).toUpperCase();
                    const svg = `<svg width="40" height="40" viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="20" cy="20" r="20" fill="#3B82F6"/><text x="20" y="25" font-family="Arial" font-size="16" fill="white" text-anchor="middle">${initial}</text></svg>`;
                    const photoURL = `data:image/svg+xml;base64,${btoa(svg)}`;

                    // Substituir desktop
                    const desktopLink = document.createElement('a');
                    desktopLink.href = '/usuario.html';
                    desktopLink.className = 'hidden md:block';
                    desktopLink.innerHTML = `<img src="${photoURL}" class="w-10 h-10 rounded-full border-2 border-orange-500" alt="Perfil">`;
                    desktopBtn.parentNode.replaceChild(desktopLink, desktopBtn);

                    // Substituir mobile
                    const mobileLink = document.createElement('a');
                    mobileLink.href = '/usuario.html';
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
            }

            // Lógica para favoritos
            if (user) {
                await checkFavoriteStatus();
            } else {
                if (favoriteBtn) favoriteBtn.style.display = 'none'; // Esconder se não logado
            }
        });

        // Verificar se já é favorito
        async function checkFavoriteStatus() {
            if (!currentUser || !favoriteBtn) return;
            try {
                const favoriteRef = doc(db, 'users', currentUser.uid, 'favorites', activityId);
                const docSnap = await getDoc(favoriteRef);
                updateFavoriteButton(docSnap.exists());
            } catch (error) {
                console.error('Erro ao verificar favorito:', error);
            }
        }

        // Atualizar botão
        function updateFavoriteButton(isFavorite) {
            if (!favoriteBtn) return;
            const svg = favoriteBtn.querySelector('svg');
            if (isFavorite) {
                svg.classList.add('text-red-500', 'fill-current');
                svg.classList.remove('text-gray-400');
                favoriteBtn.title = 'Remover dos favoritos';
            } else {
                svg.classList.remove('text-red-500', 'fill-current');
                svg.classList.add('text-gray-400');
                favoriteBtn.title = 'Adicionar aos favoritos';
            }
        }

        // Toggle favorito
        if (favoriteBtn) {
            favoriteBtn.addEventListener('click', async () => {
                if (!currentUser) {
                    alert('Faça login para favoritar atividades.');
                    return;
                }

                console.log('Toggling favorite for:', activityId);

                try {
                    const favoriteRef = doc(db, 'users', currentUser.uid, 'favorites', activityId);
                    const docSnap = await getDoc(favoriteRef);

                    if (docSnap.exists()) {
                        // Remover favorito
                        console.log('Removing favorite');
                        await deleteDoc(favoriteRef);
                        updateFavoriteButton(false);
                        showMessage('Removido dos favoritos!', 'success');
                    } else {
                        // Adicionar favorito
                        console.log('Adding favorite');
                        await setDoc(favoriteRef, {
                            id: activityId,
                            title: activityTitle,
                            image: activityImage,
                            url: window.location.href,
                            date: new Date().toISOString()
                        });
                        updateFavoriteButton(true);
                        showMessage('Adicionado aos favoritos!', 'success');
                    }
                } catch (error) {
                    console.error('Erro detalhado ao toggle favorito:', error);
                    showMessage('Erro ao salvar favorito.', 'error');
                }
            });
        }

        // Mostrar mensagem
        function showMessage(msg, type) {
            // Criar elemento de mensagem temporária
            const messageEl = document.createElement('div');
            messageEl.className = `fixed top-20 right-4 px-4 py-2 rounded-lg text-white z-50 ${type === 'success' ? 'bg-green-500' : 'bg-red-500'}`;
            messageEl.innerText = msg;
            document.body.appendChild(messageEl);
            setTimeout(() => messageEl.remove(), 3000);
        }