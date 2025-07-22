#!/bin/bash

# 証明書更新後のデプロイスクリプト（ローカル実行版）
# /etc/letsencrypt/renewal-hooks/deploy/copy-certs.sh

DOMAIN="k8s-m1.igtm.link"
CERT_PATH="/etc/letsencrypt/live/$DOMAIN"
TARGET_CERT_DIR="/etc/certs"
LOG_FILE="/var/log/certbot-deploy.log"

# ログ関数
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
    echo "$1"
}

# エラーハンドリング関数
handle_error() {
    log "ERROR: $1"
    exit 1
}

# 証明書ファイルの存在確認
if [ ! -f "$CERT_PATH/fullchain.pem" ] || [ ! -f "$CERT_PATH/privkey.pem" ]; then
    handle_error "Certificate files not found in $CERT_PATH"
fi

# ターゲットディレクトリの存在確認・作成
if [ ! -d "$TARGET_CERT_DIR" ]; then
    log "Creating target directory: $TARGET_CERT_DIR"
    mkdir -p "$TARGET_CERT_DIR" || handle_error "Failed to create target directory"
fi

# 証明書ファイルをコピー
log "Copying certificate files to $TARGET_CERT_DIR"

# フルチェーン証明書をコピー
cp "$CERT_PATH/fullchain.pem" "$TARGET_CERT_DIR/$DOMAIN.fullchain.crt" || handle_error "Failed to copy fullchain.pem"
log "Copied fullchain.pem to $TARGET_CERT_DIR/$DOMAIN.fullchain.crt"

# 秘密鍵をコピー
cp "$CERT_PATH/privkey.pem" "$TARGET_CERT_DIR/$DOMAIN.privkey.key" || handle_error "Failed to copy privkey.pem"
log "Copied privkey.pem to $TARGET_CERT_DIR/$DOMAIN.privkey.key"

# ファイル権限を設定
chmod 644 "$TARGET_CERT_DIR/$DOMAIN.fullchain.crt" || handle_error "Failed to set permissions on fullchain.crt"
chmod 600 "$TARGET_CERT_DIR/$DOMAIN.privkey.key" || handle_error "Failed to set permissions on privkey.key"

log "Certificate permissions set successfully"

# 証明書の有効期限を確認・ログ出力
CERT_EXPIRY=$(openssl x509 -in "$TARGET_CERT_DIR/$DOMAIN.fullchain.crt" -noout -enddate | cut -d= -f2)
log "Certificate expires: $CERT_EXPIRY"

# Kubernetes API Server やその他のサービスを再起動する場合
# 必要に応じて以下のコメントを外してください

# Kubernetes API Server を再起動する場合
# if systemctl is-active --quiet kube-apiserver; then
#     log "Restarting kube-apiserver"
#     systemctl restart kube-apiserver || log "WARNING: Failed to restart kube-apiserver"
# fi

# Kubernetes docker-registry を再起動する場合
if kubectl get pods -n default -l app=docker-registry --no-headers | grep -q "Running"; then
    log "Restarting docker-registry pod"
    kubectl delete pod -n default -l app=docker-registry || log "WARNING: Failed to restart docker-registry pod"
fi

log "Certificate deployment completed successfully"
