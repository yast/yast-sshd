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
# File:	clients/sshd.ycp
# Package:	Configuration of sshd
# Summary:	Main file
# Authors:	Lukas Ocilka <locilka@suse.cz>
#
# Main file for sshd configuration. Uses all other files.
module Yast
  class SshdClient < Client
    def main
      Yast.import "UI"

      #**
      # <h3>Configuration of sshd</h3>

      textdomain "sshd"

      # The main ()
      Builtins.y2milestone("----------------------------------------")
      Builtins.y2milestone("Sshd module started")

      Yast.import "Progress"
      Yast.import "Report"
      Yast.import "Summary"
      Yast.import "SshdCommandLine"

      Yast.import "CommandLine"
      Yast.include self, "sshd/wizards.rb"

      @cmdline_description = {
        "id"         => "sshd",
        # Command line help text for the Xsshd module
        "help"       => _(
          "Configuration of sshd"
        ),
        "guihandler" => fun_ref(method(:SshdSequence), "any ()"),
        "initialize" => fun_ref(Sshd.method(:Read), "boolean ()"),
        "finish"     => fun_ref(Sshd.method(:Write), "boolean ()"),
        "actions"    => {
          "ports" => {
            "handler" => fun_ref(
              SshdCommandLine.method(:CMDLinePorts),
              "boolean (map)"
            ),
            # TRANSLATORS: CommandLine help
            "help"    => _(
              "Ports used by SSHD Server"
            ),
            "example" => ["ports show", "ports add=512", "ports remove=22"]
          }
        },
        "options"    => {
          "show"   => {
            # TRANSLATORS: CommandLine help
            "help" => _("Show current settings")
          },
          "add"    => {
            "type" => "string",
            # TRANSLATORS: CommandLine help
            "help" => _("Add a new record")
          },
          "remove" => {
            "type" => "string",
            # TRANSLATORS: CommandLine help
            "help" => _("Remove a record")
          }
        },
        "mappings"   => { "ports" => ["show", "add", "remove"] }
      }

      # main ui function
      @ret = nil

      @ret = CommandLine.Run(@cmdline_description)
      Builtins.y2debug("ret=%1", @ret)

      # Finish
      Builtins.y2milestone("Sshd module finished")
      Builtins.y2milestone("----------------------------------------")

      deep_copy(@ret)
    end
  end
end

Yast::SshdClient.new.main
