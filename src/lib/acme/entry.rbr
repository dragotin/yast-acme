# Copyright (c) 2014 SUSE LLC.
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
require "byebug"

module Lectl
  # An entry in the systemd journal
  class Entry

    attr_reader :hostname, :add_hostname, :valid_through
    
    def initialize(cert)
        @hostname = cert["domain"]
        @add_hostname = cert["morenames"]
        @valid_through = DateTime.parse(cert["valid"])
    end
    
    # Calls journalctl and returns an array of Entry objects
    #
    # @param journalctl_args [String] Additional arguments to journalctl
    def self.all()
      content = File.read("/tmp/json_hn.txt")
      raw = JSON.parse(content)
      raw.map  { |item| new( item ) }
    end
  end
end
