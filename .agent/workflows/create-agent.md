---
description: how to create a new backend agent
---

## Create a New Agent

1. Create the agent module at `lib/aether/agents/<name>_agent.ex`:
   ```elixir
   defmodule Aether.Agents.MyAgent do
     use GenServer
     require Logger

     @name __MODULE__

     def start_link(_opts) do
       GenServer.start_link(__MODULE__, %{}, name: @name)
     end

     @impl true
     def init(state) do
       Logger.info("MyAgent started.")
       {:ok, state}
     end

     # Add your API functions and handlers here
   end
   ```

2. Add to supervision tree in `lib/aether/application.ex`:
   ```elixir
   children = [
     # ... existing children
     Aether.Agents.MyAgent
   ]
   ```

3. Add channel handler in `lib/aether_web/channels/editor_channel.ex`:
   ```elixir
   def handle_in("myagent:action", payload, socket) do
     result = Aether.Agents.MyAgent.do_something(payload)
     {:reply, {:ok, result}, socket}
   end
   ```

4. Test by restarting the server and sending a message from the frontend.

## Notes
- All agents are Pure Elixir GenServers
- No NIFs or native code
- Use `Task.async_stream` for parallel work
