tag imcaptor < input

	def select
		unless dom:value
			dom:value = 'x'
		dom.select
		self

	def build
		super
		dom:onfocus = do |e|
			console.log 'dom onfocus!!!!'
			var event = Imba.Event.wrap(type: 'inputfocus', target: dom)
			event.process

		dom:onblur = do |e|
			console.log 'dom onblur!!!!',e
			var event = Imba.Event.wrap(type: 'inputblur', target: dom, relatedTarget: e:relatedTarget)
			event.process
			# Imba.Events.trigger('inputblur',dom)
		return self

	def enable
		document:body:appendChild(dom) unless parent
		self