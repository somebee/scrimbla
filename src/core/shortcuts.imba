import './util' as util

var specialKeys = {
	8: "backspace"
	9: "tab"
	10: "return"
	13: "return"
	16: "shift"
	17: "ctrl"
	18: "alt"
	19: "pause"
	20: "capslock"
	27: "esc"
	32: "space"
	33: "pageup"
	34: "pagedown"
	35: "end"
	36: "home"
	37: "left"
	38: "up"
	39: "right"
	40: "down"
	45: "insert"
	46: "del"
	59: ";"
	61: "="
	96: "0"
	97: "1"
	98: "2"
	99: "3"
	100: "4"
	101: "5"
	102: "6"
	103: "7"
	104: "8"
	105: "9"
	106: "*"
	107: "+"
	109: "-"
	110: "."
	111: "/"
	112: "f1"
	113: "f2"
	114: "f3"
	115: "f4"
	116: "f5"
	117: "f6"
	118: "f7"
	119: "f8"
	120: "f9"
	121: "f10"
	122: "f11"
	123: "f12"
	144: "numlock"
	145: "scroll"
	173: "-"
	186: ";"
	187: "="
	188: ","
	189: "-"
	190: "."
	191: "/"
	192: "`"
	219: "["
	220: "\\"
	221: "]"
	222: "'"
}

var shiftNums = {
	"`": "~"
	"1": "!"
	"2": "@"
	"3": "#"
	"4": "$"
	"5": "%"
	"6": "^"
	"7": "&"
	"8": "*"
	"9": "("
	"0": ")"
	"-": "_"
	"=": "+"
	";": ": "
	"'": '"'
	",": "<"
	".": ">"
	"/": "?"
	"\\": "|"
}

def trigger key, o
	if o isa Function
		o = {command: o}
	o:trigger = key
	return o

def combo keys, o
	o = {command: o} if o isa Function
	o:keys = keys
	return o

IM.KeyBindings = [

	combo ['super+z'] do |sel| sel.view.history.undo
	combo ["super+shift+z"] do |sel| sel.view.history.redo
	combo ["super+p"] do |sel| sel.view.history.play

	combo ["super+s"], command: "save"
	combo ["super+b"], command: "run"
	combo ["alt+super+s"], command: "saveSession"
	combo ["alt+shift+l"], command: "reparse"
	combo ["alt+shift+k"], command: "reparseExtent"
	combo ["super+r"], command: "record"

	# combo ["super+l"], native: yes
	
	combo ["super+a"] do |sel| sel.selectAll
	

	combo ['tab']
		context: do |sel| sel.text.indexOf('\n') >= 0
		command: do |sel|
			sel.expandToLines
			var region = sel.region
			var nodes = sel.view.nodesInRegion(region)

			nodes.map do |match|
				if match:node.matches('._imnewline')
					console.log 'found tab in selection',match
					unless match:mode == 'start'
						match:node.indent
			sel.dirty



	combo ["shift+tab"]
		context: do |sel| sel.text.indexOf('\n') >= 0
		command: do |sel|
			sel.expandToLines
			var region = sel.region
			var nodes = sel.view.nodesInRegion(region)
			
			nodes.map do |match|
				if match:node.matches('._imnewline') && match:mode != 'start'
					match:node.undent
			sel.dirty

	combo ["shift+tab"]
		context: do |e|
			return true # String(e.view.selection).indexOf('\n') >= 0
		command: do |sel|
			console.log 'try undent'
			return true

	combo ["alt+shift+return"] do |sel| console.log 'prettify'

	combo ["backspace"]
		context: do |e|
			console.log 'deleteLeftRight backspace?!?',e.region,e.region.peek(-1,1)
			return e.region.peek(-1,1) in ['[]','{}','<>','()','""',"''"]

		command: do |sel|
			console.log 'moving!!'
			sel.expand(-1,1)
			sel.erase

	combo ["backspace"]
		context: do |sel,o|
			let reg = sel.region
			if reg.size == 0 
				if o:node = reg.prevNode('._impair,._imstr')
					return yes

		command: do |sel,o| sel.region = o:node.region.clone.reverse
	
	combo ["backspace"]
		context: do |sel,o|
			if sel.text and !util.stringIsBalanced(sel.text)
				return yes
		command: do |sel,o| yes # noop

	combo ["backspace"] do |sel| sel.erase
	combo ["shift+backspace"] do |sel| sel.erase
	combo ["alt+backspace"] do |sel| sel.erase(IM.WORD_START)
	combo ["super+backspace"] do |sel| sel.erase(IM.LINE_START)
	
	combo ["return",'shift+return','super+return'] do |sel|
			var ind = sel.indent
			ind += '\t' if util.increaseIndent(sel.head.peekbehind)

			# should not happen in string
			if sel.region.peek(-1,1) in ['[]','{}','()']
				sel.insert('\n\t' + ind)
				sel.view.insert(sel.head.loc,'\n' + ind)
			else
				sel.insert('\n' + ind)

			return yes


	combo ['space','shift+space'] do |sel|
		if sel.region.peek(-1,1) == '<>'
			sel.move(1).erase

		sel.insert(' ')

	combo ['tab'] do |sel| sel.insert('\t')


	combo ['super+up'] do |sel|
		sel.collapse.head.set(0,0).normalize
		sel.dirty

	combo ['super+down'] do |sel|
		sel.collapse.head.set(100000,0).normalize
		sel.dirty

	combo ['super+u'] do |sel,o|
		console.log sel.target, "found ut!!!"
		console.log sel.target.bubble('unwrap',{})

	combo ['alt+super+r'] do window:location.reload
]

IM.Triggers = [

	trigger '|'
		context: do |sel| sel.region.peek(-1,1) == '||'
		command: do |sel| sel.move(1) # override to do nothing

	trigger '[' do |sel| sel.insert('[$0]')
	trigger '|' do |sel| sel.insert('|$0|')
	trigger '(' do |sel| sel.insert('($0)')
	trigger '{' do |sel| sel.insert('{$0}')

	trigger '<'
		context: do |sel| !sel.peekbehind(/(\b(tag|if|class) |\d\s*$)/)
		command: do |sel| sel.insert('<$0>')

	trigger '"'
		context: do |sel,o| 
			if sel.region.peek(-1,0) == '\\' and o:node = sel.region.scope(%imstr)
				true
		command: do |sel| sel.insert('"')

	trigger "'"
		context: do |sel,o| sel.region.peek(-1,1) == "''"
		command: do |sel| sel.move(1)

	trigger "'"
		context: do |sel,o| o:node = sel.region.scope(%imstr)
		command: do |sel| sel.insert("\\'")

	trigger '"' do |sel| sel.insert('"$0"')
	trigger "'" do |sel| sel.insert("'$0'")
	
	trigger ']'
		context: do |sel| sel.region.peek(0,1) == ']'
		command: do |sel| sel.move(1) # override to do nothing

	trigger '}'
		context: do |sel| sel.region.peek(0,1) == '}'
		command: do |sel| sel.move(1) # override to do nothing

	trigger ')'
		context: do |sel| sel.region.peek(0,1) == ')'
		command: do |sel| sel.move(1) # override to do nothing
]

global class ShortcutManager
	
	def initialize view, bindings
		@view = view
		@bindings = bindings or IM.KeyBindings
		self

	def view
		@view

	def keysForEvent e
		var combo = []
		var special = specialKeys[e:which]
		var chr = special or String.fromCharCode(e:which)
		
		chr = chr.toLowerCase # unless e:shiftKey

		combo.push('ctrl') if e:ctrlKey and special != 'ctrl'
		combo.push('alt') if e:altKey and special != 'alt'
		combo.push('super') if e:metaKey && !e:ctrlKey && special !== 'meta'
		combo.push('shift') if e:shiftKey and special != 'shift'
		combo.push(chr) unless combo.indexOf(chr) >= 0

		return combo.join('+')

	def commandsForKeys combo
		@bindings.filter(|binding| binding:keys == combo)

	def getShortcut e
		var combo = keysForEvent(e.event)
		console.log combo

		for cmd in @bindings
			if cmd:keys.indexOf(combo) >= 0
				var o = {}
				# console.log 'found shortcut',combo,cmd:keys
				if !cmd:context or cmd:context.call(view,view.caret,o,e,view)
					cmd:data = o
					return cmd

		return null

	def getTrigger view, text
		for cmd in IM.Triggers
			if cmd:trigger == text
				var res = cmd:context ? cmd:context.call(view,view.caret,view,text) : yes
				return cmd if res
		return null




		