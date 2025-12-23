// --- IMPORTAÇÕES DO FIREBASE ---
import { initializeApp } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-app.js";
import { getAuth, onAuthStateChanged } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-auth.js";
import { getFirestore, doc, setDoc, deleteDoc, getDoc, collection, query, where, getDocs } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-firestore.js";

// --- CONFIGURAÇÃO DO FIREBASE ---
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

// --- VARIÁVEIS GLOBAIS ---
let currentUser = null;
let isArticle = !!document.querySelector('h1'); // Detectar se é página de artigo
let activityTitle, activityId, activityImage, favoriteBtn, collectionName;

if (isArticle) {
    activityTitle = document.querySelector('h1').innerText;
    activityId = activityTitle.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');
    activityImage = '/Assets/article-placeholder.png'; // Imagem padrão para artigos
    favoriteBtn = document.getElementById('favorite-btn');
    collectionName = 'articles';
} else {
    activityTitle = document.getElementById('activity-title').innerText;
    activityId = activityTitle.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');
    activityImage = document.querySelector('.preview-a4 img').src;
    favoriteBtn = document.getElementById('favorite-btn');
    collectionName = 'favorites';
}

// --- LÓGICA DO MENU MOBILE ---
const mobileMenuButton = document.getElementById('mobile-menu-button');
const mobileMenu = document.getElementById('mobile-menu');
if (mobileMenuButton && mobileMenu) {
    mobileMenuButton.addEventListener('click', () => {
        mobileMenu.classList.toggle('hidden');
    });
}

// --- LÓGICA DE AUTENTICAÇÃO E FAVORITOS ---
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

// --- FUNÇÕES DE FAVORITOS ---
async function checkFavoriteStatus() {
    if (!currentUser || !favoriteBtn) return;
    try {
        const favoriteRef = doc(db, 'users', currentUser.uid, collectionName, activityId);
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
            alert(`Faça login para favoritar ${isArticle ? 'artigos' : 'atividades'}.`);
            return;
        }

        console.log('Toggling favorite for:', activityId);

        try {
            const favoriteRef = doc(db, 'users', currentUser.uid, collectionName, activityId);
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

// --- FUNÇÃO PARA MOSTRAR MENSAGENS ---
function showMessage(msg, type) {
    const messageEl = document.createElement('div');
    messageEl.className = `fixed top-20 right-4 px-4 py-2 rounded-lg text-white z-50 ${type === 'success' ? 'bg-green-500' : 'bg-red-500'}`;
    messageEl.innerText = msg;
    document.body.appendChild(messageEl);
    setTimeout(() => messageEl.remove(), 3000);
}

// --- LÓGICA DA PÁGINA (PARTILHA E RELACIONADOS) ---
document.addEventListener('DOMContentLoaded', () => {
    // --- LÓGICA DOS BOTÕES DE PARTILHA ---
    const pageUrl = window.location.href;
    const pageTitle = document.querySelector('#activity-title') ? document.querySelector('#activity-title').textContent : document.querySelector('h1').textContent;
    const shareText = `Confira ${isArticle ? 'este artigo' : 'esta atividade'} incrível: "${pageTitle}"`;

    const whatsappBtn = document.getElementById('whatsapp-share-btn');
    const facebookBtn = document.getElementById('facebook-share-btn');

    if (whatsappBtn) {
        whatsappBtn.href = `https://wa.me/?text=${encodeURIComponent(shareText + ' ' + pageUrl)}`;
        whatsappBtn.target = '_blank';
        whatsappBtn.rel = 'noopener noreferrer';
    }

    if (facebookBtn) {
        facebookBtn.href = `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(pageUrl)}`;
        facebookBtn.target = '_blank';
        facebookBtn.rel = 'noopener noreferrer';
    }

    // --- LÓGICA DAS ATIVIDADES RELACIONADAS ---
    if (!isArticle) {
        loadRelatedActivities();
    } else {
        loadPopularArticles();
    }
});

async function loadRelatedActivities() {
    const relatedContainer = document.getElementById('related-activities-grid');
    const currentActivityTitle = document.getElementById('activity-title').textContent.trim();

    // CORREÇÃO: Usar um caminho absoluto a partir da raiz do site
    const basePath = '/js/';
    const jsonFiles = [
        'pintura.json', 'matematica.json', 'artes.json', 'educacao_financeira.json',
        'biologia.json', 'ciencias.json', 'educacaofisica.json', 'filosofia.json',
        'fisica.json', 'geografia.json', 'historia.json', 'ingles.json',
        'portugues.json', 'quimica.json', 'sociologia.json', 'infantil.json',
        'raciocinio.json', 'livros.json', 'lojinha.json', 'outro.json', 'desenhos.json', 'simulados.json'
    ];

    try {
        const fetchPromises = jsonFiles.map(file => 
            fetch(basePath + file).then(res => res.ok ? res.json() : []).catch(() => [])
        );

        const jsonDataArrays = await Promise.all(fetchPromises);
        let allActivities = [].concat(...jsonDataArrays);

        // Filtrar para não mostrar a atividade atual e depois embaralhar
        let relatedActivities = allActivities
            .filter(activity => activity.titulo.trim() !== currentActivityTitle)
            .sort(() => 0.5 - Math.random()) // Embaralha o array
            .slice(0, 3); // Pega os 3 primeiros

        relatedContainer.innerHTML = ''; // Limpa a mensagem "A carregar..."

        if (relatedActivities.length === 0) {
            relatedContainer.innerHTML = '<p class="col-span-full text-center text-gray-500">Nenhuma outra atividade encontrada.</p>';
            return;
        }

        relatedActivities.forEach(activity => {
            const card = document.createElement('a');
            card.href = activity.link;
            card.className = "card-hover bg-white rounded-2xl shadow-sm overflow-hidden flex flex-col";
            card.innerHTML = `
                <img src="${activity.imagem}" alt="${activity.titulo}" class="w-full h-48 object-cover">
                <div class="p-6">
                    <h3 class="font-bold text-xl mb-2">${activity.titulo}</h3>
                    <p class="text-gray-600 text-sm">${activity.descricao.substring(0, 80)}...</p>
                </div>
            `;
            relatedContainer.appendChild(card);
        });

    } catch (error) {
        console.error("Erro ao carregar atividades relacionadas:", error);
        relatedContainer.innerHTML = '<p class="col-span-full text-center text-red-500">Não foi possível carregar as sugestões.</p>';
    }
}

async function loadPopularArticles() {
    const popularArticlesList = document.getElementById('popular-articles-list');
    const jsonPath = '/js/Artigos.json'; // Carrega o JSON para a barra lateral

    try {
        const response = await fetch(jsonPath);
        if (!response.ok) throw new Error('Falha ao carregar artigos populares.');
        
        const articles = await response.json();
        popularArticlesList.innerHTML = ''; // Limpa "A carregar..."

        const popularArticles = articles.filter(article => article.popular);
        
        if (popularArticles.length > 0) {
            popularArticles.forEach((article, index) => {
                const popularLink = document.createElement('a');
                popularLink.href = article.link;
                popularLink.className = "block hover:text-cyan-600";
                popularLink.innerHTML = `<p class="font-bold">${index + 1}. ${article.titulo}</p>`;
                popularArticlesList.appendChild(popularLink);
            });
        } else {
            popularArticlesList.innerHTML = `<p class="text-gray-500">Nenhum artigo popular no momento.</p>`;
        }

    } catch (error) {
        console.error("Erro ao carregar artigos populares:", error);
        popularArticlesList.innerHTML = `<p class="text-red-500">Erro ao carregar.</p>`;
    }
}