
import { file, write, Glob } from "bun";
import { marked } from "marked";
import * as path from "path";
import * as fs from "fs";

// Paths
const ROOT = process.cwd();
const PATHS = {
    future: "task.md.resolved",
    history_root: "docs/logs",
    logic_root: "docs/adr",
    governance_root: "docs/governance",
    vitals: "bench/history.json",
    output: "docs/dashboard.html"
};

// Types
interface FileEntry {
    path: string;
    name: string;
    category: string;
    content: string;
    mtime: Date;
}

// Helpers
async function readText(relativePath: string) {
    try {
        const f = file(relativePath);
        return await f.text();
    } catch (e) {
        return "";
    }
}

async function getFiles(dir: string): Promise<FileEntry[]> {
    const entries: FileEntry[] = [];
    const glob = new Glob("**/*.md");

    // Scans dir relative to CWD
    for await (const filename of glob.scan({ cwd: dir })) {
        const fullPath = path.join(dir, filename);
        const stat = fs.statSync(fullPath);
        const content = await readText(fullPath);

        // Category is the immediate parent folder name, or 'root'
        const parts = filename.split("/"); // Glob returns forward slashes
        let category = parts.length > 1 ? parts.slice(0, -1).join("/") : "ROOT";

        entries.push({
            path: fullPath,
            name: path.basename(filename),
            category: category,
            content: content,
            mtime: stat.mtime
        });
    }
    return entries.sort((a, b) => b.name.localeCompare(a.name)); // Sort by name (usually dates/numbers) desc
}

async function generate() {
    console.log("📖 Reading Knowledge Base...");

    const future = await readText(PATHS.future);

    // Vitals
    let vitals = [];
    try {
        const vText = await readText(PATHS.vitals);
        vitals = JSON.parse(vText);
    } catch (e) { vitals = [] }
    const latestVital = vitals[0] || { elixir_ops_sec: 0, zig_ops_sec: 0 };

    // Scan Pillars
    const historyFiles = await getFiles(PATHS.history_root);
    const logicFiles = await getFiles(PATHS.logic_root);
    const governanceFiles = await getFiles(PATHS.governance_root);

    // Group History by Date (Category)
    const historyGroups: Record<string, FileEntry[]> = {};
    historyFiles.forEach(f => {
        if (!historyGroups[f.category]) historyGroups[f.category] = [];
        historyGroups[f.category].push(f);
    });

    // Sort Groups (Dates desc)
    const historyCategories = Object.keys(historyGroups).sort().reverse();

    console.log("🎨 Rendering Dashboard...");

    const html = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Aether Knowledge Base</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;700&family=Inter:wght@400;600;800&display=swap');
        body { font-family: 'Inter', sans-serif; background: #0f172a; color: #e2e8f0; }
        .mono { font-family: 'JetBrains Mono', monospace; }
        .card { background: rgba(30, 41, 59, 0.7); backdrop-filter: blur(10px); border: 1px solid rgba(255,255,255,0.05); }
        .card:hover { border-color: rgba(255,255,255,0.1); }
        
        /* Markdown Styles */
        .md-content h1 { font-size: 1.5em; font-weight: 800; color: #38bdf8; margin-bottom: 0.5em; border-bottom: 1px solid rgba(255,255,255,0.1); padding-bottom: 0.25em; }
        .md-content h2 { font-size: 1.25em; font-weight: 700; color: #94a3b8; margin-top: 1em; margin-bottom: 0.5em; }
        .md-content h3 { font-size: 1.1em; font-weight: 600; margin-top: 1em; color: #cbd5e1; }
        .md-content ul { list-style: disc; padding-left: 1.5em; margin-bottom: 1em; color: #94a3b8; }
        .md-content li { margin-bottom: 0.25em; }
        .md-content p { margin-bottom: 0.8em; line-height: 1.6; color: #cbd5e1; }
        .md-content code { background: #334155; padding: 2px 4px; border-radius: 4px; font-family: 'JetBrains Mono'; font-size: 0.9em; color: #e2e8f0; }
        .md-content pre { background: #0f172a; padding: 1em; border-radius: 8px; overflow-x: auto; margin-bottom: 1em; border: 1px solid rgba(255,255,255,0.1); }
        .md-content pre code { background: transparent; padding: 0; color: #e2e8f0; }
        .md-content a { color: #38bdf8; text-decoration: underline; }
        
        /* Accordion */
        details > summary { list-style: none; cursor: pointer; transition: all 0.2s; }
        details > summary::-webkit-details-marker { display: none; }
        details[open] > summary { margin-bottom: 1rem; }
    </style>
</head>
<body class="min-h-screen p-4 md:p-8">

    <!-- Header -->
    <header class="max-w-7xl mx-auto mb-12 flex flex-col md:flex-row justify-between items-center gap-6">
        <div>
            <h1 class="text-4xl font-extrabold text-transparent bg-clip-text bg-gradient-to-r from-blue-400 to-purple-500 tracking-tight">AETHER KNOWLEDGE BASE</h1>
            <p class="text-slate-400 mt-2 text-lg">System Intelligence & Governance Dashboard</p>
        </div>
        <div class="text-right flex flex-col items-end">
            <div class="text-xs font-bold text-slate-500 uppercase tracking-widest mb-1">System Status</div>
            <div class="flex items-center gap-2">
                <span class="relative flex h-3 w-3">
                  <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                  <span class="relative inline-flex rounded-full h-3 w-3 bg-emerald-500"></span>
                </span>
                <span class="text-emerald-400 font-mono font-bold">ONLINE</span>
            </div>
            <div class="text-xs text-slate-500 mt-1">Last Sync: ${new Date().toLocaleTimeString()}</div>
        </div>
    </header>

    <!-- Grid -->
    <main class="max-w-7xl mx-auto grid grid-cols-1 md:grid-cols-12 gap-6">

        <!-- LEFT COLUMN (Vitals + Governance + Logic) -->
        <div class="col-span-1 md:col-span-4 flex flex-col gap-6">
            
            <!-- 1. VITALS -->
            <article class="card rounded-2xl p-6 relative overflow-hidden group">
                <div class="absolute top-0 left-0 w-1 h-full bg-emerald-500"></div>
                <div class="flex justify-between items-start mb-4">
                    <h2 class="text-xl font-bold text-emerald-400 flex items-center gap-2">
                        <span>❤️</span> VITALS
                    </h2>
                    <span class="text-xs font-mono text-slate-500 bg-slate-800 px-2 py-1 rounded">/bench/</span>
                </div>
                <div class="grid grid-cols-2 gap-4 mb-4">
                    <div class="bg-slate-800/50 p-3 rounded-lg">
                        <div class="text-xs text-slate-400 uppercase">Zig</div>
                        <div class="text-2xl font-mono font-bold text-yellow-400">${latestVital.zig_ops_sec.toFixed(0)} <span class="text-sm">ops/s</span></div>
                    </div>
                    <div class="bg-slate-800/50 p-3 rounded-lg">
                        <div class="text-xs text-slate-400 uppercase">Elixir</div>
                        <div class="text-2xl font-mono font-bold text-purple-400">${latestVital.elixir_ops_sec.toFixed(0)} <span class="text-sm">ops/s</span></div>
                    </div>
                </div>
                <a href="../bench/report_history.html" class="text-xs text-blue-400 hover:text-blue-300 flex items-center gap-1">
                    View Telemetry Report &rarr;
                </a>
            </article>

            <!-- 3. GOVERNANCE -->
            <article class="card rounded-2xl p-6 relative overflow-hidden h-96 flex flex-col">
                <div class="absolute top-0 left-0 w-1 h-full bg-purple-500"></div>
                 <div class="flex justify-between items-start mb-4">
                    <h2 class="text-xl font-bold text-purple-400 flex items-center gap-2">
                        <span>⚖️</span> LAW
                    </h2>
                    <span class="text-xs font-mono text-slate-500 bg-slate-800 px-2 py-1 rounded">/docs/governance/</span>
                </div>
                <div class="overflow-y-auto pr-2 custom-scrollbar flex-1">
                    ${governanceFiles.map(f => `
                        <div class="mb-6">
                            <div class="text-xs font-bold text-slate-500 uppercase mb-2 sticky top-0 bg-slate-800/90 backdrop-blur p-1 rounded">${f.name}</div>
                            <div class="md-content text-sm text-slate-300">
                                ${marked.parse(f.content)}
                            </div>
                        </div>
                    `).join('')}
                </div>
            </article>

            <!-- 4. LOGIC -->
            <article class="card rounded-2xl p-6 relative overflow-hidden h-96 flex flex-col">
                <div class="absolute top-0 left-0 w-1 h-full bg-amber-500"></div>
                 <div class="flex justify-between items-start mb-4">
                    <h2 class="text-xl font-bold text-amber-400 flex items-center gap-2">
                        <span>🧠</span> REASON
                    </h2>
                    <span class="text-xs font-mono text-slate-500 bg-slate-800 px-2 py-1 rounded">/docs/adr/</span>
                </div>
                <div class="overflow-y-auto pr-2 custom-scrollbar flex-1">
                     ${logicFiles.map(f => `
                        <div class="mb-4">
                             <details class="group">
                                <summary class="flex items-center justify-between p-2 rounded bg-slate-800/50 hover:bg-slate-700 cursor-pointer">
                                    <span class="font-mono text-xs font-bold text-amber-200">${f.name}</span>
                                    <span class="transform group-open:rotate-180 transition-transform text-slate-400">▼</span>
                                </summary>
                                <div class="md-content text-sm text-slate-300 mt-2 p-2 pl-4 border-l-2 border-amber-500/20">
                                    ${marked.parse(f.content)}
                                </div>
                            </details>
                        </div>
                    `).join('')}
                </div>
            </article>
        </div>

        <!-- CENTER/RIGHT COLUMN (History + Strategy) -->
        <div class="col-span-1 md:col-span-8 flex flex-col gap-6">

            <!-- 2. FUTURE (Strategy) -->
            <article class="card rounded-2xl p-6 relative overflow-hidden">
                <div class="absolute top-0 left-0 w-1 h-full bg-blue-500"></div>
                <div class="flex justify-between items-start mb-4">
                    <h2 class="text-xl font-bold text-blue-400 flex items-center gap-2">
                        <span>🔭</span> THE FUTURE (Strategy)
                    </h2>
                    <span class="text-xs font-mono text-slate-500 bg-slate-800 px-2 py-1 rounded">/task.md</span>
                </div>
                <!-- Collapsible Strategy -->
                <details>
                    <summary class="flex items-center gap-2 text-sm text-slate-400 hover:text-white mb-2">
                        <span>▶ Show Roadmap</span>
                    </summary>
                     <div class="md-content text-sm text-slate-300 max-h-[300px] overflow-y-auto pr-2 custom-scrollbar p-4 bg-slate-900/50 rounded-lg">
                        ${marked.parse(future)}
                    </div>
                </details>
            </article>

            <!-- 5. HISTORY (Past) -->
            <article class="card rounded-2xl p-6 relative overflow-hidden flex-1 min-h-[600px] flex flex-col">
                 <div class="absolute top-0 left-0 w-1 h-full bg-slate-500"></div>
                 <div class="flex justify-between items-start mb-6">
                    <h2 class="text-xl font-bold text-slate-400 flex items-center gap-2">
                        <span>⏳</span> THE PAST (Archive)
                    </h2>
                    <span class="text-xs font-mono text-slate-500 bg-slate-800 px-2 py-1 rounded">/docs/logs/</span>
                </div>
                
                <div class="flex-1 overflow-y-auto pr-2 custom-scrollbar">
                    ${historyCategories.map(cat => `
                        <div class="mb-8">
                            <div class="sticky top-0 z-10 bg-[#1e293b] py-2 mb-4 border-b border-slate-700 flex items-center gap-3">
                                <span class="text-xs font-bold bg-blue-500/20 text-blue-300 px-2 py-1 rounded-sm border border-blue-500/30">
                                    ${cat === "ROOT" ? "MASTER LOG" : cat}
                                </span>
                                <span class="text-xs text-slate-500">${historyGroups[cat].length} Records</span>
                            </div>
                            
                            <div class="space-y-4">
                                ${historyGroups[cat].map(f => `
                                    <details class="group bg-slate-900/30 border border-slate-800 rounded-lg overflow-hidden">
                                        <summary class="flex items-center justify-between p-4 cursor-pointer hover:bg-slate-800/50 transition-colors">
                                            <div class="flex items-center gap-3">
                                                <div class="h-2 w-2 rounded-full bg-slate-600 group-open:bg-blue-400"></div>
                                                <span class="font-bold text-slate-200 text-sm">${f.name}</span>
                                            </div>
                                            <div class="flex items-center gap-4">
                                                 <span class="text-xs text-slate-500 font-mono">${new Date(f.mtime).toLocaleDateString()}</span>
                                                 <span class="transform group-open:rotate-180 transition-transform text-slate-400">▼</span>
                                            </div>
                                        </summary>
                                        <div class="p-6 md-content text-sm text-slate-300 border-t border-slate-800 bg-slate-900/50">
                                            ${marked.parse(f.content)}
                                        </div>
                                    </details>
                                `).join('')}
                            </div>
                        </div>
                    `).join('')}
                </div>
            </article>
        </div>

    </main>

    <footer class="max-w-7xl mx-auto mt-12 mb-8 text-center border-t border-slate-800 pt-8">
         <p class="text-slate-600 text-sm">Generated by Aether Intelligence • ${new Date().getFullYear()}</p>
         <p class="text-xs text-slate-700 mt-2 font-mono">Run 'bun scripts/render_dashboard.ts' to synchronize.</p>
    </footer>

</body>
</html>
  `;

    await write(PATHS.output, html);
    console.log(`✅ Dashboard Generated: ${PATHS.output}`);
}

generate();
