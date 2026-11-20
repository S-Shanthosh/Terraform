<div align="center">

# 🎨 Linux-Color & Log Analysis Handbook

**Amazon Linux 2023 · Terminal Colours · journald · lnav · Log Troubleshooting**

![Linux](https://img.shields.io/badge/Linux-Amazon%20Linux%202023-FCC624?logo=linux&logoColor=black)
![AWS](https://img.shields.io/badge/AWS-EC2-FF9900?logo=amazonaws&logoColor=white)
![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnubash&logoColor=white)
![Logs](https://img.shields.io/badge/Logs-journald%20%7C%20lnav-2ea44f)
![Learning](https://img.shields.io/badge/Approach-Native%20Commands%20First-blue)

*Make terminal output easier to read. Understand every command. Analyse logs with confidence.*

</div>

---

## 🧭 Quick Navigation

| # | Section | What you'll learn |
|---|---|---|
| 1 | [🎯 Purpose & learning rules](#1--purpose--learning-rules) | What Linux-Color changes—and what it does not |
| 2 | [🎨 Install Linux-Color](#2--install-linux-color) | Set up the colourful terminal |
| 3 | [🖥️ Terminal colour behaviour](#3--terminal-colour-behaviour) | eza, icons and standard commands |
| 4 | [📜 View system logs](#4--view-system-logs) | Read current, recent and live logs |
| 5 | [🚨 Filter by severity and time](#5--filter-by-severity-and-time) | Narrow down incidents |
| 6 | [🛠️ Inspect services](#6--inspect-services) | Investigate service activity |
| 7 | [🔍 Search logs](#7--search-logs) | Find errors and patterns |
| 8 | [🌈 Interactive analysis with lnav](#8--interactive-analysis-with-lnav) | Explore colour-highlighted structured logs |
| 9 | [📂 Traditional log files](#9--traditional-log-files) | Inspect files under /var/log |
| 10 | [📊 Access-log analysis](#10--access-log-analysis) | Analyse IPs, URLs and HTTP status codes |
| 11 | [💾 Disk, memory and performance](#11--disk-memory-and-performance-checks) | Investigate resource issues |
| 12 | [🧰 Optional log toolkit](#12--optional-log-toolkit-shortcuts) | Understand shortcuts without depending on them |
| 13 | [⌨️ Command building blocks](#13--understand-the-command-building-blocks) | Learn the Linux tools behind the pipelines |
| 14 | [🗓️ Practice plan](#14--daily-practice-plan) | Build confidence through repetition |

> [!IMPORTANT]
> **Learning rule — native commands first.** This handbook teaches standard Linux commands before optional conveniences. Shortcuts are not required, are not loaded automatically, and should never replace understanding the original command.

---

## 1. 🎯 Purpose & learning rules

Linux-Color improves terminal readability. It is intended for Amazon Linux 2023 and the browser-based AWS EC2 Instance Connect terminal.

It provides colour-oriented shell configuration and enhanced directory listings. The log-analysis workflow uses standard Linux utilities such as `journalctl`, `grep`, `awk`, `sort`, `uniq`, `less`, and `tail`.

**What this handbook aims to do:**
- Make directory listings easier to scan.
- Make structured logs easier to inspect with lnav.
- Teach the original Linux commands and their options.
- Keep optional aliases and toolkit shortcuts separate from the default shell setup.

**What it does not do:** It does not change the meaning of Linux commands or make log analysis automatic. You remain responsible for understanding the command, its output and the evidence behind a diagnosis.

---

## 2. 🎨 Install Linux-Color

### Requirements

- Amazon Linux 2023 EC2 instance.
- Bash shell.
- Internet access to clone the repository and install any required packages.
- For optional file icons, a Nerd Font in the terminal application on your local computer.

### Installation

```bash
git clone https://github.com/S-Shanthosh/Terraform.git
cd Terraform/Onbarding-FreeTier-AWS
./Linux-Color
source ~/.bashrc
```

### Available options

| Flag | Purpose |
|---|---|
| `--help` | Display usage information |
| `--icons` | Enable file icons in eza; requires a Nerd Font on the connecting computer |
| `--windows` | Print Windows Terminal / Nerd Font setup guidance |

Examples:

```bash
./Linux-Color --help
./Linux-Color --icons --windows
```

> [!NOTE]
> The default setup is designed for browser-based EC2 Instance Connect and uses no icons. Icons may not render correctly unless the local terminal font supports them.

### Configuration notes

- Colour configuration is stored in `~/.bashrc.d/10-colors.sh`.
- Each installer run overwrites that colour configuration file. Re-run with `--icons` when you want the icon-enabled configuration.
- The installer and shell configuration should be reviewed before adding any optional commands to your interactive shell.
- The `lnav` installation in this setup supports x86_64 only.

---

## 3. 🖥️ Terminal colour behaviour

Linux-Color uses `eza` for enhanced directory listings.

| Command | Behaviour |
|---|---|
| `eza` | Enhanced, colourised directory listing |
| `ls` | May be configured as an eza-backed listing by Linux-Color |
| `\ls` | Invoke the external system `ls` command, bypassing a shell alias |
| `command ls` | Invoke the command without a shell function or alias |
| `ll`, `la`, `lt` | Convenience listings provided by the configuration, where configured |

**Learning tip:** Use `command ls` to practise the standard listing command. Run `eza` explicitly when you want the enhanced display. Remember that `ll`, `la`, and `lt` are conveniences, not core Linux commands.

---

## 4. 📜 View system logs

Amazon Linux 2023 primarily uses systemd-journald. Start with the journal before assuming a traditional log file exists.

| Task | Native command |
|---|---|
| Current boot | `sudo journalctl -b` |
| Latest 100 entries | `sudo journalctl -n 100 --no-pager` |
| Follow new entries live | `sudo journalctl -f` |
| Logs from the last hour | `sudo journalctl --since "1 hour ago"` |
| Logs from a time range | `sudo journalctl --since "2026-11-21 06:00" --until "2026-11-21 07:00"` |

Example — display the current boot's logs:

```bash
sudo journalctl -b
```

Example — monitor new log entries as they arrive:

```bash
sudo journalctl -f
```

Press `Ctrl+C` to stop following the live journal.

---

## 5. 🚨 Filter by severity and time

### Severity levels

| Severity | Command |
|---|---|
| Warning and more severe | `sudo journalctl -p warning -b` |
| Error and more severe | `sudo journalctl -p err -b` |
| Critical and more severe | `sudo journalctl -p crit -b` |

Severity order, from most severe to least severe:

`emerg → alert → crit → err → warning → notice → info → debug`

### Combine severity with a time window

```bash
sudo journalctl -p err --since "1 hour ago"
```

> [!TIP]
> Start with the incident time window, then filter by severity. Widen the time range when the first search does not reveal the cause.

---

## 6. 🛠️ Inspect services

A service-specific journal view helps isolate activity from a single service.

### SSH service

```bash
# SSH logs from the current boot
sudo journalctl -u sshd -b

# Follow SSH logs live
sudo journalctl -u sshd -f

# SSH logs from the last hour
sudo journalctl -u sshd --since "1 hour ago"
```

### Check service state

```bash
systemctl status sshd
systemctl --failed
```

### Another service example

```bash
sudo journalctl -u nginx --since "1 hour ago"
systemctl status nginx
```

Service names can differ by distribution and installation. Check the actual unit name on your system.

---

## 7. 🔍 Search logs

### Search journal output for common problem terms

```bash
sudo journalctl -b --no-pager | grep -iE 'error|failed|denied|warning'
```

### Search traditional log files recursively

```bash
sudo grep -rniE 'error|fail|fatal|denied|timeout|oom|segfault' /var/log
```

### Understand the grep options

| Option | Meaning |
|---|---|
| `-r` | Search directories recursively |
| `-n` | Display line numbers |
| `-i` | Ignore letter case |
| `-E` | Use extended regular expressions |

These are standard grep options. Practise them individually so you know how the search is constructed.

---

## 8. 🌈 Interactive analysis with lnav

`lnav` is an interactive log viewer. For structured systemd journal output, pass JSON records to its built-in `journald_json_log` format. This format can colour identifiers such as the systemd unit, program identifier and PID.

### Current boot

```bash
sudo journalctl -b -o json --no-pager | lnav -
```

### Recent 200 entries

```bash
sudo journalctl -n 200 -o json --no-pager | lnav -
```

### A specific service

```bash
sudo journalctl -u sshd -b -o json --no-pager | lnav -
```

### Follow new entries

```bash
sudo journalctl -f -o json --no-pager | lnav -
```

### Useful lnav keys

| Key | Action |
|---|---|
| `/` | Search |
| `e` / `E` | Next / previous error, where supported by the active view |
| `w` / `W` | Next / previous warning, where supported by the active view |
| `q` | Quit |

> [!NOTE]
> **Why JSON?** Human-readable journal output is useful for everyday reading. JSON exposes structured fields such as `_SYSTEMD_UNIT`, `SYSLOG_IDENTIFIER`, and `_PID`. lnav can use these fields to identify and colour the relevant values. This works across services, not just SSH.

---

## 9. 📂 Traditional log files

Amazon Linux 2023 primarily uses journald. Traditional files may or may not be present.

### Check available log files first

```bash
ls -l /var/log
```

### Open a file when it exists

```bash
sudo lnav /var/log/messages
```

Do not assume that `/var/log/secure` exists. When it is absent, use the journal for SSH:

```bash
sudo journalctl -u sshd -b
```

---

## 10. 📊 Access-log analysis

The following examples use a conventional web access-log layout. Confirm the log format before relying on field positions.

### Requests by HTTP status code

```bash
awk '{print $9}' access.log | sort | uniq -c | sort -rn
```

### Top requested URLs

```bash
awk '{print $7}' access.log | sort | uniq -c | sort -rn | head
```

### Top client IP addresses

```bash
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -10
```

### Top 404 URLs

```bash
awk '$9==404{print $7}' access.log | sort | uniq -c | sort -rn | head -10
```

### Visual access-log report with GoAccess

```bash
goaccess access.log --log-format=COMBINED
```

### Filter JSON application logs

```bash
jq 'select(.level=="ERROR")' app.log
```

> [!WARNING]
> The examples using `$1`, `$7`, and `$9` assume a common access-log layout: client IP in field 1, request path in field 7, and HTTP status in field 9. A custom log format may use different positions. The GoAccess example assumes a Combined-style access log.

---

## 11. 💾 Disk, memory and performance checks

| What to investigate | Native command |
|---|---|
| Disk capacity | `df -h` |
| Largest directories interactively | `sudo ncdu /` |
| Largest log files | `sudo du -ah /var/log 2>/dev/null | sort -rh | head -15` |
| Live CPU and memory | `htop` |
| Disk I/O statistics | `iostat -x 2 5` |
| Memory availability | `free -h` |
| Kernel OOM messages | `sudo journalctl -k | grep -i oom` |
| Listening sockets and ports | `ss -tulpen` |

Some utilities such as `ncdu`, `htop`, `iostat`, and `goaccess` may need to be installed separately. Check package availability for your system before using them.

---

## 12. 🧰 Optional log toolkit shortcuts

**This section is optional.** The original Linux commands above are the primary learning material. The following shortcuts are conveniences only, and should be enabled only after you understand the commands they represent.

| Task | Native command to learn | Optional shortcut |
|---|---|---|
| Last 50 boot errors | `sudo journalctl -p err -b --no-pager | tail -50` | `jerr` |
| Follow journal live | `sudo journalctl -f` | `jf` |
| Logs for one service | `sudo journalctl -u sshd` | `jsvc sshd` |
| Search files for errors | `sudo grep -rniE 'error|fail|fatal|denied|timeout|oom|segfault' /var/log` | `errs /var/log` |
| Open logs in lnav | `sudo lnav /var/log` | `lg` |
| Find largest log files | `sudo du -ah /var/log 2>/dev/null | sort -rh | head -15` | `biglogs` |
| Top client IPs | `awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -10` | `topip access.log` |
| Top 404 URLs | `awk '$9==404{print $7}' access.log | sort | uniq -c | sort -rn | head -10` | `top404 access.log` |

### Enable shortcuts for the current shell only

The toolkit file is separate from the default shell setup. To load it for the current session:

```bash
source ~/.config/linux-color/log-toolkit.sh
```

These shortcuts remain available only in that shell session unless you deliberately add the source command to your own shell configuration.

> [!IMPORTANT]
> Do not add this source command to `~/.bashrc` as part of the default learning setup. Keeping it manual avoids silently replacing command practice with shortcuts.

---

## 13. 🧠 Understand the command building blocks

The access-log and troubleshooting examples combine small, standard utilities. Learn what each one does.

| Command | What it does |
|---|---|
| `journalctl` | Reads the systemd journal |
| `grep` | Searches text for matching patterns |
| `awk` | Reads and extracts fields from text records |
| `sort` | Sorts lines |
| `uniq -c` | Counts adjacent repeated lines; sort first when grouping |
| `head` | Displays the first lines |
| `tail` | Displays the last lines |
| `du -ah` | Reports file and directory sizes |
| `less` | Views text interactively |
| `jq` | Filters and processes JSON data |
| `systemctl` | Inspects and manages systemd services |

### Read a pipeline from left to right

Example:

```bash
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -10
```

1. `awk` extracts the first field from each record.
2. `sort` puts identical values together.
3. `uniq -c` counts consecutive identical values.
4. `sort -rn` sorts counts numerically, largest first.
5. `head -10` displays the first ten results.

The goal is to understand each stage—not just memorise the full pipeline.

---

## 14. 🗓️ Daily practice plan

| Day | Practical exercise |
|---|---|
| Monday | Run `sudo journalctl -p err -b`; identify one error and explain it |
| Tuesday | Run `sudo journalctl -u sshd`; inspect SSH activity |
| Wednesday | Open journal output in `lnav`; practise search and error/warning navigation |
| Thursday | Build the `awk | sort | uniq -c` pipelines for IPs and 404 responses |
| Friday | In a safe test environment, stop a test service and find the resulting evidence in the journal |

### 🎯 Golden rules

1. 🕐 **Time first:** Narrow analysis to the incident window.
2. 🚨 **Errors first:** Start with `-p err`, then widen the search.
3. 🔗 **Follow the chain:** Understand the events leading up to the error, not just the final message.
4. 🧠 **Native first:** Learn the actual commands and their options before using shortcuts.
5. 🎨 **Colour is clarity:** Use colour to read output faster, not as a substitute for understanding it.
6. 🔍 **Verify the source:** Check the service name, log format and file availability before assuming a command applies.

<div align="center">

*Made for the Onboarding Free-Tier AWS series* ☁️

**Learn the command. Understand the output. Then automate.**

</div>
