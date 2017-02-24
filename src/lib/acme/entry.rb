# Copyright (c) 2017 SUSE Linux GmbH.
#  All Rights Reserved.

#  This program is free software; you can redistribute it and/or
#  modify it under the terms of version 2 or 3 of the GNU General
#  Public License as published by the Free Software Foundation.

#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.   See the
#  GNU General Public License for more details.

#  You should have received a copy of the GNU General Public License
#  along with this program; if not, contact SUSE LLC.

#  To contact SUSE about this file by physical or electronic mail,
#  you may find current contact information at www.suse.com

require "json"
require "yast"
require "time"

module ACME
  class Entry

    ACMECMD = "LANG=C sudo -u dehydrated /usr/bin/dehydrated -j"

    attr_reader :hostnames, :valid
    def initialize(hostnames, valid)
        @hostnames = hostnames
        if not (valid.nil? or valid.empty?)
          @valid = DateTime.parse(valid)
        end
    end
   
    def hostname
      @hostnames[0]
    end

    def additional_hostnames
      @hostnames[1..-1]
    end

    # Calls dehydrated and returns an array of Entry objects
    def self.all()
      cmd = "#{ACMECMD}".strip
      path = Yast::Path.new(".target.bash_output")
      cmd_result = Yast::SCR.Execute(path, cmd)

      if cmd_result["exit"].zero?
        content = cmd_result["stdout"]
        raw = JSON.parse(content)
        raw.map { |item| new( item["requestednames"].split(" "), item["valid"] ) }
      else
        if cmd_result["stderr"] =~ /^Failed to .* timestamp:/
          # Most likely, journalctl bug when an empty list is found
          ""
        else
          raise "Calling journalctl failed: #{cmd_result["stderr"]}"
        end
      end

    end
  end
end
