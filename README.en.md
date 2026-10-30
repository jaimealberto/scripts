<!-- Language: [Español](README.md) | English -->

# 🛠️ scripts — Infrastructure automation

![License](https://img.shields.io/badge/license-MIT-green.svg)
![Bash](https://img.shields.io/badge/shell-bash-121011?logo=gnu-bash&logoColor=white)
![Python](https://img.shields.io/badge/python-3-3776AB?logo=python&logoColor=white)
![PowerShell](https://img.shields.io/badge/powershell-5391FE?logo=powershell&logoColor=white)
[![ShellCheck](https://github.com/jaimealberto/scripts/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/jaimealberto/scripts/actions/workflows/shellcheck.yml)

> 🌐 **Language:** [Español](README.md) · English

A collection of **systems administration, networking and automation** scripts that
I use to manage my own infrastructure (hypervisors, NAS, Raspberry Pi, the OPNsense
firewall and a ZeroTier mesh). Each script is self-contained, is documented in its
header and **contains no credentials**: sensitive values appear as placeholders
(`<TU_API_TOKEN>`) that you must fill in before using them.

---

## 📁 Structure

```
.
├── Linux/
│   ├── zerotier/     # ZeroTier network and host management via API
│   ├── cloudflare/   # Dynamic DNS and record management on Cloudflare
│   ├── backup/       # Remote backups (OPNsense, Raspberry Pi)
│   └── system/       # System utilities (user creation, monitoring…)
└── Windows/
    └── Ansible/      # Preparing Windows to be managed with Ansible
```

| Area | What's inside | Details |
|------|---------------|---------|
| 🔗 **[Linux/zerotier](Linux/zerotier/)** | ZeroTier installation and full management of the account, networks and members via API (add/remove, authorization, IP, description, status). | [README](Linux/zerotier/README.md) |
| ☁️ **[Linux/cloudflare](Linux/cloudflare/)** | Dynamic DNS (DDNS) and creation/removal of subdomains on domains already registered in Cloudflare. | [README](Linux/cloudflare/README.md) |
| 💾 **[Linux/backup](Linux/backup/)** | Remote backups with e-mail alerting: OPNsense configuration (API) and hot backups of Raspberry Pi. | [README](Linux/backup/README.md) |
| ⚙️ **[Linux/system](Linux/system/)** | Miscellaneous utilities: user creation for remote administration, tool installation and ping monitoring. | [README](Linux/system/README.md) |
| 🪟 **[Windows/Ansible](Windows/Ansible/)** | PowerShell scripts to enable WinRM and get Windows ready for Ansible. | [README](Windows/Ansible/README.md) |

---

## 🚀 Usage

```bash
git clone git@github.com:jaimealberto/scripts.git
cd scripts/Linux/<area>
chmod +x <script>.sh
./<script>.sh
```

Before running any script, **edit the configuration section** in its header and
replace the placeholders (`<...>`) with your real values.

### Common requirements

- **Bash** 4+ and [`jq`](https://stedolan.github.io/jq/) for the ZeroTier/Cloudflare scripts.
- **Python 3** for the Cloudflare subdomain scripts.
- **`curl`** for the API calls.
- **`msmtp`** (or equivalent) for the e-mail alerts in the backup scripts.

---

## 🔒 Security

- No script contains real tokens, keys or passwords: everything is a **placeholder**.
- Where possible, secrets can be passed through an **environment variable**
  (for example `ZT_API_TOKEN`) instead of writing them into the file.
- Always use **least-privilege API tokens** and protect configuration files
  with `chmod 600`.

---

## 📜 License

Distributed under the **MIT** license. See the [LICENSE](LICENSE) file for details.

## 👤 Author

**JaimeAlberto** — Systems administration and infrastructure
🌐 Blog: [jaimealberto.io](https://jaimealberto.io)
