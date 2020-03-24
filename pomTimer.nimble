# Package

version       = "0.1.0"
author        = "MnlPhlp"
description   = "A simple pomodoro timer for the comandline with cli-output and notifications."
license       = "MIT"
srcDir        = "src"
binDir        = "bin"
bin           = @["pomTimer"]



# Dependencies

requires "nim >= 1.0.6","progress","notify"
