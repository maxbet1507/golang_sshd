# docker image for golang(:stretch) with sshd

docker hubのgolangイメージに、
PubkeyAuthenticationのsshd を加えたものです。

デフォルトでdocker buildすると以下のユーザが作成されます。

```Shell
user@207dc84e075f:~$ id
uid=1000(user) gid=1000(user) groups=1000(user),27(sudo)

user@207dc84e075f:~$ pwd
/home/user
```

`/home/user/.ssh/authorized_keys`は空ファイルとして作成してあるので、
docker run時にvolumeマウントするとsshが可能となります。
