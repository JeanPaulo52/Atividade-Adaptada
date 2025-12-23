        // --- LÓGICA DO MENU MOBILE ---
        const mobileMenuButton = document.getElementById('mobile-menu-button');
        const mobileMenu = document.getElementById('mobile-menu');
        mobileMenuButton.addEventListener('click', () => {
            mobileMenu.classList.toggle('hidden');
        });

        // --- LÓGICA DA PÁGINA (PARTILHA E RELACIONADOS) ---
        document.addEventListener('DOMContentLoaded', () => {
            
            // --- LÓGICA DOS BOTÕES DE PARTILHA ---
            const pageUrl = window.location.href;
            const pageTitle = document.querySelector('#activity-title').textContent;
            const shareText = `Confira esta atividade incrível: "${pageTitle}"`;

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
            loadRelatedActivities();
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