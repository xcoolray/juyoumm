client = require('socket.io-client');
socket = client.connect('http://localhost:9999');

socket.on "mj_action",(a)=>
  console.log "->",a
  switch a.type
    when "start_game"
      @id = a.id
      response = {type: "none"}
    when "end_game"
      response=false
    when "tsumo"
      if a.actor == @id
        response = {
            type : "dahai",
            actor : @id,
            pai : a.pai,
            tsumogiri : true,
        }
      else
        response = {type : "none"}

    when "error"
      response = false
    else
      response = {type : "none"}
  if response
    console.log "<-",response
    socket.emit("mj_action",response)

socket.emit("join",
          type : "join",
          name : "tsumogiri",
          room : "room",
)


###c=new ServerController()
c.onconnect(new TestSocket)
c.onconnect(new TestSocket)
c.onconnect(new TestSocket)
c.onconnect(new TestSocket)###