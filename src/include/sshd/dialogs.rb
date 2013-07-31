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
# File:	include/sshd/dialogs.ycp
# Package:	Configuration of sshd
# Summary:	Dialogs definitions
# Authors:	Lukas Ocilka <locilka@suse.cz>
#
# $Id: dialogs.ycp 13879 2004-02-05 11:29:30Z jtf $
module Yast
  module SshdDialogsInclude
    def initialize_sshd_dialogs(include_target)
      Yast.import "UI"

      textdomain "sshd"

      Yast.import "Label"
      Yast.import "Wizard"
      Yast.import "Sshd"

      Yast.include include_target, "sshd/helps.rb"

      @current_ui_settings = UI.GetDisplayInfo

      @mbox_x = 1
      @mbox_y = Convert.convert(0.5, :from => "float", :to => "integer")

      # Tabs have a different layout in textmode
      if Ops.get_boolean(@current_ui_settings, "TextMode", false) == true
        @mbox_x = 0
        @mbox_y = 0
      end
    end

    def ServiceConfigurationDialogContent
      VBox("start_stop", VSpacing(1), "auto_start_up", VStretch())
    end

    def ServerConfigurationDialogContent
      VBox(
        Left(Label(_("SSHD TCP Ports"))),
        Left(
          VBox(
            MinSize(
              40,
              5,
              # A table header
              Table(Id("Port"), Header(_("Port")), [])
            ),
            Left(
              HBox(
                # a push button
                PushButton(Id("add_port"), _("&Add...")),
                # a push button
                PushButton(Id("edit_port"), _("&Edit...")),
                # a push button
                PushButton(Id("delete_port"), _("&Delete"))
              )
            ),
            VSpacing(1),
            Frame(
              # a dialog frame caption
              _("Server Features"),
              MarginBox(
                @mbox_x,
                @mbox_y,
                VBox(
                  # a check box
                  Left(
                    CheckBox(
                      Id("AllowTcpForwarding"),
                      _("Allow &TCP Forwarding")
                    )
                  ),
                  # a check box
                  Left(
                    CheckBox(Id("X11Forwarding"), _("Allow &X11 Forwarding"))
                  ),
                  # a check box
                  Left(CheckBox(Id("Compression"), _("Allow &Compression")))
                )
              )
            ),
            VSpacing(1),
            "fw",
            VStretch()
          )
        )
      )
    end

    def LoginSettingsDialogContent
      VBox(
        Frame(
          _("General Login Settings"),
          MarginBox(
            @mbox_x,
            @mbox_y,
            VBox(
              # A check box
              Left(
                CheckBox(
                  Id("PrintMotd"),
                  _("Print &Message of the Day after Login")
                )
              ),
              # A check box
              Left(CheckBox(Id("PermitRootLogin"), _("Permi&t Root Login")))
            )
          )
        ),
        VSpacing(1),
        Frame(
          _("Authentication Settings"),
          MarginBox(
            @mbox_x,
            @mbox_y,
            VBox(
              # A text entry
              Left(
                InputField(
                  Id("MaxAuthTries"),
                  _("Ma&ximum Authentication Tries")
                )
              ),
              # BNC #469207
              #		/* A check box */
              #		`Left(`CheckBox (`id("PasswordAuthentication"), _("Pa&ssword Authentication"))),

              # A check box
              Left(
                CheckBox(
                  Id("RSAAuthentication"),
                  _("RSA Authenti&cation (Protocol V. 1 Only)")
                )
              ),
              # A check box
              Left(
                CheckBox(
                  Id("PubkeyAuthentication"),
                  _("Public &Key Authentication (Protocol V. 2 Only)")
                )
              )
            )
          )
        ),
        VStretch()
      )
    end

    def ProtoAndCipherDialogContent
      VBox(
        Frame(
          _("Supported SSH protocol versions"),
          RadioButtonGroup(
            Id(:rb),
            MarginBox(
              @mbox_x,
              @mbox_y,
              VBox(
                Left(RadioButton(Id("SSHv21"), _("&2 and 1"))),
                Left(RadioButton(Id("SSHv2"), _("2 &only"))),
                Left(RadioButton(Id("SSHv1"), _("&1 only")))
              )
            )
          )
        ),
        HBox(
          VBox(
            Left(ComboBox(Id("supported_ciphers"), _("&Supported Ciphers"), [])),
            Table(Id("Ciphers"), Header(_("Cipher")), [])
          ),
          HSquash(
            VBox(
              VSpacing(1.1),
              PushButton(
                Id("add_cipher"),
                Opt(:hstretch),
                Ops.add(Ops.add(" ", Label.AddButton), " ")
              ),
              PushButton(
                Id("remove_cipher"),
                Opt(:hstretch),
                Ops.add(Ops.add(" ", Label.DeleteButton), " ")
              ),
              Empty(Opt(:vstretch))
            )
          )
        ),
        VStretch()
      )
    end
  end
end
