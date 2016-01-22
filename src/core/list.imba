export class List
	
	def initialize
		@array = []
		self

	def add item
		@array.push(item) unless @array.indexOf(item) >= 0
		return self

	def remove item
		if @array.indexOf(item) >= 0
			will-remove(item)
			@array.splice(@array.indexOf(item),1)
			did-remove(item)
		self

	def len
		@array:length

	def map cb
		@array.map(cb)

	def toArray
		@array

	def clear
		will-clear
		while @array:length
			remove(@array[@array:length - 1])
		did-clear
		self

	def will-remove item
		self

	def did-remove item
		self

	def will-clear
		self

	def did-clear
		self