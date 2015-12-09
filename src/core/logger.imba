
export class Logger
	
	prop enabled
	prop view

	def initialize view
		@enabled = yes
		@view = view
		self

	def log
		# console.log('logging through logger')
		console.log(*arguments) if @enabled
		self

	def warn
		console.log(*arguments) if @enabled
		self

	def group name
		console.group(*arguments) if @enabled
		self

	def groupCollapsed
		console.groupCollapsed(*arguments) if @enabled
		self

	def groupEnd
		console.groupEnd if @enabled
		self


