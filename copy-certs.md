https://claude.ai/chat/4fe04d1c-22a6-44c8-95bd-ffcd23c7ab56

Ubuntu 18.04.6 LTS の環境で certbot を使って AWS Route53 での証明書自動更新を設定する手順をご説明します。

1. certbot と Route53 プラグインのインストール
   bash# snapd をインストール（Ubuntu 18.04 では標準でインストールされていない場合があります）
   sudo apt update
   sudo apt install snapd

# certbot をインストール

sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

# Route53 プラグインをインストール

sudo snap set certbot trust-plugin-with-root=ok
sudo snap install certbot-dns-route53

2. AWS 認証情報の設定
AWS Route53 にアクセスするための認証情報を設定します。
方法 A: AWS CLI を使用する場合
bash# AWS CLI をインストール
sudo apt install awscli

# 認証情報を設定

aws configure

# ファイルの権限を設定

sudo chmod 600 /root/.aws/credentials
sudo chmod 600 /root/.aws/config

3. 初回証明書取得
sudo certbot certonly \
 --dns-route53 \
 -d k8s-m1.igtm.link \
 --email your-email@example.com \
 --agree-tos \
 --non-interactive
 
4. 証明書更新後のスクリプト作成
証明書が更新された後に自動的に証明書をコピーするスクリプトを作成します。
bashsudo tee /etc/letsencrypt/renewal-hooks/deploy/copy-certs.sh << 'EOF'
#!/bin/bash

DOMAIN="k8s-m1.igtm.link"
CERT_PATH="/etc/letsencrypt/live/$DOMAIN"
SSH_CONFIG="/root/.ssh/config"
TARGET_HOST="igtm-nvidia"
TARGET_CERT_DIR="/etc/certs"

# 証明書をコピー

scp -F "$SSH_CONFIG" "$CERT_PATH/fullchain.pem" "$TARGET_HOST:$TARGET_CERT_DIR/$DOMAIN.fullchain.crt"
scp -F "$SSH_CONFIG" "$CERT_PATH/privkey.pem" "$TARGET_HOST:$TARGET_CERT_DIR/$DOMAIN.privkey.key"

# ログに記録

echo "$(date): Certificate copied to $TARGET_HOST" >> /var/log/certbot-deploy.log
EOF

sudo chmod +x /etc/letsencrypt/renewal-hooks/deploy/copy-certs.sh

# 権限を設定

sudo chmod 700 /root/.ssh
sudo chmod 600 /root/.ssh/\*

5. crontab の設定
```bash
# root の crontab を編集
sudo crontab -e
```

# 以下を追加（毎日午前 2 時に実行）

0 2 \* \* \* /usr/bin/certbot renew --quiet

6. 手動でのテスト
設定が正しく動作するかテストします。
bash# 証明書の更新をテスト（実際には更新しない）
sudo certbot renew --dry-run

# 実際の更新を強制実行してテスト

sudo certbot renew --force-renewal

7. ログの確認
bash# certbot のログを確認
sudo tail -f /var/log/letsencrypt/letsencrypt.log

# デプロイスクリプトのログを確認

sudo tail -f /var/log/certbot-deploy.log
注意点

AWS IAM 権限: 使用する AWS アクセスキーには以下の Route53 権限が必要です：

route53:ListHostedZones
route53:GetChange
route53:ChangeResourceRecordSets

SSH 鍵認証: パスワード認証ではなく鍵認証を使用することを推奨します。
証明書の有効期限: Let's Encrypt の証明書は 90 日間有効で、certbot は有効期限が 30 日以内の場合のみ更新を行います。
エラーハンドリング: 必要に応じて、デプロイスクリプトにエラーハンドリングやリトライ機能を追加してください。

この設定により、証明書の取得から更新、配布まで完全に自動化されます。
