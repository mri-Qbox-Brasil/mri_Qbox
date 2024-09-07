import fs from 'fs';
import AdmZip from 'adm-zip';

const exps = global.exports;
/**
 * Função para extrair um arquivo ZIP.
 * @param zipFilePath - O caminho para o arquivo ZIP.
 * @param outputDir - O diretório onde os arquivos serão extraídos.
 */
function extractZip(zipFilePath: string, outputDir: string): void {
    // Verifica se o diretório de saída existe, senão cria
    if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir);
    }

    // Cria uma instância do AdmZip com o arquivo ZIP
    const zip = new AdmZip(zipFilePath);

    // Extrai o conteúdo para o diretório especificado
    zip.extractAllTo(outputDir, true);
    console.log(`Arquivos extraídos para: ${outputDir}`);
}

// Registra a função como um export
exps('ExtractZip', extractZip);