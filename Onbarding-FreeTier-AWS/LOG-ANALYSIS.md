<div align="center">

# 🔍 Linux Log Analysis Handbook

**Amazon Linux 2023 · journald · lnav · DevOps Troubleshooting**

![Linux](https://img.shields.io/badge/Linux-AL2023-FCC624?logo=linux&logoColor=black)
![AWS](https://img.shields.io/badge/AWS-EC2-FF9900?logo=amazonaws&logoColor=white)
![lnav](https://img.shields.io/badge/Tool-lnav-2ea44f)
![Level](https://img.shields.io/badge/Level-Beginner→Pro-blue)

*Find the problem fast. Read logs like a pro.*

</div>

---

## 🧭 Quick Navigation

| # | Section | Goal |
|---|---------|------|
| 1 | [📜 View logs](#1--view-system-logs) | See what happened |
| 2 | [🚨 Severity filters](#2--filter-by-severity) | Show only errors/warnings |
| 3 | [🛠️ Inspect a service](#3-️-inspect-a-service) | Debug one service |
| 4 | [🎨 lnav (coloured)](#4--interactive-analysis-with-lnav) | Interactive, colourful view |
| 5 | [📂 Log files](#5--traditional-log-files) | `/var/log` files |
| 6 | [🔎 grep search](#6--search-with-grep) | Find keywords |
| 7 | [⚡ Native commands & optional shortcuts](#7--native-commands-and-optional-shortcuts) | Learn first, shortcut second |
| 8 | [📊 Access-log analysis](#8--access-log-analysis) | Top IPs, 404s |
| 9 | [💾 Disk & performance](#9--disk--performance-checks) | Full disk, high CPU |
| 10 | [🗓️ Practice plan](#10-️-daily-practice-plan) | Build the skill |

> [!NOTE]
 > **Learning rule:** use the native command first. Optional Linux-Color shortcuts are separate and never replace or rename standard commands.

---

## 1. 📜 View system logs

| Task | Command |
|------|---------|
| Current boot | `sudo journalctl -b` |
| Last 100 entries | `sudo journalctl -n 100 --no-pager` |
| Live follow | `sudo journalctl -f` |
| Last hour | `sudo journalctl --since "1 hour ago"` |
| Time range | `sudo journalctl --since "2026-11-19 06:00" --until "2026-11-19 07:00"` |

---

## 2. 🚨 Filter by severity

| Level | Command |
|-------|---------|
| ⚠️ Warning and worse | `sudo journalctl -p warning -b` |
| ❌ Error and worse | `sudo journalctl -p err -b` |
| 🔥 Critical only | `sudo journalctl -p crit -b` |

> [!TIP]
> Severity order: `emerg → alert → crit → err → warning → notice → info → debug`

---

## 3. 🛠️ Inspect a service

```bash
sudo journalctl -u sshd -b          # SSH logs, this boot
sudo journalctl -u sshd -f          # follow live
sudo journalctl -u nginx --since "1 hour ago"
systemctl status sshd               # current state
systemctl --failed                  # all failed services
```

---

## 4. 🎨 Interactive analysis with lnav

lnav's built-in `journald_json_log` format colours the systemd unit, program and PID. Feed it JSON:

```bash
sudo journalctl -b -o json --no-pager | lnav -                 # current boot
sudo journalctl -n 200 -o json --no-pager | lnav -             # recent
sudo journalctl -u sshd -b -o json --no-pager | lnav -         # one service
sudo journalctl -f -o json --no-pager | lnav -                 # live
```

### ⌨️ lnav keys

| Key | Action |
|-----|--------|
| `/` | Search |
| `e` / `E` | Next / previous **error** |
| `w` / `W` | Next / previous **warning** |
| `q` | Quit |

> [!NOTE]
> **Why JSON?** It exposes fields like `_SYSTEMD_UNIT`, `SYSLOG_IDENTIFIER`, `_PID`, which lnav colours individually.

---

## 5. 📂 Traditional log files

AL2023 mainly uses journald. Check what exists first:

```bash
ls -l /var/log
sudo lnav /var/log/messages
```

> [!WARNING]
> Don't assume `/var/log/secure` exists. Use `sudo journalctl -u sshd` when it doesn't.

---

## 6. 🔎 Search with grep

```bash
sudo journalctl -b --no-pager | grep -iE 'error|failed|denied|warning'
```

---

## 7. ⚡ Native commands and optional shortcuts

**Learn and practise the native command first.** Linux-Color shortcuts are optional conveniences; they are not required.

| Task | Native Linux command (learn this) | Optional shortcut |
|---|---|---|
| Last 50 boot errors | `sudo journalctl -p err -b --no-pager | tail -50` | `jerr` |
| Follow journal live | `sudo journalctl -f` | `jf` |
| Logs for one service | `sudo journalctl -u sshd` | `jsvc sshd` |
| Search files for errors | `sudo grep -rniE 'error|fail|fatal|denied|timeout|oom|segfault' /var/log` | `errs /var/log` |
| Open logs in lnav | `sudo lnav /var/log` | `lg` |
| Find largest log files | `sudo du -ah /var/log 2>/dev/null | sort -rh | head -15` | `biglogs` |
| Top client IPs | `awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -10` | `topip access.log` |
| Top 404 URLs | `awk '$9==404{print $7}' access.log | sort | uniq -c | sort -rn | head -10` | `top404 access.log` |

### Enable shortcuts only if you want them

The installer saves shortcuts separately and does **not** load them automatically:

```bash
source ~/.config/linux-color/log-toolkit.sh
```

They are available only in the current shell session unless you choose to source the file from your own shell configuration.

### Understand the building blocks

- `grep` searches text; `-r` searches directories recursively; `-n` shows line numbers; `-i` ignores case.
- `awk` extracts fields from each log line.
- `sort` orders results.
- `uniq -c` counts adjacent repeated lines (sort first).
- `head` limits the displayed results.
- `du -ah` reports file and directory sizes.

----------|--------------|
| `jerr` | Last 50 errors this boot |
| `jf` | Follow the journal live |
| `jsvc <unit>` | Journal of one service |
| `errs <path>` | Recursive search for error/fail/denied/timeout/oom |
| `lg` | Open `/var/log` in lnav |
| `biglogs` | 15 largest files in `/var/log` |
| `hl` | Colour errors 🔴 and warnings 🟡 in piped output |
| `topip <file>` | Top 10 client IPs |
| `top404 <file>` | Top 10 URLs returning 404 |

```bash
sudo journalctl -f | hl
jsvc nginx --since "30 min ago"
topip /var/log/nginx/access.log
```

---

## 8. 📊 Access-log analysis

```bash
# Requests per status code
awk '{print $9}' access.log | sort | uniq -c | sort -rn

# Top requested URLs
awk '{print $7}' access.log | sort | uniq -c | sort -rn | head

# Visual terminal report
goaccess access.log --log-format=COMBINED

# JSON logs
cat app.log | jq 'select(.level=="ERROR")'
```

> [!NOTE]
> `topip` and `top404` assume a standard web access-log layout where the client IP is field 1, the request path is field 7, and the status code is field 9.

---

## 9. 💾 Disk & performance checks

| Problem | Command |
|---------|---------|
| Disk full? | `df -h` |
| Which folder is big? | `sudo ncdu /` |
| Big logs | `sudo du -ah /var/log 2>/dev/null | sort -rh | head -15` |
| Live CPU/memory | `htop` |
| Disk I/O | `iostat -x 2 5` |
| Memory | `free -h` |
| OOM kills | `sudo journalctl -k | grep -i oom` |
| Open ports | `ss -tulpen` |

---

## 10. 🗓️ Daily practice plan

| Day | Practice |
|-----|----------|
| Mon | Run `sudo journalctl -p err -b`; find one error and explain it |
| Tue | Run `sudo journalctl -u sshd`; read login attempts |
| Wed | Open a log with `lnav`; navigate with `e` / `w` |
| Thu | Build the `awk | sort | uniq -c` pipelines for IPs and 404s |
| Fri | Break something (stop a service), find it in logs |

---

## 🎯 Golden rules

1. 🕐 **Time first**: narrow to the incident window.
2. 🚨 **Errors first**: `-p err`, then widen.
3. 🔗 **Follow the chain**: first error is usually the cause, not the last.
4. 🧠 **Native first**: learn `journalctl`, `grep`, `awk`, `sort`, `uniq`, `du`, `less`, and `tail`. Shortcuts are optional.

<div align="center">

*Made for the Onboarding Free-Tier AWS series* ☁️

</div>
