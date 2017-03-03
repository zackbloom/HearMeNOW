_              = require 'underscore'
fs             = require 'fs'
gulp           = require 'gulp'
replace        = require 'gulp-replace'
es             = require 'event-stream'

home = require('os').homedir()

handleError = (err) ->
  gutil.log err
  gutil.beep()

  @emit 'end'

  process.exit(1)

parseCommands = (data) ->
  data.split("\n")
    .filter (entry) -> entry
    .map (entry) ->
      [command, char] = entry.split(' ')
      {command, char}

asAction = (char) ->
  if _.isNaN +char
    return "keystroke \"#{ char }\""
  else
    return "key code #{ char }"

gulp.task 'commands', ->
  commands = parseCommands fs.readFileSync('./commands').toString()

  for command in commands
    do (command) ->
      gulp.src(['./template/**/*.wflow', './template/**/*.plist'])
        .pipe replace(/ACTION/g, asAction command.char)
        .pipe replace(/COMMAND/g, command.command)
        .pipe replace(/HOME/g, home)
        .pipe gulp.dest(home + "/Library/Speech/Speakable Items/#{ command.command }.app/")

      gulp.src(['./template/Contents/MacOS/Application Stub'])
        .pipe gulp.dest(home + "/Library/Speech/Speakable Items/#{ command.command }.app/Contents/MacOS/")

      gulp.src(['./template/Contents/Resources/**/*'])
        .pipe gulp.dest(home + "/Library/Speech/Speakable Items/#{ command.command }.app/Contents/Resources/")

gulp.task 'watch', ->
  gulp.watch [
    './template'
    './commands'
  ], ['commands']

gulp.task 'build', ['commands']
gulp.task 'default', ['watch']
