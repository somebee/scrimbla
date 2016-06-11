import '../core/util' as util
import List from '../core/list'
import Region from '../region'
import Command from '../core/command'

import RangeView,LocView from './range'

tag hintview

	prop row watch: yes
	prop col watch: yes
	prop len watch: yes

	def rowDidSet new, old
		var val = "{new * 100}%"
		@dom:style:top = val

	def colDidSet new, old
		var val = "{new * 100}%"
		@dom:style:left = val

	def lenDidSet new, old
		var width = "{new * 100}%"
		@dom:style:width = width

	def buffer
		view.@buffer

	def view
		object.view

	def region
		object.region

	def render
		let reg = region
		return self unless reg

		var a = @a = @start = buffer.locToCell(reg.start)
		var b = @b = @end = buffer.locToCell(reg.end)

		row = a[0]
		col = a[1]
		
		<self.hint .{object.type} .active=(object.active) .collapsed=(reg.size == 0)>
			<.tip> <.label> object.label

	# def render
	# 	super
	# 	# setFlag('color',object.color)
	# 	# flag('active',object.active)