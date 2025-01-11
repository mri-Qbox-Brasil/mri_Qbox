const esbuild = require("esbuild");
const path = require("path");
const fs = require("fs");
const util = require("util");

// Promisify fs.readdir para facilitar a leitura assíncrona dos diretórios
const readdir = util.promisify(fs.readdir);

const IS_WATCH_MODE = process.env.IS_WATCH_MODE === "true";

// Função para verificar se um arquivo existe
const fileExists = (filePath) => fs.existsSync(path.resolve(filePath));

// Função para gerar dinamicamente a lista de arquivos .ts em um diretório
const getTsFilesFromDir = async (dirPath) => {
  try {
    const files = await readdir(dirPath);
    return files.filter(file => file.endsWith(".ts")).map(file => path.join(dirPath, file));
  } catch (err) {
    console.error(`Erro ao ler o diretório ${dirPath}:`, err);
    return [];
  }
};

// Função para gerar targets dinamicamente com base nos arquivos .ts
const generateTargets = async () => {
  const targets = [];

  // Verifica arquivos no diretório server_src
  const serverFiles = await getTsFilesFromDir("server_src");
  serverFiles.forEach((file) => {
    targets.push({
      target: "node16",
      entryPoints: [file],
      platform: "node",
      outfile: `../modules/mri/server-side/utilities-modules/_${path.basename(file, ".ts")}.js`,
    });
  });

  // Verifica arquivos no diretório client_src
  const clientFiles = await getTsFilesFromDir("client_src");
  clientFiles.forEach((file) => {
    targets.push({
      target: "es2020",
      entryPoints: [file],
      platform: "browser",
      outfile: `../modules/mri/client-side/utilities-modules/_${path.basename(file, ".ts")}.js`,
    });
  });

  return targets;
};

// Opções base para todos os builds
const baseOptions = {
  logLevel: "info",
  bundle: true,
  charset: "utf8",
  minifyWhitespace: true,
  absWorkingDir: process.cwd(),
};

/**
 * Função para construir um alvo específico.
 * @param {Object} targetOpts Opções específicas do alvo.
 */
const buildTarget = async (targetOpts) => {
  const mergedOpts = { ...baseOptions, ...targetOpts };

  if (IS_WATCH_MODE) {
    mergedOpts.watch = {
      onRebuild(error) {
        const timestamp = new Date().toISOString();
        if (error) {
          console.error(`[${timestamp}] [ESBuild Watch] (${targetOpts.entryPoints[0]}) Failed to rebuild bundle`);
        } else {
          console.log(`[${timestamp}] [ESBuild Watch] (${targetOpts.entryPoints[0]}) Successfully rebuilt bundle`);
        }
      },
    };
  }

  const result = await esbuild.build(mergedOpts);

  if (result.errors?.length) {
    throw new Error(`[ESBuild] Bundle failed with ${result.errors.length} errors`);
  }
};

/**
 * Função principal para construir todos os bundles.
 */
const buildBundle = async () => {
  try {
    console.log("[ESBuild] Starting build process...");

    // Gera dinamicamente a lista de targets
    const TARGET_ENTRIES = await generateTargets();

    if (TARGET_ENTRIES.length === 0) {
      console.warn("[ESBuild] No valid entry files found. Build skipped.");
      return;
    }

    await Promise.all(TARGET_ENTRIES.map(buildTarget));
    console.log("[ESBuild] All bundles built successfully");
  } catch (error) {
    console.error("[ESBuild] Build failed with error");
    console.error(error);
    process.exit(1);
  }
};

// Executa o build
buildBundle().catch(() => process.exit(1));
