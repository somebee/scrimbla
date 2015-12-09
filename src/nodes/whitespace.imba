tag iminsert < im

	def canAppend
		yes

	def canPrepend
		yes

	def insert reg, ins
		console.log 'insert code into iminsert!!',ins,reg

		if ins isa IM.Types:fragment
			ins = ins.code
		elif ins isa IM.Types:raw
			ins = ins.@raw
		elif ins isa String
			ins = (self.code or "").ins(ins,reg)
		
		self.code = ins
		self

	def mutated
		log 'iminsert mutated'
		var dirty = dirtyExtent
		view.highlighter.reparse(dirty)
		self

tag imwhitespace < im

tag imnewline < imwhitespace

	type 'newline'
	alias '\n'

	def canPrepend str
		if str.match(/^[\n\t\ ]+$/)
			console.log 'can prepend to newline!!'
			return yes
		return no

	def validate val = code
		val == '\n'

	def indent
		view.insert(region.end,'\t')
		self

	def undent
		log 'undent newline'
		var reg = region.clone.collapse(yes).clone(0,1)
		if reg.text == '\t'
			log 'can undent!!'
			view.erase(reg)

		# view.observer.pause do
		#	next.orphanize if next?.matches('._imtab')
		self

	def mutated
		# log 'imnewline mutated!!'
		# remove node if it is orphanized
		if code == ''
			log 'remove whole node'
			orphanize
		else
			log 'reparse newline'
			view.highlighter.reparse({nodes: [dom], code: code})

		

tag imspace < imwhitespace

	type 'whitespace'

	def validate val = code
		(/^[ ]+$/).test(val)

tag imsemicolon < imwhitespace
	type 'semicolon'
	alias ';'

tag imtab < imwhitespace
	
	type 'tab'
	alias '\t'

	def onedit e
		if e.isSurrounded
			log 'delete tab?!?'
			if e.text # otherwise we really are done
				e.redirect(prev or next or parent)
			else
				e.handled

			e.region.collapse(no)
			orphanize
			return

	def validate val = code
		val == '\t'

tag imcomment < im

	type 'comment'

	def validate code
		COMMENT.test(code)

	def mutated
		log 'imcomment mutated'
		super

	def repair
		self
		log 'repair comment'
		var region = self.region.endAtLine
		var full = region.text # should not include the last line?
		var nodes = region.nodes(no)
		log 'whole region should be',region,full,nodes
		log 'all nodes',nodes

		# VERY temporary
		if nodes:length > 1
			code = full
			while nodes:length > 1
				var el = nodes.pop
				el:node.orphanize
		self

	def oninserted e
		repair

	def canPrepend text
		no

	def canAppend text
		yes unless text.match(/[\n]/)


# allow inserting additional tabs directly here?

tag eof