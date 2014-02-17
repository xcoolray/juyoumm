assert = require('assert')
mod = require('./mj_models')
console.log(mod)

class TestStage extends mod.Stage
	test:->
		"test"

stage = new TestStage

describe "Stage",->
	it "First kyoku equal 1",->
		assert.equal(stage.kyoku,1)
	it "test mod",->
		assert.equal(stage.test(),"test")