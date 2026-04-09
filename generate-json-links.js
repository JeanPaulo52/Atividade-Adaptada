const fs = require('fs');
const path = require('path');
const cheerio = require('cheerio');

const BASE_DIR = 'nivel-2/2-bncc';
const OUTPUT_DIR = 'js';

function getAllHtmlFiles(dir, fileList = []) {
  const files = fs.readdirSync(dir);

  files.forEach(file => {
    const filePath = path.join(dir, file);
    const stat = fs.statSync(filePath);

    if (stat.isDirectory()) {
      getAllHtmlFiles(filePath, fileList);
    } else if (file.endsWith('.html')) {
      fileList.push(filePath);
    }
  });

  return fileList;
}

function extractInfoFromHtml(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const $ = cheerio.load(content);

  const titulo = $('title').text().trim() || path.basename(filePath, '.html').replace(/-/g, ' ');
  let descricao = $('meta[name="description"]').attr('content') || '';
  const imagem = $('img').first().attr('src') || '';
  const link = '/' + filePath.replace(/\\/g, '/');

  // Adicionar conteúdo descritivo da atividade se existir
  const activityContent = $('div.activity-content').html();
  if (activityContent) {
    descricao += '\n\n' + activityContent;
  }

  // Corrigir o caminho da imagem para absoluto
  let imagemCorrigida = imagem;
  if (imagem.startsWith('./')) {
    const dir = path.dirname(link);
    imagemCorrigida = dir + '/' + imagem.slice(2);
  }

  return { titulo, descricao, imagem: imagemCorrigida, link };
}

function generateJsonForCategory(category, overwrite = false) {
  const categoryDir = path.join(BASE_DIR, category);
  if (!fs.existsSync(categoryDir)) {
    console.log(`Pasta ${categoryDir} não existe.`);
    return;
  }

  const outputPath = path.join(OUTPUT_DIR, `${category}.json`);
  let existingItems = [];
  if (!overwrite && fs.existsSync(outputPath)) {
    try {
      existingItems = JSON.parse(fs.readFileSync(outputPath, 'utf8'));
      console.log(`Carregados ${existingItems.length} itens existentes de ${outputPath}`);
    } catch (error) {
      console.warn(`Erro ao ler ${outputPath}: ${error.message}. Iniciando com lista vazia.`);
    }
  }

  // Criar um set de links existentes para verificação rápida
  const existingLinks = new Set(existingItems.map(item => item.link));

  const htmlFiles = getAllHtmlFiles(categoryDir);
  const newItems = [];

  htmlFiles.forEach(file => {
    const link = '/' + file.replace(/\\/g, '/');
    if (overwrite || !existingLinks.has(link)) {
      const item = extractInfoFromHtml(file);
      newItems.push(item);
    }
  });

  const updatedItems = overwrite ? newItems : existingItems.concat(newItems);
  if (updatedItems.length > 0) {
    fs.writeFileSync(outputPath, JSON.stringify(updatedItems, null, 2));
    console.log(`${overwrite ? 'Sobrescrito' : 'Atualizado'} ${outputPath}: ${newItems.length} itens processados (total: ${updatedItems.length})`);
  } else {
    console.log(`Nenhum item para ${category}.`);
  }
}

function main() {
  const args = process.argv.slice(2);
  if (args.length === 0) {
    console.log('Uso: node generate-json-links.js <categoria> [--overwrite]');
    console.log('Exemplo: node generate-json-links.js biologia --overwrite');
    return;
  }

  const category = args[0];
  const overwrite = args.includes('--overwrite');
  generateJsonForCategory(category, overwrite);
}

main();