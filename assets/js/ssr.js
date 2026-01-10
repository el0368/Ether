import { render } from "svelte/server"
import Workbench from "../svelte/Workbench.svelte"

const components = {
  Workbench
}

export function renderSvelte(name, props) {
  const component = components[name]
  if (!component) throw new Error(`Component ${name} not found`)
  return render(component, { props })
}

const [name, props] = JSON.parse(process.argv[2])
const { html, head } = renderSvelte(name, props)
console.log(JSON.stringify({ html, head }))
