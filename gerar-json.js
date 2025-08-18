const fs = require("fs");
const path = require("path");

// Caminho da pasta onde estão suas atividades (ajuste para o seu caso)
const pastaAtividades = path.join(__dirname, "./Nivel 2/5-recortar e pintar/1-Infantil/PagDow/");

// Caminho do JSON final
const saidaJSON = path.join(__dirname, "infantil.json");

function gerarJSON() {
  const arquivos = fs.readdirSync(pastaAtividades);

  const lista = arquivos.map(arquivo => {
    const nomeSemExtensao = path.parse(arquivo).name;

    return {
      titulo: nomeSemExtensao, // Exemplo: "Atividade 1"
      descricao: "Atividade de pintura", // Você pode mudar depois
      imagem: `/Nivel 2/5-recortar e pintar/1-Infantil/PagDow/${arquivo}`,
      link: `/Nivel 2/5-recortar e pintar/1-Infantil/PagDow/${arquivo}`
    };
  });

  fs.writeFileSync(saidaJSON, JSON.stringify(lista, null, 2), "utf8");
  console.log("✅ JSON gerado com sucesso:", saidaJSON);
}

gerarJSON();
