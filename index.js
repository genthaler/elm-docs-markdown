#!/usr/bin/env node
const shell = require('shelljs')
const path = require('path')
const elm = require(path.resolve(__dirname, 'elm.js'))

const worker = elm.Elm.Supervisor.Main.init({
  flags: {
    argv: process.argv
  }
})

const send = worker.ports.rawResponse.send

worker.ports.request.subscribe(
  cmd => {
    switch (cmd.command) {
      case "Echo":
        shell.echo(cmd.message)
        break

      case "FileRead":
        send(shell.cat(path.resolve.apply(null, cmd.paths)))
        break

      case "FileWrite":
        send(shell.echo(cmd.fileContent).to(path.resolve.apply(null, cmd.paths)))
        break

      case "Exit":
        shell.echo(cmd.message)
        shell.exit(cmd.exitCode)
        break

      default:
        send({
          exitCode: 1,
          stderr: cmd.command + " sent on the wrong port"
        })
        break
    }
  })
