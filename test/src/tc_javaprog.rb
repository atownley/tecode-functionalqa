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
## File:      tc_javaprog.rb
## Created:   Sun Sep 25 11:29:12 IST 2005
## Author:    Andrew S. Townley <adz1092@yahoo.com>
##
## $Id: tc_javaprog.rb,v 1.1 2005/09/26 01:52:52 atownley Exp $
##
######################################################################

$:.unshift File.join(File.dirname(__FILE__), "../..")

require 'test/unit'
require 'fqa/javaprog'

TESTSRCDIR = "../data"

class TestJavaProg < Test::Unit::TestCase
  def setup
    Dir.chdir(TESTSRCDIR)
    class_files = Dir.glob("*.class")
    class_files.each { |f| File.delete(f) }
  end

  def test_clean_compile
    jtc = FunctionalQA::JavaProg.new("clean")
    assert_equal(0, jtc.compile, "compilation successful")
    assert_equal(0, jtc.execute, "execution successful")
    assert_equal("Hello, world!\n", jtc.output[0])
  end

  def test_execute_exit_code
    jtc = FunctionalQA::JavaProg.new("exit100")
    assert_equal(0, jtc.compile, "compilation successful")
    assert_equal(100, jtc.execute, "execution returns 100")
  end

  def test_execute_args
    jtc = FunctionalQA::JavaProg.new("echoarg")
    assert_equal(0, jtc.compile, "compilation successful")
    assert_equal(0, jtc.execute(%w( arg1 arg2 arg3)),
        "execution successful")
    assert_equal("arg1\n", jtc.output[0])
    assert_equal("arg2\n", jtc.output[1])
    assert_equal("arg3\n", jtc.output[2])
  end

  def test_execute_errarg
    jtc = FunctionalQA::JavaProg.new("errarg")
    assert_equal(0, jtc.compile, "compilation successful")
    assert_equal(3, jtc.execute(%w( arg1 arg2 arg3)),
        "execution successful")
    assert_equal("arg1\n", jtc.errors[0])
    assert_equal("arg2\n", jtc.errors[1])
    assert_equal("arg3\n", jtc.errors[2])
  end

  def test_compile_error
    jtc = FunctionalQA::JavaProg.new("compile_error")
    assert_not_equal(0, jtc.compile)
    assert_equal("compile_error.java:50: ';' expected\n", jtc.compile_errors[0])
    assert_equal("\t}\n", jtc.compile_errors[1])
    assert_equal("        ^\n", jtc.compile_errors[2])
    assert_equal("1 error\n", jtc.compile_errors[3])
  end
end
