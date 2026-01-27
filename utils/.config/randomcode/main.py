import argparse
import os
import subprocess
import sys
from pathlib import Path

def run_tmux_command(args):
    """Run a tmux command and check for errors."""
    try:
        subprocess.run(["tmux"] + args, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error running tmux command: {e}", file=sys.stderr)
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description="Launch randomcode tmux session.")
    parser.add_argument("directory", help="The directory name in ~/Sync/randomcode")
    args = parser.parse_args()

    dir_name = args.directory
    work_dir = Path.home() / "Sync/randomcode" / dir_name
    
    if not work_dir.exists():
        work_dir.mkdir(parents=True, exist_ok=True)
        
    session_name = f"Randomcode - {dir_name}"
    
    # Check if session exists
    result = subprocess.run(
        ["tmux", "has-session", "-t", session_name], 
        stdout=subprocess.DEVNULL, 
        stderr=subprocess.DEVNULL
    )
    
    if result.returncode == 0:
        # Session exists, attach
        os.execvp("tmux", ["tmux", "attach", "-t", session_name])
    
    # Start new tmux session in detached mode
    run_tmux_command(["new-session", "-d", "-s", session_name, "-c", str(work_dir)])
    
    # Window 1: editor (renaming the first window created by new-session)
    run_tmux_command(["rename-window", "-t", f"{session_name}:1", "editor"])
    run_tmux_command(["send-keys", "-t", f"{session_name}:1", "pact; nvim; clear", "C-m"])
    
    # Window 2: servers (split first, then send commands)
    run_tmux_command(["new-window", "-t", f"{session_name}:2", "-n", "servers", "-c", str(work_dir)])
    run_tmux_command(["split-window", "-v", "-t", f"{session_name}:2", "-c", str(work_dir)])
    # Target panes 1 and 2 of window 2
    run_tmux_command(["send-keys", "-t", f"{session_name}:2.1", "pact; clear; clear", "C-m"])
    run_tmux_command(["send-keys", "-t", f"{session_name}:2.2", "pact; clear; clear", "C-m"])
    
    # Window 3: agent
    run_tmux_command(["new-window", "-t", f"{session_name}:3", "-n", "agent", "-c", str(work_dir)])
    run_tmux_command(["send-keys", "-t", f"{session_name}:3", "pact; clear", "C-m"])
    
    # Window 4: working
    run_tmux_command(["new-window", "-t", f"{session_name}:4", "-n", "working", "-c", str(work_dir)])
    run_tmux_command(["send-keys", "-t", f"{session_name}:4", "pact; clear", "C-m"])
    
    # Make 'working' the active window
    run_tmux_command(["select-window", "-t", f"{session_name}:4"])
    
    # Attach to the session
    os.execvp("tmux", ["tmux", "attach", "-t", session_name])


if __name__ == "__main__":
    main()
