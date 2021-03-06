# Render Markdown

FileIO = require "./lib/file-io"

{absolutizePath} = require "./util"

isRelative = (url) ->
  url.match /^\.\.?\//

module.exports = ({application, system}) ->
  {ContextMenu, MenuBar, Modal, Progress, Util:{parseMenu}, Window} = system.UI

  container = document.createElement 'container'
  container.style.padding = "1rem"
  container.style.userSelect = "initial"

  baseDir = ""
  navigationStack = []
  # TODO: Maintain a container stack to keep state

  navigateToPath = (path) ->
    system.readFile(path)
    .then (blob) ->
      handlers.loadFile(blob, path)

  rewriteURL = (url) ->
    Promise.resolve()
    .then ->
      if isRelative(url)
        targetPath = absolutizePath baseDir, url

        system.urlForPath(targetPath)
      else if url.match /^\// # Absolute paths
        targetPath = absolutizePath "", url
        system.urlForPath(targetPath)
      else
        url

  rewriteURLs = (container) ->
    container.querySelectorAll("img").forEach (img) ->
      url = img.getAttribute("src")

      if url
        rewriteURL(url)
        .then (url) ->
          img.src = url

  handlers = Object.assign FileIO(system),
    loadFile: (blob, path) ->
      navigationStack.push path
      baseDir = path.replace /\/[^/]*$/, ""

      blob.readAsText()
      .then (textContent) ->
        if path.match /\.html$/
          container.innerHTML = textContent
        else
          container.innerHTML = marked(textContent)

        rewriteURLs(container)

    saveData: ->

    exit: ->
      application.exit()

  # Handle Links
  container.addEventListener "click", (e) ->
    [anchor] = e.path.filter (element) ->
      element.nodeName is "A"

    if anchor
      url = anchor.getAttribute("href")

      if isRelative(url)
        e.preventDefault()
        path = absolutizePath baseDir, url

        # Navigate to page
        navigateToPath(path)


  menuBar = MenuBar
    items: parseMenu """
      [F]ile
        [O]pen
        -
        E[x]it
    """
    handlers: handlers

  document.body.appendChild menuBar.element

  document.addEventListener "keydown", (e) ->
    {key, defaultPrevented} = e
    return if defaultPrevented

    if key is "Backspace"
      types = ["text", "password", "file", "search", "email", "number", "date", "color", "datetime", "datetime-local", "month", "range", "search", "tel", "time", "url", "week"]
      source = event.srcElement or event.target
      disabled = source.getAttribute("readonly") or source.getAttribute("disabled")
      abort = false

      unless disabled
        if source.isContentEditable
          abort = true
        else if source.tagName is "INPUT"
          type = source.type?.toLowerCase()

          if types.indexOf(type) > -1
            abort = true

        else if source.tagName is "TEXTAREA"
          abort = true

      unless abort
        event.preventDefault()

        e.preventDefault()
        if navigationStack.length > 1
          navigationStack.pop()

          lastPath = navigationStack.pop()
          navigateToPath(lastPath)

  container.handlers = handlers

  return container
