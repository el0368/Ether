defmodule Mix.Tasks.Compile.Zig do
  use Mix.Task
  @recursive true

  @moduledoc """
  Compiles Zig NIFs in the `native/` directory.
  """

  def run(_args) do
    native_dir = Path.absname("native/scanner")
    priv_dir = Path.absname("priv/native")
    File.mkdir_p!(priv_dir)

    if !System.find_executable("zig") do
      Mix.shell().error("Error: 'zig' compiler not found in PATH. Please install Zig.")
      {:error, ["zig not found"]}
    else

    # 1. Resolve Erlang include path
    erl_include = Path.join([:code.root_dir(), "erts-#{:erlang.system_info(:version)}", "include"])
    
    Mix.shell().info("==> Compiling Zig NIF in #{native_dir}")
    Mix.shell().info("    Erlang Include: #{erl_include}")

    # 2. Run Zig Build
    # We use ReleaseFast for performance, but Dev is also fine.
    # In a real setup, we might toggle this based on Mix.env()
    args = [
      "build", 
      "-Doptimize=ReleaseFast", 
      "-Derl_include=#{erl_include}",
      "--prefix", "zig-out"
    ]

    case System.cmd("zig", args, cd: native_dir, stderr_to_stdout: true) do
      {output, 0} ->
        Mix.shell().info(output)
        copy_artifacts(native_dir, priv_dir)
        :ok

      {output, _error_code} ->
        Mix.shell().error("Zig compilation failed:\n#{output}")
        {:error, [output]}
    end
    end
  end

  defp copy_artifacts(native_dir, priv_dir) do
    ext = case :os.type() do
      {:win32, _} -> ".dll"
      {:unix, :darwin} -> ".so"
      {:unix, _} -> ".so"
    end

    artifact_name = "scanner_nif#{ext}"
    
    # Zig Build usually puts binaries in zig-out/bin (Windows) or zig-out/lib (Unix)
    search_paths = [
      Path.join([native_dir, "zig-out", "bin", artifact_name]),
      Path.join([native_dir, "zig-out", "lib", artifact_name])
    ]

    src = Enum.find(search_paths, &File.exists?/1)

    if src do
      dest = Path.join(priv_dir, artifact_name)
      safe_copy(src, dest)
      
      # Also sync to _build so it's available immediately
      build_priv = Path.join([Mix.Project.build_path(), "lib", "ether", "priv", "native"])
      File.mkdir_p!(build_priv)
      dest_build = Path.join(build_priv, artifact_name)
      safe_copy(src, dest_build)
    else
      Mix.shell().error("    Could not find compiled artifact in #{native_dir}/zig-out")
    end
  end

  defp safe_copy(src, dest) do
    Mix.shell().info("    Syncing: #{Path.relative_to_cwd(src)} -> #{Path.relative_to_cwd(dest)}")
    case File.cp(src, dest) do
      :ok -> :ok
      {:error, :eacces} -> 
        # Windows Shadow-Copy Trick: Rename the locked file so we can put a new one in its place
        old_path = "#{dest}.old"
        File.rm(old_path) # Try to remove previous old file
        case File.rename(dest, old_path) do
          :ok -> 
            File.cp!(src, dest)
            Mix.shell().info("    (Shadow-Copied): Replaced in-use file #{Path.basename(dest)}. Change will apply on next restart.")
          {:error, _} ->
            Mix.shell().error("    Permission denied: #{Path.relative_to_cwd(dest)} is locked and cannot be renamed.")
        end
      {:error, reason} ->
        Mix.shell().error("    Failed to copy artifact: #{reason}")
    end
  end
end
