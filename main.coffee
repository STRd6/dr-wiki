style = document.createElement "style"
style.innerHTML = require "./style"
document.head.appendChild style

SystemClient = require "sys"
SystemClient.applyExtensions()
{system, application, postmaster} = SystemClient()

{UI, Observable} = system
{Modal} = UI

Viewer = require "./viewer"
viewElement = Viewer({system, application})

postmaster.delegate = viewElement.handlers

document.body.appendChild viewElement
