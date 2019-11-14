#!/usr/bin/env node
const shell = require('shelljs');
const path = require('path');
const elm = require(path.resolve(__dirname, 'elm.js'));

const worker = elm.Elm.Main.init({
  flags: {
    argv: process.argv,
    versionMessage: "1.0"
  }
});

const send = worker.ports.rawResponse.send;

worker.ports.request.subscribe(
  cmd => {
    console.log(cmd);

    switch (cmd.command) {
      case "Echo":
        shell.echo(cmd.message);
        break;

      case "FileRead":
        send(shell.cat(path.resolve.apply(null, [cmd.path])));
        break;

      case "FileWrite":
        send(shell.echo(cmd.content).to(path.resolve.apply(null, [cmd.path])));
        break;

      case "Exit":
        shell.echo(cmd.message);
        shell.exit(cmd.exitCode);
        break;

      default:
        send({
          exitCode: 1,
          stderr: cmd.command + " sent on the wrong port"
        });
        break;
    }
  });
