import progress,notify
import os,terminal,strformat,strutils,parseopt,times

const 
  modes = ['w','s','l','c']
  modeTime = [25,5,15] # workTime, short breaktime , long breaktime 
  modeText = ["time to work", "take a short break", "take a long break", "unnamed custom Interval"]
  modeDesc = ["work", "short break", "long break", "custom"]
  help = staticRead("help.txt")

proc showRemTime(time: int) =
  let min = (int) (time / 60)
  let sec = time mod 60
  stdout.write(&"  {min:02}:{sec:02} remaining")
  stdout.flushFile()


proc runPart(minutes: int) =
  let seconds = minutes * 60
  var remTime = seconds

  var bar = newProgressBar(width = terminalWidth()-30,total=seconds+1)
  bar.start()
  showRemTime(remTime)
  
  for i in 1..seconds:
    bar.increment()
    showRemTime(remTime)
    sleep(1000)
    remTime -= 1

  bar.finish()
  stdout.flushFile()


proc notify(text: string) =
  var n: Notification = newNotification("pomTimer", text, "dialog-information")
  n.timeout = 10000
  discard n.show()

type Interval = tuple[mode: 0..3,text: string,time: int]

proc showTime(intervals: seq[Interval],iterations: int) =
  var completeTime = 0
  var workTime = 0
  for interval in intervals:
    completeTime += interval.time
    if interval.mode == 0:
      workTime += interval.time
  completeTime *= iterations
  workTime *= iterations
  let min = completeTime mod 60
  let hour = (int)(completeTime/60)
  let hourText = if hour>0: &"{hour}h:" else: ""
  echo &"\ntotal time:   {hourText}{min}min"
  let wMin = workTime mod 60
  let wHour = (int)(workTime/60)
  let wHourText = if hour>0: &"{wHour}h:" else: ""
  echo &"working time: {wHourText}{wMin}min"
  let finishTime = now() + initTimeInterval(minutes = completeTime)
  echo "finished at:  " & finishTime.format("HH:MM")


proc showInfo(intervals: seq[Interval],iterations: int) =
  echo "\nyour plan:\n"
  for interval in intervals:
    let time = interval.time
    let text = if interval.text == "": "" else: &"text: {interval.text}"
    let mode = modeDesc[interval.mode]
    echo &"  mode: {mode:11}  time: {time:2}  {text}"
  echo "\n  iterations: ",iterations
  showTime(intervals,iterations)



template nextChar(): char =
  if plan.len >= i+2:
    plan[i+1]
  else:
    '_'
  

proc parsePlan(plan: string): seq[Interval] =
  var 
    parsingTime = false
    parsingText = false
    currentMode: 0..3
    timeStr = ""
    text = ""
  for i,c in plan:
    # parse custom time for a mode
    if parsingTime:
      if c in '0'..'9':
        timeStr &= c
      else:
        parsingTime = false
        if currentMode == 3:
          parsingText = true
        else:
          let time = timeStr.parseInt()
          result.add((currentMode,"",time))
          timeStr = ""
    # parse custom text for a custom interval
    if parsingText:
      if c == ':':
        parsingText = false
        let time = timeStr.parseInt()
        text = text.replace('_',' ')
        result.add((currentMode,text,time))
        text = ""
        continue
      else:
        text &= c
    # start to parse a new mode
    if not parsingTime and not parsingText:
      if c in modes:
        currentMode = modes.find(c)
        if nextChar() in '0'..'9':
          parsingTime = true
        else:
          if currentMode == 3:
            quit("Error: custom intervals need a specified time")
          result.add((currentMode,"",modeTime[currentMode]))
      else:
        quit("Error: invalid mode " & c)
  if parsingText:
    quit("Error: missing ':' to end custom task")
  
proc main() = 
  var plan = "" 
  var iterations = 1
  var showPlan = false
  var showTime = false
  if paramCount() >= 1:
    for opt in getopt():
      if opt.kind == cmdArgument:
        if fileExists(opt.key):
          # read tasks from the file
          var tmp = readFile(paramStr(1))
          for c in Whitespace:
            tmp = tmp.replace(&"{c}","")
          plan &= tmp
        else:
          # read tasks from the comandline
          plan &= opt.key
      else:
        # parse Options
        case opt.key:
          of "h","help":
            echo help
            quit(0)
          of "p","plan":
            showPlan = true
          of "t","time":
            showTime = true
          of "r","repeat":
            try:
              iterations = opt.val.parseInt()
            except ValueError:
              quit("Error: invalid value " & opt.val & " for option " & opt.key)
          else:
            quit("Error: invalid option " & opt.key)
  else:
    plan = "wswswswlwswswsw"

  if plan == "": quit(0)
  let intervals = parsePlan(plan)
  if showPlan:
    showInfo(intervals,iterations)  
  elif showTime:
    showTime(intervals,iterations)
  else:
    showInfo(intervals,iterations)
    for i in 1..iterations:
      if iterations > 1:
        echo &"iteration {i} of {iterations}"
      for interval in intervals:
        let time = interval.time
        let text = if interval.text == "": modeText[interval.mode] else: interval.text
        echo text
        notify(text)
        runPart(time)
      echo ""

main()
