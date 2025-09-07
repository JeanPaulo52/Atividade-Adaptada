// Lê o termo da URL
    function getParametroBusca() {
        const params = new URLSearchParams(window.location.search);
        return params.get('busca') || '';
    }

    // Busca e exibe resultados
    function mostrarResultados(termo, dados) {
        const lista = document.getElementById('listaResultados');
        const semResultado = document.getElementById('semResultado');
        const tituloBusca = document.getElementById('tituloBusca');
        tituloBusca.textContent = `Resultados para: "${termo}"`;

        // Filtra os dados
        const filtrados = dados.filter(item =>
            item.titulo.toLowerCase().includes(termo.toLowerCase()) ||
            item.descricao.toLowerCase().includes(termo.toLowerCase())
        );

        lista.innerHTML = '';
        if (filtrados.length === 0) {
            semResultado.style.display = 'block';
            return;
        }
        semResultado.style.display = 'none';

        filtrados.forEach(item => {
            const a = document.createElement('a');
            a.className = 'resultado-item';
            a.href = item.link;
            
            a.innerHTML = `
                <img src="${item.imagem}" alt="${item.titulo}" class="resultado-img">
                <div class="resultado-titulo-img">${item.titulo}</div>
            `;
            lista.appendChild(a);
        });
    }

    // Carrega o JSON e mostra resultados
    document.addEventListener('DOMContentLoaded', () => {
        const termo = getParametroBusca();
        if (!termo.trim()) {
            document.getElementById('tituloBusca').textContent = 'Nenhum termo pesquisado.';
            document.getElementById('semResultado').style.display = 'block';
            return;
        }
        // Liste todos os seus arquivos JSON aqui:
        const arquivos = [
            './js/pintura.json',
            './js/matematica.json',
            './js/artes.json',
            './js/educacao_financeira.json',
            './js/biologia.json',
            './js/ciencias.json',
            './js/educacaofisica.json',
            './js/filosofia.json',
            './js/fisica.json',
            './js/geografia.json',
            './js/historia.json',
            './js/ingles.json',
            './js/portugues.json',
            './js/quimica.json',
            './js/sociologia.json',
            './js/infantil.json',
            './js/raciocinio.json',
            './js/livros.json',
            './js/lojinha.json',
            './js/outro.json'
            // Adicione outros arquivos conforme necessário
        ];
        Promise.all(arquivos.map(a => fetch(a).then(r => r.json()).catch(() => [])))
            .then(arrays => {
                // Junta todos os resultados em um só array
                const dados = [].concat(...arrays);
                mostrarResultados(termo, dados);
            })
            .catch(() => {
                document.getElementById('semResultado').textContent = 'Erro ao carregar resultados.';
                document.getElementById('semResultado').style.display = 'block';
            });
    });
    
    let dados = [];

// Carrega o JSON
fetch('./js/pintura.json')
  .then(response => response.json())
  .then(data => dados = data);

function pesquisar() {
  // Apenas busca, não mostra sugestões
  document.getElementById("results").style.display = "none";
}

// Esconde os resultados ao perder o foco
function esconderResultados() {
  setTimeout(() => {
    document.getElementById("results").style.display = "none";
  }, 120); // tempo suficiente para o clique ser registrado
}

function verificaEnter(event) {
  if (event.key === "Enter") {
    irParaResultados();
  }
}

    // --- Pesquisa topo ---
    function irParaResultadosTopo() {
      const termo = document.getElementById("searchTopo").value.trim();
      if (termo) {
        window.location.href = `/resultados.html?busca=${encodeURIComponent(termo)}`;
      }
    }

    // --- Pesquisa overlay ---
    function irParaResultadosOverlay() {
      const termo = document.getElementById("searchOverlay").value.trim();
      if (termo) {
        window.location.href = `/resultados.html?busca=${encodeURIComponent(termo)}`;
      }
    }

    // --- Botão flutuante abre overlay ---
    document.getElementById('btnFlutuantePesquisa').addEventListener('click', () => {
        document.getElementById('overlayPesquisa').classList.add('ativa');
        document.getElementById('searchOverlay').focus();
    });

    // --- Fecha overlay ao clicar fora ---
    document.getElementById('overlayPesquisa').addEventListener('click', (e) => {
        if (e.target === e.currentTarget) {
            e.currentTarget.classList.remove('ativa');
            document.getElementById('searchOverlay').value = '';
        }
    });

    // --- Fecha overlay ao pressionar ESC ---
    document.addEventListener('keydown', (e) => {
        if (e.key === "Escape") {
            document.getElementById('overlayPesquisa').classList.remove('ativa');
            document.getElementById('searchOverlay').value = '';
        }
    });