
        // --- LÓGICA DO MENU MOBILE ---
        const mobileMenuButton = document.getElementById('mobile-menu-button');
        const mobileMenu = document.getElementById('mobile-menu');
        mobileMenuButton.addEventListener('click', () => {
            mobileMenu.classList.toggle('hidden');
        });

        // --- LÓGICA DA BARRA DE PESQUISA ---
        const searchForm = document.getElementById('search-form');
        const searchInput = document.getElementById('search-input');

        searchForm.addEventListener('submit', function(event) {
            event.preventDefault(); // Impede o recarregamento da página
            
            const query = searchInput.value.trim(); // Pega o valor da busca e remove espaços extras
            
            if (query) {
                // Redireciona para a página de resultados, passando a busca como um parâmetro na URL
                window.location.href = `resultados.html?q=${encodeURIComponent(query)}`;
            }
        });