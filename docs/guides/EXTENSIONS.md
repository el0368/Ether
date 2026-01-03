# Extending Ether IDE

Ether is built on the **SPEL-AI** stack (Svelte, Phoenix, Elixir). "Extensions" in Ether are simply new **Agents** (Backend Logic) and **Components** (Frontend UI).

## Architecture

Unlike VS Code which uses a sandboxed API, Ether extensions are **first-class citizens**.

1.  **Backend**: An Elixir GenServer (Agent) that performs logic.
2.  **Communication**: Messages sent via `EditorChannel` (WebSocket).
3.  **Frontend**: A Svelte Component that renders the UI.

## Tutorial: Creating a "Clock" Extension

### 1. Create the Backend Agent
Create `lib/aether/agents/clock_agent.ex`:

```elixir
defmodule Aether.Agents.ClockAgent do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def get_time do
    Time.to_string(Time.utc_now())
  end
end
```

Add it to your supervision tree in `lib/aether/application.ex`:

```elixir
children = [
  Aether.Agents.ClockAgent,
  # ...
]
```

### 2. Expose via Channel
Update `lib/aether_web/channels/editor_channel.ex`:

```elixir
def handle_in("clock:get", _payload, socket) do
  time = Aether.Agents.ClockAgent.get_time()
  {:reply, {:ok, %{time: time}}, socket}
end
```

### 3. Create Frontend Component
Create `assets/src/components/ClockPanel.svelte`:

```svelte
<script>
  let { channel } = $props();
  let time = $state("Loading...");

  function refresh() {
    channel.push("clock:get", {}).receive("ok", (resp) => {
      time = resp.time;
    });
  }
</script>

<div class="p-4">
  <h2 class="text-xl font-bold">{time}</h2>
  <button class="btn btn-primary btn-sm mt-2" onclick={refresh}>
    Refresh Time
  </button>
</div>
```

### 4. Register in UI
Add your panel to `App.svelte` sidebar logic.

## Types of Extensions
-   **Language Servers**: Implement `LSPAgent` logic.
-   **Tools**: Git, Docker, Database tools.
-   **AI**: Agents that modify code (`RefactorAgent`).
