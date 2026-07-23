"""Launch or attach to project-specific herdr workspaces in ~/Sync/randomcode."""

import argparse
import json
import subprocess
import sys
from collections.abc import Sequence
from pathlib import Path
from typing import Any, NoReturn

WORKSPACE_ROOT = Path.home() / "Sync/randomcode"


def die(message: str, code: int = 1) -> NoReturn:
    """Print message to stderr and exit."""
    print(message, file=sys.stderr)
    sys.exit(code)


def run_herdr(
    args: Sequence[str], capture: bool = False
) -> subprocess.CompletedProcess[str]:
    """Run a herdr command, dying with a readable message on failure."""
    try:
        return subprocess.run(
            ["herdr", *args], check=True, capture_output=capture, text=True
        )
    except FileNotFoundError:
        die("Error: herdr is not installed or not in PATH.")
    except subprocess.CalledProcessError as e:
        detail = f"\n{e.stderr.strip()}" if e.stderr else ""
        die(f"Error running herdr command: {e}{detail}")


def herdr_json(args: Sequence[str]) -> dict[str, Any]:
    """Run a herdr command and return the parsed "result" object from its JSON stdout."""
    stdout = run_herdr(args, capture=True).stdout
    try:
        return json.loads(stdout)["result"]
    except (json.JSONDecodeError, KeyError) as e:
        die(f"Error: unexpected herdr output from 'herdr {' '.join(args)}': {e}")


def workspace_id_for_label(label: str) -> str | None:
    """Return the id of the workspace with the given label, or None."""
    workspaces = herdr_json(["workspace", "list", "--json"])["workspaces"]
    for ws in workspaces:
        if ws["label"] == label:
            return ws["workspace_id"]
    return None


def create_tab(workspace_id: str, work_dir: Path, label: str) -> dict[str, Any]:
    """Create an unfocused tab in the workspace and return its result object."""
    return herdr_json(
        [
            "tab",
            "create",
            "--workspace",
            workspace_id,
            "--cwd",
            str(work_dir),
            "--label",
            label,
            "--no-focus",
        ]
    )


def build_workspace(work_dir: Path, label: str) -> None:
    """Create the workspace and its editor/servers/agent/working/ssh tabs."""
    created = herdr_json(
        ["workspace", "create", "--cwd", str(work_dir), "--label", label, "--focus"]
    )
    workspace_id = created["workspace"]["workspace_id"]

    run_herdr(["tab", "rename", created["tab"]["tab_id"], "editor"])
    run_herdr(["pane", "run", created["root_pane"]["pane_id"], "pact; nvim; clear"])

    servers = create_tab(workspace_id, work_dir, "servers")
    top_pane_id = servers["root_pane"]["pane_id"]
    bottom = herdr_json(
        [
            "pane",
            "split",
            "--pane",
            top_pane_id,
            "--direction",
            "down",
            "--cwd",
            str(work_dir),
            "--no-focus",
        ]
    )
    for pane_id in (top_pane_id, bottom["pane"]["pane_id"]):
        run_herdr(["pane", "run", pane_id, "pact; clear; clear"])

    working_tab_id = ""
    for tab_label in ("agent", "working", "ssh"):
        tab = create_tab(workspace_id, work_dir, tab_label)
        run_herdr(["pane", "run", tab["root_pane"]["pane_id"], "pact; clear"])
        if tab_label == "working":
            working_tab_id = tab["tab"]["tab_id"]

    run_herdr(["tab", "focus", working_tab_id])


def main() -> None:
    parser = argparse.ArgumentParser(description="Launch randomcode herdr workspace.")
    parser.add_argument("directory", help="The directory name in ~/Sync/randomcode")
    args = parser.parse_args()

    dir_name = args.directory.strip()
    if not dir_name or Path(dir_name).name != dir_name or dir_name in {".", ".."}:
        die(
            "Error: directory must be a single folder name (no path separators).",
            code=2,
        )

    work_dir = WORKSPACE_ROOT / dir_name
    work_dir.mkdir(parents=True, exist_ok=True)

    label = f"Randomcode - {dir_name}"
    existing_id = workspace_id_for_label(label)
    if existing_id is not None:
        # This process is already an attached herdr pane (nested `herdr` is
        # refused), so focusing takes over the current view directly.
        run_herdr(["workspace", "focus", existing_id])
        return

    build_workspace(work_dir, label)


if __name__ == "__main__":
    main()
