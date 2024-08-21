# 打印

```c
#ifdef debug
	#define info(args...) fprintf(stdout, ##args) //can put txt
//  #define info(...) fprintf(stdout, __VA_ARGS__)
#else
	#define info
#endif

// or level
enum {LOG_DEBUG, LOG_INFO, LOG_WARN, LOG_ERROR};

#define log_debug(...) log_log(LOG_DEBUG, __FILE__, __LINE__, __VA_ARGS__)
#define log_info(...)  log_log(LOG_INFO,  __FILE__, __LINE__, __VA_ARGS__)
#define log_warn(...)  log_log(LOG_WARN,  __FILE__, __LINE__, __VA_ARGS__)
#define log_error(...) log_log(LOG_ERROR, __FILE__, __LINE__, __VA_ARGS__)

void log_log(int level, const char *file, int line, const char* fmt, ...)
{
#ifndef DEBUG
    return;
#else
    char buffer[256];
    va_list marker;

    va_start(marker, fmt);
    vsnprintf(buffer, 256, fmt, marker);
    va_end(marker);

    fprintf(stdout, "[%s-%d] %s", *file, line, buffer);
#endif
}

```

