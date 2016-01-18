import Region from '../region'


export def isWhitespace str
	(/^[\n\t\ ]+$/).test(str)

export def commonAncestor a,b
	if a isa Array
		var arr = a.slice
		return arr.reduce(&,arr.shift) do |prev,curr,i|
			commonAncestor(prev,curr)

	return (a or b) if !a or !b

	a = a.@dom or a
	b = b.@dom or b

	a = a:parentNode until a.contains(b)
	b = b:parentNode until b.contains(a)

	return tag(a)


var pairs =
	'"': '"'
	"'": "'"
	'(': ')'
	'<': '>'
	'[': ']'
	'{': '}'

export def wrapText text, open, close
	close ||= pairs[open]
	text = text.replace(/\'/g,"\\'") if open == "'"
	(open or '') + text + (close or '')

export def normalizeNewlines str
	if str.indexOf('\r\n') >= 0
		return str.replace(/\r\n/g,'\n')
	return str

export def stringIsBalanced str
	var opens = '[{("\''
	var closes = ']})"\''
	var stack = []
	var i = 0
	var s,end

	while s = str[i++]
		var oid = opens.indexOf(s)

		if s == end
			stack.pop
			end = stack[stack:length - 1]
		elif oid >= 0
			stack.push(end = closes[oid])

	return stack:length == 0 ? true : false

export def colToLoc line, col, tabsize = 4
	var ci = 0
	var rci = 0 # real column
	var char

	return 0 if col == 0

	while char = line[ci++]
		if char == '\t'
			var rest = tabsize - rci % tabsize
			rci += rest
		else
			rci += 1

		if rci >= col
			return ci

	return line:length

export def colToViewCol line, col, tabsize = 4
	var ci = 0
	var rci = 0 # real column
	var char

	return 0 if col == 0

	while char = line[ci++]
		if char == '\t'
			var rest = tabsize - rci % tabsize
			break if rest > 3 and col <= rci + 2
			rci += rest
		else
			rci += 1

		break if col <= rci
	return rci

export def colsForLine line, tabsize = 4
	var col = 0
	var idx = 0
	var char
	while char = line[idx++]
		if char == '\t'
			var rest = tabsize - col % tabsize
			col += rest
		else
			col += 1
	return col

export def rowcol buf, loc, tabsize = 4
	buf = buf.toString
	var pos = loc
	var col = 0
	var line = 0
	var char

	# go back to start of line
	while char = buf[pos - 1]
		if char == '\n'
			break
		pos--

	# get column for slice
	while (pos < loc) and char = buf[pos]
		if char == '\t'
			var rest = tabsize - (col % tabsize)
			col += rest
		else
			col += 1
		pos++

	while char = buf[pos - 1]
		if char == '\n'
			line++
		pos--

	return [line,col]

export def increaseIndent str
	var reg = /^(\s*(.*\=\s*)?(export |global |extend )?(class|def|tag|unless|if|else|elif|switch|try|catch|finally|for|while|until|do))/
	var other = /\b(do)\b/
	reg.test(str) or other.test(str)


export def repeatString str, count
	return Array.new( count + 1 ).join( str )


export def patchString orig, str, mode
		var text = orig.toString

		if mode == 'append'
			return text + str
		elif mode == 'prepend'
			return "" + str + text
		else
			if let region = Region.normalize(mode)
				# let region = Region.normalize()
				text.substr(0,region.start) + str + text.slice(region.end)


