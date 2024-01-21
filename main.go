package main

import (
	stdliblog "log"
	"time"
	"go.uber.org/zap"
)

func main() {
	logger, err := zap.NewProduction()
	if err != nil {
		stdliblog.Fatal(err)
	}
	log := logger.Sugar()
	for {
		log.Info("Hello, world!")
		time.Sleep(time.Second * 1)
	}
}
