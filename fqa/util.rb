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
## File:      util.rb
## Created:   Sun Sep 25 18:00:58 IST 2005
## Author:    Andrew S. Townley <adz1092@yahoo.com>
##
## $Id: util.rb,v 1.1 2005/09/26 01:52:55 atownley Exp $
##
######################################################################

module FunctionalQA

  # This is a very simple stopwatch class to use to monitor
  # elapsed time of an event.

  class Stopwatch

    # To not automatically start the timer, pass in a value of
    # false to the new method.

    def initialize(autostart = true)
      @started = nil
      @stopped = nil

      start if autostart
    end

    def start
      @stopped = nil
      @started = Time.now
    end

    def stop
      @stopped = Time.now
    end

    def lap
      Time.now - @started
    end

    def elapsed
      @stopped - @started
    end

    attr_reader :started, :stopped
  end

  # This class is a simple decorator which associates a
  # specific time value with the object to be decorated

  class TimestampDecorator
    def initialize(obj)
      @timestamp = Time.now
      @obj = obj
    end

    def to_s
      "#{@timestamp} #{obj}"
    end

    attr_reader :obj, :timestamp
  end
end

module Util
  def Util::print_exception(e, local = false)
    msg = "#{e.class}:  #{e} "
    msg << print_backtrace(e, local)
  end

  def Util::print_backtrace(e, local = false)
    msg = ""
    if local
      e.backtrace.each do |sf| 
        msg << "\n\tfrom #{sf}" if sf.to_s !~ /^\// && sf.to_s !~ /\.\.\//
      end
    else
      msg << "\n\tfrom " << e.backtrace.join("\n\tfrom ")
    end
    msg
  end
end
