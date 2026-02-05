const fs = require("fs");
const path = require("path");

const pastaBase = "./nivel-2/2-BNCC/Artes/PagDow/"; // caminho da pasta raiz
let atividades = [];

// Função para extrair a meta description do arquivo HTML
function extrairMetaDescription(caminhoHtml) {
  try {
    const conteudo = fs.readFileSync(caminhoHtml, "utf-8");
    const regex = /meta\s+name=["']description["']\s+content=["']([^"']*)["']/i;
    const match = conteudo.match(regex);
    return match ? match[1] : "Atividade de Matematica.";
  } catch (erro) {
    return "Atividade de Matematica.";
  }
}

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
        const caminhoHtml = path.join(caminhoCompleto, html);
        const descricao = extrairMetaDescription(caminhoHtml);

        atividades.push({
          titulo: html.replace(".html", "").replace(/[-_]/g, " "),
          descricao: descricao,
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
