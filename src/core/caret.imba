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

	def adjust reg, ins = yes
		return self unless region
		region.adjust(reg,ins)
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
		console.log 'move caret-mark',offset,mode,IM.CHAR

		if mode == IM.CHAR
			console.log 'move by a certain charcount'
			# region.move(offset)
			region.b += offset
			region.collapseToHead if collapsed
		# head.alter(mode,offset)
		return self

	def moveUp
		# first remember the current column
		var curr = buffer.locToCell(region.b)
		var cell = [curr[0] - 1,curr[1]]
		var loc = buffer.cellToLoc(cell)
		console.log 'move down from',curr,cell,loc
		move(loc - region.b) # simply move by that amount
		self

	def moveDown
		# var cell = region.cell
		var curr = buffer.locToCell(region.b)
		var cell = [curr[0] + 1,curr[1]]
		console.log 'move down from',curr,cell
		var loc = buffer.cellToLoc(cell)
		move(loc - region.b) # simply move by that amount
		# first remember the current column
		self

	def collapseToStart
		region.collapseToStart

	def collapseToEnd
		region.collapseToEnd

	def node
		@node ||= <caretview[self]>

export class Carets < List

	def initialize view
		@view = view
		@array = []
		self