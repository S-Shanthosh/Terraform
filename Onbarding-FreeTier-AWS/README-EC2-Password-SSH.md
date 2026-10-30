# 🔑 EC2 Password SSH Login

![AWS EC2](https://img.shields.io/badge/AWS-EC2-FF9900?logo=amazonec2&logoColor=white)
![Auth](https://img.shields.io/badge/Auth-Password-blue)
![Use](https://img.shields.io/badge/Use-Practice%20Only-red)

Log in to EC2 from your local machine with a **username + password** instead of a key pair. 🖥️➡️☁️

---

## 🚨 DISCLAIMER

> **For practice only. This setup is vulnerable.**
> - Password SSH on a public IP gets brute-forced fast
> - `NOPASSWD` sudo = whoever gets in becomes **root**
> - User data is readable in plain text, so never use a real or reused password
>
> 🗑️ **Terminate the instance within a few hours.**

---

## 🚀 Setup

### 1️⃣ Lock down the Security Group 🛡️
**EC2 → Security Groups → Inbound rules**
- Type `SSH`, Port `22`, Source **`My IP`**
- Never use `0.0.0.0/0`

### 2️⃣ Run the script on the instance
Either way works:
- **At launch:** paste into **Advanced details → User data** (keep the `#!/bin/bash` line)
- **After launch:** connect via **EC2 Instance Connect** or SSH, then paste

```bash
#!/bin/bash
set +H
sudo bash <<'EOF'
useradd -m -s /bin/bash shanthosh 2>/dev/null
echo 'shanthosh:SET_YOUR_PASSWORD' | chpasswd
echo 'shanthosh ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/90-shanthosh
chmod 440 /etc/sudoers.d/90-shanthosh
mkdir -p /etc/ssh/sshd_config.d
echo 'PasswordAuthentication yes' > /etc/ssh/sshd_config.d/00-password.conf
sshd -t && (systemctl restart sshd || systemctl restart ssh)
EOF
```

Replace `SET_YOUR_PASSWORD` with a strong password (no `'` character).

**What it does:**

| Line | Purpose |
|---|---|
| `useradd` / `chpasswd` | Creates user `shanthosh` with a password |
| `sudoers.d` | Passwordless sudo |
| `00-password.conf` | Enables password login (overrides cloud-image default) |
| `sshd -t` | Checks config before restart, so you don't get locked out |
| `restart sshd \|\| ssh` | `sshd` on Amazon Linux, `ssh` on Ubuntu |

### 3️⃣ Connect 🔌
Get the **Public IPv4** from the EC2 console.

| Client | Command |
|---|---|
| 🟦 **PowerShell** | `ssh shanthosh@PUBLICIP` |
| 🐧 **WSL** | `ssh shanthosh@PUBLICIP` |
| 🖧 **PuTTY** | Host: `PUBLICIP`, Port `22` → Open → login `shanthosh` → enter password |
| 🟦 **VScode** | `New Terminal--> ssh shanthosh@PUBLICIP` |

---

## ⚠️ Notes

- 🔄 **Public IP changes on every stop/start** (the cost-saver Lambda stops instances hourly). Check the IP again each time.
- ❌ `Permission denied` → password typo, Security Group "My IP" outdated (your ISP IP changed), or script not applied
- ⏱️ If the connection times out, check the Security Group rule

---

## 🧹 Cleanup
**EC2 → Instances → Terminate** when done. 🗑️



**Older version**
**Just for info**
#!/bin/bash
set -e

USERNAME="shanthosh"
USERPASS="ChangeMe-Str0ng!Pass"   

# Create user (idempotent) and set password
id "$USERNAME" &>/dev/null || useradd -m -s /bin/bash "$USERNAME"
echo "${USERNAME}:${USERPASS}" | chpasswd

# Passwordless sudo, validated before it is installed
echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-${USERNAME}
chmod 440 /etc/sudoers.d/90-${USERNAME}
visudo -cf /etc/sudoers.d/90-${USERNAME}

# Enable SSH password authentication (also overrides cloud-image drop-ins)
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
for f in /etc/ssh/sshd_config.d/*.conf; do
  [ -f "$f" ] && sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' "$f"
done

# Restart SSH (service name differs by distro)
systemctl restart sshd 2>/dev/null || systemctl restart ssh
