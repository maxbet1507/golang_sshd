# docker image for golang(:stretch) with sshd

docker hubのgolangイメージに、
PubkeyAuthenticationのsshd を加えたものです。

## 使用方法

ベースイメージを`golang:stretch_sshd`として作成し、
追加パッケージ等は別Dockerfileから`FROM`でイメージ継承します。

```Shell
docker build -t golang:stretch_sshd .
```

デフォルトでdocker buildすると以下のユーザが作成されます。

```Shell
user@207dc84e075f:~$ id
uid=1000(user) gid=1000(user) groups=1000(user),27(sudo)

user@207dc84e075f:~$ pwd
/home/user
```

dockerホスト側のレポジトリ等をコンテナにマウントする際に、
上記のuid/gidだと問題がある場合は、docker build時の--build-argで変更します。

docker run時に個別にマウントオプションを書くこともできますが、
docker-compose.ymlにまとめておいた方が楽だと思います。

```yaml
version: "3.7"
services:
  example:
    build: .
    cap_add:
      - SYS_PTRACE
    security_opt:
      - seccomp:unconfined    
    volumes:
    - "~/.ssh/id_rsa.pub:/home/user/.ssh/authorized_keys:ro"
    - "~/.gitconfig:/home/user/.gitconfig:ro"
    - "..:/go/src/github.com/maxbet1507/golang_sshd:rw"
    ports:
    - "10022:22"
```

`/home/user/.ssh/authorized_keys`は空ファイルとして作成してあるので、
docker run時にvolumeマウントするとsshが可能となります。

> Dockerfile内で空ディレクトリやファイルを作成していますが、
> イメージでパスを作成済みにしておくと、そのOwner/Modeでマウントされるようです。
