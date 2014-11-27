# -*- coding: utf-8 -*-
$LOAD_PATH << File.expand_path('../lib', __FILE__)

require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
end
