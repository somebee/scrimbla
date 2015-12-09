
###
Bridge for communicating with the Imba compiler in a worker
###
export class ImbacWorker
		
	def initialize path = "/vendor/imba/imbac.worker.min.js"
		@path = path
		@callbacks = []
		self

	def worker
		@worker ||= if true
			let process = Worker.new(@path)
			process:onmessage = do |e| onmessage(e)
			process

	def onmessage e
		if var fn = @callbacks.shift
			fn(e:data,e)

	def compile code, o, cb
		@callbacks.push(cb)
		worker.postMessage(['compile',code,o])
		self

	def analyze code, o, cb
		@callbacks.push(cb)
		worker.postMessage(['analyze',code,o])
		self