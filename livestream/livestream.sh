#!/bin/sh

ffmpeg -nostdin -hide_banner -nostats -loglevel quiet  \
  -f v4l2 -format mjpeg -framerate 30 -video_size 1280x720  \
  -i /dev/video0 -codec:v h264_omx -b:v 2M -bufsize 1M -filter:v fps=fps=30  \
  -f flv rtmp://127.0.0.1/birdcam/live

