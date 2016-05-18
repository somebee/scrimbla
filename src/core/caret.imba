import './util' as util
import List from './list'
import Region from '../region'
import Command from './command'

export class Caret
	
	prop view
	prop region
	prop collapsed
	prop active
	# remember column

	def buffer
		view.@buffer

	def initialize view
		@view = view # should rather be for buffer, no?
		@region = Region.new(0,0,view.root,view)
		@collapsed = yes
		self

	def adjust rel, ins = yes
		console.log 'adjust',rel.a,rel.b,region.a,region.b,ins,rel.size
		region.adjust(rel,ins)
		self

	def set region
		console.log 'Caret.set',region
		self.region = Region.normalize(region,view)
		self

	def destroy
		deactivate
		view.carets.remove(self)
		self

	def activate
		active = yes
		self

	def deactivate
		active = no
		self

	def modified
		view.listeners.emit('SelectionModified',region,self)
		self
	# what does this do?
	def normalize
		# head.normalize
		self

	def isCollapsed
		region.isCollapsed

	def isReversed
		region.reversed

	def decollapse
		# just a friendly flag to say that the caret
		collapsed = no
		# tail = head.clone if tail == head
		self

	def move offset = 1, mode = 0
		return self if offset == 0
		console.log 'move caret-mark',offset,mode
		var to = Math.max(Math.min(buffer.size,region.b + offset),0)
		region.b = to
		region.collapseToHead if collapsed
		modified
		return self

	def expand a = 0, b = 0
		region.expand(a,b)
		self

	def alter offset = 1, mode = 0
		if mode == IM.CHAR
			move(offset)
		else
			var loc = buffer.offsetFromLoc(region.b,mode)
			console.log 'altered to new',loc,'from',region.b
			moveTo(loc)

		@realCol = null
		self

	def moveTo loc
		move(loc - region.b)

	def moveUp
		# first remember the current column
		var curr = buffer.locToCell(region.b)
		@realCol ||= curr[1]
		var cell = [curr[0] - 1,@realCol]
		var loc = buffer.cellToLoc(cell)
		console.log 'move down from',curr,cell,loc,@realCol
		moveTo(loc) # simply move by that amount
		self

	def moveDown
		# var cell = region.cell
		var curr = buffer.locToCell(region.b)
		@realCol ||= curr[1]
		var cell = [curr[0] + 1,@realCol]
		console.log 'move down from',curr,cell
		var loc = buffer.cellToLoc(cell)
		moveTo(loc) # simply move by that amount
		# first remember the current column
		self

	def collapseToStart
		region.collapseToStart
		collapsed = yes
		self


	def collapseToEnd
		region.collapseToEnd
		collapsed = yes
		self

	def expandToLines
		console.log 'caret expandToLines'
		collapsed = no
		region.a = buffer.offsetFromLoc(region.a,IM.LINE_START)
		region.b = buffer.offsetFromLoc(region.b,IM.LINE_END)
		self

	def selectAll
		collapsed = no
		# why change the previous region instead of creating a new one?
		region.a = 0
		region.b = buffer.len
		self

	def insert text, edit
		var sub = ''
		view.history.mark('action')

		if !collapsed
			let reg = region
			if reg.size > 0
				sub = reg.text
				view.erase(reg)
			collapseToStart

		let sel
		# need a different syntax for $0 -- can be in regular pasted code
		# should have a separate command for insertSnippet probably.
		if text.indexOf('$0') >= 0
			sel = region.clone(0,sub:length).move(text.indexOf('$0'))
			text = text.replace('$0',sub)

		edit ||= {size: text:length}

		view.runCommand('Insert', region.start, text)

		if sel
			region = sel
			modified
		return self

	def erase mode
		console.log 'erase!!'
		view.history.mark('action')

		if region.size == 0 # collapsed
			console.log 'isCollapsed',mode			
			view.erase(region.clone.expand(-1,0))
			return self

		console.log 'erasing region',region

		view.erase(region)
		collapseToStart # should happen be default through adjust no?
		return self

	def dirty
		self

	def text
		region.text

	def peekbehind reg
		var str = buffer.substringBeforeLoc(region.start)
		reg isa RegExp ? str.match(reg) : str

	def peekahead reg
		var str = buffer.substringAfterLoc(region.end)
		reg isa RegExp ? str.match(reg) : str

	def indent
		var str = buffer.linestringForLoc(region.start)
		var ind = str.match(/^(\t*)/)[0]
		return ind

	def model
		self

	def node
		@node ||= <caretview[self]>

	def unblink force
		@node.unblink(force) if @node
		self

	def blink force
		@node.blink(force) if @node
		self

export class RemoteCaret < Caret
	
	def node
		@node ||= <caretview[self].remote>

export class Carets < List

	def initialize view
		@view = view
		@array = []
		self