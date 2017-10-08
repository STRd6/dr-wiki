SystemClient = require "sys"
SystemClient.applyExtensions()
SystemClient()
.then ({system, application}) ->
  global.system = system

  {UI, Observable} = system
  {Modal} = UI

  Viewer = require "./viewer"
  viewElement = Viewer({system, application})

  document.body.appendChild viewElement

style = document.createElement "style"
style.innerHTML = require "./style"
document.head.appendChild style
