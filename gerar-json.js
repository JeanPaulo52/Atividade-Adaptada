const fs = require("fs");
const path = require("path");

const pastaBase = "./Nivel 2/2-BNCC/Educação_financeira/PagDow/"; // caminho da pasta raiz
let atividades = [];

function listarPastas(dir) {
  const pastas = fs.readdirSync(dir);

  pastas.forEach(item => {
    const caminhoCompleto = path.join(dir, item);
    const stat = fs.statSync(caminhoCompleto);

    if (stat.isDirectory()) {
      // pega os arquivos da pasta
      const arquivos = fs.readdirSync(caminhoCompleto);
      
      const html = arquivos.find(f => f.endsWith(".html"));
      const imagem = arquivos.find(f => f.endsWith(".webp"));

      if (html && imagem) {
        atividades.push({
          titulo: html.replace(".html", "").replace(/[-_]/g, " "),
          descricao: "Atividade de educação financeira.",
          imagem: path.join(caminhoCompleto, imagem).replace(pastaBase + "/", ""),
          link: path.join(caminhoCompleto, html).replace(pastaBase + "/", "")
        });
      }

      // continua descendo em subpastas
      listarPastas(caminhoCompleto);
    }
  });
}

listarPastas(pastaBase);

// Salvar JSON final
fs.writeFileSync("BNCC.json", JSON.stringify(atividades, null, 2), "utf-8");
console.log("✅ JSON gerado com sucesso! Total de atividades:", atividades.length);
