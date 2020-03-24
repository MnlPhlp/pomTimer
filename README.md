# pomTimer
This is a cli pomodoro timer with custom intervals and times. It shows a progress bar and notifications.

## Usage
```
Usage: pomTimer [PLAN] [OPTIONS]

Plan:
    list some tasks to form your plan (eg. wswlwsw)
    whitespaces are ignored so you can seperate tasks as you want
    or
    specify a file to read tasks from
    
Tasks:
    w[TIME]           work                 default time: 25min
    s[TIME]           take a short break   default time:  5min
    l[TIME]           take a long break    default time: 15min
    cTIME[TEXT]:      custom task          default time:  none

Options:
    -p, --plan        show the parsed plan and exit (includes -t)
    -t, --time        show the time your plan will take and exit
    -h, --help        show this help
    -r:N, --repeat:N  repeat the plan N times
```
