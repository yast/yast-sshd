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
# Complex functions for dialogs handling
module Yast
  module SshdComplexInclude
    def initialize_sshd_complex(include_target)
      Yast.import "UI"

      textdomain "sshd"

      Yast.import "Label"
      Yast.import "Popup"
      Yast.import "Wizard"
      Yast.import "Sshd"
      Yast.import "Confirm"
      Yast.import "Report"

      Yast.include include_target, "sshd/helps.rb"
    end

    def ReallyExit
      # yes-no popup
      Popup.YesNo(_("Really exit?\nAll changes will be lost."))
    end

    # Read settings dialog
    # @return `abort if aborted and `next otherwise
    def ReadDialog
      Wizard.RestoreHelp(Ops.get_string(@HELPS, "read", ""))
      Wizard.SetDesktopTitleAndIcon("sshd")
      ret = Sshd.Read
      ret ? :next : :abort
    end

    # Write settings dialog
    # @return `abort if aborted and `next otherwise
    def WriteDialog
      Wizard.RestoreHelp(Ops.get_string(@HELPS, "write", ""))
      Wizard.SetDesktopTitleAndIcon("sshd")
      ret = Sshd.Write
      ret ? :next : :abort
    end

    # Initializes the table of ports

    def InitPortsTable
      ports = Sshd.GetSSHDOption("Port")

      if ports != nil && ports != []
        items = []
        Builtins.foreach(ports) do |port|
          items = Builtins.add(items, Item(Id(port), port))
        end

        # Redraw table of ports and enable modification buttons
        UI.ChangeWidget(Id("Port"), :Items, items)
        UI.ChangeWidget(Id("edit_port"), :Enabled, true)
        UI.ChangeWidget(Id("delete_port"), :Enabled, true)
      else
        # Redraw table of ports and disable modification buttons
        UI.ChangeWidget(Id("Port"), :Items, [])
        UI.ChangeWidget(Id("edit_port"), :Enabled, false)
        UI.ChangeWidget(Id("delete_port"), :Enabled, false)
      end

      nil
    end

    # Initializes Cipher Settings Table

    def InitCipherTable
      tmp_list = Sshd.GetDefaultSSHDOption("Ciphers")
      defaults = Builtins.sort(
        Builtins.splitstring(Ops.get(tmp_list, 0, ""), ", ")
      )

      tmp_list = Sshd.GetSSHDOption("Ciphers")
      current_ciphers = Builtins.sort(
        Builtins.splitstring(Ops.get(tmp_list, 0, ""), ", ")
      )

      # nil must have been set before
      # it says the item should be removed from config and use the 'default' settings
      current_ciphers = deep_copy(defaults) if tmp_list == nil

      # ciphers to enable
      combobox_items = []
      # all enabled ciphers
      table_items = []

      # all default (known) ciphers
      Builtins.foreach(defaults) do |cipher|
        # cipher is enabled
        if Builtins.contains(current_ciphers, cipher)
          table_items = Builtins.add(table_items, Item(Id(cipher), cipher)) 
          # cipher is disabled
        else
          combobox_items = Builtins.add(
            combobox_items,
            Item(Id(cipher), cipher)
          )
        end
      end

      UI.ChangeWidget(Id("supported_ciphers"), :Items, combobox_items)
      UI.ChangeWidget(Id("Ciphers"), :Items, table_items)

      # some cipher(s) are allowed -> allow removing them
      UI.ChangeWidget(
        Id("remove_cipher"),
        :Enabled,
        table_items != nil && Ops.greater_than(Builtins.size(table_items), 0)
      )
      UI.ChangeWidget(
        Id("Ciphers"),
        :Enabled,
        table_items != nil && Ops.greater_than(Builtins.size(table_items), 0)
      )

      # some cipher(s) are not allowed -> allow adding them
      UI.ChangeWidget(
        Id("add_cipher"),
        :Enabled,
        table_items != nil && Ops.greater_than(Builtins.size(combobox_items), 0)
      )
      UI.ChangeWidget(
        Id("supported_ciphers"),
        :Enabled,
        table_items != nil && Ops.greater_than(Builtins.size(combobox_items), 0)
      )

      nil
    end

    # Initializes Protocol Settings Dialog

    def InitProtocolVersion
      protocols = Sshd.GetSSHDOption("Protocol")

      if protocols != nil && protocols != []
        case Ops.get(protocols, 0, "")
          when "1,2", "2,1"
            UI.ChangeWidget(Id("SSHv21"), :Value, true)
          when "2"
            UI.ChangeWidget(Id("SSHv2"), :Value, true)
          when "1"
            UI.ChangeWidget(Id("SSHv1"), :Value, true)
        end
      end

      nil
    end

    def InitServerConfigurationDialog(id)
      InitPortsTable()

      Builtins.foreach(["AllowTcpForwarding", "X11Forwarding", "Compression"]) do |key|
        UI.ChangeWidget(Id(key), :Value, Sshd.GetSSHDOption(key) == ["yes"])
      end

      nil
    end

    # Initializes the Login Settings Dialog

    def InitLoginSettingsDialog(id)
      UI.ChangeWidget(Id("MaxAuthTries"), :ValidChars, "0123456789")
      _MaxAuthTries = Sshd.GetSSHDOption("MaxAuthTries")
      UI.ChangeWidget(
        Id("MaxAuthTries"),
        :Value,
        Ops.get(_MaxAuthTries, 0, "0")
      )

      Builtins.foreach(
        [
          "PrintMotd",
          "PermitRootLogin",
          # "PasswordAuthentication", BNC #469207
          "RSAAuthentication",
          "PubkeyAuthentication"
        ]
      ) do |key|
        UI.ChangeWidget(Id(key), :Value, Sshd.GetSSHDOption(key) == ["yes"])
      end

      nil
    end

    # Removes the port from list of current ports
    #
    # @param string port_number
    def DeletePort(port)
      Sshd.SetSSHDOption("Port", Builtins.filter(Sshd.GetSSHDOption("Port")) do |single_port|
        single_port != port
      end)

      nil
    end

    # Function handles the adding or editing port number.
    # When the current_port is not 'nil', the dialog will
    # allow to edit it.
    #
    # @param [String] current_port a port number to be edited or 'nil' when adding a new one
    def AddEditPortDialog(current_port)
      UI.OpenDialog(
        Opt(:decorated),
        VBox(
          MinWidth(
            30,
            HBox(
              HSpacing(1),
              Frame(
                current_port == nil ?
                  # A popup dialog caption
                  _("Add New Port") :
                  # A popup dialog caption
                  _("Edit Current Port"),
                # A text entry
                TextEntry(
                  Id("port_number"),
                  _("&Port"),
                  current_port == nil ? "" : current_port
                )
              ),
              HSpacing(1)
            )
          ),
          VSpacing(1),
          ButtonBox(
            PushButton(Id(:ok), Opt(:default), Label.OKButton),
            PushButton(Id(:cancel), Label.CancelButton)
          )
        )
      )

      UI.ChangeWidget(Id("port_number"), :ValidChars, "0123456789")
      UI.SetFocus(Id("port_number"))

      ret = nil
      while true
        ret = UI.UserInput
        if ret == :ok
          new_port = Convert.to_string(
            UI.QueryWidget(Id("port_number"), :Value)
          )

          if new_port == ""
            UI.SetFocus(Id("port_number"))
            Report.Error(_("Port number must not be empty."))
            next
          end

          Sshd.SetSSHDOption(
            "Port",
            Builtins.add(Sshd.GetSSHDOption("Port"), new_port)
          )

          DeletePort(current_port) if current_port != nil
        end

        break
      end

      UI.CloseDialog

      nil
    end

    # Function handles Add, Edit and Delete buttons
    #
    # @param any action from "add_port", "edit_port" or "delete_port"
    def HandleServerConfigurationDialog(id, event)
      event = deep_copy(event)
      action = Ops.get(event, "ID")

      selected_port = Convert.to_string(
        UI.QueryWidget(Id("Port"), :CurrentItem)
      )

      # Adding a new port
      if action == "add_port"
        AddEditPortDialog(nil) 
        # Editing current port
      elsif action == "edit_port"
        AddEditPortDialog(selected_port) 
        # Deleting current port
      elsif action == "delete_port"
        DeletePort(selected_port) if Confirm.DeleteSelected
      end

      InitPortsTable()

      nil
    end



    # Stores the current configuration from Server Configuration Dialog
    def StoreServerConfigurationDialog(id, event)
      event = deep_copy(event)
      Sshd.SetModified

      # Stores all boolean values and turns them to the "yes"/"no" notation
      Builtins.foreach(["AllowTcpForwarding", "X11Forwarding", "Compression"]) do |key|
        Sshd.SetSSHDOption(
          key,
          [
            Convert.to_boolean(UI.QueryWidget(Id(key), :Value)) == true ? "yes" : "no"
          ]
        )
      end

      nil
    end

    def StoreProtocolConfigurationDialog(id, event)
      event = deep_copy(event)
      Sshd.SetModified

      current = Convert.to_string(UI.QueryWidget(Id(:rb), :CurrentButton))

      case current
        when "SSHv21"
          Sshd.SetSSHDOption("Protocol", ["2,1"])
        when "SSHv2"
          Sshd.SetSSHDOption("Protocol", ["2"])
        when "SSHv1"
          Sshd.SetSSHDOption("Protocol", ["1"])
      end

      nil
    end

    def HandleProtocolConfigurationDialog(id, event)
      event = deep_copy(event)
      action = Ops.get(event, "ID")

      tmp_list = Sshd.GetSSHDOption("Ciphers")

      # nil must have been set before
      # it says the item should be removed from config and use the 'default' settings
      tmp_list = Sshd.GetDefaultSSHDOption("Ciphers") if tmp_list == nil

      ciphers = Builtins.sort(
        Builtins.splitstring(Ops.get(tmp_list, 0, ""), ", ")
      )
      backup = deep_copy(ciphers)

      if action == "remove_cipher"
        cipher_to_remove = Convert.to_string(
          UI.QueryWidget(Id("Ciphers"), :CurrentItem)
        )
        if Confirm.Delete(cipher_to_remove)
          Builtins.y2milestone("Removing: %1", cipher_to_remove)

          ciphers = Builtins.filter(ciphers) do |one_cipher|
            one_cipher != cipher_to_remove
          end
        end
      elsif action == "add_cipher"
        cipher_to_add = Convert.to_string(
          UI.QueryWidget(Id("supported_ciphers"), :Value)
        )
        Builtins.y2milestone("Adding: %1", cipher_to_add)

        if cipher_to_add != nil
          ciphers = Builtins.toset(Builtins.add(ciphers, cipher_to_add))
        end
      end

      # Nothing has changed
      return nil if ciphers == backup

      if ciphers != nil
        tmp_list2 = Sshd.GetDefaultSSHDOption("Ciphers")
        defaults = Builtins.sort(
          Builtins.splitstring(Ops.get(tmp_list2, 0, ""), ", ")
        )

        # the default ciphers -> remove the entry completely
        if ciphers == defaults
          Sshd.SetSSHDOption("Ciphers", nil)
        else
          Sshd.SetSSHDOption("Ciphers", [Builtins.mergestring(ciphers, ",")])
        end
      else
        Builtins.y2error("Ciphers: %1", ciphers)
      end

      InitCipherTable()

      nil
    end

    # Stores the current configuration from Login Settings  Dialog
    def StoreLoginSettingsDialog(id, event)
      event = deep_copy(event)
      Sshd.SetModified

      # Stores an integer value as a string
      Sshd.SetSSHDOption(
        "MaxAuthTries",
        [Convert.to_string(UI.QueryWidget(Id("MaxAuthTries"), :Value))]
      )

      # Stores all boolean values and turns them to the "yes"/"no" notation
      Builtins.foreach(
        [
          "PrintMotd",
          "PermitRootLogin",
          # "PasswordAuthentication", BNC #469207
          "RSAAuthentication",
          "PubkeyAuthentication"
        ]
      ) do |key|
        Sshd.SetSSHDOption(
          key,
          [
            Convert.to_boolean(UI.QueryWidget(Id(key), :Value)) == true ? "yes" : "no"
          ]
        )
      end

      nil
    end

    def InitProtocolConfigurationDialog(id)
      InitProtocolVersion()
      InitCipherTable()

      nil
    end
  end
end
