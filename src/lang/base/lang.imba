
export class Lang
	
	def self.register name
		IM.LANGUAGES[name] = self

	def self.parserForView view
		var lang = IM.LANGUAGES[view.lang] or IM.LANGAUGES:imba
		return view.@parser ||= lang.new(view)


	def log *pars
		console.log(*pars)
		self

	def annotate view
		self

	def analyze view
		self