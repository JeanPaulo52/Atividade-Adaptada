const fs = require('fs');
const path = require('path');

const jsonDir = path.join(__dirname, 'js');

function normalizeLink(link) {
  // 1. Converter maiúsculas para minúsculas
  let normalized = link.toLowerCase();
  
  // 2. Converter espaços para hífens nas pastas
  // Procura por padrões como "/Pasta Com Espacos/" e converte para "/pasta-com-espacos/"
  normalized = normalized.replace(/\/([a-z\-]*\s[a-z\s\-]*)\//g, (match, folderName) => {
    const convertedFolder = folderName.trim().replace(/\s+/g, '-');
    return `/${convertedFolder}/`;
  });
  
  // 3. Também converter espaços em nomes de arquivo
  // Procura por padrões como "/Arquivo Com Espacos.webp" e converte
  normalized = normalized.replace(/\/([a-z\-]*\s[a-z\s\-]*)\.(webp|html|png|jpg|jpeg|gif)$/gi, (match, fileName, ext) => {
    const convertedName = fileName.trim().replace(/\s+/g, '-');
    return `/${convertedName}.${ext.toLowerCase()}`;
  });
  
  // 4. Remover caracteres acentuados (ç, ã, é, etc)
  normalized = normalized.normalize('NFD').replace(/[\u0300-\u036f]/g, '');
  
  return normalized;
}

let totalUpdated = 0;
let totalLinks = 0;

fs.readdirSync(jsonDir).filter(f => f.endsWith('.json')).forEach(file => {
  const filePath = path.join(jsonDir, file);
  let content = fs.readFileSync(filePath, 'utf8');
  const original = content;
  
  // Processar todos os links e imagens
  content = content.replace(/("(link|imagem)":\s*)"([^"]+)"/g, (match, prefix, type, linkValue) => {
    totalLinks++;
    const normalized = normalizeLink(linkValue);
    if (normalized !== linkValue) {
      console.log(`  ${type}: ${linkValue} → ${normalized}`);
      return prefix + '"' + normalized + '"';
    }
    return match;
  });
  
  if (content !== original) {
    fs.writeFileSync(filePath, content, 'utf8');
    console.log(`✓ ${file}`);
    totalUpdated++;
  }
});

console.log(`\n✓ Total de arquivos atualizados: ${totalUpdated}`);
console.log(`✓ Total de links processados: ${totalLinks}`);
