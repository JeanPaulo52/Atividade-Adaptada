import os
import glob
import json

json_dir = r"c:\Users\jean\Desktop\Atividade Adaptada.com\js"
counter = 0

# Mapa de substituições
replacements = {
    '/2-BNCC/': '/2-bncc/',
    '/Artes/': '/artes/',
    '/Biologia/': '/biologia/',
    '/Ciencias/': '/ciencias/',
    '/Educacao Fisica/': '/educacao-fisica/',
    '/Educacao_financeira/': '/educacao-financeira/',
    '/Filosofia/': '/filosofia/',
    '/Fisica/': '/fisica/',
    '/Geografia/': '/geografia/',
    '/Historia/': '/historia/',
    '/Ingles/': '/ingles/',
    '/Lingua Portuguesa/': '/lingua-portuguesa/',
    '/Matematica/': '/matematica/',
    '/Quimica/': '/quimica/',
    '/Sociologia/': '/sociologia/',
    '/PagDow/': '/pagdow/',
    '/Raciocinio/': '/raciocinio/',
    '/Infantil/': '/infantil/',
    '/Pintura/': '/pintura/',
    '/1-pagina inicial/': '/1-pagina-inicial/',
    '/4-Outras atividades/': '/4-outras-atividades/',
    '/5-recortar e pintar/': '/5-recortar-e-pintar/',
}

for json_file in glob.glob(os.path.join(json_dir, '*.json')):
    with open(json_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    
    # Aplicar todas as substituições
    for old, new in replacements.items():
        content = content.replace(old, new)
    
    if content != original:
        with open(json_file, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"OK: {os.path.basename(json_file)}")
        counter += 1

print(f"\nTotal de arquivos atualizados: {counter}")
