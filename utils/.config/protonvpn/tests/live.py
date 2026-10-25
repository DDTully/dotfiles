#!/usr/bin/env python3
"""Disconnect and reconnect the host; restore access immediately on failure."""

import socket
import subprocess


def call(*args, timeout=15):
    return subprocess.run(args, capture_output=True, text=True, timeout=timeout)


def internet(family):
    address = (
        "https://1.1.1.1/cdn-cgi/trace" if family == "-4"
        else "https://[2606:4700:4700::1111]/cdn-cgi/trace"
    )
    return call("curl", "--noproxy", "*", family, "--silent", "--fail",
                "--max-time", "3", "--output", "/dev/null", address).returncode == 0


try:
    assert internet("-4") and internet("-6"), "Connected internet failed"
    print("PASS: connected IPv4 and IPv6 work", flush=True)
    try:
        result = call("protonvpn", "disconnect", timeout=15)
        status = call("protonvpn", "status")
        assert "Status: Disconnected" in status.stdout, "Host did not disconnect"
        print(f"PASS: disconnected (CLI exit {result.returncode})", flush=True)
        assert not internet("-4") and not internet("-6"), "Disconnected internet leaked"
        print("PASS: disconnected IPv4 and IPv6 blocked", flush=True)
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
            sock.settimeout(1)
            try:
                sock.sendto(bytes.fromhex(
                    "123401000001000000000000076578616d706c6503636f6d0000010001"
                ), ("9.9.9.9", 53))
                sock.recv(4096)
                raise AssertionError("Direct DNS leaked")
            except OSError:
                print("PASS: direct DNS blocked", flush=True)
        api = call("curl", "--noproxy", "*", "--silent", "--max-time", "5",
                   "--output", "/dev/null", "--write-out", "%{http_code}",
                   "https://vpn-api.proton.me/vpn/v1/logicals")
        assert api.returncode == 0 and api.stdout in {"200", "400", "401", "403"}, "API unreachable"
        print("PASS: Proton API bootstrap reachable", flush=True)
    finally:
        reconnect = call("systemctl", "--user", "restart", "protonvpn-chicago.service", timeout=25)
        assert reconnect.returncode == 0, "Login-service reconnect failed"
    assert internet("-4") and internet("-6"), "Reconnected internet failed"
    assert "Chicago" in call("protonvpn", "status").stdout, "Wrong VPN city"
    assert call("systemctl", "is-active", "protonvpn-lockdown.service").returncode == 0, "Firewall rolled back"
    assert call("pkexec", "/usr/bin/nft", "list", "table", "inet", "protonvpn_lockdown").returncode == 0, "Firewall missing"
    assert call("pkexec", "/usr/bin/systemctl", "stop", "protonvpn-lockdown-rollback.timer").returncode == 0, "Could not cancel rollback"
    print("PASS: Chicago login service reconnected; IPv4/IPv6 restored; firewall active; rollback cancelled", flush=True)
except BaseException:
    print("FAIL: restoring access immediately, without waiting for the timer", flush=True)
    call("pkexec", "/usr/local/sbin/protonvpn-lockdown-disable", timeout=30)
    call("systemctl", "--user", "restart", "protonvpn-chicago.service", timeout=40)
    raise
