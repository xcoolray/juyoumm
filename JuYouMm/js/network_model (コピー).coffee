class ActionEncoder
  #idindex_table:{0:2,1:3,2:0,3:1}#id,index
  #indexid_table:{0:0,1:1,2:2,3:3}#id,index
  id:0
  kaze_index:{E:0,S:1,W:2,N:3}
  index_kaze:{0:"E",1:"S",2:"W",3:"N"}
  pai_strs:["1m","2m","3m","4m","5m","6m","7m","8m","9m","1p","2p","3p","4p","5p","6p","7p","8p","9p","1s","2s","3s","4s","5s","6s","7s","8s","9s","E","S","W","N","P","F","C"]
  json_to_action:(a)->
    if a.hasOwnProperty("actor")
      a.actor=@id_to_index a.actor
    if a.hasOwnProperty("oya")
      a.oya=@id_to_index a.oya
    if a.hasOwnProperty("target")
      a.target=@id_to_index a.target
    if a.pai
      a.pai=@toval a.pai
    if a.tehais
      tehai=[]
      for arr,i in a.tehais
        tehai[@id_to_index i]=arr.map((i)=>@toval(i))
      a.tehais=tehai
    if a.consumed
      a.consumed=a.consumed.map((i)=>@toval(i))
    if a.hora_tehais
      a.hora_tehais=a.hora_tehais.map((i)=>@toval(i))
    if a.bakaze
      a.bakaze=@kaze_index[a.bakaze]
    if a.dora_marker
      a.dora_marker=@toval a.dora_marker
    a

  toval:(a)->
    a=@pai_strs.indexOf(a)
    if a==-1 
      return 0
    else 
      return a
  tostr:(a)->
    @pai_strs[a]
  action_to_json:(action)->
    a={}
    for i,j of action
      a[i]=j
    if a.hasOwnProperty("actor")
      a.actor=@index_to_id a.actor
    if a.hasOwnProperty("target")
      a.target=@index_to_id a.target
    if a.hasOwnProperty("oya")
      a.oya=@index_to_id a.oya
    if a.hasOwnProperty("pai")
      a.pai=@tostr a.pai
    if a.consumed
      c=a.consumed
      a.consumed=[]
      for i in c
        a.consumed.push(@tostr(i))
    if a.hasOwnProperty("bakaze")
      a.bakaze=@index_kaze[a.bakaze]
    if a.hasOwnProperty("dora_marker")
      a.dora_marker=@tostr a.dora_marker
    if a.type=="dahai"
      a.tsumogiri=false
      #あとで適切に設定する
    if a.hasOwnProperty("tehais")
      tehai=[]
      for arr,i in a.tehais
        tehai[@index_to_id i]=arr.map((p)=>@tostr(p))
      a.tehais=tehai
    a
  id_to_index:(a)->
    (a+(4-@id))%4
  index_to_id:(a)->
    (a+@id)%4

class ServerManager
  constructor:->
    @games=[]
  onconnect:(socket)->
    #for i in @games
      #if i.is_end()
        #@games.splice(i,1)
    
    if @games.length==0||@games[@games.length-1].is_playing()
      @games.push(new ServerController)
    @games[games.length-1].onconnect(socket)
      
#複数Stageを持てるように改良 or インスタンス複数作成を前提に設計すること
class ServerController extends ActionEncoder
  constructor:->
    @stage=new Stage
    @players=@stage.players
    for i in ["tsumo","dahai","reach","pon","chi","kan","start_kyoku","reach_accepted","hora","ryukyoku","end_kyoku","end_game","none"]
      @stage.add_listener(i,(a)=>
        @send(a)
      )
    
    @p_sockets=[]

    @playing_flag=false
    @end_flag=false
  is_playing:->
    @playing_flag
  is_end:->
    @end_flag

  onconnect:(socket)->
    socket.on "join",(join_message)=>
      @p_sockets.push(socket)
      socket.on("disconnect", =>@p_sockets.splice(@p_sockets.indexOf(socket)))
      socket.on('mj_action',(a)=>@receive(socket,a))
      if @p_sockets.length>=4
        @playing_flag=true
        for i in [0...4]
          @p_sockets[i].emit "mj_action",{type: "start_game", id:i, names: [0,1,2,3]}
        setInterval(=>
          @stage.update()
        ,100)

  receive:(socket,mes)->
    n=@p_sockets.indexOf(socket)
    console.log "receive",n,mes
    a=@json_to_action mes
    @players[n].set_action(a)

  send:(a)->
    mes=@action_to_json a
    console.log "send",mes
    for i in @p_sockets
      i.emit('mj_action',mes)

class CliantController extends ActionEncoder
  constructor:(socket)->
    @stage=new CliantStage
    @players=@stage.players
    @my_actor=@stage.players[0]

    @my_actor.add_listener("selected",(a)=>
      @send a.action
    )
    @socket=socket

    @socket.on('mj_action',(a)=>@receive(@json_to_action a))
    alert "join"
    @socket.emit "join",(@action_to_json { type: "join", name: "", room: "default" })

    window.onload= =>
      new MyGame(@stage)

  receive:(a)->
    #console.log "receive",a
    if a.type=="start_game"
      @id=a.id
      titya=@id_to_index(@id)
      for i in [0...4]
        @players[(titya+i)%4].kaze=i

    @stage.act(a)

  send:(a)->
    console.log("send",a)
    @socket.emit('mj_action',@action_to_json a)

class CliantStage extends Stage
  constructor:->
    super
    @update=()->false

exports={ServerController:ServerController}