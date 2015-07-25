### 1wire

rc.local

mount 1wire

```/opt/owfs/bin/owfs --allow_other -u -m /mnt/1wire```

start pushing temp values to fettot
```su - nolstedt -c "cd /home/nolstedt/mixed/1wire_collect/bunny_forward; /usr/bin/screen -dmS temp /usr/bin/ruby bunny_forward.rb"```

http://wiki.m.nu/index.php/OWFS_p%C3%A5_Rasperry_Pi
