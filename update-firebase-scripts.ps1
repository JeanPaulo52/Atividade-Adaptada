# Script PowerShell para atualizar scripts Firebase em páginas HTML

$workspacePath = "c:\Users\jean\Desktop\Atividade Adaptada.com"

# Scripts combinados
$activityScript = @"
    <!-- Scripts Firebase combinados para personalizar botão e favoritos -->
    <script type="module">
        import { initializeApp } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-app.js";
        import { getAuth, onAuthStateChanged } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-auth.js";
        import { getFirestore, doc, setDoc, deleteDoc, getDoc } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-firestore.js";

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
        const activityId = activityTitle.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');
        const activityImage = document.querySelector('.preview-a4 img').src;
        const favoriteBtn = document.getElementById('favorite-btn');

        onAuthStateChanged(auth, async (user) => {
            currentUser = user;

            const desktopBtn = document.getElementById('login-btn-desktop');
            const mobileBtn = document.getElementById('login-btn-mobile');

            if (desktopBtn && mobileBtn) {
                if (user) {
                    const initial = (user.displayName || user.email || 'U').charAt(0).toUpperCase();
                    const svg = `<svg width="40" height="40" viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="20" cy="20" r="20" fill="#3B82F6"/><text x="20" y="25" font-family="Arial" font-size="16" fill="white" text-anchor="middle">${initial}</text></svg>`;
                    const photoURL = `data:image/svg+xml;base64,${btoa(svg)}`;

                    const desktopLink = document.createElement('a');
                    desktopLink.href = '/usuario.html';
                    desktopLink.className = 'hidden md:block';
                    desktopLink.innerHTML = `<img src="${photoURL}" class="w-10 h-10 rounded-full border-2 border-orange-500" alt="Perfil">`;
                    desktopBtn.parentNode.replaceChild(desktopLink, desktopBtn);

                    const mobileLink = document.createElement('a');
                    mobileLink.href = '/usuario.html';
                    mobileLink.className = 'block mt-4';
                    mobileLink.innerHTML = `<img src="${photoURL}" class="w-10 h-10 rounded-full border-2 border-orange-500 mx-auto" alt="Perfil">`;
                    mobileBtn.parentNode.replaceChild(mobileLink, mobileBtn);

                    setTimeout(async () => {
                        try {
                            const profileRef = doc(db, 'users', user.uid);
                            const profileSnap = await getDoc(profileRef);
                            if (profileSnap.exists() && profileSnap.data().photoURL) {
                                const newPhotoURL = profileSnap.data().photoURL;
                                const desktopImg = desktopLink.querySelector('img');
                                const mobileImg = mobileLink.querySelector('img');
                                if (desktopImg) desktopImg.src = newPhotoURL;
                                if (mobileImg) mobileImg.src = newPhotoURL;
                            }
                        } catch (error) {
                            console.error('Erro ao buscar foto do Firestore:', error);
                        }
                    }, 100);
                } else {
                }
            }

            if (user) {
                await checkFavoriteStatus();
            } else {
                if (favoriteBtn) favoriteBtn.style.display = 'none';
            }
        });

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

        if (favoriteBtn) {
            favoriteBtn.addEventListener('click', async () => {
                if (!currentUser) {
                    alert('Faça login para favoritar atividades.');
                    return;
                }

                try {
                    const favoriteRef = doc(db, 'users', currentUser.uid, 'favorites', activityId);
                    const docSnap = await getDoc(favoriteRef);

                    if (docSnap.exists()) {
                        await deleteDoc(favoriteRef);
                        updateFavoriteButton(false);
                        showMessage('Removido dos favoritos!', 'success');
                    } else {
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
                    console.error('Erro ao toggle favorito:', error);
                    showMessage('Erro ao salvar favorito.', 'error');
                }
            });
        }

        function showMessage(msg, type) {
            const messageEl = document.createElement('div');
            messageEl.className = `fixed top-20 right-4 px-4 py-2 rounded-lg text-white z-50 ${type === 'success' ? 'bg-green-500' : 'bg-red-500'}`;
            messageEl.innerText = msg;
            document.body.appendChild(messageEl);
            setTimeout(() => messageEl.remove(), 3000);
        }
    </script>
"@

$articleScript = @"
    <!-- Scripts Firebase combinados para personalizar botão e favoritos -->
    <script type="module">
        import { initializeApp } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-app.js";
        import { getAuth, onAuthStateChanged } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-auth.js";
        import { getFirestore, doc, setDoc, deleteDoc, getDoc } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-firestore.js";

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
        const articleTitle = document.querySelector('h1').innerText;
        const articleId = articleTitle.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');
        const articleImage = document.querySelector('img') ? document.querySelector('img').src : '/Assets/default-image.jpg';
        const favoriteBtn = document.getElementById('favorite-btn');

        onAuthStateChanged(auth, async (user) => {
            currentUser = user;

            const desktopBtn = document.getElementById('login-btn-desktop');
            const mobileBtn = document.getElementById('login-btn-mobile');

            if (desktopBtn && mobileBtn) {
                if (user) {
                    const initial = (user.displayName || user.email || 'U').charAt(0).toUpperCase();
                    const svg = `<svg width="40" height="40" viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="20" cy="20" r="20" fill="#3B82F6"/><text x="20" y="25" font-family="Arial" font-size="16" fill="white" text-anchor="middle">${initial}</text></svg>`;
                    const photoURL = `data:image/svg+xml;base64,${btoa(svg)}`;

                    const desktopLink = document.createElement('a');
                    desktopLink.href = '/usuario.html';
                    desktopLink.className = 'hidden md:block';
                    desktopLink.innerHTML = `<img src="${photoURL}" class="w-10 h-10 rounded-full border-2 border-orange-500" alt="Perfil">`;
                    desktopBtn.parentNode.replaceChild(desktopLink, desktopBtn);

                    const mobileLink = document.createElement('a');
                    mobileLink.href = '/usuario.html';
                    mobileLink.className = 'block mt-4';
                    mobileLink.innerHTML = `<img src="${photoURL}" class="w-10 h-10 rounded-full border-2 border-orange-500 mx-auto" alt="Perfil">`;
                    mobileBtn.parentNode.replaceChild(mobileLink, mobileBtn);

                    setTimeout(async () => {
                        try {
                            const profileRef = doc(db, 'users', user.uid);
                            const profileSnap = await getDoc(profileRef);
                            if (profileSnap.exists() && profileSnap.data().photoURL) {
                                const newPhotoURL = profileSnap.data().photoURL;
                                const desktopImg = desktopLink.querySelector('img');
                                const mobileImg = mobileLink.querySelector('img');
                                if (desktopImg) desktopImg.src = newPhotoURL;
                                if (mobileImg) mobileImg.src = newPhotoURL;
                            }
                        } catch (error) {
                            console.error('Erro ao buscar foto do Firestore:', error);
                        }
                    }, 100);
                } else {
                }
            }

            if (user) {
                await checkFavoriteStatus();
            } else {
                if (favoriteBtn) favoriteBtn.style.display = 'none';
            }
        });

        async function checkFavoriteStatus() {
            if (!currentUser || !favoriteBtn) return;
            try {
                const favoriteRef = doc(db, 'users', currentUser.uid, 'articles', articleId);
                const docSnap = await getDoc(favoriteRef);
                updateFavoriteButton(docSnap.exists());
            } catch (error) {
                console.error('Erro ao verificar favorito:', error);
            }
        }

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

        if (favoriteBtn) {
            favoriteBtn.addEventListener('click', async () => {
                if (!currentUser) {
                    alert('Faça login para favoritar artigos.');
                    return;
                }

                try {
                    const favoriteRef = doc(db, 'users', currentUser.uid, 'articles', articleId);
                    const docSnap = await getDoc(favoriteRef);

                    if (docSnap.exists()) {
                        await deleteDoc(favoriteRef);
                        updateFavoriteButton(false);
                        showMessage('Removido dos favoritos!', 'success');
                    } else {
                        await setDoc(favoriteRef, {
                            id: articleId,
                            title: articleTitle,
                            image: articleImage,
                            url: window.location.href,
                            date: new Date().toISOString()
                        });
                        updateFavoriteButton(true);
                        showMessage('Adicionado aos favoritos!', 'success');
                    }
                } catch (error) {
                    console.error('Erro ao toggle favorito:', error);
                    showMessage('Erro ao salvar favorito.', 'error');
                }
            });
        }

        function showMessage(msg, type) {
            const messageEl = document.createElement('div');
            messageEl.className = `fixed top-20 right-4 px-4 py-2 rounded-lg text-white z-50 ${type === 'success' ? 'bg-green-500' : 'bg-red-500'}`;
            messageEl.innerText = msg;
            document.body.appendChild(messageEl);
            setTimeout(() => messageEl.remove(), 3000);
        }
    </script>
"@

# Lista de arquivos HTML com favorite-btn
$files = @(
    "c:\Users\jean\Desktop\Atividade Adaptada.com\Nivel 2\2-BNCC\Artes\PagDow\ATD-ARTS-1\ATD-ARTS-1.html",
    "c:\Users\jean\Desktop\Atividade Adaptada.com\Nivel 2\1-pagina inicial\2-Artigos\1- Como brincar ensina\brincar-também-ensina.html",
    "c:\Users\jean\Desktop\Atividade Adaptada.com\Nivel 2\1-pagina inicial\2-Artigos\2 - A história da educação especial\história-da-educação-especial-no-Brasil.html",
    "c:\Users\jean\Desktop\Atividade Adaptada.com\Nivel 2\1-pagina inicial\2-Artigos\10-bncc educação infanil\bncc-educação-infantil.html",
    "c:\Users\jean\Desktop\Atividade Adaptada.com\Nivel 2\1-pagina inicial\2-Artigos\3 - Jogos que eninam de verdade\jogos-que-ensinam-pela-gamificação.html",
    "c:\Users\jean\Desktop\Atividade Adaptada.com\Nivel 2\1-pagina inicial\2-Artigos\4- Como Estimular a Autonomia das Crianças no Ambiente Escolar e em Casa\Como-Estimular-a-Autonomia-das-Crianças-no-Ambiente-Escolar-e-em-Casa.html",
    "c:\Users\jean\Desktop\Atividade Adaptada.com\Nivel 2\1-pagina inicial\2-Artigos\5- Atividades Simples para Desenvolver Habilidades Socioemocionais na Infância\Atividades-Simples-para-Desenvolver-Habilidades-Socioemocionais-na-Infância.html",
    "c:\Users\jean\Desktop\Atividade Adaptada.com\Nivel 2\1-pagina inicial\2-Artigos\8-A-volta-da-reprova\A-volta-da-reprova-nas-escolas-brasileiras.html",
    "c:\Users\jean\Desktop\Atividade Adaptada.com\Nivel 2\1-pagina inicial\2-Artigos\6- 5 Atitudes Simples que Mostram à Criança que Ela é Valorizada\5-Atitudes-Simples-que-Mostram-à-Criança-que-Ela-é-Valorizada.html",
    "c:\Users\jean\Desktop\Atividade Adaptada.com\Nivel 2\1-pagina inicial\2-Artigos\7- Ensinando as crianças a resolver conflitos\Ensinando-as-crianças-a-resolverem-conflitos.html",
    "c:\Users\jean\Desktop\Atividade Adaptada.com\Nivel 2\1-pagina inicial\2-Artigos\11-Habilidades-da-BNCC-Educação-Infantil\Habilidades-da-BNCC-Educação-Infantil.html",
    "c:\Users\jean\Desktop\Atividade Adaptada.com\Nivel 2\1-pagina inicial\2-Artigos\12-6-atividades-matematicas\As Melhores Atividades de Matemática para Educação Infantil.html",
    "c:\Users\jean\Desktop\Atividade Adaptada.com\Nivel 2\1-pagina inicial\2-Artigos\13_concurso_educacao_guaruja\concurso_educacao_guaruja.html",
    "c:\Users\jean\Desktop\Atividade Adaptada.com\Nivel 2\1-pagina inicial\2-Artigos\Atividade-para-educação-infantil\atividades-para-educação-infantil.html",
    "c:\Users\jean\Desktop\Atividade Adaptada.com\Nivel 2\1-pagina inicial\2-Artigos\14_alfabetização_infantil\alfabetização_infantil.html",
    "c:\Users\jean\Desktop\Atividade Adaptada.com\Nivel 2\1-pagina inicial\2-Artigos\praticas-pedagogicas-inovadoras\praticas-pedagogicas-na-educação-infantil.html",
    "c:\Users\jean\Desktop\Atividade Adaptada.com\Nivel 2\1-pagina inicial\2-Artigos\15_A_Importância_da_Música_na_Educação_Infantil_Estímulo_à_Linguagem_e_à_Criatividade\A_Importância_da_Música_na_Educação_Infantil_Estímulo_à_Linguagem_e_à_Criativi.html",
    "c:\Users\jean\Desktop\Atividade Adaptada.com\Nivel 2\1-pagina inicial\2-Artigos\ComoAdaptarAula\Noticia 2.html",
    "c:\Users\jean\Desktop\Atividade Adaptada.com\Nivel 2\1-pagina inicial\2-Artigos\Consciência Fonológica\Conciencia Fonologica.html",
    "c:\Users\jean\Desktop\Atividade Adaptada.com\Nivel 2\1-pagina inicial\2-Artigos\Damas - seus beneficios\Noticia 4.html",
    "c:\Users\jean\Desktop\Atividade Adaptada.com\Nivel 2\1-pagina inicial\2-Artigos\Dia do Autismo\Noticia 7.html",
    "c:\Users\jean\Desktop\Atividade Adaptada.com\Nivel 2\1-pagina inicial\2-Artigos\DiaDaDown\Noticia 4.html",
    "c:\Users\jean\Desktop\Atividade Adaptada.com\Nivel 2\1-pagina inicial\2-Artigos\O poder da leitura\Noticia 8.html",
    "c:\Users\jean\Desktop\Atividade Adaptada.com\Nivel 2\1-pagina inicial\2-Artigos\oPoder do NÃO\Noticia 6.html",
    "c:\Users\jean\Desktop\Atividade Adaptada.com\Nivel 2\1-pagina inicial\2-Artigos\OpoderdoFeedBack\Noticia 3.html",
    "c:\Users\jean\Desktop\Atividade Adaptada.com\Nivel 2\1-pagina inicial\2-Artigos\Plano Semanal de Alfabetização 5 Dias de Atividades Prontas para a Sala de Aula\Plano Semanal de Alfabetização 5 Dias de Atividades Prontas para a Sala de Aula.html"
)

$updatedCount = 0

foreach ($file in $files) {
    Write-Host "Processando $file"
    
    $content = Get-Content $file -Raw
    
    if ($content -match "<!-- Scripts Firebase combinados para personalizar botão e favoritos -->") {
        Write-Host "  Já tem o script combinado. Pulando."
        continue
    }
    
    # Determinar tipo
    $isActivity = $content -match 'id="activity-title"'
    $scriptToUse = if ($isActivity) { $activityScript } else { $articleScript }
    
    # Substituir qualquer script Firebase existente
    # Procurar por <script type="module"> que contenha firebase
    $pattern = '<script type="module">[\s\S]*?firebase[\s\S]*?</script>'
    if ($content -match $pattern) {
        $content = $content -replace $pattern, $scriptToUse
    } else {
        # Se não encontrou, adicionar antes de </body>
        $content = $content -replace '</body>', "$scriptToUse`n</body>"
    }
    
    Set-Content $file $content -Encoding UTF8
    $updatedCount++
    Write-Host "  Atualizado."
}

Write-Host "Total de páginas atualizadas: $updatedCount"