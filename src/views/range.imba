export tag RangeView

	prop view
	prop region
	prop row watch: yes
	prop col watch: yes
	prop len watch: yes

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

		if reg
			row = region.row
			col = region.col
			len = region.size

		<self.RangeView> '|'