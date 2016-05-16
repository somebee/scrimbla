import './util' as util
import Region from '../region'

export class Buffer

	prop view

	def initialize view
		@view = view
		@buffer = ''
		@cache = {}
		self

	def set buffer
		if buffer == @buffer
			return self

		@buffer = buffer
		@cache = {}
		@lines = null
		self

	def refresh
		set view.root.code

	def lines
		@lines ||= if true
			@buffer.split('\n')

	def split
		@buffer.split(*arguments)

	def linecount
		lines:length

	def line nr
		if nr isa Number
			lines[nr] or ''
		else
			''

	def len
		@buffer:length

	# location to 
	def loc-to-rc loc
		util.rowcol(self, loc)

	def location
		self

	def locToRow loc
		var ln = 0
		var len = 0
		for ln,i in lines
			len += ln:length + 1
			return i if loc < len
		return lines:length

	def locToCell loc
		if @cache[loc]
			return @cache[loc]

		var pos = loc
		var col = 0
		var row = 0
		var char

		var buf = @buffer
		var tabsize = @view.tabSize

		# go back to start of line
		# goes through the whole
		while char = buf[pos - 1]
			if char == '\n'
				break
			pos--

		# get column for slice
		while (pos < loc) and char = buf[pos]
			if char == '\t'
				var rest = tabsize - (col % tabsize)
				col += rest
			else
				col += 1
			pos++

		while char = buf[pos - 1]
			if char == '\n'
				row++
			pos--

		return @cache[loc] = [row,col]

	def cellToLoc cell
		var loc = 0
		var row = cell[0]
		var col = cell[1]
		var lines = lines

		for line,i in lines
			if i < row
				loc += line:length + 1 # the last line
			elif i == row
				var colLoc = util.colToLoc(line,col)
				loc += colLoc
			else
				break
		return loc
		
	def substr region, len
		if region isa Region
			@buffer.substr(region.start,region.size)

		elif region isa Number
			@buffer.substr(region,len or 1)
		else
			throw 'must be region or number'

	def toString
		@buffer or ''

	# analysis should happen in the buffer, not in the view?

	def offsetFromLoc loc, mode
		# should be able to do this without using views
		# should instead iterate with pairings etc
		var nodes = view.nodesInRegion(loc)
		var node = nodes[0]
		var mid = node and node:node
		var lft = nodes:prev and nodes:prev:node
		var rgt = nodes:next and nodes:next:node
		var chr
		var part

		if mode == IM.WORD_START
			var el = mid or lft
			if lft?.matches(%imclose)
				return lft.parent.region.start
			elif lft?.matches(%imstr)
				return lft.region.start
			else
				loc -= 1
				while chr = @buffer[loc - 1]
					if chr in [' ','\t','\n','.']
						return loc
					loc -= 1
				return loc
				# let loc = self.loc
				# let buf = view.buffer
				# console.log 'peekbehind',peekbehind,loc,str
				# let str = peekbehind.split('').reverse().join('')
				# loc -= str.match(/^([\s\t\.]*.+?|)(\b|$)/)[1][:length]
				# self.loc = loc

		elif mode == IM.WORD_END
			var el = mid or rgt
			if rgt?.matches(%imopen)
				return rgt.parent.region.end
			elif rgt?.matches(%imstr)
				return rgt.region.end
			else
				while chr = @buffer[loc + 1]
					if !chr or chr in [' ','\t','\n','.']
						return loc + 1
					loc += 1
				return loc
				# console.log 'peekahead',peekahead,loc
				# loc += peekahead.match(/^([\s\.]*.+?|)(\b|$)/)[1][:length]
				# loc++ until buf[loc].match(/[\n\]/)
				# self.loc = loc

		elif mode == IM.LINE_END
			return loc
			# self.set(row,1000)

		elif mode == IM.LINE_START

			return loc
			# FIXME tabs-for-spaces
			# let tabs = linestr.match(/^\t*/)[0][:length]
			# let newcol = tabs * view.tabSize
			# self.col = col > newcol ? newcol : 0

		else
			return loc