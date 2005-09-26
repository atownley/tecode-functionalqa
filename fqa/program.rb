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
## File:      program.rb
## Created:   Sun Sep 25 17:36:57 IST 2005
## Author:    Andrew S. Townley <adz1092@yahoo.com>
##
## $Id: program.rb,v 1.1 2005/09/26 01:52:55 atownley Exp $
##
######################################################################

module FunctionalQA

  class CompileException < Exception
    def initialize(rc, output, errors)
      super("Compile failed (exit code #{rc}).")
      @rc, @output, @errors = rc, output, errors
    end

    def to_s
      s = super << " "
      s << @errors.join("\n")
    end
  end

  # This class provides some common utility methods for
  # dealing with external programs under test.  Specific
  # subclasses exist for programs in various languages that
  # know how to compile and execute themselves.

  class Program
    def initialize(name, build = true)
      @name = name
      @build = build
      @compile_out = []
      @execute_out = []
      @compile_err = []
      @execute_err = []
      @compiled = false
    end

    def output
      @execute_out
    end

    def errors
      @execute_err
    end

    def compile_output
      @compile_out
    end

    def compile_errors
      @compile_err
    end

    def compile?
      @build
    end

    # This method should be overridden to take whatever steps
    # are necessary to compile the program.

    def compile(*args)
puts "barf"
      -1 
    end

    # This method should be overridden to take whatever steps
    # are necessary to execute the program.

    def execute(*args)
      -10
    end

    # This method is used to run the program.  If the program
    # needs to be compiled, it is first compiled and then run
    # according to the type of program that it is.  Note that
    # this compile cannot take any arguments.  It is assumed
    # that any arguments necessary will be provided by the
    # specific class or the external environment.  To specify
    # compilation environments directly, use the compile
    # method directly.

    def run(*args)
      if compile? && !@compiled
        rc = compile
        @compiled = true if rc == 0
        if(rc != 0)
          raise CompileException.new(rc, @compile_out, @compile_err)
        end
      end

      execute(args)
    end

    attr_reader :name
  end
end
