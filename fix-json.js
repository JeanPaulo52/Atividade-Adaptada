const fs = require('fs');
const path = require('path');

const jsonDir = path.join(__dirname, 'js');

const replacements = [
  { from: '/2-BNCC/', to: '/2-bncc/' },
  { from: '/Artes/', to: '/artes/' },
  { from: '/Biologia/', to: '/biologia/' },
  { from: '/Biologia_', to: '/biologia_' },
  { from: '/Ciencias/', to: '/ciencias/' },
  { from: '/Ciencias_', to: '/ciencias_' },
  { from: '/Educacao Fisica/', to: '/educacao-fisica/' },
  { from: '/Educacao_financeira/', to: '/educacao-financeira/' },
  { from: '/Educacao Fisica', to: '/educacao-fisica' },
  { from: '/Filosofia/', to: '/filosofia/' },
  { from: '/Filosofia_', to: '/filosofia_' },
  { from: '/Fisica/', to: '/fisica/' },
  { from: '/Fisica_', to: '/fisica_' },
  { from: '/Geografia/', to: '/geografia/' },
  { from: '/Geografia_', to: '/geografia_' },
  { from: '/Historia/', to: '/historia/' },
  { from: '/Historia_', to: '/historia_' },
  { from: '/Ingles/', to: '/ingles/' },
  { from: '/Ingles_', to: '/ingles_' },
  { from: '/Lingua Portuguesa/', to: '/lingua-portuguesa/' },
  { from: '/Matematica/', to: '/matematica/' },
  { from: '/Quimica/', to: '/quimica/' },
  { from: '/Sociologia/', to: '/sociologia/' },
  { from: '/PagDow/', to: '/pagdow/' },
  // Também corrigir nomes de arquivos em maiúsculas
  { from: 'Biologia.html', to: 'biologia.html' },
  { from: 'Ciencias.html', to: 'ciencias.html' },
  { from: 'Fisica.html', to: 'fisica.html' },
  { from: 'Filosofia.html', to: 'filosofia.html' },
  { from: 'Geografia.html', to: 'geografia.html' },
  { from: 'Historia.html', to: 'historia.html' },
  { from: 'Sociologia.html', to: 'sociologia.html' }
];

let count = 0;

fs.readdirSync(jsonDir).filter(f => f.endsWith('.json')).forEach(file => {
  const filePath = path.join(jsonDir, file);
  let content = fs.readFileSync(filePath, 'utf8');
  const original = content;
  
  replacements.forEach(rep => {
    content = content.replaceAll(rep.from, rep.to);
  });
  
  if (content !== original) {
    fs.writeFileSync(filePath, content, 'utf8');
    console.log(`OK: ${file}`);
    count++;
  }
});

console.log(`\nTotal: ${count} arquivos atualizados`);

