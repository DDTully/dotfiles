#!/usr/bin/env python3
"""Reinstall an active host firewall and verify that its live rules reload."""

from pathlib import Path
import subprocess


def run(*args):
    return subprocess.run(args, check=True, capture_output=True, text=True)


root = Path(__file__).resolve().parents[1]
run("nft", "add", "set", "inet", "protonvpn_lockdown", "reinstall_probe", "{ type ipv4_addr; }")
try:
    run("bash", str(root / "install-lockdown"))
    result = subprocess.run(
        ["nft", "list", "set", "inet", "protonvpn_lockdown", "reinstall_probe"],
        capture_output=True
    )
    assert result.returncode != 0, "Reinstall left the old live ruleset intact"
    print("PASS: reinstall loaded the new ruleset")
finally:
    run("systemctl", "stop", "protonvpn-lockdown-rollback.timer")
    subprocess.run(
        ["nft", "delete", "set", "inet", "protonvpn_lockdown", "reinstall_probe"],
        capture_output=True
    )
