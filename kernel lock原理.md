# spin_lock

[参考](https://zhuanlan.zhihu.com/p/363993550)

```c
static inline void arch_spin_lock(arch_spinlock_t *lock)
{
    unsigned long tmp;
    u32 newval;
    arch_spinlock_t lockval;
prefetchw(&lock->slock);    // gcc 内置预取指令，指定读取到最近的缓存以加速执行
    __asm__ __volatile__(
"1: ldrex   %0， [%3]\n"         // lockval = &lock->slock
"   add %1， %0， %4\n"           // newval = lockval + 1 << 16，等于 lockval.tickets.next +1；
"   strex   %2， %1， [%3]\n"     // 将 lock->slock = newval
"   teq %2， #0\n"               // 测试上一步操作的执行结果
"   bne 1b"                     // 如果执行 lock->slock = newval 失败，则跳到标号 1 处从头执行
    : "=&r" (lockval)， "=&r" (newval)， "=&r" (tmp)
    : "r" (&lock->slock)， "I" (1 << TICKET_SHIFT)
    : "cc");
// 没进行 +1 操作前的 lockval.tickets.next 是否等于 lockval.tickets.owner
    // 不相等时，调用 wfe 指令进入 idle 状态，等待 CPU event，被唤醒后继续判断锁变量是否相等
    while (lockval.tickets.next != lockval.tickets.owner) { 
        wfe();
        lockval.tickets.owner = ACCESS_ONCE(lock->tickets.owner);
    }
    // 内存屏障 
    smp_mb();
}

```

从上述的注释中大概可以看出加锁的实现：

1、先将 spinlock 结构体中的 next 变量 + 1，不管是否能够获得锁

2、**判断 +1 操作之前的next 是否等于 owner **，只有在 next 与 owner 相等时，才能完成加锁，否则就循环等待，从这里也可以看到，自旋锁并不是完全地自旋，而是使用了 wfe 指令。

要完整地理解加锁过程，就必须要提到解锁，因为这两者是相对的，解锁的实现很简单：就是将 spinlock 结构体中的 owner 进行 +1 操作，因此，当一个 spinlock 初始化时，next 和 onwer 都为 0。某个执行流 A 获得锁，next + 1，此时在其它执行流 B 眼中，next ！= owner，所以 B 等待。当 A 调用 spin_unlock 时，owner + 1。

此时 next == owner，所以 B 可以欢快地继续往下执行，这就是加解锁的逻辑。需要注意的是，B 在请求锁时会先将 next + 1，此时的 next 为 new_next，而用于判断是否等于 owner 的那个 next 是 old next，这里需要注意。



在上述的 spinlock 的实现中体现了排队的思想：假设三个进程 A、B、C，A 先获得锁，B 请求锁，接着 C 请求锁，在 B 看来，spinlock 的 next-owner = 1，而在 C 看来，next- owner = 2（B 执行了 next+1 操作），当 A 释放时， owner + 1，此时在 B 看来，next==owner，B 可以继续往下执行，而 C 需要继续等待。这样就实现了先到先得的排队机制。不管能不能获得锁，先将 next + 1，这个操作相当于获取一个号码牌用于后续的排队。

对于第二个问题，为什么要使用汇编代码来实现，一方面，汇编代码执行效率更快，另一方面， next+1 这个操作需要独占访问，为什么呢？同样举一个例子：CPU0 的进程 A 和 CPU1 的进程 B 同时请求锁，此时 A 获取到 next 的值为 0，B 获取到的 next 值也是 0，A 和 B 分别对 next 进行 +1 操作，两个自增操作最终产生的 next 值都为 1，然后再写回到内存，可以想到，此时 next 最终的值为 1，而不是我们预期中的 2.

*正常的操作流程应该是， CPU0 上的 A 取 next，对 next 自增，然后将 next 写回。即使同时 CPU1 上的 B 也要访问 next，也要CPU0 上的 A 操作完之后才能继续操作。可惜的是，这种多核中的独占访问并没有 C 语言的实现，而是需要硬件架构的支持，由 CPU 提供特殊的独占指令或者原子操作指令，在 arm 中，strex 和 ldrex 就是实现了独占访问，当处理器 A 使用了 ldrex 指令独占访问了 next 时，处理器 B 使用 ldrex 回写 next 时就会失败，然后重新读取 next 的值再更新，这也解释了上面的汇编代码的实现。对于 CPU 间的独占指令，每个架构的实现不一样，这也是为什么在 SMP 架构中，spinlock 的源码实现在 arch 目录下，因为它是硬件相关的。*