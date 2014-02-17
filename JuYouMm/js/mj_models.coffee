###Copyright (c) 2012 hoo89 (hoo89@me.com) Licensed MIT###

#ゲームの進行を担当する部分

class ModelBase
  constructor:->
    @listeners={}
  add_listener:(type,a)->
    if !@listeners[type]
      @listeners[type]=[a]
    else
      @listeners[type].push(a)
    a
  notify:(action)->
    if @listeners[action.type]
      for i in @listeners[action.type]
        i(action)
  #remove_listener:(a)->
    #@listeners.splice(@listeners.indexOf(a),1)

MAX_KYOKU=4

class Stage extends ModelBase
  constructor:->
    super
    @states={
      start_kyoku:0
      tsumo:1
      dahai:2
      other_player:3
      end_kyoku:4
      end_game:5
    }
    @state=@states.start_kyoku
    @action_que=[true,true,true,true]
    @rest_actions=[] #reach_acceptedのあと他のplayerのchi|pon|kanを持っておくためのキュー
    @ActionSortIndex={hora:0,pon:1,kan:2,chi:3,none:4}
    
    @players = []
    for i in [0..3]
      if i==0
        @players.push(new NPC(i,i))
      else
        @players.push(new Plain(i,i))

    @kyoku=1
    @titya=0
    @honba=0
    @bakaze=0
    @kyotaku=0

  get_action:->
    for i in [0..3]
      if @players[i].action
        @action_que[i]=@players[i].pop_action()
      if !@action_que[i]
        return

    switch @state
      #start_kyoku
      when 0
        a=@get_start_action()
      #tsumo
      when 1
        a=@get_tsumo_action()
      #dahai|kan|reach
      when 2
        a=@get_dahai_action()
      #pon|kan|chi|hora|reach_accepted
      when 3
        a=@get_other_player_action()
      #end_kyoku
      when 4
        a=@get_end_kyoku()
      when 5
        pass

    @action_que=[false,false,false,false]
    a

  update:->
    a=@get_action()

    if a
      console.log(a)
      @act a
      a

  get_start_action:->
    @yama=new Yama
    @yama.shuffle()
    #@yama.tsumikomi [0,1,2,3,7,11,12,13,15,16,17,25,25]
    @wanpai=@yama.pop_wanpai()
    oya=@players.filter((i)->i.is_oya())[0].number
    a={"type": "start_kyoku",
    "bakaze": @bakaze,
    "kyoku":@kyoku,
    "honba": @honba,
    "kyotaku": @kyotaku,
    "oya": oya,
    "dora_marker" :@wanpai[0],
    "tehais":[[],[],[],[]]  
    }
    for i in [0...4]
      for j in [0...13]
        a.tehais[i].push @yama.shift()
    a

  get_tsumo_action:->
    if @yama.length()==0
      type:"ryukyoku"
    else
      type:"tsumo",actor:@phase,pai:@yama.shift()

  get_dahai_action:->
    for i in @action_que
      if i.actor == @phase
        return i

  get_other_player_action:->
    if @rest_actions.length!=0
      return @rest_actions.pop()

    #ロン>鳴き、ポン＞チー
    @action_que.sort((a,b)=>
      diff=@ActionSortIndex[a.type]-@ActionSortIndex[b.type]
      if diff!=0||a.type=="none" then diff
      else @players[@phase].get_distance(a.actor)-@players[@phase].get_distance(b.actor)
    )

    a=@action_que[0]

    if a.type!="hora"&&@reached_player!=false
      p=@reached_player
      @reached_player=false
      @rest_actions=[a]
      return {type:"reach_accepted",actor:p}

    a

  get_end_kyoku:->
    if @kyoku <= MAX_KYOKU
      type:"end_kyoku"
    else
      type: "end_game"

  act:(a)->
    switch a.type
      when "start_kyoku"
        @start(a)
        @state=@states.tsumo
      when "tsumo"
        @turn++
        @players[a.actor].tsumo(a)
        @state=@states.dahai
      when "hora"
        @players[a.actor].hora(a)
        @agari(a)
        @end_kyoku(a)
        @state=@states.end_kyoku
      when "reach"
        @players[a.actor].reach_naki_count=@naki_count
        @reached_player=a.actor
      when "reach_accepted"
        @players[a.actor].reach_accepted(a)
        @kyotaku++
        #点数変更
        a.actor.score-=1000
      when "dahai"
        @players[a.actor].dahai(a)
        #他のPlayerに鳴き、ロン問い合わせ
        @state=@states.other_player
      when "pon"
        @players[a.actor].pon(a)
        @phase_set a.actor
        @state=@states.dahai
      when "chi"
        @players[a.actor].actor.chi(a)
        @phase_set a.actor.number
        @state=@states.dahai
      when "kan"
        if a.target==a.actor
          @players[a.actor].kan(a)
        else
          @players[a.actor].minkan(a)
          #カンStage処理
          @phase_set a.actor
          @state=@states.dahai
      when "none"
        @next_phase()
        @state=@states.tsumo
      when "ryukyoku"
        @end_kyoku(a)
        @state=@states.end_kyoku
      when "end_kyoku"
        @state=@states.start_kyoku
      when "end_game"
        @state=@states.end_game
    if a.type=="pon"||a.type=="chi"||a.type=="kan"
      @naki_count++

    @notify a

    for i in @players
      i.ask(a)
    
    a

  start:(a)->
    @action_que.length=0
    for i,n in @players
      i.set_kyoku()
      i.state=new MJState(i,@)
      i.checker=new HaiChecker(i.state)
      i.kaze=(4+n-a.oya)%4 #???
    @kan_count=0
    @wanpai=[]
    @doras=[]
    @uradoras=[]
    @reachbou=[0,0,0,0]
    @phase_set a.oya
    @naki_count=0

    @bakaze=a.bakaze
    @kyoku=a.kyoku
    @honba=a.honba
    @doras=[a.dora_marker]

    @reached_player=false

    for i,n in a.tehais
      for j in i
        @players[n].push_tehai(j)

  next_phase:()->    
    @phase_set(@phase+1)

  end_kyoku:(end_reason)->
    @end_reason_settigs||={
      0:["hora","nagasimangan"]
      1:["ryukyoku"]
    }
    
    switch end_reason.type
      when "hora"
        if @players[end_reason.actor].is_oya()
          @honba++
        else
          @next_kyoku()
          
      when "ryukyoku"
        #親がテンパイしてたかどうか調べといて分岐
        sum=0
        flag=false
        for i in @players
          if i.tenpai() then sum++
        ten=[[0,0],[3000,1000],[1500,1500],[1000,3000],[0,0]]
        for i in @players
          if i.tenpai()
            i.score+=ten[sum][0]
          else
            i.score-=ten[sum][1]
          if i.is_oya()
            flag=i.tenpai()
        if flag
          @honba++
        else
          @next_kyoku()

  agari:(a)->
    agari=@players[a.actor].get_agari()
    if a.actor==a.target
      b=@players.filter((i)->i!=a.actor)
      for i in b
        if i.is_oya()
          i.score-=agari.scores[1]
          @players[a.actor].score+=agari.scores[1]
        else
          i.score-=agari.scores[0]
          @players[a.actor].score+=agari.scores[0]        
    else
      @players[a.target].score-=agari.score
      @players[a.actor].score+=agari.score
      if @kyotaku!=0
        @players[a.actor].score+=@kyotaku*1000
        @kyotaku=0

  phase_set:(a)->
    @phase=a%4
    @now_player=@players[@phase]

  get_titya:->
    @players[@titya]

  next_kyoku:->
    @honba=0
    @kyoku++

    for i in @players
      i.kaze=(i.kaze-1)%4

class Yama
  constructor:->
    @a=[0..33].concat([0..33],[0..33],[0..33])
    #@count=0
    @count2=0
    
  shift:->
    #@a[@count++]
    @a.shift()
  unshift:->
    @a.unshift()
  get:()->
    @a
  shuffle:->
    @a=@a.shuffle()
  length:->
    @a.length
  pop_wanpai:->
    w=@a[124..131]
    @a.splice(124,14)
    w
  tsumikomi:(pais)->
    for i in pais
      @a.splice(@a.indexOf(i),1)
    for i in pais
      @a.unshift(i)

class MJState
  constructor:(player,stage)->
    @player=player
    @stage=stage
  doras:->
    if !@player.reach
      @stage.doras
    else
      @stage.doras.concat(@stage.uradoras)
  #ドラはここで数える
  #どれが赤ドラか、という情報はCheckerから参照できないため
  dora_count:->
    0
  #red_dora_count
  honba:->
    @stage.honba
  reachbou:->
    @stage.reachbou.reduce((x,y)->x+y)
  yakuhai:(h)->
    30<h<34||@jikaze(h)||@bakaze(h)
  jikaze:(h)->
    h==27+@player.kaze
  bakaze:(h)->
    h==27+@stage.bakaze
  get_yama_length:()->
    @stage.yama.length()
  menzen:()->
    @player.menzen
  tsumo:()->
    @player.tsumohai
  reach:()->
    @player.reach
  reach_count:()->
    @player.reach_count
  is_oya:()->
    @player.is_oya()
  is_doublereach:()->
    @stage.naki_count==0&&@player.kawa.length==0
  is_ippatsu:()->
    @player.reach_kawa_count==0&&@player.reach_naki_count==@stage.naki_count

class Player extends ModelBase
  constructor:(n,k)->
    super()
    @number=n
    @kaze=k
    @score=25000
    @set_kyoku()

  set_action:(a)->
    @action=a 
    @last_action=a
    if a then @notify type:"selected",action:a,actor:@number

  pop_action:->
    a=@action
    @set_action false
    a
  set_kyoku:->
    @set_action false
    @reach=false
    @reach_kawa_count=0
    @reach_naki_count=0
    @menzen=true
    @tsumohai=null
    @tehai=[]
    @kawa=[]
  push_tehai:(h) ->
    @tehai.push(h)
  clear_tehai:->
    #@tehai.pop()
  push_kawa:(h)->
    @kawa.push(h)
  pop_kawa:->

  tsumo:(a)->
    @push_tehai(a.pai)
    @tsumohai=a.pai
  dahai:(a)->
    @tehai.splice(@tehai.indexOf(a.pai),1)
    @kawa.push(a.pai)
    @tsumohai=false
    if @reach then @reach_kawa_count++
  reach_accepted:(a)->
    @reach=true
  ask:(a)->
    @target_pai=a.pai
    @target_player=a.actor
  pon:(a)->
    @menzen=false
  chi:(a)->
    @menzen=false
  hora:(a)->
    if a.hasOwnProperty("hora_tehais")
      @clear_tehai()
      for i in a.hora_tehais
        @push_tehai(i)
  kan:(a)->
  daiminkan:(a)->
    @menzen=false
  kakan:(a)->
  is_oya:()->
    @kaze==0
  get_agari:()->
    null
  can_agari:()->
    false
  can_ron:(h)->
    false
  can_pon:(h)->
    false
  can_chi:(h)->
    false
  can_kan:(h)->
    false
  can_reach:()->
    false
  tenpai:->
    false
  get_distance:(player)->
    #player_aから見て上家が1,対面が2,下家が3
    a=@number-player.number
    if a>0
      return a
    else
      return a+4
    return 0

class Player1 extends Player
  push_tehai:(pai)->
    super
    @checker.push_tehai(pai)
  clear_tehai:->
    @checker.clear_tehai()
  tsumo:(a)->
    @push_tehai(a.pai)
    @tsumohai=a.pai
    @checker.check_agari()#重いようならNPCのこれは切る
  dahai:(a)->
    super
    @checker.remove(a.pai)
  get_agari:()->
    @checker.get_actually_score()
  can_agari:()->
    @checker.can_agari()
  can_ron:()->
    @checker.check_agari()
    if @target_pai in @checker.machis.map((i)->i[0])
      return @checker.machis.map((i)->i[1])
  can_pon:()->
    if @checker.can_pon(@target_pai)&&!@reach
      return [@target_pai]
  can_chi:()->
    if @get_distance(@target_player)==1&&!@reach #これでいいのか微妙
      @checker.can_chi(@target_pai)
  can_reach:()->
    if @checker.machis.length!=0&&@menzen&&!@reach
      return @checker.machis.map((i)->i[1])
  hora:(a)->
    super
    if a.target!=@
      @checker.push_tehai(a.pai)
      @checker.check_agari()
  tenpai:->
    @checker.machis.length!=0
  pon:(a)->
    super
    @checker.pon(a.pai,a.consumed)
  chi:(a)->
    super
    @checker.chi(a.pai,a.consumed)
  kan:(a)->
    super
    @checker.kan(a.pai,a.consumed)
  daiminkan:(a)->
    super
    @checker.daiminkan(a.pai,a.consumed)

class MyPlayer extends Player1
  ask:(a)->
    super
    switch a.type
      when "tsumo","reach","pon","chi","kan"
        if a.actor==@number
          return
      when "dahai"
        if a.actor!=@number
          return
    @set_action type:"none",actor:@number    

class NPC extends Player1
  ask:(a)->
    super
    unless (a.type=="hello"||a.type=="tsumo"&&a.actor==@number)
      @set_action type:"none",actor:@number
  tsumo:(a)->
    super
    @set_action type: "dahai",pai: a.pai,index: 13,actor:@number
    
class Plain extends Player1
