import './util' as util
import List from './list'
import Region from '../region'
import Command from './command'

export class Caret
	
	prop view
	prop region
	prop collapsed
	# remember column

	def buffer
		view.@buffer

	def initialize view
		@view = view # should rather be for buffer, no?
		@region = Region.new(0,0,view.root,view)
		@collapsed = yes
		self

	def adjust rel, ins = yes
		return self unless region

		console.log 'adjust',rel.a,rel.b,region.a,region.b,ins,rel.size

		region.adjust(rel,ins)

		# if ins
		# 	if rel.start <= region.start
		# 		region.move(rel.size)
		# else
		# 	if rel.end <= region.start
		# 		region.move(-rel.size)

		# what if it intersects?
		# if rel.end <= region.start
		#	ins ? region.move(rel.size) : region.move(-rel.size)
		#	# add ? move(rel.size) : move(-rel.size)
		# region.adjust(reg,ins)
		self

	def destroy
		deactivate
		view.carets.remove(self)
		self

	# what does this do?
	def normalize
		head.normalize
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

	def selectAll
		collapsed = no
		# why change the previous region instead of creating a new one?
		region.a = 0
		region.b = buffer.len
		self

	# should be possible to do for regions directly?
	def expandToLines
		selectable
		var [a,b] = ends
		a.col = 0
		b.col = 1000
		dirty

	def move offset = 1, mode = 0
		console.log 'move caret-mark',offset,mode
		region.b += offset
		region.collapseToHead if collapsed
		return self

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
		view.history.mark('action')

		if collapsed
			console.log 'isCollapsed',mode
			collapsed = no
			move(-1)

		console.log 'erasing region',region
		view.erase(region)
		collapseToStart
		return self

	def node
		@node ||= <caretview[self]>

export class Carets < List

	def initialize view
		@view = view
		@array = []
		self