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
## File:      stats.rb
## Created:   Sun Sep 25 18:13:19 IST 2005
## Author:    Andrew S. Townley <adz1092@yahoo.com>
##
## $Id: stats.rb,v 1.1 2005/09/26 01:52:55 atownley Exp $
##
######################################################################

require 'fqa/util'

module FunctionalQA

  class TestStats
    def initialize(name)
      @delegate = nil
      @name = name
      @timer = Stopwatch.new(false)
      @started = nil
      @stopped = nil
      @warnings = []
      @errors = []
      start
    end

    def start
      @timer.start
    end

    def stop
      @timer.stop
    end

    def started
      @timer.started
    end

    def stopped
      @timer.stopped
    end

    def elapsed
      @timer.elapsed
    end

    def passed?
      @errors.length == 0
    end

    def log_warning(message)
      item = TimestampDecorator.new(message)
      @warnings << item
      @delegate.log_warning(item) if @delegate
    end

    def log_error(message)
      item = TimestampDecorator.new(message)
      @errors << item
      @delegate.log_error(item) if @delegate
    end

    attr_accessor :name, :warnings, :errors, :delegate
  end

  class ScriptStats < TestStats
    def initialize(*args)
      super
      @teststats = []
    end

    def record_test(stats)
      @teststats << stats
      @errors.concat(stats.errors)
      @warnings.concat(stats.warnings)
    end

    def test_statistics
      @teststats
    end

    def passed
      passed = @teststats.length
      @teststats.each { |ts| passed = passed -1 if ts.errors.length != 0 }
      passed
    end

    def failed
      @teststats.length - passed
    end

    def total
      @teststats.length
    end

    def test_results
      @teststats
    end
  end
end
