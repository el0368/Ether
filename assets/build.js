import { build } from "bun"
import { SveltePlugin } from "bun-plugin-svelte"

const isWatch = process.argv.includes("--watch")

async function doBuild() {
  const result = await build({
    entrypoints: ["js/app.js"],
    outdir: "../priv/static/assets",
    minify: !isWatch,
    sourcemap: isWatch ? "external" : "none",
    plugins: [
      SveltePlugin({
        compilerOptions: {
          hydratable: true
        }
      })
    ],
    external: ["/fonts/*", "/images/*"]
  })

  if (result.success) {
    console.log("Build successful")
  } else {
    console.error("Build failed")
    for (const message of result.logs) {
      console.error(message)
    }
    process.exit(1)
  }
}

doBuild()
