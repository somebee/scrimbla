import Region from '../region'

var labels =
	"Unexpected 'TAG_END'": 'Tag closed unexpectedly'
	"Unexpected 'TERMINATOR'": 'Unexpected ⏎'
	"Unexpected 'POST_IF'": 'Missing body in <b>IF</b>'

var rules = [
	[/Uncaught Error: tag (\w+) is not defined/,"tag <b>$1</b> does not exist"]
]

export class Hint

	def self.build o, view
		self.new(o, view)

	prop view
	prop region
	prop active

	def initialize opts, view
		@view = view
		@data = opts
		@active = no
		@region = opts:loc ? Region.normalize(opts:loc,view) : null
		# try to find the node immediately
		@node = opts:node || node
		self

	def getAttribute key
		@data[key]

	def setAttribute key,val
		@data[key] = val
		self

	def type
		@data:type or 'error'

	def group
		@data:group

	def ref
		@data:ref

	def node
		@node ||= @region and view.nodeAtRegion(@region)

	def row
		region.row

	def col
		region.col

	def label
		@label ||= if true
			var lbl = @data:label or @data:message or 'Hint'
			lbl = lbl.split(/error at (\[[\d\:]*\])\:\s*/).pop
			lbl = labels[lbl] or lbl


	def activate
		unless @active
			# node?.setAttribute('hint',ref)
			@active = yes
			node?.setHint(self)
		self

	def deactivate
		console.log 'deactivate hint!!'
		active = no
		self
		# cleanup
		# remove

	def prune
		view.hints.prune(self)

	# should make this hint ready to be removed
	def cleanup
		if @node
			@node.setHint(null) if @node.hint == self
		self

	def remove
		view.hints.rem(self)
		return self

	def changed
		# console.log 'deactivate on changed!'
		# @deactivate = yes
		prune
		self

	def adjust reg, ins = yes
		return self unless region

		if region.intersects(reg)
			# deactivate
			prune
			# @deactivate = yes

		region.adjust(reg,ins)
		self

	def popup
		<hintview@popup[self]>


# TODO use List

export class Hints
	
	var nr = 0

	def initialize view
		@prune = []
		@array = []
		@map = {}
		@view = view

	def toArray
		@array

	def get ref
		@map[ref]

	def activate
		for item in @array
			item.activate
		self

	# this should take care of deallocating the hint no?
	def rem hint
		if hint isa Function
			hint = @array.filter(hint)

		if hint isa Array
			rem(item) for item in hint
			return hint

		if hint isa String
			return rem get(hint)

		if @array.indexOf(hint) >= 0
			hint.cleanup
			@array.splice(@array.indexOf(hint),1)

		return hint

	def prune hint
		@prune.push(hint) unless @prune.indexOf(hint) >= 0
		return self

	def clear
		var arr = @array
		@array = []

		for item in arr
			item.deactivate
		self

	def cleanup

		@array.map do |item|
			if @prune.indexOf(item) >= 0
				item.deactivate
				rem(item)
		@prune = []
		self


	def filter cb
		@array.filter(cb)

	def map cb
		@array.map(cb)

	def add o
		var ref = o:ref = "hint{nr++}"
		o = Hint.build(o,@view) unless o isa Hint
		@map[ref] = o
		@array.push(o)
		return o