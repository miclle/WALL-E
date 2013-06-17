##Text to Speech 文本转语音

###Festival Text to Speech

```
sudo apt-get install festival
```

Test:

```
echo "Just what do you think you're doing, Dave?" | festival --tts
```

```
festival --tts file
```

or to speak RPi’s IP address:

```
hostname -I | festival -tts
```
 
###Espeak Text to Speech

```
sudo apt-get install espeak
```
Test:

```
espeak "Hello World" # Replace Hello World with your text, must be enclosed by ""
espeak -f <file> # Read out file <file>
espeak "Hello, I am Espeak, the voice synthesizer" 2>/dev/null
```
```
espeak -vzh “hello world“
espeak -vzh  "你好"
```
其中-vzh是汉语支持

朗读文件：
```
espeak -vzh+m2 -s 100 -f 文件名
```
其中+m2是使用第二种男声发音，类似的+f2是使用第二种女声发音，-s是语速


festival发生中规中距，espeak速度快且支持中文发声只是效果有点怪。

 
###Google Text to Speech

Google’s Text to Speech engine is a little different to Festival and Espeak. Your text is sent to Google’s servers to generate the speech file which is then returned to your Pi and played using mplayer. This means you will need an internet connection for it to work, but the speech quality is superb.  
I used used ax206geek’s bash script to access the Google Text to Speech engine:  
Create a file speech.sh with:

```
nano speech.sh
```
Add these lines to the file and save it (in nano editor use CTRL-O writeOut)

```
#!/bin/bash
say() { local IFS=+;/usr/bin/mplayer -ao alsa -really-quiet -noconsolecontrols "http://translate.google.com/translate_tts?tl=en&q=$*"; }
say $*
```

Alternatively save from here: File:Speech.sh
Add execute permissions to your script with:

```
chmod u+x speech.sh
```

Test it using:

```
./speech.sh Look Dave, I can see you're really upset about this.
```

EXTRA: Dan Fountain improved on the above script to speak any length of text (Google limits you to 100 bytes normally). His excellent easy-to-read webpage describes this at http://danfountain.com/2013/03/raspberry-pi-text-to-speech/
Recommendations



http://elinux.org/RPi_Text_to_Speech_(Speech_Synthesis)