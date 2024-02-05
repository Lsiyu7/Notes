## git remote

增加远程仓库

`git remote add origin git://path`

版本回退:

`git add` 的反向命令`git checkout --[PATH] <filename> `，撤销工作区修改，即把暂存区最新版本转移到工作区

`git commit`的反向命令`git reset HEAD <filename>`，就是把仓库最新版本转移到暂存区

文件更改必须加入缓存区

`git reset --hard HEAD^`//回退上一个版本 --hard 参数指硬回退 直接将仓库回退到工作区

![image-20240205145315146](.\image\image-20240205145315146.png)

