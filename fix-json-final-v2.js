const fs = require('fs');
const path = require('path');

const jsonDir = path.join(__dirname, 'js');

// Função para normalizar acentos
function removeAccents(str) {
  return str.normalize('NFD').replace(/[\u0300-\u036f]/g, '');
}

const replacements = [
  // Substituições por regex (sem acentos)
  { regex: /Educa[çc][ãa]o Fisica/gi, replace: 'educacao-fisica' },
  { regex: /Educa[çc][ãa]o_financeira/gi, replace: 'educacao_financeira' },
  { regex: /Filosifia/gi, replace: 'filosofia' },  // Erro de digitação
];

let count = 0;

fs.readdirSync(jsonDir).filter(f => f.endsWith('.json')).forEach(file => {
  const filePath = path.join(jsonDir, file);
  let content = fs.readFileSync(filePath, 'utf8');
  const original = content;
  
  replacements.forEach(rep => {
    content = content.replace(rep.regex, rep.replace);
  });
  
  if (content !== original) {
    fs.writeFileSync(filePath, content, 'utf8');
    console.log(`OK: ${file}`);
    count++;
  }
});

console.log(`\nTotal: ${count} arquivos atualizados`);
