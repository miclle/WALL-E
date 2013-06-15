##Ruby On Raspberry Pi

###Install RVM stable with ruby:

- http://rvm.io/rvm/install

- ```
$ \curl -L https://get.rvm.io | bash -s stable --ruby
```  
**注**：这个过程大概需要耗费**`2小时`**以上！编译ruby源代码，以及安装需要花相当长的时间，CPU一直会在90%以上，所以在安装过程中不要让你的Raspberry Pi做别的事情，不要打开`startx`界面。也许你可以在睡觉之前运行这个命令，rvm会帮你搞定一切！  
ruby安装好后，会执行`importing default gemsets`这一步也会很耗费时间，不过到这里时如果不想等可以`control + c`中止。  
```
source ~/.profile
```

- 查询已经安装的ruby   
```rvm list```

- 设置默认版本  
```rvm use 2.0.0 --default```

- 测试是否正确  

- ```
pi@raspberrypi ~ $ ruby -v
ruby 2.0.0p195 (2013-05-14 revision 40734) [armv6l-linux-eabihf]
pi@raspberrypi ~ $ gem -v
2.0.3
pi@raspberrypi:~ $ gem source -r https://rubygems.org/
https://rubygems.org/ removed from sources
pi@raspberrypi:~ $ gem source -a http://ruby.taobao.org
http://ruby.taobao.org added to sources
pi@raspberrypi:~ $ gem install bundler --no-rdoc --no-ri -V
```


- http://www.sinatrarb.com/  
- ```
pi@raspberrypi:~ $ gem install sinatra --no-rdoc --no-ri -V  
```  
