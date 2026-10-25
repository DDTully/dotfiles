# Proton VPN lockdown

Chicago autoconnect runs once at desktop login using
`protonvpn-chicago.service`. Failed initial connections retry every 30 seconds;
this service does not continuously force reconnection after a manual disconnect.
Proton's standard kill switch remains enabled. An independent nftables table
blocks non-VPN output and forwarding, including IPv6 and direct DNS, even when
Proton intentionally disconnects. Existing UFW/Docker tables are not flushed.

## Install

Requires the official Proton CLI, an existing signed-in session, WireGuard,
NetworkManager, nftables, and a systemd graphical session.

From the repository root:

```bash
stow --simulate --verbose --target="$HOME" utils
stow --target="$HOME" utils
systemctl --user daemon-reload
systemctl --user enable protonvpn-chicago.service
sudo bash ~/.config/protonvpn/install-lockdown
```

The installer schedules automatic firewall removal in one minute. Test
disconnect/reconnect locally, then cancel rollback **only after success**:

```bash
sudo systemctl stop protonvpn-lockdown-rollback.timer
```

NetworkManager requires the firewall unit, preventing normal NetworkManager
startup if loading the firewall fails. Stopping the firewall service alone
does not remove its rules. This is not protection against a privileged user
intentionally changing the network or manually starting other network managers.

## Bootstrap exceptions and maintenance

- Loopback and traffic through `proton0` are allowed.
- WireGuard UDP with Proton's fwmark `0xea13b2c` is allowed.
- TCP 443, 7770, and 8443 to the 36 Chicago entry addresses cached on 2026-10-23 is allowed
  for Proton's pre-tunnel reachability check. These are explicit bootstrap
  exceptions, not a general HTTPS allowance. If Chicago's entry addresses change,
  update `chicago_servers` from Proton's server list and reinstall locally.
  All three ports are needed because this CLI's parallel probe returns the first
  completed result, even if another port would succeed.
- `vpn-api.proton.me` is pinned in `/etc/hosts` to `185.159.159.148`;
  only HTTPS to that address is allowed outside the tunnel. This is a deliberate
  bootstrap exception, not unrestricted internet access. The original hosts file
  is backed up to `/etc/hosts.before-protonvpn-lockdown` on first installation.
- DHCP broadcast, DHCPv6 multicast, and IPv6 neighbor discovery are allowed.
- Other direct LAN traffic, internet traffic, DNS, and container forwarding
  outside the VPN are blocked. Existing established connections are not exempt.

This configuration is specific to the installed Proton WireGuard backend.
Do not switch to OpenVPN without adapting and retesting it. If Proton changes
its API address, interface name, or fwmark, it fails closed: update the pin and
rules locally and rerun tests. API DNS is deliberately not allowed as a fallback.
DHCP unicast renewal is blocked; broadcast rebinding is allowed. Network time
is blocked until the VPN connects, so a badly incorrect clock can prevent TLS.

## Recovery

From a local terminal:

```bash
sudo /usr/local/sbin/protonvpn-lockdown-disable
systemctl --user disable --now protonvpn-chicago.service
```

This removes only the custom firewall and its NetworkManager dependency;
Proton's standard kill switch and other firewalls remain unchanged. The static
hosts entry is retained; remove the exact `185.159.159.148 vpn-api.proton.me`
line manually if no longer needed. Do not restore an old hosts backup over
unrelated later edits.

## Verification

The isolated test does not change the host's interfaces or firewall:

```bash
sudo unshare --net python3 ~/.config/protonvpn/tests/firewall.py
systemd-analyze --user verify ~/.config/systemd/user/protonvpn-chicago.service
```

Also test the actual host with the VPN connected, deliberately disconnected,
and reconnected. A fresh login and reboot are separate acceptance checks;
unit enablement alone does not prove either happened successfully.

`tests/live.py` performs the disruptive host disconnect/reconnect checks and
cancels rollback only after they pass; on failure it requests authentication
to restore access immediately. `sudo python3 ~/.config/protonvpn/tests/reinstall.py`
reinstalls an already-active host firewall and checks that the new rules load.
Neither host test is part of the isolated namespace test.
