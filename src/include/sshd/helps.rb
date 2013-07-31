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
# File:	include/sshd/helps.ycp
# Package:	Configuration of sshd
# Summary:	Help texts of all the dialogs
# Authors:	Lukas Ocilka <locilka@suse.cz>
module Yast
  module SshdHelpsInclude
    def initialize_sshd_helps(include_target)
      textdomain "sshd"

      # All helps are here
      @HELPS = {
        # Read dialog help
        "read"                 => _(
          "<p><b><big>Initializing the sshd Configuration</big></b><br>\n</p>\n"
        ),
        # Write dialog help
        "write"                => _(
          "<p><b><big>Saving the sshd Configuration</big></b><br>\n</p>\n"
        ),
        # Server Configuration dialog help
        "server_configuration" => _(
          "<p><b><big>Server Configuration</big></b><br>\nConfigure SSHD here.<br></p>"
        ),
        # Login Settings dialog help 1
        "login_settings"       => _(
          "<p><b><big>Login Settings</big></b><br>\n" +
            "Here you can configure the SSHD login and authentication settings.\n" +
            "Some apply to a particular protocol version only.</p>"
        ) +
          # Login Settings dialog help 2, text taken from sshd_config manpage
          _(
            "<p><b>Print Message of the Day After Login</b>\n" +
              "Specifies whether sshd should print /etc/motd when\n" +
              "a user logs in interactively.</p>"
          ) +
          # Login Settings dialog help 3, text taken from sshd_config manpage
          _(
            "<p><b>Permit Root Login</b><br>\nSpecifies whether root can log in using ssh.</p>"
          ) +
          # Login Settings dialog help 4, text taken from sshd_config manpage
          _(
            "<p><b>Maximum Authentication Tries</b><br>\n" +
              "Specifies the maximum number of authentication attempts permitted per connection.\n" +
              "Once the number of failures reaches half this value, additional failures are logged.</p>"
          ) +
          # Login Settings dialog help 5, text taken from sshd_config manpage
          _(
            "<p><b>RSA Authentication</b><br>\n" +
              "Specifies whether pure RSA authentication is allowed.\n" +
              "This option applies to protocol version 1 only.</p>"
          ) +
          # Login Settings dialog help 6, text taken from sshd_config manpage
          _(
            "<p><b>Public Key Authentication</b><br>\n" +
              "Specifies whether public key authentication is allowed.\n" +
              "This option applies to protocol version 2 only.</p>"
          ),
        # Protocol and Cipher Settings dialog help
        "proto_settings"       => _(
          "<p><b><big>Protocol and Cipher Settings</big></b><br>\nConfigure SSHD protocol version and cipher settings.<br></p>\n"
        )
      }
    end
  end
end
