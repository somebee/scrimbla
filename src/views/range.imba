export tag LineRangeView

export tag LineRegionView
	prop view
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

export tag RangeView

	prop view
	prop region
	prop row watch: yes

	def buffer
		view.@buffer

	def rowDidSet new, old
		var val = "{new * view.lineHeight}px"
		@dom:style:top = val

	def ranges
		for reg,i in @regions
			<LineRegionView@{i}.part view=view row=reg[0] col=reg[1] len=reg[2]> '|'

	def calculate
		var a = @a = buffer.locToCell(region.start)
		var b = @b = buffer.locToCell(region.end)
		var lc = @lc = (b[0] - a[0])

		self.row = a[0]

		@regions = []

		for r in [0..@lc]
			# 80 is arbitrary
			var c = r == 0 ? @a[1] : 0
			var l = r == @lc ? (@b[1] - c) : (80 - c)
			@regions.push([r,c,l])
		self


	def render
		let reg = region
		return self unless reg
		calculate

		<self.RangeView>
			<@dim> "|"
			ranges