import progress,notify
import os,terminal,strformat,strutils

const 
  modes = ['w','s','l','c']
  modeTime = [25,5,15] # workTime, short breaktime , long breaktime 
  modeText = ["time to work", "take a short break", "take a long break", "unnamed custom Interval"]
  modeDesc = ["work", "short break", "long break", "custom"]

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

proc showInfo(intervals: seq[Interval]) =
  var completeTime = 0
  echo "your plan:"
  for interval in intervals:
    let time = interval.time
    let text = interval.text
    let mode = modeDesc[interval.mode]
    echo &"mode: {mode:11}  time: {time:2}  text: {text}"
    completeTime += time
  echo "\ncomplete time: ",completeTime," minutes\n"


template nextChar(): char =
  if plan.len >= i+2:
    plan[i+1]
  else:
    '_'
  

proc parseInput(plan: string): seq[Interval] =
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
        if currentMode != 3:
          let time = timeStr.parseInt()
          result.add((currentMode,"",time))
          timeStr = ""
        else:
          parsingText = true
    # parse custom text for a custom interval
    if parsingText:
      if c == ':':
        parsingText = false
        let time = timeStr.parseInt()
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
  

var plan = "" 
if paramCount() >= 1:
  if fileExists(paramStr(1)):
    plan = readFile(paramStr(1))
    for c in Whitespace:
      plan = plan.replace(&"{c}","")
  else:
    for i in 1..paramCount():
      plan &= paramStr(i)
else:
  plan = "wswswswlwswswswl"

let intervals = parseInput(plan)

showInfo(intervals)

for interval in intervals:
  let time = interval.time
  let text = if interval.text == "": modeText[interval.mode] else: interval.text
  echo text
  notify(text)
  runPart(time)


