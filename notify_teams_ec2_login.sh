#!/bin/bash

WEBHOOK_URL="ENTER_WORKFLOW_URL"

# Check event argument, proceed only if event=login ie. PAM_TYPE=open_session
if [ "$PAM_TYPE" != "open_session" ]; then
  exit 0
fi


USER="${PAM_USER:-unknown}"
IP_RAW="${PAM_RHOST:-unknown}"

# Resolve IP numeric if possible
IP=$(getent hosts "$IP_RAW" | awk '{ print $1 }')
if [ -z "$IP" ]; then
  IP="$IP_RAW"
fi

# JST time
TIME_UTC=$(date -u +"%Y-%m-%d %H:%M:%S")
TIME=$(date -d "$TIME_UTC 9 hour" +"%Y-%m-%d %H:%M:%S")

# Hostname
HOST="$(hostname -s)"


read -r -d '' PAYLOAD << EOF
{
  "attachments": [
    {
      "contentType": "application/vnd.microsoft.card.adaptive",
      "content": {
        "\$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
        "type": "AdaptiveCard",
        "version": "1.2",
        "body": [
          {
            "type": "TextBlock",
            "text": "**サーバー名前 ログインアラート**",
            "weight": "Bolder",
            "size": "Medium",
            "wrap": true
          },
          {
            "type": "TextBlock",
            "text": "**ユーザー:** $USER",
            "wrap": true
          },
          {
            "type": "TextBlock",
            "text": "**IP アドレス:** $IP",
            "wrap": true
          },
          {
            "type": "TextBlock",
            "text": "**ホスト:** $HOST",
            "wrap": true
          },
          {
            "type": "TextBlock",
            "text": "**時刻:** $TIME",
            "wrap": true
          }
        ]
      }
    }
  ]
}
EOF

curl -s -H "Content-Type: application/json" -d "$PAYLOAD" "$WEBHOOK_URL"



# sudo vi /usr/local/bin/notify_teams_ec2_login.sh
# sudo chmod +x /usr/local/bin/notify_teams_ec2_login.sh
# sudo vi /etc/pam.d/sshd
# session optional pam_exec.so /usr/local/bin/notify_teams_ec2_login.sh login | session required pam_exec.so /usr/local/bin/notify_teams_ec2_login.sh login
# sudo systemctl restart sshd