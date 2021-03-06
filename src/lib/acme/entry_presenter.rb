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
require "delegate"

module ACME
  # Presenter for Entry adding useful methods for the dialogs
  class EntryPresenter < SimpleDelegator

    # NOTE: using %b is not i18n-friendly
    TIME_FORMAT = "%Y-%m-%d"

    def initialize(entry)
      __setobj__(entry)
    end

    # Original entry
    def entry
      __getobj__
    end

    
    # User readable representation of the timestamp
    def formatted_time
      if not valid.nil?
        valid.strftime(TIME_FORMAT)
      end
    end
        
    def formatted_additional_hostnames
      additional_hostnames.join(", ")
    end
  end
end
