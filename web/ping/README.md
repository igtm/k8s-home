# ping

ただ ping を返すだけの api サーバー(Go 製)
k8s まわりの実験場

# 現状の k8s 環境

- デプロイ周り: skaffold & helm

# Local 開発環境(dev deploy)

- localhost への port-forwarding(ingress 生成せずに直で繋ぐ想定)
- ファイル変更時自動再デプロイ

```shell
skaffold dev
```

# 本番デプロイ

```shell
skaffold run -p prd # ingress も生成される
```

# プロジェクト作成時にやったことメモ

- skaffold & helm を入れた

```shell
# プロジェクト作成時にやったこと
skaffold init -k helm # auto generating sfaffold.yaml
helm create helm # auto generating helm/
# helm/ と skaffold.yaml を適宜修正
```
