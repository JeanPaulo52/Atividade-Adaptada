// Importa os módulos necessários do Node.js
const fs = require('fs');
const path = require('path');
const { glob } = require('glob');

// --- CONFIGURAÇÃO PRINCIPAL ---
const YOUR_WEBSITE_URL = 'https://www.atividadeadaptada.com.br'; // URL completa do seu site
const SOURCE_DIRECTORY = '.'; // Pasta raiz do projeto
const SITEMAP_OUTPUT_FILE = 'sitemap.xml'; // Nome do arquivo de sitemap a ser gerado

// --- CONFIGURAÇÃO DE ROTAS DINÂMICAS (A PARTIR DE ARQUIVOS JSON) ---
// Adicione um objeto para cada tipo de conteúdo dinâmico
const dynamicRoutesConfig = [
  { jsonFile: path.join('js', 'pintura.json'), routePrefix: 'pintura', paramKey: 'id' },
  { jsonFile: path.join('js', 'matematica.json'), routePrefix: 'matematica', paramKey: 'id' },
  { jsonFile: path.join('js', 'artes.json'), routePrefix: 'artes', paramKey: 'id' },
  { jsonFile: path.join('js', 'educacao_financeira.json'), routePrefix: 'educacao_financeira', paramKey: 'id' },
  { jsonFile: path.join('js', 'biologia.json'), routePrefix: 'biologia', paramKey: 'id' },
  { jsonFile: path.join('js', 'ciencias.json'), routePrefix: 'ciencias', paramKey: 'id' },
  { jsonFile: path.join('js', 'educacaofisica.json'), routePrefix: 'educacaofisica', paramKey: 'id' },
  { jsonFile: path.join('js', 'filosofia.json'), routePrefix: 'filosofia', paramKey: 'id' },
  { jsonFile: path.join('js', 'fisica.json'), routePrefix: 'fisica', paramKey: 'id' },
  { jsonFile: path.join('js', 'geografia.json'), routePrefix: 'geografia', paramKey: 'id' },
  { jsonFile: path.join('js', 'historia.json'), routePrefix: 'historia', paramKey: 'id' },
  { jsonFile: path.join('js', 'ingles.json'), routePrefix: 'ingles', paramKey: 'id' },
  { jsonFile: path.join('js', 'portugues.json'), routePrefix: 'portugues', paramKey: 'id' },
  { jsonFile: path.join('js', 'quimica.json'), routePrefix: 'quimica', paramKey: 'id' },
  { jsonFile: path.join('js', 'sociologia.json'), routePrefix: 'sociologia', paramKey: 'id' },
  { jsonFile: path.join('js', 'infantil.json'), routePrefix: 'infantil', paramKey: 'id' },
  { jsonFile: path.join('js', 'raciocinio.json'), routePrefix: 'raciocinio', paramKey: 'id' },
  { jsonFile: path.join('js', 'livros.json'), routePrefix: 'livros', paramKey: 'id' },
  { jsonFile: path.join('js', 'lojinha.json'), routePrefix: 'lojinha', paramKey: 'id' },
  { jsonFile: path.join('js', 'outro.json'), routePrefix: 'outro', paramKey: 'id' }
];

async function generateSitemap() {
  console.log('Iniciando a geração do sitemap...');
  const allUrls = new Set(); // Usamos um Set para evitar URLs duplicadas

  // 1. Encontrar páginas estáticas (.html)
  try {
    const staticPages = await glob(`${SOURCE_DIRECTORY}/**/*.html`, {
      ignore: '**/404.html',
    });

    staticPages.forEach(pagePath => {
      let route = path.relative(SOURCE_DIRECTORY, pagePath).replace(/\\/g, '/');
      route = (route === 'index.html') ? '' : route.replace('.html', '');
      allUrls.add(`${YOUR_WEBSITE_URL}/${route}`);
    });
    console.log(`Encontradas ${staticPages.length} páginas estáticas.`);
  } catch (error) {
    console.error('Erro ao buscar páginas estáticas:', error);
    return;
  }

  // 2. Gerar rotas dinâmicas a partir dos arquivos JSON
  dynamicRoutesConfig.forEach(config => {
    try {
      if (fs.existsSync(config.jsonFile)) {
        const jsonData = fs.readFileSync(config.jsonFile, 'utf8');
        const items = JSON.parse(jsonData);

        if (Array.isArray(items)) {
          items.forEach(item => {
            const param = item[config.paramKey];
            if (param) {
              // Estrutura de URL: seusite.com.br/routePrefix/param
              const route = `${config.routePrefix}/${param}`;
              allUrls.add(`${YOUR_WEBSITE_URL}/${route}`);
            }
          });
          console.log(`Encontrados ${items.length} itens dinâmicos em ${config.jsonFile}.`);
        }
      } else {
        console.warn(`Aviso: Arquivo JSON não encontrado: ${config.jsonFile}`);
      }
    } catch (error) {
      console.error(`Erro ao processar o arquivo JSON ${config.jsonFile}:`, error);
    }
  });

  // 3. Construir o XML final
  let sitemapXml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">`;

  allUrls.forEach(url => {
    sitemapXml += `
  <url>
    <loc>${url}</loc>
    <lastmod>${new Date().toISOString().split('T')[0]}</lastmod>
    <priority>0.8</priority>
  </url>`;
  });

  sitemapXml += `
</urlset>`;

  fs.writeFileSync(SITEMAP_OUTPUT_FILE, sitemapXml);
  console.log(`✅ Sitemap gerado com sucesso em: ${SITEMAP_OUTPUT_FILE}`);
  console.log(`Total de ${allUrls.size} URLs mapeadas.`);
}

generateSitemap();
