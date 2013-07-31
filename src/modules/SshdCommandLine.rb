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
# File:	modules/SshdCommandLine.ycp
# Package:	Configuration of SSHD
# Summary:	SSHD CommandLine functions
# Authors:	Lukas Ocilka <locilka@suse.cz>
#
# CommandLine functions for SSHD Configuration
require "yast"

module Yast
  class SshdCommandLineClass < Module
    def main
      textdomain "sshd"

      Yast.import "Sshd"
      Yast.import "String"
      Yast.import "CommandLine"
    end

    def CMDLinePorts(options)
      options = deep_copy(options)
      Builtins.y2milestone("%1", options)
      ports = Sshd.GetSSHDOption("Port")

      if Ops.get(options, "show") != nil
        CommandLine.Print(String.UnderlinedHeader(_("SSHD Server Ports:"), 0))
        CommandLine.Print("")

        CommandLine.Print(
          String.TextTable([_("Port")], Builtins.maplist(ports) { |port| [port] }, {})
        )
        return false
      elsif Ops.get(options, "add") != nil
        port_nr = Builtins.tointeger(Ops.get_string(options, "add", ""))
        if port_nr == nil
          CommandLine.Print(
            Builtins.sformat(
              "Invalid port number definition '%1'",
              Ops.get_string(options, "add", "")
            )
          )
          return false
        end

        ports = Builtins.toset(
          Builtins.add(ports, Ops.get_string(options, "add", ""))
        )
        return Sshd.SetSSHDOption("Port", ports)
      elsif Ops.get(options, "remove") != nil
        port_nr = Builtins.tointeger(Ops.get_string(options, "remove", ""))
        if port_nr == nil
          CommandLine.Print(
            Builtins.sformat(
              "Invalid port number definition '%1'",
              Ops.get_string(options, "remove", "")
            )
          )
          return false
        end

        ports = Builtins.filter(ports) do |one_port|
          one_port != Ops.get_string(options, "remove", "")
        end
        return Sshd.SetSSHDOption("Port", ports)
      end

      nil
    end

    publish :function => :CMDLinePorts, :type => "boolean (map)"
  end

  SshdCommandLine = SshdCommandLineClass.new
  SshdCommandLine.main
end
