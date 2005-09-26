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
## File:      javaprog.rb
## Created:   Sun Sep 25 11:29:12 IST 2005
## Author:    Andrew S. Townley <adz1092@yahoo.com>
##
## $Id: javaprog.rb,v 1.1 2005/09/26 01:52:56 atownley Exp $
##
######################################################################

require 'fqa/program'
require 'fqa/open3'

module FunctionalQA

  # This class is used to encapsulate the compilation and
  # execution of a stand-alone Java application.  At the
  # moment, this class is pretty "down & dirty" because I'm in
  # a bit of a hurry...  I'll come back to it when I get a
  # chance.

  class JavaProg < Program
    # This method attempts to compile the prog.  Any extra
    # compiler arguments may be passed in.

    def compile(*args)
      # build the compile command
      cmd = []
      cmd << find_javac
      cmd.concat(args) if args != nil
      cmd << name.gsub("\.", "\/") + ".java"

      javac_in, javac_out, javac_err = Open3.popen3(cmd.join(" "))
      javac_in.close
      @compile_out = javac_out.readlines
      @compile_err = javac_err.readlines
      $?.exitstatus
    end

    # This method executes the prog, passing in any
    # command-line arguments.  It returns the return code of
    # the prog

    def execute(*args)
      cmd = []
      cmd << find_java
      cmd << name
      cmd.concat(args) if args != nil

      prog_in, prog_out, prog_err = Open3.popen3(cmd.join(" "))
      prog_in.close
      @execute_out = prog_out.readlines
      @execute_err = prog_err.readlines
      $?.exitstatus
    end

  private
    def java_home
      javahome = ENV["JAVA_HOME"];
      
      if javahome == nil
        raise "error:  unable to find JAVA_HOME"
      end
      
      javahome
    end

    def find_javac
      javac = "#{java_home}/bin/javac"
      if !File.exist?(javac)
        raise "error:  unable to find Java compiler"
      end

      javac
    end

    def find_java
      java = "#{java_home}/bin/java"
      if !File.exist?(java)
        raise "error:  unable to find Java Virtual Machine"
      end

      java
    end
  end
end
