const fs = require('fs');
const path = require('path');

const jsonDir = path.join(__dirname, 'js');

// Listas específicas de substituição direta
const directReplacements = {
  'BNCC.json': [
    ['/Educa' + String.fromCharCode(0xE7) + '[' + String.fromCharCode(0xE3) + String.fromCharCode(0xE1) + ']o Fisica/', '/educacao-fisica/'],
    ['/Educa' + String.fromCharCode(0xE7) + '[' + String.fromCharCode(0xE3) + String.fromCharCode(0xE1) + ']o_financeira/', '/educacao_financeira/'],
  ],
  'educacao_financeira.json': [
    ['/Educa' + String.fromCharCode(0xE7) + '[' + String.fromCharCode(0xE3) + String.fromCharCode(0xE1) + ']o_financeira/', '/educacao_financeira/'],
  ]
};

let count = 0;

Object.keys(directReplacements).forEach(fileName => {
  const filePath = path.join(jsonDir, fileName);
  if (fs.existsSync(filePath)) {
    let content = fs.readFileSync(filePath, 'utf8');
    const original = content;
    
    directReplacements[fileName].forEach(([from, to]) => {
      const regex = new RegExp(from, 'g');
      content = content.replace(regex, to);
    });
    
    if (content !== original) {
      fs.writeFileSync(filePath, content, 'utf8');
      console.log(`OK: ${fileName}`);
      count++;
    }
  }
});

console.log(`\nTotal: ${count} arquivos com correções finais`);
