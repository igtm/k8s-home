package main

import (
	"fmt"
	"github.com/slack-go/slack"
	"io"
	"log"
	"net/http"
	"os"
	"strings"
	"time"
)

var (
	slackWebhookUrl = os.Getenv("SLACK_WEBHOOK")

	slackChannelName = os.Getenv("SLACK_CHANNEL_NAME")
	targetUrls       = os.Getenv("TARGET_URLS")
	jst              = time.FixedZone("Asia/Tokyo", 9*60*60)
)

func main() {
	targetUrlSlice := strings.Split(targetUrls, ",")

	for _, u := range targetUrlSlice {
		resp, err := http.Get(u)
		if err != nil {
			panic(err)
		}
		defer resp.Body.Close()
		var body string
		if resp.StatusCode == http.StatusOK {
			bodyBytes, err := io.ReadAll(resp.Body)
			if err != nil {
				log.Fatal(err)
			}
			body = strings.TrimSpace(string(bodyBytes))
		}

		// date -Iseconds
		t, err := time.Parse("2006-01-02T15:04:05-0700", body)
		if err != nil {
			panic(err)
		}

		if t.Before(time.Now().Add(-2 * time.Hour)) {
			// 通知
			_ = slack.PostWebhook(slackWebhookUrl, &slack.WebhookMessage{
				Username: "circleci死活監視くん",
				Channel:  slackChannelName,
				Attachments: []slack.Attachment{
					{
						Color: "good",
						Text:  fmt.Sprintf("<!channel> コンテンツが '%s' より更新されていません", t.In(jst).Format(time.RFC3339)),
						Fields: []slack.AttachmentField{
							{
								Title: "date",
								Value: time.Now().In(jst).Format(time.RFC3339),
								Short: true,
							},
						},
					},
				},
			})
		}

	}
}
