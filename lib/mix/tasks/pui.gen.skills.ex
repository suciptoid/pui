defmodule Mix.Tasks.Pui.Gen.Skills do
  use Mix.Task

  @shortdoc "Copy bundled PUI agent skills into your project"

  @moduledoc """
  Generate PUI skills into agent skill directories.

  By default, this task installs skills into `.agents/skills`.

      mix pui.gen.skills

  Install into Claude-compatible path:

      mix pui.gen.skills --agent claude

  Install into all built-in compatible paths:

      mix pui.gen.skills --all

  Install into a custom path:

      mix pui.gen.skills --target .my-agent/skills

  Options:

    * `--agent` - one of `codex`, `claude`, `cursor` (default: `codex`)
    * `--all` - install into all built-in compatible paths
    * `--target` - custom destination path (relative to cwd)
    * `--force` - overwrite existing skill folders
  """

  @switches [agent: :string, all: :boolean, target: :string, force: :boolean]
  @aliases [a: :agent, t: :target, f: :force]

  @built_in_targets %{
    "codex" => ".agents/skills",
    "claude" => ".claude/skills",
    "cursor" => ".cursor/skills"
  }

  @impl Mix.Task
  def run(args) do
    {opts, _argv, invalid} = OptionParser.parse(args, switches: @switches, aliases: @aliases)

    if invalid != [] do
      Mix.raise("Invalid options: #{inspect(invalid)}")
    end

    source_root = pui_skills_source_root()

    unless File.dir?(source_root) do
      Mix.raise("PUI skill templates not found at #{source_root}")
    end

    targets = resolve_targets(opts)
    force? = Keyword.get(opts, :force, false)

    skills = discover_skills(source_root)

    if skills == [] do
      Mix.raise("No skill templates were found in #{source_root}")
    end

    Enum.each(targets, fn target ->
      install_skills(skills, source_root, target, force?)
    end)

    Mix.shell().info("Installed #{length(skills)} PUI skills to #{length(targets)} target(s).")
  end

  defp pui_skills_source_root do
    :pui
    |> :code.priv_dir()
    |> to_string()
    |> Path.join("skills_templates")
  end

  defp resolve_targets(opts) do
    cond do
      target = opts[:target] ->
        [target]

      opts[:all] ->
        Map.values(@built_in_targets)

      true ->
        agent = opts[:agent] || "codex"

        case Map.fetch(@built_in_targets, agent) do
          {:ok, target} ->
            [target]

          :error ->
            Mix.raise(
              "Unknown --agent '#{agent}'. Use one of: #{Enum.join(Map.keys(@built_in_targets), ", ")}"
            )
        end
    end
  end

  defp discover_skills(source_root) do
    source_root
    |> File.ls!()
    |> Enum.filter(fn name -> File.dir?(Path.join(source_root, name)) end)
    |> Enum.filter(fn name -> File.exists?(Path.join([source_root, name, "SKILL.md"])) end)
    |> Enum.sort()
  end

  defp install_skills(skills, source_root, target, force?) do
    File.mkdir_p!(target)

    Enum.each(skills, fn skill_name ->
      src = Path.join(source_root, skill_name)
      dest = Path.join(target, skill_name)

      cond do
        File.exists?(dest) and not force? ->
          Mix.raise(
            "Skill '#{skill_name}' already exists at #{dest}. Re-run with --force to overwrite."
          )

        File.exists?(dest) and force? ->
          File.rm_rf!(dest)
          copy_skill!(src, dest)

        true ->
          copy_skill!(src, dest)
      end

      Mix.shell().info("  - #{skill_name} -> #{dest}")
    end)
  end

  defp copy_skill!(src, dest) do
    case File.cp_r(src, dest) do
      {:ok, _files} -> :ok
      {:error, reason, _path} -> Mix.raise("Failed copying #{src} to #{dest}: #{inspect(reason)}")
    end
  end
end
