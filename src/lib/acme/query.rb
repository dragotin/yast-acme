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

require "acme/entry"

module ACME
  # Wrapper for acme options.
  class Query

    # Creates a new query based on some filters
    #
    # @param filters [Hash] valid keys are :boot, :priority, :unit and :match,
    #   the values must follow the format accepted by the corresponding
    #   journalctl argument.
    def initialize()
    end

    # Calls journalctl and returns an Array of Entry objects
    def entries
      Entry.all()
    end

    def to_s
      "Moep."
    end
  end
end
