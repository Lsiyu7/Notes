## git remote

增加远程仓库

````bash
git remote add origin git://path
````

版本回退:

`git add` 的反向命令`git checkout --[PATH] <filename> `，撤销工作区修改，即把暂存区最新版本转移到工作区

`git commit`的反向命令`git reset HEAD <filename>`，就是把仓库最新版本转移到暂存区

文件更改必须加入缓存区

`git reset --hard HEAD^`//回退上一个版本 --hard 参数指硬回退 直接将仓库回退到工作区

![image-20240205145315146](.\image\image-20240205145315146.png)

## 存储更改

`git stash` 临时保存更改

`git stash apply `  `git stash pop` 都用于恢复更改，前者apply 不会删除stash中缓存 pop则会将push中缓存删除。

## 恢复Git提交

假设你正在处理一个Git项目，你发现一个特定的提交引入了一些不希望的更改。您需要在不从历史记录中删除提交的情况下撤销这些更改。您可以使用以下命令来撤消该特定提交：

```bash
git revert commitHash
```

这是一种安全且非破坏性的方式来纠正项目中的错误或不必要的更改。

例如你有一系列的提交：

- Commit A
- Commit B （此处引入了不需要的更改）
- Commit C
- Commit D

要反转Commit B的效果，可以运行：

```bash
git revert commitHashOfB
```

Git将创建一个新的提交，我们称之为`Commit E`，它否定了`Commit B`引入的更改。提交E成为分支中的最新提交，项目现在反映了如果提交B从未发生过的状态。

## 重置Git提交

让我们假设您已经提交了一个项目。然而在检查后，您意识到需要调整或完全撤销最后一次提交。对于这种情况，Git提供了以下强大的命令：

### Soft reset

```pgsql
git reset --soft HEAD^
```

这个命令允许你回溯你的最后一次提交，同时保留你在暂存区中的所有更改。简单地说，您可以使用此命令轻松地取消提交，同时保留代码更改。当您需要修改上一次提交时，这个命令非常方便。

### Mixed reset

```pgsql
git reset --mixed HEAD^
```

这是使用`git reset HEAD^`而不指定`--soft`或`--hard`时的默认行为。它取消提交最后一次提交，并从暂存区中删除其更改。但是它会将这些更改保留在工作目录中。当你想取消提交最后一次提交并从头开始进行更改，同时在重新提交之前将更改保留在工作目录中时，这很有帮助。

### Hard reset

```pgsql
git reset --hard HEAD^
```

`git reset --hard HEAD^`会从Git历史记录中完全删除最后一次提交沿着的所有相关更改。当你使用`git reset --hard HEAD^`时，就没有回头路了。所以当你想永久放弃最后一次提交和它的所有修改时，要非常小心地使用它。

### refs

```bash
git push origin HEAD:refs/for/master
```

git push 肯定是推送
origin : 是远程的库的名字
HEAD: 是一个特别的指针，它是一个指向你正在工作的本地分支的指针，
可以把它当做本地分支的别名，git这样就可以知道你工作在哪个分支
refs/for :意义在于我们提交代码到服务器之后是需要经过 code review 之后才能进行merge的
refs/heads： 不需要
