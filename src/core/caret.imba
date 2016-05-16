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
		console.log 'move caret-mark',offset,mode
		region.b += offset
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

	def collapseToEnd
		region.collapseToEnd

	def expandToLines
		console.log 'caret expandToLines'
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

		let move = 0
		let sel

		# need a different syntax for $0 -- can be in regular pasted code
		# should have a separate command for insertSnippet probably.
		if text.indexOf('$0') >= 0
			sel = region.clone(0,sub:length).move(text.indexOf('$0'))
			text = text.replace('$0',sub)

		edit ||= {size: text:length}

		# head.normalize

		view.runCommand('Insert', region.start, text)

		# var res = view.insert(region.start, text, edit)
		view.log 'inserted -- now move',edit:size

		if sel
			region = sel
			console.log "MARK SPECIAL MOVE"

			# should trigger move(!)
		return self

	def erase mode
		console.log 'erase!!'
		view.history.mark('action')

		if region.size == 0 # collapsed
			console.log 'isCollapsed',mode
			collapsed = no
			move(-1)

		console.log 'erasing region',region
		view.erase(region)
		collapseToStart
		return self

	def dirty
		self

	def text
		region.text

	def peekbehind
		buffer.substringBeforeLoc(region.start)

	def peekahead
		buffer.substringAfterLoc(region.end)

	def indent
		var str = buffer.linestringForLoc(region.start)
		var ind = str.match(/^(\t*)/)[0]
		return ind

	def model
		self

	def node
		@node ||= <caretview[self]>

export class RemoteCaret < Caret
	
	def node
		@node ||= <caretview[self].remote>

export class Carets < List

	def initialize view
		@view = view
		@array = []
		self