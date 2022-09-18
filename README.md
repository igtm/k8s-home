# おうちk8s

おうちの k8s cluster application たち

[k3s](https://k3s.io/) で構築した

### Private docker registry

```shell
Endpoint: k8s-m1.igtm.link:5000

# /etc/hosts on master node
127.0.0.1 k8s-m1.igtm.link

# /etc/hosts on some client
<master node ip> k8s-m1.igtm.link

# deploy registry container
kubectl apply -f docker-registry.yaml
```

- 証明書ファイルは[Let's Encrypt製](https://numb86-tech.hatenablog.com/entry/2020/08/04/223754)
- [registry dockerを使用](https://qiita.com/yuyakato/items/c5b1b1293c5879e231ab)


### memo

- Let's encrypt 製の鍵じゃないとダメだった
- Traefik Ingress Controller/Klipper Load Balancer が k3s にデフォで入っている
  - https://rancher.com/docs/k3s/latest/en/networking/
  - https://dev.to/bbende/k3s-on-raspberry-pi-ingress-lf4?signin=true