export tag LineRangeView

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
		return self unless reg
		

		var a = buffer.locToCell(region.start)
		var b = buffer.locToCell(region.end)
			
		# multiple lines
		var row = a[0]
		var lc = (b[0] - a[0]) + 1
		self.row = row

		# create the initial one
		var reg1 = [0,a[1],lc == 1 ? (b[1] - a[1]) : (80 - a[1])]	
		var regions = [reg1]

		var r = 0

		while b[0] > row
			row++
			var r = row - a[0]
			var c = 0
			var l = row == b[0] ? b[1] : 80
			regions.push([r,c,l])

		<self.RangeView>
			# far from idea
			for reg in regions
				<RangeView.part view=view row=reg[0] col=reg[1] len=reg[2]> '|'