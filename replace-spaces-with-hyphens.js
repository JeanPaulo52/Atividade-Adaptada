const fs = require('fs');
const path = require('path');

const jsonDir = path.join(__dirname, 'js');

function replaceSpacesInLinks(content) {
  // Substitui espaços por hífens APENAS nos valores de "link" e "imagem"
  // Mantém espaços em "titulo" e "descricao"
  
  return content.replace(/("(?:link|imagem)":\s*)"([^"]+)"/g, (match, prefix, linkValue) => {
    // Substitui TODOS os espaços por hífens no path
    const normalized = linkValue.replace(/\s+/g, '-');
    
    if (normalized !== linkValue) {
      console.log(`  ${linkValue.substring(0, 50)}... → ${normalized.substring(0, 50)}...`);
    }
    
    return prefix + '"' + normalized + '"';
  });
}

let totalUpdated = 0;

fs.readdirSync(jsonDir).filter(f => f.endsWith('.json')).forEach(file => {
  const filePath = path.join(jsonDir, file);
  let content = fs.readFileSync(filePath, 'utf8');
  const original = content;
  
  // Processar todos os links e imagens
  content = replaceSpacesInLinks(content);
  
  if (content !== original) {
    fs.writeFileSync(filePath, content, 'utf8');
    console.log(`✓ ${file}`);
    totalUpdated++;
  }
});

console.log(`\n✓ Total de arquivos atualizados: ${totalUpdated}`);
