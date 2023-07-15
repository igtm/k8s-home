# おうちk8s

おうちの k8s cluster application たち

[k3s](https://k3s.io/) で構築した

# Installed Apps

- [Registry v2.7](https://hub.docker.com/_/registry)
- [Algo Workflow v3.4.8](https://github.com/argoproj/argo-workflows/releases/tag/v3.4.8)


### Private docker registry

```shell
Endpoint: k8s-m1.igtm.link:5000

# /etc/hosts on master node
127.0.0.1 k8s-m1.igtm.link

# /etc/hosts on your client
<master node ip> k8s-m1.igtm.link

# run this command on master node and paste output to kubeconfig on your client
# (modify server ip to k8s-m1.igtm.link)
kubectl config view  --raw

# deploy registry container
kubectl apply -f docker-registry.yaml
```

- 証明書ファイルは[Let's Encrypt製](https://numb86-tech.hatenablog.com/entry/2020/08/04/223754)
- [registry dockerを使用](https://qiita.com/yuyakato/items/c5b1b1293c5879e231ab)

### 証明書の更新(3ヶ月おき)

```shell
sudo certbot certonly --manual -d k8s-m1.igtm.link --preferred-challenges dns-01
# TXTレコードを更新して検証させる

# master node の証明書を置き換える
scp -F ~/.ssh/config /etc/letsencrypt/live/k8s-m1.igtm.link/fullchain.pem igtm-nvidia:/etc/certs/k8s-m1.igtm.link.fullchain.crt
scp -F ~/.ssh/config /etc/letsencrypt/live/k8s-m1.igtm.link/privkey.pem igtm-nvidia:/etc/certs/k8s-m1.igtm.link.privkey.key

# docker-registry でりぽ
```

自動化したい...
https://blog.potproject.net/2019/11/21/k8s-k3s-lets-encrypt-ingress

### memo

- Let's encrypt 製の鍵じゃないとダメだった
- Traefik Ingress Controller/Klipper Load Balancer が k3s にデフォで入っている
  - https://rancher.com/docs/k3s/latest/en/networking/
  - https://dev.to/bbende/k3s-on-raspberry-pi-ingress-lf4?signin=true
