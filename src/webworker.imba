extern postMessage

var compiler = require 'imba/src/compiler/compiler'

var api = {}

def api.compile code, o = {}
	try
		var res = compiler.compile(code,o)
		console.log "returned from compiler"
		return {code: res.toString, sourcemap: res:sourcemap}
	catch e
		return {error: e}

def api.analyze code, o = {}
	var meta
	try
		var ast = compiler.parse(code,o)
		meta = ast.analyze(loglevel: 0)
	catch e
		# console.log "something wrong {e:message}"
		# unless e isa ImbaParseError
		# 	if e:lexer
		# 		e = ImbaParseError.new(e, tokens: e:lexer:tokens, pos: e:lexer:pos)
		# 	else
		# 		e = {message: e:message}
		# 
		e = e.toJSON if e:toJSON # isa ImbaParseError
		meta = {warnings: [e]}
	return meta

global def onmessage e
	# console.log 'message to webworker'
	var params = e:data
	var id = params:id

	if api[params[0]] isa Function
		let fn = api[params[0]]
		var result = fn.apply(api,params.slice(1))
		postMessage(id: id, data: result)
