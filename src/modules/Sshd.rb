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
# File:	modules/Sshd.ycp
# Package:	Configuration of SSHD
# Summary:	SSHD settings, input and output functions
# Authors:	Lukas Ocilka <locilka@suse.cz>
#
# Representation of the configuration of SSHD.
# Input and output routines.
require "yast"

module Yast
  class SshdClass < Module
    def main
      Yast.import "UI"
      textdomain "sshd"

      Yast.import "Progress"
      Yast.import "Report"
      Yast.import "Message"
      Yast.import "Service"
      Yast.import "Popup"
      Yast.import "Mode"
      Yast.import "SuSEFirewall"

      # Data was modified?
      @modified = false

      @service_name = "sshd"

      @start_service = nil

      # map of SSHD settings
      @SETTINGS = {}

      # FIXME: read the default config from configuration file
      @DEFAULT_CONFIG = {
        "Port"                 => ["22"],
        "AllowTcpForwarding"   => ["yes"],
        "X11Forwarding"        => ["no"],
        "Compression"          => ["yes"],
        "PrintMotd"            => ["yes"],
        "PermitRootLogin"      => ["yes"],
        "IgnoreUserKnownHosts" => ["no"],
        "MaxAuthTries"         => ["6"],
        # BNC #469207
        # "PasswordAuthentication"	: ["yes"],
        "RSAAuthentication"    => [
          "no"
        ],
        "PubkeyAuthentication" => ["yes"],
        "Ciphers"              => [
          "aes128-cbc,3des-cbc,blowfish-cbc,cast128-cbc,arcfour128,arcfour256,arcfour,aes192-cbc,aes256-cbc,aes128-ctr,aes192-ctr,aes256-ctr"
        ]
      }
    end

    # Returns whether the configuration has been modified.
    def GetModified
      @modified
    end

    # Sets that the configuration has been modified.
    def SetModified
      @modified = true

      nil
    end

    def GetStartService
      @start_service
    end

    def SetStartService(new_state)
      if new_state == nil
        Builtins.y2error("Cannot set 'StartService' to %1", new_state)
        return
      elsif @start_service == new_state
        Builtins.y2warning("'StartService' unchanged")
        return
      end

      @start_service = new_state
      SetModified()

      nil
    end

    # Describes whether the daemon is running
    def Running
      Service.Status(@service_name) == 0
    end

    def ReadStartService
      @start_service = Running()

      @start_service != nil
    end

    # Reads current sshd configuration
    def ReadSSHDSettings
      Builtins.foreach(SCR.Dir(path(".etc.ssh.sshd_config"))) do |key|
        val = Convert.convert(
          SCR.Read(Builtins.add(path(".etc.ssh.sshd_config"), key)),
          :from => "any",
          :to   => "list <string>"
        )
        Ops.set(@SETTINGS, key, val) if val != nil
      end

      Builtins.y2milestone("SSHD configuration has been read: %1", @SETTINGS)
      true
    end

    # Writes current sshd configuration
    def WriteSSHDSettings
      Builtins.y2milestone("Writing SSHD configuration: %1", @SETTINGS)

      Builtins.foreach(@SETTINGS) do |option_key, option_val|
        SCR.Write(
          Builtins.add(path(".etc.ssh.sshd_config"), option_key),
          option_val
        )
      end
      # This is very important
      # it flushes the cache, and stores the configuration on the disk
      SCR.Write(path(".etc.ssh.sshd_config"), nil)

      true
    end

    # Returns the SSHD Option as a list of strings.
    #
    # @param [String] option_key of the SSHD configuration
    # @return [Array<String>] with option_values
    def GetSSHDOption(option_key)
      Ops.get(@SETTINGS, option_key, Ops.get(@DEFAULT_CONFIG, option_key, []))
    end

    # Returns default SSHD Option as a list of strings.
    #
    # @param [String] option_key of the SSHD configuration
    # @return [Array<String>] with option_values

    def GetDefaultSSHDOption(option_key)
      Ops.get(@DEFAULT_CONFIG, option_key, [])
    end

    # Sets values for an option.
    #
    # @param [String] option_key with the SSHD configuration key
    # @param list <string> option_values with the SSHD configuration values
    def SetSSHDOption(option_key, option_vals)
      option_vals = deep_copy(option_vals)
      Ops.set(@SETTINGS, option_key, option_vals)

      nil
    end

    # Exports the current configuration.
    #
    # @return [Hash] of a current configuration
    #
    #
    # **Structure:**
    #
    #     $[
    #        "config" : (map <string, list<string> >) SETTINGS,
    #        "status" : (boolean) service_status,
    #      ]
    def Export
      { "config" => @SETTINGS, "status" => Running() }
    end

    # Imports a configuration
    def Import(import_map)
      import_map = deep_copy(import_map)
      @SETTINGS = Ops.get_map(import_map, "config", {})
      SetStartService(Ops.get_boolean(import_map, "status", false) == true)
      SetModified()
      Builtins.y2milestone("Configuration has been imported")
      true
    end

    #   Returns a confirmation popup dialog whether user wants to really abort.
    def Abort
      Popup.ReallyAbort(GetModified())
    end

    # Checks whether an Abort button has been pressed.
    # If so, calls function to confirm the abort call.
    #
    # @return [Boolean] true if abort confirmed
    def PollAbort
      # Do not check UI when running in CommandLine mode
      return false if Mode.commandline

      return Abort() if UI.PollInput == :abort

      false
    end

    # Read all SSHD settings
    # @return true on success
    def Read
      # SSHD read dialog caption
      caption = _("Initializing the SSHD Configuration")

      steps = 4

      Progress.New(
        caption,
        " ",
        steps,
        [
          # Progress stage 1
          _("Read the current SSHD configuration"),
          # Progress stage 2
          _("Read the current SSHD state"),
          # Progress stage 3
          _("Read firewall settings"),
          # Progress stage 4
          _("Read service status")
        ],
        [
          # Progress step 1
          _("Reading the current SSHD configuration..."),
          # Progress step 2
          _("Reading the current SSHD state"),
          # Progress step 3
          _("Reading firewall settings..."),
          # Progress step 4
          _("Reading service status..."),
          Message.Finished
        ],
        ""
      )

      return false if PollAbort()
      Progress.NextStage
      Report.Error(Message.CannotReadCurrentSettings) if !ReadSSHDSettings()

      return false if PollAbort()
      Progress.NextStage
      Report.Error(Message.CannotReadCurrentSettings) if !ReadStartService()

      return false if PollAbort()
      Progress.NextStep
      progress_state = Progress.set(false)
      # Error message
      Report.Error(_("Cannot read firewall settings.")) if !SuSEFirewall.Read
      Progress.set(progress_state)

      return false if PollAbort()
      Progress.NextStage

      return false if PollAbort()
      Progress.NextStage
      @start_service = Service.Enabled(@service_name)

      @modified = false
      true
    end

    def AdjustSSHDService
      enable_and_start = GetStartService()
      enabled = Service.Enabled(@service_name)
      running = Service.Status(@service_name) == 0

      if enable_and_start == nil
        Builtins.y2error(
          "Configuration error: Cannot start/stop service %1",
          @service_name
        )
        return false
      end

      # Service enable/disable
      if enable_and_start == enabled
        Builtins.y2milestone(
          "Service '%1' is already in the desired state",
          @service_name
        )
      else
        if enable_and_start && !Service.Enable(@service_name)
          Builtins.y2error("Cannot enable service %1", @service_name)
          return false
        elsif !enable_and_start && !Service.Disable(@service_name)
          Builtins.y2error("Cannot disable service %1", @service_name)
          return false
        end
      end

      # Start / restart service
      if enable_and_start
        if Running()
          if !Service.Restart(@service_name)
            Builtins.y2error("Cannot restart service %1", @service_name)
            return false
          end
        else
          if !Service.Start(@service_name)
            Builtins.y2error("Cannot start service %1", @service_name)
            return false
          end
        end 
        # Stop a running service
      elsif Running()
        return false if !Service.Stop(@service_name)
      end

      true
    end

    # Write all SSHD settings
    # @return true on success
    def Write
      # SSHD read dialog caption
      caption = _("Saving the SSHD Configuration")

      steps = 4

      Progress.New(
        caption,
        " ",
        steps,
        [
          # Progress stage 1
          _("Write the SSHD settings"),
          # Progress stage 2
          _("Write firewall settings"),
          # Progress stage 3
          _("Adjust SSHD service")
        ],
        [
          # Progress step 1
          _("Writing the SSHD settings..."),
          # Progress step 2
          _("Writing firewall settings..."),
          # Progress step 3
          _("Adjusting SSHD service..."),
          Message.Finished
        ],
        ""
      )

      return false if PollAbort()
      Progress.NextStage
      # Error message
      Report.Error(_("Cannot write the SSHD settings.")) if !WriteSSHDSettings()

      return false if PollAbort()
      Progress.NextStage
      progress_state = Progress.set(false)
      # Error message
      Report.Error(_("Cannot write firewall settings.")) if !SuSEFirewall.Write
      Progress.set(progress_state)

      return false if PollAbort()
      Progress.NextStage
      AdjustSSHDService()

      Progress.NextStage

      true
    end

    # AutoYaST-related functions

    def Summary
      ret = ""

      # TRANSLATORS: summary item
      if !GetModified()
        # TRANSLATORS: summary item
        return _("Not configured yet.")
      end

      ports = GetSSHDOption("Port")
      if Builtins.size(ports) == 1
        # TRANSLATORS: summary item
        ret = Ops.add(
          ret,
          Builtins.sformat(
            _("SSHD Server will use port: %1"),
            Ops.get(ports, 0, "")
          )
        )
      elsif Ops.greater_than(Builtins.size(ports), 0)
        # TRANSLATORS: summary item
        ret = Ops.add(
          ret,
          Builtins.sformat(
            _("SSHD Server will use ports: %1"),
            Builtins.mergestring(ports, ", ")
          )
        )
      end

      ret
    end

    publish :function => :GetModified, :type => "boolean ()"
    publish :function => :SetModified, :type => "void ()"
    publish :function => :GetStartService, :type => "boolean ()"
    publish :function => :SetStartService, :type => "void (boolean)"
    publish :function => :GetSSHDOption, :type => "list <string> (string)"
    publish :function => :GetDefaultSSHDOption, :type => "list <string> (string)"
    publish :function => :SetSSHDOption, :type => "void (string, list <string>)"
    publish :function => :Export, :type => "map ()"
    publish :function => :Import, :type => "boolean (map)"
    publish :function => :Abort, :type => "boolean ()"
    publish :function => :PollAbort, :type => "boolean ()"
    publish :function => :Read, :type => "boolean ()"
    publish :function => :Write, :type => "boolean ()"
    publish :function => :Summary, :type => "string ()"
  end

  Sshd = SshdClass.new
  Sshd.main
end
