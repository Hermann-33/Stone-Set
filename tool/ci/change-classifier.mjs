import process from 'node:process';
import { pathToFileURL } from 'node:url';

const markdownOnly = /(^|\/)(?:[^/]+\.md)$/i;

export function classifyChanges(paths) {
  const files = [...new Set(paths.map(normalizePath).filter(Boolean))];
  const matches = (pattern) => files.some((path) => pattern.test(path));
  const recognized = /^(?:.*\.md|\.github\/.*|apps\/(?:mobile|dashboard)\/.*|packages\/(?:domain|data|ui)\/.*|supabase\/.*|(?:bin|lib|test)\/.*|tool\/(?:ci|operator)\/.*|config\/.*|assets\/ranks\/.*|pubspec\.yaml|pubspec\.lock|analysis_options\.yaml|package\.json|package-lock\.json|\.gitignore|\.metadata|LICENSE)$/;
  const unknown = files.some((path) => !recognized.test(path));

  const domain = matches(/^packages\/domain\//);
  const data = matches(/^packages\/data\//);
  const ui = matches(/^packages\/ui\//);
  const mobileApp = matches(/^apps\/mobile\//);
  const dashboardApp = matches(/^apps\/dashboard\//);
  const rootDart = matches(/^(?:(?:bin|lib)\/.*\.dart|test\/.*\.dart)$/);
  const dartDependency = matches(/^(?:pubspec\.yaml|pubspec\.lock|analysis_options\.yaml)$/);
  const operator = matches(/^tool\/operator\//);
  const supabase = matches(/^supabase\//) || matches(/^(?:package\.json|package-lock\.json)$/);
  const mobileVisual = unknown || mobileApp || ui || matches(/^assets\/ranks\//);
  const mobileBuild = unknown || mobileApp || domain || data || ui || rootDart || dartDependency;
  const mobilePerformance = unknown || mobileApp || ui || matches(/^assets\/ranks\//);
  const dashboard = unknown || dashboardApp || domain || data || ui || rootDart || dartDependency;
  const dashboardVisual = unknown || dashboardApp || ui;
  const flutter = unknown || mobileBuild || dashboard;

  return {
    docs_only: files.length > 0 && files.every((path) => markdownOnly.test(path)),
    flutter,
    domain,
    data,
    ui,
    root_dart: rootDart,
    operator,
    mobile_app: mobileApp,
    mobile_build: mobileBuild,
    mobile_visual: mobileVisual,
    mobile_performance: mobilePerformance,
    dashboard_app: dashboardApp,
    dashboard,
    dashboard_visual: dashboardVisual,
    supabase: unknown || supabase,
    unknown,
  };
}

function normalizePath(value) {
  return value.trim().replaceAll('\\', '/').replace(/^\.\//, '');
}

async function main() {
  const input = await readStandardInput();
  const result = classifyChanges(input.split(/\r?\n/));
  for (const [name, enabled] of Object.entries(result)) {
    process.stdout.write(`${name}=${enabled}\n`);
  }
}

async function readStandardInput() {
  const chunks = [];
  for await (const chunk of process.stdin) chunks.push(chunk);
  return Buffer.concat(chunks).toString('utf8');
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  await main();
}
