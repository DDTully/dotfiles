#!/usr/bin/env python3
"""Exercise the real firewall in isolated client/server network namespaces."""

import os
import asyncio
from pathlib import Path
import subprocess
import sys
import time
import unittest

from proton.vpn.backend.networkmanager.core import tcpcheck


ROOT = Path(__file__).resolve().parents[1]


def run(*args, check=True):
    return subprocess.run(args, check=check, capture_output=True, text=True)


class FirewallTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        if os.geteuid() != 0:
            raise RuntimeError("Run with pkexec or sudo inside unshare --net")
        cls.server = subprocess.Popen(["unshare", "--net", "sleep", "300"])
        time.sleep(0.2)
        cls.pid = str(cls.server.pid)
        cls.children = []
        run("ip", "link", "set", "lo", "up")
        cls.remote("ip", "link", "set", "lo", "up")
        for client, server, v4, v6 in (
            ("wan0", "wanpeer", "198.18.0", "fd10"),
            ("proton0", "tunpeer", "198.19.0", "fd11"),
        ):
            run("ip", "link", "add", client, "type", "veth", "peer", "name", server)
            run("ip", "link", "set", server, "netns", cls.pid)
            run("ip", "addr", "add", f"{v4}.2/24", "dev", client)
            run("ip", "-6", "addr", "add", f"{v6}::2/64", "dev", client, "nodad")
            run("ip", "link", "set", client, "up")
            cls.remote("ip", "addr", "add", f"{v4}.1/24", "dev", server)
            cls.remote("ip", "-6", "addr", "add", f"{v6}::1/64", "dev", server, "nodad")
            cls.remote("ip", "link", "set", server, "up")
        cls.remote("ip", "addr", "add", "185.159.159.148/32", "dev", "lo")
        cls.remote("ip", "addr", "add", "89.187.180.40/32", "dev", "lo")
        run("ip", "route", "add", "185.159.159.148/32", "via", "198.18.0.1")
        run("ip", "route", "add", "89.187.180.40/32", "via", "198.18.0.1")
        for address, port in (("198.18.0.1", "443"), ("185.159.159.148", "443"),
                              ("185.159.159.148", "80"), ("89.187.180.40", "443"),
                              ("89.187.180.40", "7770"), ("89.187.180.40", "8443")):
            cls.children.append(subprocess.Popen(
                ["nsenter", "-t", cls.pid, "-n", "python3", "-m", "http.server",
                 port, "--bind", address], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
            ))
        cls.children.append(subprocess.Popen(
            ["nsenter", "-t", cls.pid, "-n", "python3", "-c",
             "import socket; s=socket.socket(socket.AF_INET, socket.SOCK_DGRAM); "
             "s.bind(('198.18.0.1', 53)); "
             "exec('while True:\\n data, peer = s.recvfrom(4096)\\n s.sendto(data, peer)')"],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
        ))
        time.sleep(0.4)
        assert cls.ping("198.18.0.1"), "IPv4 fixture is unreachable before firewall"
        assert cls.ping("fd10::1"), "IPv6 fixture is unreachable before firewall"
        assert cls.http("185.159.159.148", 443), "API fixture is unreachable before firewall"
        assert cls.http("185.159.159.148", 80), "Non-HTTPS fixture is unreachable before firewall"
        assert cls.udp(), "UDP fixture is unreachable before firewall"
        assert cls.http("89.187.180.40", 443), "Chicago fixture is unreachable before firewall"
        run("tc", "qdisc", "add", "dev", "wan0", "root", "netem", "delay", "30ms")

    @classmethod
    def remote(cls, *args):
        return run("nsenter", "-t", cls.pid, "-n", *args)

    @staticmethod
    def ping(address, mark=None):
        args = ["ping", "-n", "-c", "1", "-W", "1"]
        if mark is not None:
            args += ["-m", mark]
        return run(*args, address, check=False).returncode == 0

    @staticmethod
    def http(address, port):
        return run("curl", "--noproxy", "*", "--max-time", "1", "--silent", "--fail",
                   f"http://{address}:{port}/", check=False).returncode == 0

    @staticmethod
    def udp(mark="0"):
        return run("python3", "-c",
                   "import socket, sys; s=socket.socket(socket.AF_INET, socket.SOCK_DGRAM); "
                   "s.settimeout(0.5); s.setsockopt(socket.SOL_SOCKET, socket.SO_MARK, int(sys.argv[1], 0)); "
                   "s.sendto(b'probe', ('198.18.0.1', 53)); "
                   "assert s.recv(4096) == b'probe'", mark, check=False).returncode == 0

    @classmethod
    def tearDownClass(cls):
        for child in cls.children:
            child.terminate()
            child.wait()
        cls.server.terminate()
        cls.server.wait()

    def test_firewall_contract(self):
        rules = ROOT / "lockdown.nft"
        self.assertTrue(rules.exists(), "VPN-only firewall has not been implemented")
        run("nft", "-f", str(rules))
        run("nft", "-f", str(rules))
        self.assertFalse(self.ping("198.18.0.1"), "Direct IPv4 leaked")
        self.assertFalse(self.ping("fd10::1"), "Direct IPv6 leaked")
        self.assertFalse(self.http("198.18.0.1", 443), "Arbitrary HTTPS leaked")
        self.assertFalse(self.udp(), "Direct DNS/UDP leaked")
        self.assertTrue(self.udp("0xea13b2c"), "Marked WireGuard transport blocked")
        self.assertFalse(self.udp("0x1234"), "Unrelated marked traffic leaked")
        self.assertTrue(self.http("185.159.159.148", 443), "Proton API bootstrap blocked")
        self.assertTrue(self.http("89.187.180.40", 443), "Chicago TCP reachability check blocked")
        self.assertTrue(asyncio.run(tcpcheck.is_any_port_reachable(
            "89.187.180.40", [443, 7770, 8443]
        )), "Proton's real parallel TCP probe rejects Chicago")
        self.assertFalse(self.http("185.159.159.148", 80), "Non-HTTPS API traffic allowed")
        self.assertTrue(self.ping("198.19.0.1"), "Tunnel IPv4 blocked")
        self.assertTrue(self.ping("fd11::1"), "Tunnel IPv6 blocked")
        self.assertTrue(self.ping("127.0.0.1"), "Loopback blocked")
        run("ip", "link", "set", "proton0", "down")
        self.assertFalse(self.ping("198.18.0.1"), "IPv4 leaked after tunnel loss")
        self.assertFalse(self.ping("fd10::1"), "IPv6 leaked after tunnel loss")
        run("ip", "link", "set", "proton0", "up")
        self.assertTrue(self.ping("198.19.0.1"), "Tunnel recovery blocked")


if __name__ == "__main__":
    unittest.main(argv=[sys.argv[0]], verbosity=2)
