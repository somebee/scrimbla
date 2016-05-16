export tag RangeView

	prop view
	prop region
	prop row watch: yes
	prop col watch: yes
	prop len watch: yes

	def buffer
		view.@buffer

	def rowDidSet new, old
		var val = "{new * view.lineHeight}px"
		@dom:style:top = val

	def colDidSet new, old
		var val = "{new * view.charWidth}px"
		@dom:style:left = val

	def lenDidSet new, old
		var width = "{new * view.charWidth}px"
		@dom:style:width = width

	def render
		let reg = region

		var a = buffer.locToCell(region.start)
		var b = buffer.locToCell(region.end)
			
		# multiple lines
		if a[0] != b[0]
			yes
		else
			row = reg.row
			col = reg.col
			len = reg.size

		<self.RangeView> '|'