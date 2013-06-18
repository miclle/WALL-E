#!/bin/bash
# http://translate.google.com/translate_tts?tl=zh-CN&q=sdaf
# https://translate.google.cn/translate_tts?ie=UTF-8&q=您好&tl=zh-CN&total=1&idx=0&textlen=6
say() { local IFS=+;/usr/bin/mplayer -ao alsa -really-quiet -noconsolecontrols "http://translate.google.com/translate_tts?tl=en&q=$*"; }
say $*