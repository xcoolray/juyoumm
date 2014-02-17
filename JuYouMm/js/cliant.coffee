#window.onload= =>
#  new MyGame(new Stage)
###
class TestSocket
  jsons:['{"type":"hello","protocol":"mjsonp","protocol_version":1}',
  '{"type":"start_game","id":2,"names":["manue","manue","manue","manue"]}',
  '{"type":"start_kyoku","bakaze":"E","kyoku":1,"honba":0,"oya":0,"dora_marker":"5sr","tehais":[["?","?","?","?","?","?","?","?","?","?","?","?","?"],["?","?","?","?","?","?","?","?","?","?","?","?","?"],["1m","1m","3m","4m","7p","9p","9p","3s","7s","S","P","F","F"],["?","?","?","?","?","?","?","?","?","?","?","?","?"]]}',
  '{"type":"tsumo","actor":0,"pai":"?"}',
  '{"type":"dahai","actor":0,"pai":"E","tsumogiri":false}',
  '{"type":"tsumo","actor":1,"pai":"?"}',
  '{"type":"dahai","actor":1,"pai":"C","tsumogiri":false}',
  '{"type":"tsumo","actor":2,"pai":"4p"}',
  '{"type":"dahai","actor":2,"pai":"S","tsumogiri":false}',
  '{"type":"tsumo","actor":3,"pai":"?"}',
  '{"type":"dahai","actor":3,"pai":"C","tsumogiri":false}',
  '{"type":"tsumo","actor":0,"pai":"?"}',
  '{"type":"dahai","actor":0,"pai":"C","tsumogiri":false}',
  '{"type":"tsumo","actor":1,"pai":"?"}',
  '{"type":"dahai","actor":1,"pai":"P","tsumogiri":false}',
  '{"type":"tsumo","actor":2,"pai":"N"}',
  '{"type":"dahai","actor":2,"pai":"P","tsumogiri":false}',
  '{"type":"tsumo","actor":3,"pai":"?"}',
  '{"type":"dahai","actor":3,"pai":"N","tsumogiri":false}',
  '{"type":"tsumo","actor":0,"pai":"?"}',
  '{"type":"dahai","actor":0,"pai":"W","tsumogiri":false}',
  '{"type":"tsumo","actor":1,"pai":"?"}',
  '{"type":"dahai","actor":1,"pai":"7m","tsumogiri":false}',
  '{"type":"tsumo","actor":2,"pai":"4p"}',
  '{"type":"dahai","actor":2,"pai":"N","tsumogiri":false}',
  '{"type":"tsumo","actor":3,"pai":"?"}',
  '{"type":"dahai","actor":3,"pai":"3p","tsumogiri":false}',
  '{"type":"tsumo","actor":0,"pai":"?"}',
  '{"type":"dahai","actor":0,"pai":"1p","tsumogiri":false}',
  '{"type":"tsumo","actor":1,"pai":"?"}',
  '{"type":"dahai","actor":1,"pai":"W","tsumogiri":true}',
  '{"type":"tsumo","actor":2,"pai":"4p"}',
  '{"type":"dahai","actor":2,"pai":"7s","tsumogiri":false}',
  '{"type":"tsumo","actor":3,"pai":"?"}',
  '{"type":"dahai","actor":3,"pai":"4s","tsumogiri":true}',
  '{"type":"tsumo","actor":0,"pai":"?"}',
  '{"type":"dahai","actor":0,"pai":"8p","tsumogiri":false}',
  '{"type":"tsumo","actor":1,"pai":"?"}',
  '{"type":"dahai","actor":1,"pai":"F","tsumogiri":true}',
  '{"type":"pon","actor":2,"target":1,"pai":"F","consumed":["F","F"]}',
  '{"type":"dahai","actor":2,"pai":"3s","tsumogiri":false}',
  '{"type":"tsumo","actor":3,"pai":"?"}',
  '{"type":"dahai","actor":3,"pai":"2m","tsumogiri":false}',
  '{"type":"tsumo","actor":0,"pai":"?"}',
  '{"type":"dahai","actor":0,"pai":"5m","tsumogiri":false}',
  '{"type":"tsumo","actor":1,"pai":"?"}',
  '{"type":"dahai","actor":1,"pai":"E","tsumogiri":true}',
  '{"type":"tsumo","actor":2,"pai":"S"}',
  '{"type":"dahai","actor":2,"pai":"S","tsumogiri":true}',
  '{"type":"tsumo","actor":3,"pai":"?"}',
  '{"type":"dahai","actor":3,"pai":"4s","tsumogiri":true}',
  '{"type":"tsumo","actor":0,"pai":"?"}',
  '{"type":"dahai","actor":0,"pai":"1m","tsumogiri":false}',
  '{"type":"pon","actor":2,"target":0,"pai":"1m","consumed":["1m","1m"]}',
  '{"type":"dahai","actor":2,"pai":"7p","tsumogiri":false}',
  '{"type":"tsumo","actor":3,"pai":"?"}',
  '{"type":"dahai","actor":3,"pai":"6p","tsumogiri":false}',
  '{"type":"tsumo","actor":0,"pai":"?"}',
  '{"type":"dahai","actor":0,"pai":"9m","tsumogiri":true}',
  '{"type":"tsumo","actor":1,"pai":"?"}',
  '{"type":"dahai","actor":1,"pai":"9s","tsumogiri":false}',
  '{"type":"tsumo","actor":2,"pai":"7p"}',
  '{"type":"dahai","actor":2,"pai":"7p","tsumogiri":true}',
  '{"type":"tsumo","actor":3,"pai":"?"}',
  '{"type":"dahai","actor":3,"pai":"2p","tsumogiri":false}',
  '{"type":"tsumo","actor":0,"pai":"?"}',
  '{"type":"dahai","actor":0,"pai":"2m","tsumogiri":false}',
  '{"type":"hora","actor":2,"target":0,"pai":"2m","hora_tehais":["3m","4m","4p","4p","4p","9p","9p"],"yakus":[["sangenpai",1]],"fu":40,"fan":1,"hora_points":1300,"deltas":[-1300,0,1300,0],"scores":[23700,25000,26300,25000]}',
  '{"type":"end_kyoku"}',
  '{"type":"end_game"}']

  on:(type,func)->
    @[type]=func
    if type=="hello"
      func(@jsons.shift())
    else
  	  setInterval(()=>
        if a=@jsons.shift()
          #console.log a
  	      func(a)
  	   ,100)
  emit:(type,msg)->
    false
  	###
    
socket = new WebSocket('ws://127.0.0.1:8080')
new CliantController(socket)
