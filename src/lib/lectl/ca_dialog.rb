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

#  To contact Novell about this file by physical or electronic mail,
#  you may find current contact information at www.suse.com

require "yast"
require "lectl/query_presenter.rb"
require "lectl/newcert_dialog.rb"

Yast.import "UI"
Yast.import "Label"
Yast.import "Popup"

module Lectl
  # Dialog to display journal entries with several filtering options
  class CaDialog

    include Yast::UIShortcuts
    include Yast::I18n
    include Yast::Logger

    def initialize
      textdomain "lectl"

      @query = QueryPresenter.new
     read_entries
    end

    # Displays the dialog
    def run
      return unless create_dialog

      begin
        return event_loop
      ensure
        close_dialog
      end
    end

  private

    # Draws the dialog
    def create_dialog
      Yast::UI.OpenDialog(
        Opt(:decorated, :defaultsize),
        VBox(
          # Header
          Heading(_("Let's Encrypt Certificates")),

          # Log entries
          VSpacing(0.3),
          HBox(
            table,
          
          # Footer buttons
            VBox(
              VWeight(1, PushButton(Id(:new), _("New Cert..."))),
              VWeight(1, PushButton(Id(:revoke), _("Revoke"))),
              VWeight(1, PushButton(Id(:remove), _("Remove"))),
              VStretch()
            )
          )
        )
      )
    end

    def close_dialog
      Yast::UI.CloseDialog
    end

    # Simple event loop
    def event_loop
      loop do
        case input = Yast::UI.UserInput
        when :cancel
          # Break the loop
          break
        when :new
          # The user clicked the filter button
          NewCertDialog.new().run
            
        when :revoke
          # The content of the search box changed
        when :remove
          # The user clicked the refresh button
        else
          log.warn "Unexpected input #{input}"
        end
      end
    end

    # Table widget to display log entries
    def table
      headers = @query.columns.map {|c| c[:label] }

      Table(
        Id(:entries_table),
        Opt(:keepSorting),
        Header(*headers),
        table_items
      )
    end

    def table_items
      # Reduce it to an array with only the visible fields
      entries_fields = @entries.map do |entry|
        @query.columns.map {|c| entry.send(c[:method]) }
      end
    
      # Return the result as an array of Items
      entries_fields.map {|fields| Item(*fields) }
    end
    
    def read_entries
      log.info "Calling lectl'"
      @entries = @query.entries
      log.info "Call to lectl returned #{@entries.size} entries."
    rescue => e
      log.warn e.message
      @entries = []
      Yast::Popup.Message(e.message)
    end
  end
end
