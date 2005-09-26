#! /usr/bin/env ruby
######################################################################
##
## Copyright (c) 2005, Andrew S. Townley
## All rights reserved.
## 
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions
## are met:
## 
##     * Redistributions of source code must retain the above
##     copyright notice, this list of conditions and the following
##     disclaimer.
## 
##     * Redistributions in binary form must reproduce the above
##     copyright notice, this list of conditions and the following
##     disclaimer in the documentation and/or other materials provided
##     with the distribution.
## 
##     * Neither the names Andrew Townley or Townley Enterprises,
##     Inc. nor the names of its contributors may be used to endorse
##     or promote products derived from this software without specific
##     prior written permission.  
## 
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
## "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
## LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
## FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
## COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
## INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
## (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
## SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
## HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
## STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
## ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
## OF THE POSSIBILITY OF SUCH DAMAGE.
##
## File:      demo1.rb
## Created:   Sun Sep 25 15:49:45 IST 2005
## Author:    Andrew S. Townley <adz1092@yahoo.com>
##
## $Id: demo1.rb,v 1.1 2005/09/26 01:52:55 atownley Exp $
##
######################################################################

$:.unshift File.join(File.dirname(__FILE__), "..")

require 'fqa/fqa'

TESTSRCDIR = "../test/data"

class RegressionTests < FunctionalQA::TestScript
  def initialize
    super("Demonstration regression tests")
    Dir.chdir(TESTSRCDIR)
  end

  def testcase1(prog)
    rc = prog.run(%w( one two three four ))
    assert_equal(4, rc, "supplied 4 arguments")
    assert_equal("one", prog.errors[0].chomp)
    assert_equal("two", prog.errors[1].chomp)
    assert_equal("three", prog.errors[2].chomp)
    assert_equal("four", prog.errors[3].chomp)
  end

  def testcase2(prog)
    rc = prog.run
    assert_equal(0, rc)
  end

  # this is intentionally broken...
  def testcase3(prog)
    rc = prog.run("blah")
    assert_equal(0, rc, "program should exit normally")
  end
end

# This part hopefully won't be necessary for much longer... it
# really should be totally dynamic like Test::Unit, but I need
# to figure out how to set everything up I need.  For a
# regular test runner, it might be easy, but for the program
# test runner, it isn't as easy.

runner = FunctionalQA::ProgramTestRunner.new(
    FunctionalQA::JavaProg.new("errarg"))
runner.run(RegressionTests.new)
