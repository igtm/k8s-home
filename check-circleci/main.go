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
	slackWebhookUrl  = os.Getenv("SLACK_WEBHOOK")
	slackChannelName = os.Getenv("SLACK_CHANNEL_NAME")
	targetUrls       = os.Getenv("TARGET_URLS")
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
		t, err := time.Parse(time.RFC3339, body)
		if err != nil {
			panic(err)
		}

		if t.Before(time.Now().Add(-1 * time.Hour)) {
			// 通知
			_ = slack.PostWebhook(slackWebhookUrl, &slack.WebhookMessage{
				Username: "hoge",
				Channel:  slackChannelName,
				Attachments: []slack.Attachment{
					{
						Color: "good",
						Text:  fmt.Sprintf("test: version=%s", body),
						Fields: []slack.AttachmentField{
							{
								Title: "date",
								Value: time.Now().Format(time.RFC3339),
								Short: true,
							},
						},
					},
				},
			})
		}

	}
}
