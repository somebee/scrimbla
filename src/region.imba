

export class Region
	
	prop a
	prop b
	prop view
	prop root

	# remove root from region

	def self.normalize val, view
		return val if val isa Region
		return Region.new(val[0],val[1],null,view) if val isa Array
		return Region.new(val,val,null,view) if val isa Number

		if val isa Object and val:line isa Number
			var lines = view.@buffer.lines
			var loc = 0
			for line,i in lines
				if i < (val:line - 1)
					loc += line:length + 1
				else break

			loc += (val:column or 0)
			return Region.new(loc,loc,null,view)


	def initialize a,b,root,view
		@a = a
		@b = b
		@root = root
		@view = view
		return self

	def start
		Math.min(@a,@b)

	def end
		Math.max(@a,@b)

	def clone ad = 0, bd = 0
		Region.new(@a + ad,@b + bd,@root,@view)

	def contains rel
		if rel isa Region
			start <= rel.start and end >= rel.end
		elif rel isa Number
			start <= rel and end >= rel

	def adjust rel, add = yes
		if rel.end < start
			add ? move(rel.size) : move(-rel.size)
		self

	def intersects rel
		# is this decent?
		rel = Region.normalize(rel)
		var a = Math.max(start,rel.start)
		var b = Math.min(end,rel.end)
		return b >= a
		
	def relativeTo rel
		# could use move instead
		Region.new(@a - rel.start,@b - rel.start,@root,@view)

	def intersection region
		self

	def equals region
		start == region.start && end == region.end

	def same region
		region and region.a == a and region.b == b

	def size
		end - start

	def move num = 1
		@a += num
		@b += num
		self

	def collapsed
		size == 0

	def reverse
		var a = @a, b = @b
		@a = b
		@b = a
		return self

	def reversed
		@a > @b

	def normalize
		var a = start
		var b = end
		@a = a
		@b = b
		self

	def collapse forward = yes
		if forward
			@a = @b = end
			# @a = @b
		else
			@b = @a
			@a = @b = start
		self

	# expand to closest /n
	def expand atStart, atEnd
		if b < a
			@b += atStart
			@a += atEnd
		else
			@a += atStart
			@b += atEnd		
		self
		
	def text
		view.substr(self)

	def toString
		"[{@a},{@b}]"

	def insert node
		self

	def nodes includeEnds = yes
		view.nodesInRegion(self,includeEnds)

	def prevNode query
		var nodes = nodes(no)
		var node = nodes:lft
		if query isa Imba.Selector or query isa String
			while node
				return node if node.matches(query)
				node = node?.isLast ? node.parent : null
			return null
		return node

	def nextNode query
		var nodes = nodes(no)
		var node = nodes:rgt
		if query isa Imba.Selector or query isa String
			while node
				return node if node.matches(query)
				node = node?.isFirst ? node.parent : null
			return null
		return node

	def scope query
		var nodes = nodes(no)
		var node
		if nodes:lft
			node = nodes:lft.up(query)
		elif nodes:rgt
			node ||= nodes:rgt.up(query)
		elif nodes[0]
			node ||= nodes[0]:node.closest(query)
		return node

	def buffer
		@root.code

	def startAtLine
		normalize
		var buffer = buffer
		var a = start

		if buffer[a] == '\n' and size == 0
			a-- # if we are at the end of a line

		while a >= 0 and buffer[a] != '\n'
			a--
		@a = a
		self

	def endAtLine
		normalize
		var buffer = buffer
		var b = (end - 1)
		while b >= 0 and buffer[b] and buffer[b] != '\n'
			b++
		@b = b
		self

	def cell
		view.@buffer.locToCell(a)

	def row
		cell[0]

	def col
		cell[1]

	def peekbehind len = 1
		len == 1 ? buffer[start - 1] : buffer.substring(start - len,start)

	def peekahead len = 1
		len == 1 ? buffer[end] : buffer.substr(end,len)

	def indent
		clone.startAtLine.text.match(/^\n?(\t*)/)[1]

	def peek before = 0, after = 0
		clone(before,after).text

	def lloc
		{startLine: 0, startCol: 2}

	def toJSON
		[a,b]
	