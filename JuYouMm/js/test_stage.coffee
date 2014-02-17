assert = require('assert')
mod = require('./mj_models')

class TestYama
  constructor:->
    @reset()
  reset:->
    @a=[0..33].concat([0..33],[0..33],[0..33])
  shift:->
    @a.shift()
  unshift:->
    @a.unshift()
  get:()->
    @a
  shuffle:->
    pass
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

class TestStage extends mod.Stage
	constructor:->
		super
		@yama = new TestYama
	

stage = new TestStage

describe "Stage",->
	it "First kyoku equal 1",->
		assert.equal(stage.kyoku,1)
	it ,->
		assert.equal(stage.test(),"test")