# Linux Log Analysis

This guide uses native Linux commands. Linux-Color does not create aliases that rename or hide standard Linux commands.

## 1. View system logs

Show logs from the current boot:

```bash
sudo journalctl -b
```

Show the most recent 100 entries:

```bash
sudo journalctl -n 100 --no-pager
```

Follow new entries as they arrive:

```bash
sudo journalctl -f
```

## 2. Filter by severity

Show warnings and more severe messages:

```bash
sudo journalctl -p warning -b
```

Show errors and more severe messages:

```bash
sudo journalctl -p err -b
```

## 3. Inspect a service

For SSH service logs:

```bash
sudo journalctl -u sshd -b
```

Follow SSH service logs live:

```bash
sudo journalctl -u sshd -f
```

## 4. Analyse journal output with lnav

Use the native `journalctl` command and pipe its output into `lnav`:

```bash
sudo journalctl -b --no-pager | lnav -
```

For SSH:

```bash
sudo journalctl -u sshd -b --no-pager | lnav -
```

Inside lnav, use `q` to quit and `/` to search. Use `e` and `w` to navigate error and warning entries where supported by the current lnav view.

## 5. Inspect traditional log files

Amazon Linux 2023 primarily uses systemd-journald. Traditional files may or may not exist on a given installation. Check before opening one:

```bash
ls -l /var/log
```

If the file exists, open it with lnav. For example:

```bash
sudo lnav /var/log/messages
```

Do not assume `/var/log/secure` exists; use the SSH journal commands above when it does not.

## 6. Search logs with grep

Search journal output for common problem terms:

```bash
sudo journalctl -b --no-pager | grep -iE 'error|failed|denied|warning'
```

## Command-line learning principle

Learn the standard Linux commands first: `journalctl`, `grep`, `less`, `tail`, and `ls`. Tools such as `lnav` enhance inspection and analysis; they do not replace the underlying Linux commands.
