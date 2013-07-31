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
# File:	include/sshd/wizards.ycp
# Package:	Configuration of sshd
# Summary:	Wizards definitions
# Authors:	Lukas Ocilka <locilka@suse.cz>
module Yast
  module SshdWizardsInclude
    def initialize_sshd_wizards(include_target)
      Yast.import "UI"

      textdomain "sshd"

      Yast.import "Sequencer"
      Yast.import "Wizard"
      Yast.import "CWM"
      Yast.import "CWMTab"
      Yast.import "CWMFirewallInterfaces"
      Yast.import "CWMServiceStart"
      Yast.import "Sshd"

      Yast.include include_target, "sshd/complex.rb"
      Yast.include include_target, "sshd/dialogs.rb"
    end

    def SaveAndRestart
      Wizard.CreateDialog
      Wizard.RestoreHelp(Ops.get_string(@HELPS, "write", ""))
      Sshd.Write
      UI.CloseDialog

      nil
    end

    # Main workflow of the sshd configuration
    # @return sequence result
    def MainSequence
      widgets = {
        "sc"            => {
          "widget"        => :custom,
          "help"          => Ops.get_string(@HELPS, "server_configuration", ""),
          "custom_widget" => ServerConfigurationDialogContent(),
          "handle"        => fun_ref(
            method(:HandleServerConfigurationDialog),
            "symbol (string, map)"
          ),
          "init"          => fun_ref(
            method(:InitServerConfigurationDialog),
            "void (string)"
          ),
          "store"         => fun_ref(
            method(:StoreServerConfigurationDialog),
            "void (string, map)"
          )
        },
        "ls"            => {
          "widget"        => :custom,
          "help"          => Ops.get_string(@HELPS, "login_settings", ""),
          "custom_widget" => LoginSettingsDialogContent(),
          "init"          => fun_ref(
            method(:InitLoginSettingsDialog),
            "void (string)"
          ),
          "store"         => fun_ref(
            method(:StoreLoginSettingsDialog),
            "void (string, map)"
          )
        },
        "pacs"          => {
          "widget"        => :custom,
          "help"          => Ops.get_string(@HELPS, "proto_settings", ""),
          "custom_widget" => ProtoAndCipherDialogContent(),
          "handle"        => fun_ref(
            method(:HandleProtocolConfigurationDialog),
            "symbol (string, map)"
          ),
          "init"          => fun_ref(
            method(:InitProtocolConfigurationDialog),
            "void (string)"
          ),
          "store"         => fun_ref(
            method(:StoreProtocolConfigurationDialog),
            "void (string, map)"
          )
        },
        "fw"            => CWMFirewallInterfaces.CreateOpenFirewallWidget(
          { "services" => ["service:sshd"], "display_details" => true }
        ),
        "start_stop"    => CWMServiceStart.CreateStartStopWidget(
          {
            "service_id"                => "sshd",
            # label - service status, informative text
            "service_running_label"     => _(
              "SSH server is running"
            ),
            # label - service status, informative text
            "service_not_running_label" => _(
              "SSH server is not running"
            ),
            # push button (SSH service handling)
            "start_now_button"          => _(
              "&Start SSH Server Now"
            ),
            # push button (SSH service handling)
            "stop_now_button"           => _(
              "S&top SSH Server Now"
            ),
            "save_now_action"           => fun_ref(
              method(:SaveAndRestart),
              "void ()"
            ),
            # push button (SSH service handling)
            "save_now_button"           => _(
              "Save Settings and Reload SSH Server &Now"
            ),
            "help"                      => Builtins.sformat(
              CWMServiceStart.StartStopHelpTemplate(true),
              # part of help text, used to describe pusbuttons (matching SSH service handling but without "&")
              _("Start SSH Server Now"),
              # part of help text, used to describe pusbuttons (matching SSH service handling but without "&")
              _("Stop SSH Server Now"),
              # part of help text, used to describe pusbuttons (matching SSH service handling but without "&")
              _("Save Settings and Reload SSH Server Now")
            )
          }
        ),
        "auto_start_up" => CWMServiceStart.CreateAutoStartWidget(
          {
            "get_service_auto_start" => fun_ref(
              Sshd.method(:GetStartService),
              "boolean ()"
            ),
            "set_service_auto_start" => fun_ref(
              Sshd.method(:SetStartService),
              "void (boolean)"
            ),
            # radio button (starting SSH service - option 1)
            "start_auto_button"      => _(
              "Now and When &Booting"
            ),
            # radio button (starting SSH service - option 2)
            "start_manual_button"    => _(
              "&Manually"
            ),
            "help"                   => Builtins.sformat(
              CWMServiceStart.AutoStartHelpTemplate,
              # part of help text, used to describe radiobuttons (matching starting SSH service but without "&")
              _("Now and When Booting"),
              # part of help text, used to describe radiobuttons (matching starting SSH service but without "&")
              _("Manually")
            )
          }
        )
      }

      tabs = {
        "service_configuration" => {
          "header"       => _("&Start-Up"),
          "widget_names" => ["start_stop", "auto_start_up"],
          "contents"     => ServiceConfigurationDialogContent()
        },
        "server_configuration"  => {
          "header"       => _("&General"),
          "widget_names" => ["sc", "fw"],
          "contents"     => ServerConfigurationDialogContent()
        },
        "login_settings"        => {
          "header"       => _("&Login Settings"),
          "widget_names" => ["ls"],
          "contents"     => LoginSettingsDialogContent()
        },
        "proto_and_cipher"      => {
          "header"       => _("&Protocol and Ciphers"),
          "widget_names" => ["pacs"],
          "contents"     => ProtoAndCipherDialogContent()
        }
      }

      wd = {
        "tab" => CWMTab.CreateWidget(
          {
            "tab_order"    => [
              "service_configuration",
              "server_configuration",
              "login_settings",
              "proto_and_cipher"
            ],
            "tabs"         => tabs,
            "widget_descr" => widgets,
            "initial_tab"  => "server_configuration"
          }
        )
      }

      contents = VBox("tab")

      w = CWM.CreateWidgets(
        ["tab"],
        Convert.convert(
          wd,
          :from => "map <string, any>",
          :to   => "map <string, map <string, any>>"
        )
      )

      caption = _("SSHD Server Configuration")
      contents = CWM.PrepareDialog(contents, w)

      Wizard.SetContentsButtons(
        caption,
        contents,
        "",
        Label.BackButton,
        Label.OKButton
      )
      Wizard.HideBackButton
      Wizard.SetAbortButton(:abort, Label.CancelButton)
      Wizard.SetDesktopTitleAndIcon("sshd")

      CWM.Run(w, { :abort => fun_ref(method(:ReallyExit), "boolean ()") })
    end

    # AutoYaST configuration of sshd
    # @return sequence result
    def SshdAutoSequence
      aliases = { "main" => lambda { MainSequence() } }

      sequence = {
        "ws_start" => "main",
        "main"     => { :abort => :abort, :next => :next }
      }

      Wizard.CreateDialog

      ret = Sequencer.Run(aliases, sequence)

      UI.CloseDialog
      deep_copy(ret)
    end

    # Whole configuration of sshd
    # @return sequence result
    def SshdSequence
      aliases = {
        "read"  => [lambda { ReadDialog() }, true],
        "main"  => lambda { MainSequence() },
        "write" => [lambda { WriteDialog() }, true]
      }

      sequence = {
        "ws_start" => "read",
        "read"     => { :abort => :abort, :next => "main" },
        "main"     => { :abort => :abort, :next => "write" },
        "write"    => { :abort => :abort, :next => :next }
      }

      Wizard.CreateDialog
      Wizard.SetDesktopTitleAndIcon("sshd")

      ret = Sequencer.Run(aliases, sequence)

      UI.CloseDialog
      deep_copy(ret)
    end
  end
end
