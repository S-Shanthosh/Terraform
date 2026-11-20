# 💸 AWS Cost Saver

![AWS Lambda](https://img.shields.io/badge/AWS-Lambda-FF9900?logo=awslambda&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.12-3776AB?logo=python&logoColor=white)
![Region](https://img.shields.io/badge/Region-ap--southeast--2-2ea44f)
![Cost](https://img.shields.io/badge/Cost-$0%20(Free%20Tier)-brightgreen)

Hourly Lambda that **stops running EC2 + RDS** and **emails you** if any **Elastic IP** or **NAT Gateway** is live. 🛑📧

---

## ⚙️ What it does

| Resource | Action |
|---|---|
| 🖥️ EC2 (running) | **Stopped** |
| 🗄️ RDS instances / clusters | **Stopped** |
| 🌐 Elastic IPs | **Email alert** |
| 🚪 NAT Gateways | **Email alert** |

> Email is sent **only if something live is found**.

> 📝 **Note:** The script is generic and scans **all regions** by default.
> If your org SCP blocks some regions (e.g. only `ap-southeast-2` allowed), those regions return `AccessDenied` errors and get emailed hourly.
> Fix: replace the `regions = [...]` line in `lambda_function.py` with `regions = ["ap-southeast-2"]` (or your allowed regions).
> Also add `ec2:DescribeRegions` to the IAM policy for the all-regions mode.

---

## 🚀 Setup

### 1️⃣ SNS topic (alerts)
1. **SNS → Topics → Create topic** → Standard → `aws-cost-alerts`
2. **Create subscription** → Protocol `Email` → your email
3. Click **Confirm subscription** in the inbox
4. Copy the **Topic ARN**

### 2️⃣ IAM role
Use an existing role with `AWSLambdaBasicExecutionRole` plus this policy
(or `PowerUserAccess` for a quick start):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeRegions", "ec2:DescribeInstances", "ec2:StopInstances",
        "ec2:DescribeAddresses", "ec2:DescribeNatGateways",
        "rds:DescribeDBInstances", "rds:StopDBInstance",
        "rds:DescribeDBClusters", "rds:StopDBCluster"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "sns:Publish",
      "Resource": "<SNS_TOPIC_ARN>"
    }
  ]
}
```

### 3️⃣ Lambda
1. **Lambda → Create function** → name `cost-saver` → Python **3.12**
2. Execution role → **existing role** from step 2
3. Paste `lambda_function.py` → **Deploy**
4. **Configuration → General** → Timeout **3 min** (runs in seconds), Memory **128 MB**
5. **Configuration → Environment variables**:

| Key | Value |
|---|---|
| `SNS_TOPIC_ARN` | `arn:aws:sns:ap-southeast-2:<ACCOUNT_ID>:aws-cost-alerts` |

### 4️⃣ Test ⚠️
**Test tab → event `{}` → Test.**
This is **live**: it really stops running EC2/RDS.
Expected: `Succeeded`, `"alerts": []` if nothing billable is live.

### 5️⃣ Schedule ⏰
**EventBridge → Scheduler → Create schedule**
- Name: `cost-saver-hourly`
- Pattern: **Cron** → `cron(0 * * * ? *)` (every hour)
- Flexible time window: **Off**
- Target: **Lambda → Invoke → `cost-saver`**
- Create a new role for the schedule

---

## 💰 Cost: $0

| Service | Usage | Free tier |
|---|---|---|
| Lambda | ~730 runs/month | 1M requests/month |
| EventBridge Scheduler | 730 invocations | 14M/month |
| SNS email | Alerts only | 1,000/month |
| CloudWatch Logs | Tiny | 5 GB/month |

---

## ⚠️ Limits

- 💾 **EBS volumes** of stopped instances still bill
- 🌐 **Elastic IPs** keep billing until released (alert repeats hourly)
- 🚪 **NAT Gateways** can only be deleted, not stopped (alert only)
- 🗄️ Stopped **RDS auto-starts after 7 days** (hourly run stops it again)
- 🔁 Read replicas can't be stopped
- ⚖️ Load balancers are **not** handled

---

## 🔍 Verify
**Lambda → Monitor → View CloudWatch logs** → check the latest run has no errors.
