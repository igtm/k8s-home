# check-circleci

RFC3999の時刻が書かれた VERSION ファイルを見て 1時間以上離れていたらslack通知するcronjob

```shell
# config
cp cron.yaml.example cron.yaml

# build go, docker image and push it
make build
make push

# create cron
make cron
```
