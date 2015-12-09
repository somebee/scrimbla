IMDEBUG = yes

# wtf er alt dette?
IM = {}
IM.NEWLINE = '\n'
IM.CHAR = 0
IM.WORD_START = 1
IM.WORD_END = 2
IM.PUNCTUATION_START = 3
IM.PUNCTUATION_END = 4
IM.SUB_WORD_START = 5
IM.SUB_WORD_END = 6
IM.LINE_START = 7
IM.LINE_END = 8
IM.EMPTY_LINE = 9

IM.FS = require './core/fs'

var SourceMap = require 'source-map'

# if global:require
import Region from "./region"

require './helpers'

require './core/history'
require './core/logger'
require './core/shortcuts'

require "./views/captor"
require "./view"
require "./editor"

import Highlighter from "./core/highlighter"
import ImbacWorker from "./core/worker"

def IM.worker
	@worker ||= ImbacWorker.new

export var util = require './core/util'
# nodes
require "./nodes/index"


export def worker
	IM.worker

export SourceMap
export Region
export Highlighter