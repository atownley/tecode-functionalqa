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
## File:      observer.rb
## Created:   Sun Sep 25 18:00:58 IST 2005
## Author:    Andrew S. Townley <adz1092@yahoo.com>
##
## $Id: observer.rb,v 1.1 2005/09/26 01:52:56 atownley Exp $
##
######################################################################

require 'fqa/stats'
require 'fqa/util'

module FunctionalQA

  class ConsoleDelegate
    def initialize
      @verbose = false
    end

    def log_error(message)
      puts "#{fmt_time(message.timestamp)} *** Error: #{message.obj}" if verbose
    end

    def log_warning(message)
      puts "#{fmt_time(message.timestamp)} *** Warning: #{message.obj}" if verbose
    end

    def script_enter(stats)
      puts "#{fmt_time(stats.started)} Script \'#{stats.name}\' started." if verbose
    end

    def script_exit(stats)
      if verbose
        print "#{fmt_time(stats.stopped)} Script \'#{stats.name}\' exited with "
        puts "#{stats.errors.length} errors, #{stats.warnings.length} warnings in #{stats.elapsed} seconds."
      else
        if stats.passed?
          status = "passed"
        else
          status = "failed"
        end
        puts "\nScript \'#{stats.name}\' #{status}. "
      end

      # if we failed, print the failures
      count = 0
      stats.test_results.each do |tr|
        if !tr.passed?
          count = count + 1
          print_failure(count, tr)
        end
      end

      # print some summary information
      testcount = stats.total
      pct = ((stats.passed * 1.0) / testcount) * 100
      print "#{testcount} tests run, #{stats.passed} passed, #{stats.failed} failed (%0.0f%% passed)" % (pct)

      if verbose
        puts ""
      else
        puts ". Time:  #{stats.elapsed} seconds."
      end
    end

    def testcase_enter(stats)
      puts "#{fmt_time(stats.started)} Testcase #{stats.name} started." if verbose
    end

    def testcase_exit(stats)
      if verbose
        print "#{fmt_time(stats.stopped)} Testcase #{stats.name} exited with "
        puts "#{stats.errors.length} errors, #{stats.warnings.length} warnings in #{stats.elapsed} seconds."
      else
        if stats.passed?
          print "."
        else
          print "F"
        end
      end
    end

    attr_accessor :verbose
  private
    def fmt_time(timestamp)
      timestamp.strftime("%Y-%m-%d %H:%M:%S")
    end

    def print_failure(count, stats)
      puts "\n  #{count}) Testcase \'#{stats.name}\' failed."
      stats.errors.each { |err| puts "\t" << err.obj }
      puts ""
    end
  end

  # This class provides the default implementation of the test
  # execution observer.  It's main job is to collect test
  # statistics during the test run.

  class DefaultTestObserver
    def initialize
      @map = {}
      @delegate = ConsoleDelegate.new
    end

    def script_enter(test_script)
      stats = @map[test_script] = ScriptStats.new(test_script.name)
      @delegate.script_enter(stats)
      stats.delegate = @delegate
    end

    def testcase_enter(test_script, test_name)
      stats = @map[test_name] = TestStats.new(test_name)
      @delegate.testcase_enter(stats)
      stats.delegate = @delegate
    end

    def testcase_exit(test_script, test_name, exception = nil)
      stats = @map[test_name]
      if exception
        if exception.class == ::Test::Unit::AssertionFailedError
          msg = exception.message.gsub("\n", " ")
          msg << "#{Util::print_backtrace(exception, true)})"
          stats.log_error(msg)
        else
          stats.log_error(Util::print_exception(exception)) if exception
        end
      end
      stats.stop
      @map[test_script].record_test(stats)
      @delegate.testcase_exit(stats)
    end

    def script_exit(test_script, exception = nil)
      stats = @map[test_script]
      stats.log_error(Util::print_exception(exception)) if exception
      stats.stop
      @delegate.script_exit(stats)
    end

    def verbose
      delegate.verbose
    end

    def verbose=(val)
      delegate.verbose = val
    end

    attr_accessor :delegate
  end

end
