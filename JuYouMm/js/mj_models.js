
/*Copyright (c) 2012 hoo89 (hoo89@me.com) Licensed MIT */
var MAX_KYOKU, MJState, ModelBase, MyPlayer, NPC, Plain, Player, Player1, Stage, Yama,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

ModelBase = (function() {
  function ModelBase() {
    this.listeners = {};
  }

  ModelBase.prototype.add_listener = function(type, a) {
    if (!this.listeners[type]) {
      this.listeners[type] = [a];
    } else {
      this.listeners[type].push(a);
    }
    return a;
  };

  ModelBase.prototype.notify = function(action) {
    var i, _i, _len, _ref, _results;
    if (this.listeners[action.type]) {
      _ref = this.listeners[action.type];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        _results.push(i(action));
      }
      return _results;
    }
  };

  return ModelBase;

})();

MAX_KYOKU = 4;

Stage = (function(_super) {
  __extends(Stage, _super);

  function Stage() {
    var i, _i;
    Stage.__super__.constructor.apply(this, arguments);
    this.states = {
      start_kyoku: 0,
      tsumo: 1,
      dahai: 2,
      other_player: 3,
      end_kyoku: 4,
      end_game: 5
    };
    this.state = this.states.start_kyoku;
    this.action_que = [true, true, true, true];
    this.rest_actions = [];
    this.ActionSortIndex = {
      hora: 0,
      pon: 1,
      kan: 2,
      chi: 3,
      none: 4
    };
    this.players = [];
    for (i = _i = 0; _i <= 3; i = ++_i) {
      if (i === 0) {
        this.players.push(new NPC(i, i));
      } else {
        this.players.push(new Plain(i, i));
      }
    }
    this.kyoku = 1;
    this.titya = 0;
    this.honba = 0;
    this.bakaze = 0;
    this.kyotaku = 0;
  }

  Stage.prototype.get_action = function() {
    var a, i, _i;
    for (i = _i = 0; _i <= 3; i = ++_i) {
      if (this.players[i].action) {
        this.action_que[i] = this.players[i].pop_action();
      }
      if (!this.action_que[i]) {
        return;
      }
    }
    switch (this.state) {
      case 0:
        a = this.get_start_action();
        break;
      case 1:
        a = this.get_tsumo_action();
        break;
      case 2:
        a = this.get_dahai_action();
        break;
      case 3:
        a = this.get_other_player_action();
        break;
      case 4:
        a = this.get_end_kyoku();
        break;
      case 5:
        pass;
    }
    this.action_que = [false, false, false, false];
    return a;
  };

  Stage.prototype.update = function() {
    var a;
    a = this.get_action();
    if (a) {
      console.log(a);
      this.act(a);
      return a;
    }
  };

  Stage.prototype.get_start_action = function() {
    var a, i, j, oya, _i, _j;
    this.yama = new Yama;
    this.yama.shuffle();
    this.wanpai = this.yama.pop_wanpai();
    oya = this.players.filter(function(i) {
      return i.is_oya();
    })[0].number;
    a = {
      "type": "start_kyoku",
      "bakaze": this.bakaze,
      "kyoku": this.kyoku,
      "honba": this.honba,
      "kyotaku": this.kyotaku,
      "oya": oya,
      "dora_marker": this.wanpai[0],
      "tehais": [[], [], [], []]
    };
    for (i = _i = 0; _i < 4; i = ++_i) {
      for (j = _j = 0; _j < 13; j = ++_j) {
        a.tehais[i].push(this.yama.shift());
      }
    }
    return a;
  };

  Stage.prototype.get_tsumo_action = function() {
    if (this.yama.length() === 0) {
      return {
        type: "ryukyoku"
      };
    } else {
      return {
        type: "tsumo",
        actor: this.phase,
        pai: this.yama.shift()
      };
    }
  };

  Stage.prototype.get_dahai_action = function() {
    var i, _i, _len, _ref;
    _ref = this.action_que;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      i = _ref[_i];
      if (i.actor === this.phase) {
        return i;
      }
    }
  };

  Stage.prototype.get_other_player_action = function() {
    var a, p;
    if (this.rest_actions.length !== 0) {
      return this.rest_actions.pop();
    }
    this.action_que.sort((function(_this) {
      return function(a, b) {
        var diff;
        diff = _this.ActionSortIndex[a.type] - _this.ActionSortIndex[b.type];
        if (diff !== 0 || a.type === "none") {
          return diff;
        } else {
          return _this.players[_this.phase].get_distance(a.actor) - _this.players[_this.phase].get_distance(b.actor);
        }
      };
    })(this));
    a = this.action_que[0];
    if (a.type !== "hora" && this.reached_player !== false) {
      p = this.reached_player;
      this.reached_player = false;
      this.rest_actions = [a];
      return {
        type: "reach_accepted",
        actor: p
      };
    }
    return a;
  };

  Stage.prototype.get_end_kyoku = function() {
    if (this.kyoku <= MAX_KYOKU) {
      return {
        type: "end_kyoku"
      };
    } else {
      return {
        type: "end_game"
      };
    }
  };

  Stage.prototype.act = function(a) {
    var i, _i, _len, _ref;
    switch (a.type) {
      case "start_kyoku":
        this.start(a);
        this.state = this.states.tsumo;
        break;
      case "tsumo":
        this.turn++;
        this.players[a.actor].tsumo(a);
        this.state = this.states.dahai;
        break;
      case "hora":
        this.players[a.actor].hora(a);
        this.agari(a);
        this.end_kyoku(a);
        this.state = this.states.end_kyoku;
        break;
      case "reach":
        this.players[a.actor].reach_naki_count = this.naki_count;
        this.reached_player = a.actor;
        break;
      case "reach_accepted":
        this.players[a.actor].reach_accepted(a);
        this.kyotaku++;
        a.actor.score -= 1000;
        break;
      case "dahai":
        this.players[a.actor].dahai(a);
        this.state = this.states.other_player;
        break;
      case "pon":
        this.players[a.actor].pon(a);
        this.phase_set(a.actor);
        this.state = this.states.dahai;
        break;
      case "chi":
        this.players[a.actor].actor.chi(a);
        this.phase_set(a.actor.number);
        this.state = this.states.dahai;
        break;
      case "kan":
        if (a.target === a.actor) {
          this.players[a.actor].kan(a);
        } else {
          this.players[a.actor].minkan(a);
          this.phase_set(a.actor);
          this.state = this.states.dahai;
        }
        break;
      case "none":
        this.next_phase();
        this.state = this.states.tsumo;
        break;
      case "ryukyoku":
        this.end_kyoku(a);
        this.state = this.states.end_kyoku;
        break;
      case "end_kyoku":
        this.state = this.states.start_kyoku;
        break;
      case "end_game":
        this.state = this.states.end_game;
    }
    if (a.type === "pon" || a.type === "chi" || a.type === "kan") {
      this.naki_count++;
    }
    this.notify(a);
    _ref = this.players;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      i = _ref[_i];
      i.ask(a);
    }
    return a;
  };

  Stage.prototype.start = function(a) {
    var i, j, n, _i, _j, _len, _len1, _ref, _ref1, _results;
    this.action_que.length = 0;
    _ref = this.players;
    for (n = _i = 0, _len = _ref.length; _i < _len; n = ++_i) {
      i = _ref[n];
      i.set_kyoku();
      i.state = new MJState(i, this);
      i.checker = new HaiChecker(i.state);
      i.kaze = (4 + n - a.oya) % 4;
    }
    this.kan_count = 0;
    this.wanpai = [];
    this.doras = [];
    this.uradoras = [];
    this.reachbou = [0, 0, 0, 0];
    this.phase_set(a.oya);
    this.naki_count = 0;
    this.bakaze = a.bakaze;
    this.kyoku = a.kyoku;
    this.honba = a.honba;
    this.doras = [a.dora_marker];
    this.reached_player = false;
    _ref1 = a.tehais;
    _results = [];
    for (n = _j = 0, _len1 = _ref1.length; _j < _len1; n = ++_j) {
      i = _ref1[n];
      _results.push((function() {
        var _k, _len2, _results1;
        _results1 = [];
        for (_k = 0, _len2 = i.length; _k < _len2; _k++) {
          j = i[_k];
          _results1.push(this.players[n].push_tehai(j));
        }
        return _results1;
      }).call(this));
    }
    return _results;
  };

  Stage.prototype.next_phase = function() {
    return this.phase_set(this.phase + 1);
  };

  Stage.prototype.end_kyoku = function(end_reason) {
    var flag, i, sum, ten, _i, _j, _len, _len1, _ref, _ref1;
    this.end_reason_settigs || (this.end_reason_settigs = {
      0: ["hora", "nagasimangan"],
      1: ["ryukyoku"]
    });
    switch (end_reason.type) {
      case "hora":
        if (this.players[end_reason.actor].is_oya()) {
          return this.honba++;
        } else {
          return this.next_kyoku();
        }
        break;
      case "ryukyoku":
        sum = 0;
        flag = false;
        _ref = this.players;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          i = _ref[_i];
          if (i.tenpai()) {
            sum++;
          }
        }
        ten = [[0, 0], [3000, 1000], [1500, 1500], [1000, 3000], [0, 0]];
        _ref1 = this.players;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          i = _ref1[_j];
          if (i.tenpai()) {
            i.score += ten[sum][0];
          } else {
            i.score -= ten[sum][1];
          }
          if (i.is_oya()) {
            flag = i.tenpai();
          }
        }
        if (flag) {
          return this.honba++;
        } else {
          return this.next_kyoku();
        }
    }
  };

  Stage.prototype.agari = function(a) {
    var agari, b, i, _i, _len, _results;
    agari = this.players[a.actor].get_agari();
    if (a.actor === a.target) {
      b = this.players.filter(function(i) {
        return i !== a.actor;
      });
      _results = [];
      for (_i = 0, _len = b.length; _i < _len; _i++) {
        i = b[_i];
        if (i.is_oya()) {
          i.score -= agari.scores[1];
          _results.push(this.players[a.actor].score += agari.scores[1]);
        } else {
          i.score -= agari.scores[0];
          _results.push(this.players[a.actor].score += agari.scores[0]);
        }
      }
      return _results;
    } else {
      this.players[a.target].score -= agari.score;
      this.players[a.actor].score += agari.score;
      if (this.kyotaku !== 0) {
        this.players[a.actor].score += this.kyotaku * 1000;
        return this.kyotaku = 0;
      }
    }
  };

  Stage.prototype.phase_set = function(a) {
    this.phase = a % 4;
    return this.now_player = this.players[this.phase];
  };

  Stage.prototype.get_titya = function() {
    return this.players[this.titya];
  };

  Stage.prototype.next_kyoku = function() {
    var i, _i, _len, _ref, _results;
    this.honba = 0;
    this.kyoku++;
    _ref = this.players;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      i = _ref[_i];
      _results.push(i.kaze = (i.kaze - 1) % 4);
    }
    return _results;
  };

  return Stage;

})(ModelBase);

Yama = (function() {
  function Yama() {
    var _i, _j, _k, _l, _results, _results1, _results2, _results3;
    this.a = (function() {
      _results3 = [];
      for (_l = 0; _l <= 33; _l++){ _results3.push(_l); }
      return _results3;
    }).apply(this).concat((function() {
      _results = [];
      for (_i = 0; _i <= 33; _i++){ _results.push(_i); }
      return _results;
    }).apply(this), (function() {
      _results1 = [];
      for (_j = 0; _j <= 33; _j++){ _results1.push(_j); }
      return _results1;
    }).apply(this), (function() {
      _results2 = [];
      for (_k = 0; _k <= 33; _k++){ _results2.push(_k); }
      return _results2;
    }).apply(this));
    this.count2 = 0;
  }

  Yama.prototype.shift = function() {
    return this.a.shift();
  };

  Yama.prototype.unshift = function() {
    return this.a.unshift();
  };

  Yama.prototype.get = function() {
    return this.a;
  };

  Yama.prototype.shuffle = function() {
    return this.a = this.a.shuffle();
  };

  Yama.prototype.length = function() {
    return this.a.length;
  };

  Yama.prototype.pop_wanpai = function() {
    var w;
    w = this.a.slice(124, 132);
    this.a.splice(124, 14);
    return w;
  };

  Yama.prototype.tsumikomi = function(pais) {
    var i, _i, _j, _len, _len1, _results;
    for (_i = 0, _len = pais.length; _i < _len; _i++) {
      i = pais[_i];
      this.a.splice(this.a.indexOf(i), 1);
    }
    _results = [];
    for (_j = 0, _len1 = pais.length; _j < _len1; _j++) {
      i = pais[_j];
      _results.push(this.a.unshift(i));
    }
    return _results;
  };

  return Yama;

})();

MJState = (function() {
  function MJState(player, stage) {
    this.player = player;
    this.stage = stage;
  }

  MJState.prototype.doras = function() {
    if (!this.player.reach) {
      return this.stage.doras;
    } else {
      return this.stage.doras.concat(this.stage.uradoras);
    }
  };

  MJState.prototype.dora_count = function() {
    return 0;
  };

  MJState.prototype.honba = function() {
    return this.stage.honba;
  };

  MJState.prototype.reachbou = function() {
    return this.stage.reachbou.reduce(function(x, y) {
      return x + y;
    });
  };

  MJState.prototype.yakuhai = function(h) {
    return (30 < h && h < 34) || this.jikaze(h) || this.bakaze(h);
  };

  MJState.prototype.jikaze = function(h) {
    return h === 27 + this.player.kaze;
  };

  MJState.prototype.bakaze = function(h) {
    return h === 27 + this.stage.bakaze;
  };

  MJState.prototype.get_yama_length = function() {
    return this.stage.yama.length();
  };

  MJState.prototype.menzen = function() {
    return this.player.menzen;
  };

  MJState.prototype.tsumo = function() {
    return this.player.tsumohai;
  };

  MJState.prototype.reach = function() {
    return this.player.reach;
  };

  MJState.prototype.reach_count = function() {
    return this.player.reach_count;
  };

  MJState.prototype.is_oya = function() {
    return this.player.is_oya();
  };

  MJState.prototype.is_doublereach = function() {
    return this.stage.naki_count === 0 && this.player.kawa.length === 0;
  };

  MJState.prototype.is_ippatsu = function() {
    return this.player.reach_kawa_count === 0 && this.player.reach_naki_count === this.stage.naki_count;
  };

  return MJState;

})();

Player = (function(_super) {
  __extends(Player, _super);

  function Player(n, k) {
    Player.__super__.constructor.call(this);
    this.number = n;
    this.kaze = k;
    this.score = 25000;
    this.set_kyoku();
  }

  Player.prototype.set_action = function(a) {
    this.action = a;
    this.last_action = a;
    if (a) {
      return this.notify({
        type: "selected",
        action: a,
        actor: this.number
      });
    }
  };

  Player.prototype.pop_action = function() {
    var a;
    a = this.action;
    this.set_action(false);
    return a;
  };

  Player.prototype.set_kyoku = function() {
    this.set_action(false);
    this.reach = false;
    this.reach_kawa_count = 0;
    this.reach_naki_count = 0;
    this.menzen = true;
    this.tsumohai = null;
    this.tehai = [];
    return this.kawa = [];
  };

  Player.prototype.push_tehai = function(h) {
    return this.tehai.push(h);
  };

  Player.prototype.clear_tehai = function() {};

  Player.prototype.push_kawa = function(h) {
    return this.kawa.push(h);
  };

  Player.prototype.pop_kawa = function() {};

  Player.prototype.tsumo = function(a) {
    this.push_tehai(a.pai);
    return this.tsumohai = a.pai;
  };

  Player.prototype.dahai = function(a) {
    this.tehai.splice(this.tehai.indexOf(a.pai), 1);
    this.kawa.push(a.pai);
    this.tsumohai = false;
    if (this.reach) {
      return this.reach_kawa_count++;
    }
  };

  Player.prototype.reach_accepted = function(a) {
    return this.reach = true;
  };

  Player.prototype.ask = function(a) {
    this.target_pai = a.pai;
    return this.target_player = a.actor;
  };

  Player.prototype.pon = function(a) {
    return this.menzen = false;
  };

  Player.prototype.chi = function(a) {
    return this.menzen = false;
  };

  Player.prototype.hora = function(a) {
    var i, _i, _len, _ref, _results;
    if (a.hasOwnProperty("hora_tehais")) {
      this.clear_tehai();
      _ref = a.hora_tehais;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        _results.push(this.push_tehai(i));
      }
      return _results;
    }
  };

  Player.prototype.kan = function(a) {};

  Player.prototype.daiminkan = function(a) {
    return this.menzen = false;
  };

  Player.prototype.kakan = function(a) {};

  Player.prototype.is_oya = function() {
    return this.kaze === 0;
  };

  Player.prototype.get_agari = function() {
    return null;
  };

  Player.prototype.can_agari = function() {
    return false;
  };

  Player.prototype.can_ron = function(h) {
    return false;
  };

  Player.prototype.can_pon = function(h) {
    return false;
  };

  Player.prototype.can_chi = function(h) {
    return false;
  };

  Player.prototype.can_kan = function(h) {
    return false;
  };

  Player.prototype.can_reach = function() {
    return false;
  };

  Player.prototype.tenpai = function() {
    return false;
  };

  Player.prototype.get_distance = function(player) {
    var a;
    a = this.number - player.number;
    if (a > 0) {
      return a;
    } else {
      return a + 4;
    }
    return 0;
  };

  return Player;

})(ModelBase);

Player1 = (function(_super) {
  __extends(Player1, _super);

  function Player1() {
    return Player1.__super__.constructor.apply(this, arguments);
  }

  Player1.prototype.push_tehai = function(pai) {
    Player1.__super__.push_tehai.apply(this, arguments);
    return this.checker.push_tehai(pai);
  };

  Player1.prototype.clear_tehai = function() {
    return this.checker.clear_tehai();
  };

  Player1.prototype.tsumo = function(a) {
    this.push_tehai(a.pai);
    this.tsumohai = a.pai;
    return this.checker.check_agari();
  };

  Player1.prototype.dahai = function(a) {
    Player1.__super__.dahai.apply(this, arguments);
    return this.checker.remove(a.pai);
  };

  Player1.prototype.get_agari = function() {
    return this.checker.get_actually_score();
  };

  Player1.prototype.can_agari = function() {
    return this.checker.can_agari();
  };

  Player1.prototype.can_ron = function() {
    var _ref;
    this.checker.check_agari();
    if (_ref = this.target_pai, __indexOf.call(this.checker.machis.map(function(i) {
      return i[0];
    }), _ref) >= 0) {
      return this.checker.machis.map(function(i) {
        return i[1];
      });
    }
  };

  Player1.prototype.can_pon = function() {
    if (this.checker.can_pon(this.target_pai) && !this.reach) {
      return [this.target_pai];
    }
  };

  Player1.prototype.can_chi = function() {
    if (this.get_distance(this.target_player) === 1 && !this.reach) {
      return this.checker.can_chi(this.target_pai);
    }
  };

  Player1.prototype.can_reach = function() {
    if (this.checker.machis.length !== 0 && this.menzen && !this.reach) {
      return this.checker.machis.map(function(i) {
        return i[1];
      });
    }
  };

  Player1.prototype.hora = function(a) {
    Player1.__super__.hora.apply(this, arguments);
    if (a.target !== this) {
      this.checker.push_tehai(a.pai);
      return this.checker.check_agari();
    }
  };

  Player1.prototype.tenpai = function() {
    return this.checker.machis.length !== 0;
  };

  Player1.prototype.pon = function(a) {
    Player1.__super__.pon.apply(this, arguments);
    return this.checker.pon(a.pai, a.consumed);
  };

  Player1.prototype.chi = function(a) {
    Player1.__super__.chi.apply(this, arguments);
    return this.checker.chi(a.pai, a.consumed);
  };

  Player1.prototype.kan = function(a) {
    Player1.__super__.kan.apply(this, arguments);
    return this.checker.kan(a.pai, a.consumed);
  };

  Player1.prototype.daiminkan = function(a) {
    Player1.__super__.daiminkan.apply(this, arguments);
    return this.checker.daiminkan(a.pai, a.consumed);
  };

  return Player1;

})(Player);

MyPlayer = (function(_super) {
  __extends(MyPlayer, _super);

  function MyPlayer() {
    return MyPlayer.__super__.constructor.apply(this, arguments);
  }

  MyPlayer.prototype.ask = function(a) {
    MyPlayer.__super__.ask.apply(this, arguments);
    switch (a.type) {
      case "tsumo":
      case "reach":
      case "pon":
      case "chi":
      case "kan":
        if (a.actor === this.number) {
          return;
        }
        break;
      case "dahai":
        if (a.actor !== this.number) {
          return;
        }
    }
    return this.set_action({
      type: "none",
      actor: this.number
    });
  };

  return MyPlayer;

})(Player1);

NPC = (function(_super) {
  __extends(NPC, _super);

  function NPC() {
    return NPC.__super__.constructor.apply(this, arguments);
  }

  NPC.prototype.ask = function(a) {
    NPC.__super__.ask.apply(this, arguments);
    if (!(a.type === "hello" || a.type === "tsumo" && a.actor === this.number)) {
      return this.set_action({
        type: "none",
        actor: this.number
      });
    }
  };

  NPC.prototype.tsumo = function(a) {
    NPC.__super__.tsumo.apply(this, arguments);
    return this.set_action({
      type: "dahai",
      pai: a.pai,
      index: 13,
      actor: this.number
    });
  };

  return NPC;

})(Player1);

Plain = (function(_super) {
  __extends(Plain, _super);

  function Plain() {
    return Plain.__super__.constructor.apply(this, arguments);
  }

  return Plain;

})(Player1);
