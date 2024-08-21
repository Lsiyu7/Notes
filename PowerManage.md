# PM

```c
struct dev_pm_info {
        ....
	struct timer_list	suspend_timer;    		// 休眠时候用到的定时器
	unsigned long		timer_expires; 			// 定时器的超时函数
	struct work_struct	work;					// 用于workqueue中的工作项
	wait_queue_head_t	wait_queue;				// 等待队列，用于异步pm操作时候使用
	atomic_t			usage_count;			// 设备的引用计数，通过该字段判断是否有设备使用
	atomic_t			child_count;			// 此设备的"active"子设备的个数
	unsigned int		disable_depth:3;		// 用于禁止Runtime helper function。等于0代表使能，1代表禁止
	unsigned int		idle_notification:1;	// 如果该值被设，则调用runtime_idle回调函数
	unsigned int		request_pending:1;		// 如果设备，代表工作队列有work请求
	unsigned int		deferred_resume:1;		//当设备正在执行-> runtime_suspend()的时候，如果->runtime_resume()将要运行，而等待挂起操作完成并不实际，就会设置该值；这里的意思是“一旦你挂起完成，我就开始恢复"
	unsigned int		run_wake:1;				//如果设备能产生runtime wake-up events事件，就设置该值
	unsigned int		runtime_auto:1;			//如果设置，则表示用户空间已允许设备驱动程序通过/sys/devices/.../power/control接口在运行时对该设备进行电源管理
	unsigned int		no_callbacks:1;			//表明该设备不是有Runtime PM callbacks
	unsigned int		irq_safe:1;				//表示->runtime_suspend()和->runtime_resume()回调函数将在持有自旋锁并禁止中断的情况下被调用
	unsigned int		use_autosuspend:1;		//表示该设备驱动支持延迟自动休眠功能
	unsigned int		timer_autosuspends:1;	//表明PM核心应该在定时器到期时尝试进行自动休眠（autosuspend），而不是一个常规的挂起（normal suspend)
	unsigned int		memalloc_noio:1;
	enum rpm_request	request;				// runtime pm请求类型
	enum rpm_status		runtime_status;			// runtime pm设备状态
	int			runtime_error;					// 如果该值设备，表明有错误
	int			autosuspend_delay;				// 延迟时间，用于自动休眠
	unsigned long		last_busy;				
	unsigned long		active_jiffies;
	unsigned long		suspended_jiffies;
	unsigned long		accounting_timestamp;
 
};
```

1. 回调是互斥的(例如:  对于同一个设备，禁止并行执行runtime_suspend和runtime_resume或者同一个设备runtime_suspend回调)。不过例外情况是:runtime_suspend()或runtime_resume()可以和runtime_idle()并行执行。
2. runtime_idle()和runtime_suspend回调只能对"active"设备执行。
3. runtime_idle和runtime_suspend回调只能对其引用计数(usage count)等于零，且器active children个数是零或者“power.ignore_children”标志被设置的设备执行。
4. runtime_resume只能对挂起（suspend）的设备执行。
5. 如果runtime suspend()即将被执行，或者有一个挂起的请求执行，runtime idle()将不会在同一个设备上执行。
6. 如果runtime_suspend回调已经执行或者已经在pending状态，则取消该设备的runtime idle请求。
7. 如果runtime_resume回调已经执行，其他callbacks则将不被执行对于同一个设备。
8. 如果该设备下的任何一个子设备都处于idle，parent设备才可以idle。
9. 如果parent设备下任何一个设备处于active状态，parent设备必须active。
10. parent设备下任何一个设备处于idle,需要上报给parent用于记录。
