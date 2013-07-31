# encoding: utf-8

# ***************************************************************************
#
# Copyright (c) 2000 - 2012 Novell, Inc.
# All Rights Reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of version 2 of the GNU General Public License as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.   See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, contact Novell, Inc.
#
# To contact Novell about this file by physical or electronic mail,
# you may find current contact information at www.novell.com
#
# ***************************************************************************
# File:	clients/sshd_auto.ycp
# Package:	Configuration of sshd
# Summary:	Main file for SSHD in AutoYaST
# Authors:	Lukas Ocilka <locilka@suse.cz>
#
# AutoYaST client for SSHD Configuration
module Yast
  class SshdAutoClient < Client
    def main
      Yast.import "UI"

      #**
      # <h3>Configuration of sshd</h3>

      textdomain "sshd"

      Yast.import "Progress"

      # The main ()
      Builtins.y2milestone("----------------------------------------")
      Builtins.y2milestone("sshd_auto module started")

      Yast.include self, "sshd/wizards.rb"

      @ret = nil
      @func = ""
      @param = {}

      # Checking parameters
      if Ops.greater_than(Builtins.size(WFM.Args), 0) &&
          Ops.is_string?(WFM.Args(0))
        @func = Convert.to_string(WFM.Args(0))
        if Ops.greater_than(Builtins.size(WFM.Args), 1) &&
            Ops.is_map?(WFM.Args(1))
          @param = Convert.to_map(WFM.Args(1))
        end
      end
      Builtins.y2milestone("Running: %1", @func)

      # All needed functions
      case @func
        when "Summary"
          @ret = Sshd.Summary
        when "Reset"
          @orig = Progress.set(false)
          @ret = Sshd.Read
          Progress.set(@orig)
        when "Change"
          @ret = SshdAutoSequence()
          Builtins.y2milestone("ret: %1", @ret)
          Sshd.SetModified if @ret == :next
        when "Import"
          @ret = Sshd.Import(@param)
        when "Read"
          @orig1 = Progress.set(false)
          @ret = Sshd.Read
          Progress.set(@orig1)
        when "Export"
          @ret = Sshd.Export
        when "GetModified"
          @ret = Sshd.GetModified
        when "SetModified"
          Sshd.SetModified
        when "Write"
          @orig2 = Progress.set(false)
          @ret = Sshd.Write
          Progress.set(@orig2)
        else
          Builtins.y2error("Unknown function: %1, Params %2", @func, @param)
      end

      # Finish
      Builtins.y2debug("ret=%1", @ret)
      Builtins.y2milestone("sshd_auto module finished")
      Builtins.y2milestone("----------------------------------------")

      deep_copy(@ret)
    end
  end
end

Yast::SshdAutoClient.new.main
