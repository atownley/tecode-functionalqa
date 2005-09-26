#--
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
## File:      testrunner.rb
## Created:   Sun Sep 25 13:01:46 IST 2005
## Author:    Andrew S. Townley <adz1092@yahoo.com>
##
## $Id: testrunner.rb,v 1.1 2005/09/26 01:52:56 atownley Exp $
##
######################################################################
#++

require 'test/unit/assertions'
require 'fqa/observer'

# Note:  this module is similar to, but very different in
# organization and intent than the standard Ruby Test::Unit by
# Nathaniel Talbott.  It does leverage his work wherever there
# is an overlap, but it is normally at the lower levels of the
# system, like the assertion methods, for example.

module FunctionalQA

  # This class represents a collection of test cases to be run
  # which are related in some way.  Individual test cases are
  # just methods which start with "testcase" and normally take
  # no arguments.

  class TestScript
    include ::Test::Unit::Assertions

    # The only required parameter is a name which is used to
    # identify the test script to a human.

    def initialize(name)
      @name = name
      @logger = nil
    end

    # This method is used to collect the names of all of the
    # test cases in the script.  It would be handy to have the
    # annotation stuff from C# or Tiger here...

    def get_tests
      methods = public_methods(true)
      methods.delete_if { |m| m !~ /^testcase./ }
    end

    def log_warning(message)
      @logger.log_warning(message) if @logger
    end

    def log_error(message)
      @logger.log_error(message) if @logger
    end

    attr_reader   :name
    attr_accessor :logger
  end

  # This class implements the Controller pattern for executing
  # tests.  It supports a pluggable Observer instance which is
  # notified of certain "interesting" events as they are about
  # to happen.

  class TestRunner
    def initialize
      @observer = DefaultTestObserver.new
    end

    # This method is used to execute the specific test script

    def run(test_script)
      test_script.logger = observer
      notify("script_enter", test_script)

      test_script.get_tests.each do |test|
        notify("testcase_enter", test_script, test)
        begin
          run_test(test_script, test)
          notify("testcase_exit", test_script, test)
        rescue Exception => e
          notify("testcase_exit", test_script, test, e)
        end
      end

      notify("script_exit", test_script)
      test_script.logger = nil
    end

    # This method is pulled out here because other test
    # runners may wish to provide specific arguments to test
    # cases.  If this is true, all that needs to be done is
    # override this method and it still fits nicely into the
    # rest of the framework.

    def run_test(test_script, test)
      test_script.send(test)
    end

    attr_accessor :observer
  private
    def notify(event, *args)
      return if @observer == nil
      
      @observer.send(event, *args)
    end
  end

  # This class provides a specialized test runner which is
  # used to easily provide functional regression tests for an
  # external command.

  class ProgramTestRunner < TestRunner
    def initialize(prog)
      super()
      @prog = prog
    end

    def run_test(test_script, test)
      test_script.send(test, @prog)
    end
  end
end
