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
| 7 | [⚡ Toolkit shortcuts](#7--log-toolkit-shortcuts-section-11) | Aliases from Linux-Color |
| 8 | [📊 Access-log analysis](#8--access-log-analysis) | Top IPs, 404s |
| 9 | [💾 Disk & performance](#9--disk--performance-checks) | Full disk, high CPU |
| 10 | [🗓️ Practice plan](#10-️-daily-practice-plan) | Build the skill |

> [!NOTE]
> Linux-Color never renames standard commands. The shortcuts in section 7 are **new** names, so `journalctl`, `grep`, `ls` still work normally.

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

## 7. ⚡ Log toolkit shortcuts (Section 11)

Installed by the Linux-Color log toolkit. Run `source ~/.bashrc` after install.

| Shortcut | What it does |
|----------|--------------|
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
| Big logs | `biglogs` |
| Live CPU/memory | `htop` |
| Disk I/O | `iostat -x 2 5` |
| Memory | `free -h` |
| OOM kills | `sudo journalctl -k | grep -i oom` |
| Open ports | `ports` |

---

## 10. 🗓️ Daily practice plan

| Day | Practice |
|-----|----------|
| Mon | `jerr`, find one error, explain it |
| Tue | `jsvc sshd`, read login attempts |
| Wed | `lg`, navigate with `e` / `w` |
| Thu | `topip` and `top404` on a web log |
| Fri | Break something (stop a service), find it in logs |

---

## 🎯 Golden rules

1. 🕐 **Time first**: narrow to the incident window.
2. 🚨 **Errors first**: `-p err`, then widen.
3. 🔗 **Follow the chain**: first error is usually the cause, not the last.
4. 🧠 **Learn the basics**: `journalctl`, `grep`, `less`, `tail`. Tools like `lnav` enhance them, they don't replace them.

<div align="center">

*Made for the Onboarding Free-Tier AWS series* ☁️

</div>
