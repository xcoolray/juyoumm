#Server side.
app = require('http').createServer(handler)
io = require('socket.io').listen(app)
fs = require('fs')
game=require('./game')
app.listen(9999)

handler=(req, res)->
  fs.readFile(__dirname + '/index.html', (err, data) ->
    if err 
      res.writeHead(500)
      return res.end('Error loading index.html')
    res.writeHead(200)
    res.end(data)
  )

c=new game.ServerController

io.sockets.on('connection', (socket)->
  c.onconnect(socket)
)
