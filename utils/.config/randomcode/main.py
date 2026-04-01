import argparse
import os
import subprocess
import sys
from pathlib import Path
from typing import NoReturn, Sequence


def die(message: str, code: int = 1) -> NoReturn:
    print(message, file=sys.stderr)
    sys.exit(code)


def run_tmux_command(args: Sequence[str]) -> None:
    """Run a tmux command and check for errors."""
    try:
        subprocess.run(["tmux", *args], check=True)
    except FileNotFoundError:
        die("Error: tmux is not installed or not in PATH.")
    except subprocess.CalledProcessError as e:
        die(f"Error running tmux command: {e}")


def run_tmux_capture(args: Sequence[str]) -> str:
    """Run a tmux command and return stdout."""
    try:
        result = subprocess.run(
            ["tmux", *args],
            check=True,
            capture_output=True,
            text=True,
        )
        return result.stdout
    except FileNotFoundError:
        die("Error: tmux is not installed or not in PATH.")
    except subprocess.CalledProcessError as e:
        die(f"Error running tmux command: {e}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Launch randomcode tmux session.")
    parser.add_argument("directory", help="The directory name in ~/Sync/randomcode")
    args = parser.parse_args()

    dir_name = args.directory.strip()
    if not dir_name or Path(dir_name).name != dir_name or dir_name in {".", ".."}:
        die(
            "Error: directory must be a single folder name (no path separators).",
            code=2,
        )

    work_dir = Path.home() / "Sync/randomcode" / dir_name

    if not work_dir.exists():
        work_dir.mkdir(parents=True, exist_ok=True)

    session_name = f"Randomcode - {dir_name}"

    # Check if session exists
    try:
        result = subprocess.run(
            ["tmux", "has-session", "-t", session_name],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except FileNotFoundError:
        die("Error: tmux is not installed or not in PATH.")

    if result.returncode == 0:
        # Session exists, attach
        os.execvp("tmux", ["tmux", "attach", "-t", session_name])

    # Start new tmux session and create windows.
    run_tmux_command(
        ["new-session", "-d", "-s", session_name, "-n", "editor", "-c", str(work_dir)]
    )
    run_tmux_command(
        ["send-keys", "-t", f"{session_name}:editor", "pact; nvim; clear", "C-m"]
    )

    run_tmux_command(
        ["new-window", "-n", "servers", "-t", session_name, "-c", str(work_dir)]
    )
    run_tmux_command(
        ["split-window", "-v", "-t", f"{session_name}:servers", "-c", str(work_dir)]
    )
    server_panes = [
        pane_id
        for pane_id in run_tmux_capture(
            ["list-panes", "-t", f"{session_name}:servers", "-F", "#{pane_id}"]
        ).splitlines()
        if pane_id
    ]
    for pane_id in server_panes:
        run_tmux_command(["send-keys", "-t", pane_id, "pact; clear; clear", "C-m"])

    run_tmux_command(
        ["new-window", "-n", "agent", "-t", session_name, "-c", str(work_dir)]
    )
    run_tmux_command(["send-keys", "-t", f"{session_name}:agent", "pact; clear", "C-m"])

    run_tmux_command(
        ["new-window", "-n", "working", "-t", session_name, "-c", str(work_dir)]
    )
    run_tmux_command(
        ["send-keys", "-t", f"{session_name}:working", "pact; clear", "C-m"]
    )

    run_tmux_command(
        ["new-window", "-n", "ssh", "-t", session_name, "-c", str(work_dir)]
    )
    run_tmux_command(["send-keys", "-t", f"{session_name}:ssh", "pact; clear", "C-m"])

    # Make 'working' the active window
    run_tmux_command(["select-window", "-t", f"{session_name}:working"])

    # Attach to the session
    os.execvp("tmux", ["tmux", "attach", "-t", session_name])


if __name__ == "__main__":
    main()
