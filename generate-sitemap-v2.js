// Script para gerar sitemap.xml atualizado
const fs = require('fs');
const path = require('path');

const YOUR_WEBSITE_URL = 'https://www.atividadeadaptada.com.br';
const SOURCE_DIRECTORY = '.';
const SITEMAP_OUTPUT_FILE = 'sitemap.xml';

function getAllHtmlFiles(dir, fileList = []) {
  const files = fs.readdirSync(dir);

  files.forEach(file => {
    const filePath = path.join(dir, file);
    const stat = fs.statSync(filePath);

    if (stat.isDirectory()) {
      // Ignorar node_modules, .git e outros diretórios
      if (!file.startsWith('.') && file !== 'node_modules') {
        getAllHtmlFiles(filePath, fileList);
      }
    } else if (file.endsWith('.html') && file !== '404.html') {
      fileList.push(filePath);
    }
  });

  return fileList;
}

async function generateSitemap() {
  console.log('Iniciando geração do sitemap...');
  const allUrls = new Set();

  try {
    // 1. Encontrar todas as páginas HTML estáticas
    const htmlFiles = getAllHtmlFiles(SOURCE_DIRECTORY);
    console.log(`Encontrados ${htmlFiles.length} arquivos HTML.`);

    htmlFiles.forEach(filePath => {
      // Normalizar caminho
      let route = path.relative(SOURCE_DIRECTORY, filePath).replace(/\\/g, '/');
      
      // Remover index.html
      if (route === 'index.html') {
        route = '';
      } else {
        route = route.replace('.html', '');
      }

      // Construir URL
      const url = route ? `${YOUR_WEBSITE_URL}/${route}` : `${YOUR_WEBSITE_URL}/`;
      allUrls.add(url);
    });

    // 2. Tentar adicionar rotas dinâmicas dos JSON (se existirem)
    const jsonFiles = [
      'js/pintura.json',
      'js/matematica.json',
      'js/artes.json',
      'js/educacao_financeira.json',
      'js/biologia.json',
      'js/ciencias.json',
      'js/educacaofisica.json',
      'js/filosofia.json',
      'js/fisica.json',
      'js/geografia.json',
      'js/historia.json',
      'js/ingles.json',
      'js/portugues.json',
      'js/quimica.json',
      'js/sociologia.json',
      'js/infantil.json',
      'js/raciocinio.json',
      'js/livros.json',
      'js/simulado.json',
      'js/BNCC.json'
    ];

    jsonFiles.forEach(jsonFile => {
      try {
        if (fs.existsSync(jsonFile)) {
          const jsonData = JSON.parse(fs.readFileSync(jsonFile, 'utf8'));
          
          if (Array.isArray(jsonData)) {
            jsonData.forEach(item => {
              if (item.id) {
                const category = path.basename(jsonFile, '.json').toLowerCase();
                const url = `${YOUR_WEBSITE_URL}/${category}/${item.id}`;
                allUrls.add(url);
              }
            });
            console.log(`✓ Processados ${jsonData.length} itens de ${jsonFile}`);
          }
        }
      } catch (error) {
        console.warn(`⚠ Não foi possível processar ${jsonFile}: ${error.message}`);
      }
    });

    // 3. Construir XML do sitemap
    let sitemapXml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">`;

    // Ordenar URLs para melhor legibilidade
    const sortedUrls = Array.from(allUrls).sort();
    
    sortedUrls.forEach(url => {
      const lastmod = new Date().toISOString().split('T')[0];
      // Dar prioridade maior para páginas principais
      let priority = '0.7';
      if (url === `${YOUR_WEBSITE_URL}/` || url === `${YOUR_WEBSITE_URL}`) {
        priority = '1.0';
      } else if (url.includes('nivel-2') && !url.includes('BNCC')) {
        priority = '0.9';
      } else if (url.includes('categoria') || url.includes('artigos')) {
        priority = '0.85';
      }

      sitemapXml += `
  <url>
    <loc>${url}</loc>
    <lastmod>${lastmod}</lastmod>
    <priority>${priority}</priority>
  </url>`;
    });

    sitemapXml += `
</urlset>`;

    // 4. Salvar arquivo
    fs.writeFileSync(SITEMAP_OUTPUT_FILE, sitemapXml);
    console.log(`\n✅ Sitemap gerado com sucesso!`);
    console.log(`📁 Arquivo: ${SITEMAP_OUTPUT_FILE}`);
    console.log(`📊 Total de URLs: ${sortedUrls.length}`);
    console.log(`🌐 Primeiro URL: ${sortedUrls[0]}`);
    console.log(`🌐 Último URL: ${sortedUrls[sortedUrls.length - 1]}`);

  } catch (error) {
    console.error('❌ Erro ao gerar sitemap:', error);
    process.exit(1);
  }
}

generateSitemap();
