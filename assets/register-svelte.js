import { plugin } from "bun";
import { SveltePlugin } from "bun-plugin-svelte";

plugin(SveltePlugin({
  compilerOptions: {
    hydratable: true
  }
}));
