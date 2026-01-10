import { render } from "svelte/server"
import Workbench from "../svelte/Workbench.svelte"
import ActivityBar from "../svelte/ActivityBar.svelte"
import Explorer from "../svelte/Explorer.svelte"
import Editor from "../svelte/Editor.svelte"

const components = {
  Workbench,
  ActivityBar,
  Explorer,
  Editor
}

export function renderSvelte(name, props) {
  const component = components[name]
  if (!component) throw new Error(`Component ${name} not found`)
  return render(component, { props })
}

const [name, props] = JSON.parse(process.argv[2])
const { html, head } = renderSvelte(name, props)
console.log(JSON.stringify({ html, head }))
