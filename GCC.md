# args

| ansi         | 只支持 ANSI 标准的 C  语法。这一选项将禁止 GNU C 的某些特色， 例如 asm 或 typeof 关键词。 |
| ------------ | ------------------------------------------------------------ |
| -c           | 只编译并生成目标文件。                                       |
| -DMACRO      | 以字符串"1"定义  MACRO 宏。                                  |
| -DMACRO=DEFN | 以字符串"DEFN"定义  MACRO 宏。                               |
| -E           | 只运行 C 预编译器。                                          |
| -g           | 生成调试信息。GNU 调试器可利用该信息。                       |
| -IDIRECTORY  | 指定额外的头文件搜索路径DIRECTORY。                          |
| -LDIRECTORY  | 指定额外的函数库搜索路径DIRECTORY。                          |
| -lLIBRARY    | 连接时搜索指定的函数库LIBRARY。                              |
| -m486        | 针对 486 进行代码优化。                                      |
| -o FILE      | 生成指定的输出文件。用在生成可执行文件时。                   |
| -O0          | 不进行优化处理。                                             |
| -O 或 -O1    | 优化生成代码。                                               |
| -O2          | 进一步优化。                                                 |
| -O3          | 比 -O2 更进一步优化，包括 inline  函数。                     |
| -shared      | 生成共享目标文件。通常用在建立共享库时。                     |
| -static      | 禁止使用共享连接。                                           |
| -UMACRO      | 取消对 MACRO 宏的定义。                                      |
| -w           | 不生成任何警告信息。                                         |
| -Wall        | 生成所有警告信息。                                           |

**`-o`**

制定目标名称, 默认的时候, gcc 编译出来的文件是 a.out。

eg.
` gcc -o hello.asm -S hello.c`

---

**`-llibrary`**

制定编译的时候使用的库

eg.

`gcc -lcurses hello.c`

使用 ncurses 库编译程序

`-Ldir`

制定编译的时候，搜索库的路径。比如你自己的库，可以用它制定目录，不然编译器将只在标准库的目录找。这个dir就是目录的名称。

---

`-Idir`

在你是用 #include "file" 的时候, gcc/g++ 会先在当前目录查找你所制定的头文件, 如果没有找到, 他回到默认的头文件目录找, 如果使用 -I 制定了目录,他会先在你所制定的目录查找, 然后再按常规的顺序去找。

对于 #include<file>, gcc/g++ 会到 -I 制定的目录查找, 查找不到, 然后将到系统的默认的头文件目录查找 。

`-I`

---

**`-O0 、-O1 、-O2 、-O3`**

编译器的优化选项的 4 个级别，-O0 表示没有优化, -O1 为默认值，-O3 优化级别最高。

`-g`

只是编译器，在编译的时候，产生调试信息。

`-gstabs`

此选项以 stabs 格式声称调试信息, 但是不包括 gdb 调试信息。

`-gstabs+`

此选项以 stabs 格式声称调试信息, 并且包含仅供 gdb 使用的额外调试信息。

*`-ggdb`*

此选项将尽可能的生成 gdb 的可以使用的调试信息。

---

**`-E` **

只激活预处理,这个不生成文件, 你需要把它重定向到一个输出文件里面。

eg.

`gcc -E hello.c > pianoapan.txt `
` gcc -E hello.c | more `

---

**`-c`**

只激活预处理,编译,和汇编,也就是他只把程序做成obj文件

例子用法:

gcc -c hello.c 

他将生成 .o 的 obj 文件

---

**`-S`**

只激活预处理和编译，就是指把文件编译成为汇编代码。

eg.

gcc -S hello.c 

他将生成 .s 的汇编代码，你可以用文本编辑器察看。

***

**`-C`**

在预处理的时候, 不删除注释信息, 一般和-E使用, 有时候分析程序，用这个很方便的。

---

`-Ddebug`

相当于 C 语言中的 #define debug

`-Ddebug = 1`

相当于 C 语言中的 #define debug = 1

`-Udebug`

相当于 C 语言中的 #undef debug

`-undef`

取消对任何非标准宏的定义

---

**`-x language filename`**

设定文件所使用的语言, 使后缀名无效, 对以后的多个有效。也就是根据约定 C 语言的后缀名称是 .c 的，而 C++ 的后缀名是 .C 或者 .cpp, 如果你很个性，决定你的 C 代码文件的后缀名是 .pig 哈哈，那你就要用这个参数, 这个参数对他后面的文件名都起作用，除非到了下一个参数的使用。 可以使用的参数吗有下面的这些：'c', 'objective-c', 'c-header', 'c++', 'cpp-output', 'assembler', 与 'assembler-with-cpp'。

eg.

`gcc -x c hello.pig `

 `-x none <filename>`

关掉上一个选项，也就是让gcc根据文件名后缀，自动识别文件类型 。

eg.

`gcc -x c hello.pig -x none hello2.c`

---

**`-M`**

生成文件关联的信息。包含目标文件所依赖的所有源代码你可以用 gcc -M hello.c 来测试一下，很简单。

-MM

和上面的那个一样，但是它将忽略由 #include<file> 造成的依赖关系。

-MD

和-M相同，但是输出将导入到.d的文件里面

-MMD

和 -MM 相同，但是输出将导入到 .d 的文件里面。

---

**`-Wa,option`**

此选项传递 option 给汇编程序; 如果 option 中间有逗号, 就将 option 分成多个选项, 然 后传递给会汇编程序。

-Wl.option

此选项传递 option 给连接程序; 如果 option 中间有逗号, 就将 option 分成多个选项, 然 后传递给会连接程序。

---

**`-static`**

此选项将禁止使用动态库，所以，编译出来的东西，一般都很大，也不需要什么动态连接库，就可以运行。

-share

此选项将尽量使用动态库，所以生成文件比较小，但是需要系统由动态库。

-traditional

试图让编译器支持传统的C语言特性。

GCC 是 GNU 的 C 和 C++ 编译器。实际上，GCC 能够编译三种语言：C、C++ 和 Object C（C 语言的一种面向对象扩展）。利用 gcc 命令可同时编译并连接 C 和 C++ 源程序。

如果你有两个或少数几个 C 源文件，也可以方便地利用 GCC 编译、连接并生成可执行文件。例如，假设你有两个源文件 main.c 和 factorial.c 两个源文件，现在要编 译生成一个计算阶乘的程序。

# dump_stack()



```c
//包含头文件

#include <linux/kprobes.h>

#include <asm/traps.h>
```

# switch gcc version

` update-alternatives --config gcc `

[参考]([ubuntu系统查看gcc版本及版本切换_ubuntu查看gcc版本-CSDN博客](https://blog.csdn.net/qq_39779233/article/details/105124478))