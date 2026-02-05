const fs = require('fs');
const path = require('path');

const jsonDir = path.join(__dirname, 'js');

const replacements = [
  // Substituições de maiúsculas/minúsculas  
  { from: '/2-BNCC/', to: '/2-bncc/' },
  { from: '/Artes/', to: '/artes/' },
  { from: '/Biologia/', to: '/biologia/' },
  { from: '/Biologia_', to: '/biologia_' },
  { from: '/Biologia.', to: '/biologia.' },
  { from: '/Ciencias/', to: '/ciencias/' },
  { from: '/Ciencias_', to: '/ciencias_' },
  { from: '/Ciencias.', to: '/ciencias.' },
  { from: '/Ciencas.', to: '/ciencias.' },  // Corrigir erro de digitação
  { from: '/Educacao Fisica/', to: '/educacao-fisica/' },
  { from: '/Educacao_financeira/', to: '/educacao-financeira/' },
  { from: '/Filosofia/', to: '/filosofia/' },
  { from: '/Filosofia_', to: '/filosofia_' },
  { from: '/Filosofia.', to: '/filosofia.' },
  { from: '/Fisica/', to: '/fisica/' },
  { from: '/Fisica_', to: '/fisica_' },
  { from: '/Fisica.', to: '/fisica.' },
  { from: '/Geografia/', to: '/geografia/' },
  { from: '/Geografia_', to: '/geografia_' },
  { from: '/Geografia.', to: '/geografia.' },
  { from: '/Historia/', to: '/historia/' },
  { from: '/Historia_', to: '/historia_' },
  { from: '/Historia.', to: '/historia.' },
  { from: '/Ingles/', to: '/ingles/' },
  { from: '/Ingles_', to: '/ingles_' },
  { from: '/Ingles.', to: '/ingles.' },
  { from: '/Lingua Portuguesa/', to: '/lingua-portuguesa/' },
  { from: '/Matematica/', to: '/matematica/' },
  { from: '/Quimica/', to: '/quimica/' },
  { from: '/Sociologia/', to: '/sociologia/' },
  { from: '/PagDow/', to: '/pagdow/' },
  // Corrigir com acentos
  { from: '/Educação Fisica/', to: '/educacao-fisica/' },
  { from: '/Educação_financeira/', to: '/educacao-financeira/' },
  { from: '/Educação Fisica', to: '/educacao-fisica' },
  { from: 'Educação_fisica', to: 'educacao_fisica' },
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
