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
module Yast
  class AgSshdClient < Client
    def main
      @READ = {
        "sshd" => {
          "AcceptEnv"              => [
            "LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES ",
            "LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT ",
            "LC_IDENTIFICATION LC_ALL"
          ],
          "PasswordAuthentication" => ["no"],
          "Port"                   => ["22"],
          "Protocol"               => ["2,1"],
          "Subsystem"              => ["sftp\t/usr/lib64/ssh/sftp-server"],
          "UsePAM"                 => ["yes"],
          "X11Forwarding"          => ["yes"]
        }
      }
      @WRITE = {}
      @EXECUTE = {}

      Yast.include self, "testsuite.rb"

      # TESTSUITE_INIT([READ, WRITE, EXECUTE], nil);

      DUMP("------ Dir -----")
      TEST(lambda { SCR.Dir(path(".sshd")) }, [@READ, @WRITE, @EXECUTE], nil)
      DUMP("")

      DUMP("------ Read -----")
      Builtins.foreach(SCR.Dir(path(".sshd"))) do |param|
        TEST(lambda { SCR.Read(Builtins.add(path(".sshd"), param)) }, [
          @READ,
          @WRITE,
          @EXECUTE
        ], nil)
      end

      nil
    end
  end
end

Yast::AgSshdClient.new.main
